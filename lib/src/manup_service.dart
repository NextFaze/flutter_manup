part of manup;

/// A Function that should return the current operating system
typedef OSGetter = String Function();

class ManUpService {
  final String url;
  final PackageInfoProvider packageInfoProvider;
  Client http;
  // allow overriding of how we get the operating system
  // for testing purposes
  OSGetter os;
  Metadata _manupData;
  // read platform data
  PlatformData get configData => this.getPlatformData(os(), _manupData);
  final ManupDelegate delegate;

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
    var context = this?.delegate?.appContext?.call();
    if (context == null) {
      return;
    }
    ManupAppDialog _dialog = ManupAppDialog();
    switch (status) {
      case ManUpStatus.supported:
        _dialog
            .showConfirmDialog(
                context: context,
                message: _manupData.setting(key: ""),
                trueText: "Update",
                falseText: "Later")
            .then((shouldUpdate) => shouldUpdate ? canLaunch(url) : false)
            .then((canLaunch) => canLaunch ? launch(url) : "");

        break;
      case ManUpStatus.unsupported:
        _dialog
            .showErrorDialog(
                context: context,
                message: _manupData.setting(key: ""),
                trueText: "Update")
            .then((_) => canLaunch(url))
            .then((canLaunch) => canLaunch ? launch(url) : "");
        break;
      case ManUpStatus.disabled:
        _dialog
            .showErrorDialog(
                context: context,
                message: _manupData.setting(key: ""),
                trueText: "Retry")
            .then((shouldRetry) => shouldRetry ? this.validate() : "");
        break;
      default:
        break;
    }
  }
}
