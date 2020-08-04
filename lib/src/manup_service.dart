part of manup;

/// A Function that should return the current operating system
typedef OSGetter = String Function();

class ManUpService with DialogMixin {
  final String url;
  final PackageInfoProvider packageInfoProvider;
  Client http;
  // allow overriding of how we get the operating system
  // for testing purposes
  OSGetter os;
  Metadata _manupData;
  // read platform data
  PlatformData get configData => this.getPlatformData(os(), _manupData);
  ManupDelegate delegate;

  ///
  ManUpService(this.url,
      {this.packageInfoProvider = const DefaultPackageInfoProvider(),
      this.http,
      this.os,
      this.delegate});

  Future<ManUpStatus> validate() async {
    delegate?.manUpConfigUpdateStarting?.call();
    try {
      ManUpStatus status = await _validate();
      this._handleManUpStatus(status);
      return status;
    } catch (e) {
      throw e;
    }
  }

  Future<ManUpStatus> _validate() async {
    PackageInfo info = await this.packageInfoProvider.getInfo();
    _manupData = await this.getMetadata();

    PlatformData platformData = configData;
    if (!platformData.enabled) {
      return ManUpStatus.disabled;
    }

    try {
      Version currentVersion = Version.parse(info.version);
      VersionConstraint latestVersion =
          VersionConstraint.parse('>=${platformData.latestVersion}');
      VersionConstraint minVersion =
          VersionConstraint.parse('>=${platformData.minVersion}');
      if (latestVersion.allows(currentVersion)) {
        return ManUpStatus.latest;
      } else if (minVersion.allows(currentVersion)) {
        return ManUpStatus.supported;
      }
      return ManUpStatus.unsupported;
    } catch (exception) {
      throw ManUpException(exception.toString());
    }
  }

  @visibleForTesting
  T setting<T>({String key}) => _manupData?.setting(key: key) ?? null;

  @visibleForTesting
  PlatformData getPlatformData(String os, Metadata data) {
    if (data == null) {
      throw ManUpException('No data, validate must be called first.');
    }
    if (os == 'ios') {
      return data.ios;
    } else if (os == 'android') {
      return data.android;
    }
    throw ManUpException('Platform not supported');
  }

  @visibleForTesting
  Future<Metadata> getMetadata() async {
    try {
      var data = await this.http.get(this.url);
      this.http.close();
      Map<String, dynamic> json = jsonDecode(data.body);
      return Metadata(data: json);
    } catch (exception) {
      throw ManUpException(exception.toString());
    }
  }

  // manup status validation
  _handleManUpStatus(ManUpStatus status) {
    switch (status) {
      case ManUpStatus.latest:
        this.delegate?.manUpFinishedValidation?.call();
        return;
      case ManUpStatus.supported:
        this.delegate?.manUpUpdateAvailable?.call();
        break;
      case ManUpStatus.unsupported:
        this.delegate?.manUpUpdateRequired?.call();
        break;
      case ManUpStatus.disabled:
        this.delegate?.manUpMaintenanceMode?.call();
        break;
      default:
        return;
    }
    BuildContext context = this?.delegate?.appContext;
    if (context != null && this?.delegate?.shouldShowManupAlert == true) {
      showManupDialog(context, status, this).then((isDone) =>
          isDone ? this.delegate?.manUpFinishedValidation?.call() : "");
    } else {
      this.delegate?.manUpFinishedValidation?.call();
    }
  }
}

// Show app dialog based on manup status
mixin DialogMixin {
  Future<bool> showManupDialog(
      BuildContext context, ManUpStatus status, ManUpService service) async {
    ManupAppDialog _dialog = ManupAppDialog();
    Metadata metadata = service._manupData;
    switch (status) {
      case ManUpStatus.latest:
        return Future.value(true);
      case ManUpStatus.supported:
        var launchUrl = service.configData.updateUrl;
        return _dialog
            .showConfirmDialog(
                context: context,
                message: metadata.supportedMessage,
                trueText: "Update",
                falseText: "Later")
            .then((shouldUpdate) => shouldUpdate ? canLaunch(launchUrl) : false)
            .then((canLaunch) => canLaunch ? launch(launchUrl) : false)
            .then((isLaunched) => !isLaunched);
      case ManUpStatus.unsupported:
        var launchUrl = service.configData.updateUrl;
        return _dialog
            .showErrorDialog(
                context: context,
                message: metadata.unsupportedMessage,
                trueText: "Update")
            .then((_) => canLaunch(launchUrl))
            .then((canLaunch) => canLaunch ? launch(launchUrl) : "")
            .then((_) => false);

      case ManUpStatus.disabled:
        return _dialog
            .showErrorDialog(
                context: context,
                message: metadata.disabledMessage,
                trueText: "Retry")
            .then((shouldRetry) => shouldRetry ? service.validate() : "")
            .then((_) => false);
    }
    throw ManUpException("Unknown manup status");
  }
}
