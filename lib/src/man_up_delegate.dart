part of manup;

/// `ManUpDelegate` class has required methods.
/// Default implementation is in `ManUpDelegateMixin` file.
abstract class ManUpDelegate {
  void manUpStatusChanged(ManUpStatus status);
  void manUpConfigUpdateStarting();
  void manUpUpdateRequired();
  void manUpUpdateAvailable();
  void manUpMaintenanceMode();
}
