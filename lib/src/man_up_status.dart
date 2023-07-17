part of manup;

/// Possible ManUp Status
enum ManUpStatus {
  /// This is the latest version available (current version >= latestVersion)
  latest,

  /// This is a supported version (currentVersion >= minimumVersion) but a newer
  /// version is available.
  supported,

  /// This is an unsupported version (currentVersion < minimumVersion)
  unsupported,

  /// The app has been disabled for some reason (enabled is false in the config file)
  disabled,
}
