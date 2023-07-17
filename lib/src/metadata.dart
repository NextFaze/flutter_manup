part of manup;

/// Version information for a particular platform
class PlatformData {
  /// The minimum allowed version
  final String minVersion;

  /// The latest version
  final String latestVersion;

  /// Whether the app is enabled and is allowed to run
  final bool enabled;

  /// The URL for update information (eg app store url)
  final String? updateUrl;

  PlatformData(
      {required this.minVersion,
      required this.latestVersion,
      required this.enabled,
      this.updateUrl});

  @visibleForTesting
  static PlatformData fromData(Map<String, dynamic> data) {
    return PlatformData(
        enabled: data['enabled'],
        latestVersion: data['latest'],
        minVersion: data['minimum'],
        updateUrl: data['url']);
  }
}

/// Version information extracted from the JSON file
class Metadata {
  /// ios specific configuration
  PlatformData? get ios =>
      _data?['ios'] != null ? PlatformData.fromData(_data!['ios']) : null;

  /// android specific configuration
  PlatformData? get android => _data?['android'] != null
      ? PlatformData.fromData(_data!['android'])
      : null;

  /// windows specific configuration
  PlatformData? get windows => _data?['windows'] != null
      ? PlatformData.fromData(_data!['windows'])
      : null;

  /// macos specific configuration
  PlatformData? get macos =>
      _data?['macos'] != null ? PlatformData.fromData(_data!['macos']) : null;

  /// linux specific configuration
  PlatformData? get linux =>
      _data?['linux'] != null ? PlatformData.fromData(_data!['linux']) : null;

  /// web specific configuration
  PlatformData? get web =>
      _data?['web'] != null ? PlatformData.fromData(_data!['web']) : null;

  dynamic rawSetting({String? key, String? os}) =>
      // try for the os specific value first
      _data?[os ?? manupOS()]?[key] ??
      // Fall back to the root of the json file
      _data?[key] ??
      null;

  T setting<T>({required String key, required T orElse, String? os}) {
    var value = rawSetting(key: key, os: os);
    return value is T ? value : orElse;
  }

  // Configuration file data
  final Map<String, dynamic>? _data;
  Metadata({Map<String, dynamic>? data}) : _data = data;
}

extension MetaDataMessages on Metadata {
  // version is supported but new update is available
  String get supportedMessage => setting<String>(
        key: 'supportedMessage',
        orElse: 'There is an update available.',
      );
  // version is not supported, update required
  String get unsupportedMessage => setting<String>(
        key: 'unsupportedMessage',
        orElse:
            'This version is no longer supported. Please update to the latest version',
      );
  // maintenance mode
  String get disabledMessage => setting<String>(
        key: 'disabledMessage',
        orElse:
            'The app is currently in maintenance, please check again shortly',
      );
}
