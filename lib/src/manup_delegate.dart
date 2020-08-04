part of manup;

/// `ManupDelegate` class has required methods.
/// Need  `appContext` and `shouldShowAlert` to show dialog.
/// Other methods are optional.
/// Default implemetation is in `ManupDelegateMixin` file.
abstract class ManupDelegate {
  // required
  BuildContext get appContext;
  http.Client get httpClient;
  // optionals
  bool get shouldShowManupAlert;
  String get operatingSystem;
  // informative
  void manUpConfigUpdateStarting();
  void manUpUpdateRequired();
  void manUpUpdateAvailable();
  void manUpMaintenanceMode();
  void manUpFinishedValidation();
}
