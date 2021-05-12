part of manup;

/// `ManupDelegate` class has required methods.
/// Default implementation is in `ManupDelegateMixin` file.
abstract class ManupDelegate {
  void manUpStatusChanged(ManUpStatus status);
  void manUpConfigUpdateStarting();
  void manUpUpdateRequired();
  void manUpUpdateAvailable();
  void manUpMaintenanceMode();
}
