part of manup;

/// Default implemetation of [ManupDelegate], just override `appContext` to show app alerts.
mixin ManupDelegateMixin on ManupDelegate {
  // required
  BuildContext get appContext => null;
  http.Client get httpClient => null;
  // optionals
  bool get shouldShowManupAlert => true;
  String get operatingSystem => Platform.operatingSystem;
  // informative
  void manUpConfigUpdateStarting() {}
  void manUpUpdateRequired() {}
  void manUpUpdateAvailable() {}
  void manUpMaintenanceMode() {}
  void manUpFinishedValidation() {}
}
