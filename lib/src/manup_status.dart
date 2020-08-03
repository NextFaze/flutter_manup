part of manup;

/// Possible ManUp Status
enum ManUpStatus {
  /// This is the latest version
  latest,

  /// This is a supported version
  supported,

  /// This is an unsupported version
  unsupported,

  /// The app has been disabled for some reason
  disabled,
}
