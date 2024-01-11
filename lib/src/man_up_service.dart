part of manup;

abstract class ManUpService {
  final PackageInfoProvider packageInfoProvider;

  final ConfigStorage fileStorage;

  final String? os;
  Metadata _manUpData = Metadata();

  PlatformData? get configData =>
      os != null ? this.getPlatformData(os!, _manUpData) : null;
  ManUpDelegate? delegate;

  ManUpService({
    this.packageInfoProvider = const DefaultPackageInfoProvider(),
    String? os,
    ConfigStorage storage = const ConfigStorage(),
    this.delegate,
  })  : fileStorage = storage,
        this.os = os ?? manupOS();

  /// Fetch the ManUp json file (after which settings can be retrieved using
  /// [setting]) and return the calculated status.
  Future<ManUpStatus> validate([Metadata? metadata]) async {
    delegate?.manUpConfigUpdateStarting();
    try {
      ManUpStatus status = await _validate(metadata);
      this._handleManUpStatus(status);
      return status;
    } catch (e) {
      throw e;
    } finally {
      await _storeManUpFile();
    }
  }

  Future<ManUpStatus> _validate([Metadata? metadata]) async {
    PackageInfo info = await this.packageInfoProvider.getInfo();
    metadata ??= await this.getMetadata();
    _manUpData = metadata;
    PlatformData? platformData = configData;

    if (platformData == null) {
      return ManUpStatus.latest;
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

  /// Retrieve an arbitrary setting key from your ManUp config json. Must have
  /// run `validate()` first for this to work.
  /// For example:
  /// ```dart
  /// final enableMyFeature = service.setting<bool>(key: 'myFeatureEnabled', orElse: false)
  /// ```
  ///
  /// To pluck the 'myFeatureEnabled' key from your json file.
  T setting<T>({
    required String key,
    required T orElse,

    /// Will default to current OS but you may want a setting from another os
    String? os,
  }) =>
      _manUpData.setting<T>(key: key, orElse: orElse, os: os);

  @visibleForTesting
  PlatformData? getPlatformData(String os, Metadata data) {
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
    if (os == 'web') {
      return data.web;
    }

    throw ManUpException('Platform not supported');
  }

  @visibleForTesting
  Future<Metadata> getMetadata();

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

  String getMessage({required ManUpStatus forStatus}) {
    switch (forStatus) {
      case ManUpStatus.supported:
        return _manUpData.supportedMessage;
      case ManUpStatus.unsupported:
        return _manUpData.unsupportedMessage;
      case ManUpStatus.disabled:
        return _manUpData.disabledMessage;
      case ManUpStatus.latest:
        return "";
    }
  }

  /// manUp file storage
  Future<void> _storeManUpFile() async {
    if (kIsWeb) return;
    try {
      if (_manUpData._data == null) {
        return;
      }
      String json = jsonEncode(_manUpData._data);
      await fileStorage.storeFile(fileData: json);
    } catch (e) {
      print("cannot store file. $e");
    }
  }

  @protected
  Future<Metadata> readManUpFile() async {
    var data = await fileStorage.readFile();
    Map<String, dynamic>? json = jsonDecode(data);
    return Metadata(data: json);
  }

  /// call this on dispose.
  void close() {
    // _client.close();
    this.delegate = null;
  }
}
