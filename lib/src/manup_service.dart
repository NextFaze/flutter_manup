part of manup;

class ManUpService {
  final String url;
  final PackageInfoProvider packageInfoProvider;

  final ConfigStorage fileStorage;

  String? os;
  Metadata? _manUpData;
  // read platform data
  PlatformData? get configData => this.getPlatformData(os, _manUpData);
  ManupDelegate? delegate;

  final http.Client _client;

  ///
  ManUpService(
    this.url, {
    this.packageInfoProvider = const DefaultPackageInfoProvider(),
    this.os,
    required http.Client http,
    ConfigStorage storage = const ConfigStorage(),
  })  : _client = http,
        fileStorage = storage;

  Future<ManUpStatus> validate() async {
    delegate?.manUpConfigUpdateStarting();
    try {
      ManUpStatus status = await _validate();
      this._handleManUpStatus(status);
      return status;
    } catch (e) {
      throw e;
    } finally {
      await _storeManUpFile();
    }
  }

  Future<ManUpStatus> _validate() async {
    PackageInfo info = await this.packageInfoProvider.getInfo();
    _manUpData = await this.getMetadata();

    PlatformData? platformData = configData;
    //
    if (platformData == null) {
      return ManUpStatus.unsupported;
    }
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

  T? setting<T>({String? key}) => _manUpData?.setting(key: key) ?? null;

  @visibleForTesting
  PlatformData? getPlatformData(String? os, Metadata? data) {
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
      Map<String, dynamic>? json = jsonDecode(data.body);
      return Metadata(data: json);
    } catch (exception) {
      try {
        var metadata = await _readManUpFile();
        return metadata;
      } catch (e) {
        throw ManUpException(exception.toString());
      }
    }
  }

  // manUp status validation
  void _handleManUpStatus(ManUpStatus status) {
    this.delegate?.manUpStatusChanged(status);
    switch (status) {
      case ManUpStatus.supported:
        this.delegate?.manUpUpdateAvailable();
        break;
      case ManUpStatus.unsupported:
        this.delegate?.manUpUpdateRequired();
        break;
      case ManUpStatus.disabled:
        this.delegate?.manUpMaintenanceMode();
        break;
      default:
        break;
    }
  }

  String? getMessage({ManUpStatus? forStatus}) {
    switch (forStatus) {
      case ManUpStatus.supported:
        return _manUpData?.supportedMessage;
      case ManUpStatus.unsupported:
        return _manUpData?.unsupportedMessage;
      case ManUpStatus.disabled:
        return _manUpData?.disabledMessage;
      default:
        return "";
    }
  }

  /// manUp file storage
  Future<void> _storeManUpFile() async {
    try {
      if (_manUpData == null || _manUpData?._data == null) {
        return;
      }
      String json = jsonEncode(_manUpData!._data);
      await fileStorage.storeFile(fileData: json);
    } catch (e) {
      print("cannot store file. $e");
    }
  }

  Future<Metadata> _readManUpFile() async {
    var data = await fileStorage.readFile();
    Map<String, dynamic>? json = jsonDecode(data);
    return Metadata(data: json);
  }

  //call this on dispose.
  void close() {
    _client.close();
    this.delegate = null;
  }
}
