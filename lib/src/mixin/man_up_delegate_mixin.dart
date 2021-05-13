part of manup;

/// Default implementation of [ManUpDelegate]
mixin ManUpDelegateMixin on ManUpDelegate {
  void manUpStatusChanged(ManUpStatus status) {}
  void manUpConfigUpdateStarting() {}
  void manUpUpdateRequired() {}
  void manUpUpdateAvailable() {}
  void manUpMaintenanceMode() {}
}
