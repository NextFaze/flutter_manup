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
}

/// Version information extracted from the JSON file
class Metadata {
  /// ios specific configuration
  final PlatformData ios;

  /// android specific configuration
  final PlatformData android;

  Metadata({this.ios, this.android});
}
