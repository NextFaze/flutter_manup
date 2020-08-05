part of manup;

/// Default implemetation of [ManupDelegate]
mixin ManupDelegateMixin on ManupDelegate {
  bool get shouldShowManupAlert => true;
  // informative
  void manupStatusChanged(ManUpStatus status) {}
  void manUpConfigUpdateStarting() {}
  void manUpUpdateRequired() {}
  void manUpUpdateAvailable() {}
  void manUpMaintenanceMode() {}
}
