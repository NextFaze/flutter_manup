part of manup;

class ManUpService {
  final String url;
  final PackageInfoProvider packageInfoProvider;

  String os;
  Metadata _manupData;
  // read platform data
  PlatformData get configData => this.getPlatformData(os, _manupData);
  ManupDelegate delegate;

  http.Client _client;

  ///
  ManUpService(this.url,
      {this.packageInfoProvider = const DefaultPackageInfoProvider(),
      this.os,
      http.Client http})
      : _client = http;

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
      var data = await _client.get(this.url);
      Map<String, dynamic> json = jsonDecode(data.body);
      return Metadata(data: json);
    } catch (exception) {
      throw ManUpException(exception.toString());
    }
  }

  // manup status validation
  _handleManUpStatus(ManUpStatus status) {
    this.delegate?.manUpStatusChanged?.call(status);
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
        break;
    }
  }

  String getMessage({ManUpStatus forStatus}) {
    switch (forStatus) {
      case ManUpStatus.supported:
        return _manupData?.supportedMessage;
      case ManUpStatus.unsupported:
        return _manupData?.unsupportedMessage;
        break;
      case ManUpStatus.disabled:
        return _manupData?.disabledMessage;
        break;
      default:
        return "";
    }
  }

  //call this on dispose.
  void close() {
    _client.close();
    _client = null;
    this.delegate = null;
  }
}
