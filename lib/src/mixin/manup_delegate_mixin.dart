part of manup;

/// Default implementation of [ManupDelegate]
mixin ManupDelegateMixin on ManupDelegate {
  void manUpStatusChanged(ManUpStatus status) {}
  void manUpConfigUpdateStarting() {}
  void manUpUpdateRequired() {}
  void manUpUpdateAvailable() {}
  void manUpMaintenanceMode() {}
}
