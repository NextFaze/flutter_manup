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
  final String updateUrl;

  PlatformData(
      {this.minVersion, this.latestVersion, this.enabled, this.updateUrl});

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
  PlatformData get ios => PlatformData.fromData(_data['ios']);

  /// android specific configuration
  PlatformData get android => PlatformData.fromData(_data['android']);

  // Configuration file data
  final Map<String, dynamic> _data;

  dynamic rawSetting({String key}) =>
      _data.containsKey(key) ? _data[key] : null;

  T setting<T>({String key}) {
    var value = rawSetting(key: key);
    return value is T ? value : null;
  }

  Metadata({Map<String, dynamic> data}) : _data = data;
}

// message extension
extension MetaDataMessages on Metadata {
  // version is supported but new update is available
  String get supportedMessage =>
      setting<String>(key: 'supportedMessage') ??
      "There is an update available.";
  // version is not supported, update required
  String get unsupportedMessage =>
      setting<String>(key: 'unsupportedMessage') ??
      "This version is no longer supported. Please update to the latest version";
  //maintenance mode
  String get disabledMessage =>
      setting<String>(key: 'disabledMessage') ??
      "The app is currently in maintenance, please check again shortly";
}
