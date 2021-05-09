part of manup;

class ManUpService {
  final String url;
  final PackageInfoProvider packageInfoProvider;
  @visibleForTesting
  ConfigStorage fileStorage = ConfigStorage();

  String os;
  Metadata _manupData;
  // read platform data
  PlatformData get configData => this.getPlatformData(os, _manupData);
  ManupDelegate delegate;

  http.Client _client;

  ///
  ManUpService(
    this.url, {
    this.packageInfoProvider = const DefaultPackageInfoProvider(),
    this.os,
    http.Client http,
  }) : _client = http;

  Future<ManUpStatus> validate() async {
    delegate?.manUpConfigUpdateStarting?.call();
    try {
      ManUpStatus status = await _validate();
      this._handleManUpStatus(status);
      return status;
    } catch (e) {
      throw e;
    } finally {
      _storeManupFile();
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
    } else if (os == 'windows') {
      return data.windows;
    } else if (os == 'macos') {
      return data.macos;
    } else if (os == 'linux') {
      return data.linux;
    }
    throw ManUpException('Platform not supported');
  }

  @visibleForTesting
  Future<Metadata> getMetadata() async {
    try {
      final uri = Uri.parse(this.url);
      var data = await _client.get(uri);
      Map<String, dynamic> json = jsonDecode(data.body);
      return Metadata(data: json);
    } catch (exception) {
      try {
        var metadata = await _readManupFile();
        return metadata;
      } catch (e) {
        throw ManUpException(exception.toString());
      }
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

  /// manup file storage
  void _storeManupFile() async {
    try {
      if (_manupData == null || _manupData._data == null) {
        return;
      }
      String json = jsonEncode(_manupData._data);
      fileStorage.storeFile(fileData: json);
    } catch (e) {
      print("cannot store file. $e");
    }
  }

  Future<Metadata> _readManupFile() async {
    var data = await fileStorage.readfile();
    Map<String, dynamic> json = jsonDecode(data);
    return Metadata(data: json);
  }

  //call this on dispose.
  void close() {
    _client?.close();
    _client = null;
    fileStorage = null;
    this.delegate = null;
  }
}
