part of mandatory_update;

/// Version information for a particular platform
class PlatformData {
  final String minVersion;
  final String latestVersion;
  final bool enabled;
  final String updateUrl;

  PlatformData({this.minVersion, this.latestVersion, this.enabled, this.updateUrl});
}

/// Version information
class Metadata {
  final PlatformData ios;
  final PlatformData android;

  Metadata({this.ios, this.android});
}
