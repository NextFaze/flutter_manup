part of manup;

/// `ManupDelegate` class has required methods.
/// Default implemetation is in `ManupDelegateMixin` file.
abstract class ManupDelegate {
  bool get shouldShowManupAlert;
  // informative
  void manUpStatusChanged(ManUpStatus status);
  void manUpConfigUpdateStarting();
  void manUpUpdateRequired();
  void manUpUpdateAvailable();
  void manUpMaintenanceMode();
}
