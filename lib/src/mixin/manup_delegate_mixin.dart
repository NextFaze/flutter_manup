part of manup;

/// Default implemetation of [ManupDelegate]
mixin ManupDelegateMixin on ManupDelegate {
  void manupStatusChanged(ManUpStatus status) {}
  void manUpConfigUpdateStarting() {}
  void manUpUpdateRequired() {}
  void manUpUpdateAvailable() {}
  void manUpMaintenanceMode() {}
}
