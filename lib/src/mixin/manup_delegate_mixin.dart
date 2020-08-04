part of manup;

/// Default implemetation of [ManupDelegate], just override `appContext` to show app alerts.
mixin ManupDelegateMixin on ManupDelegate {
  BuildContext get appContext => null;
  bool get shouldShowManupAlert => true;
  // informative
  void manUpConfigUpdateStarting() {}
  void manUpUpdateRequired() {}
  void manUpUpdateAvailable() {}
  void manUpMaintenanceMode() {}
  void manUpFinishedValidation() {}
}
