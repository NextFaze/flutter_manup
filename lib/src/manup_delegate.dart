part of manup;

/// `ManupDelegate` class has required methods.
/// Need  `buildContext` and `shouldShowManupAlert` to show dialog.
/// Default implemetation is in `ManupDelegateMixin` file.
abstract class ManupDelegate {
  BuildContext get buildContext;
  bool get shouldShowManupAlert;
  // informative
  void manUpConfigUpdateStarting();
  void manUpUpdateRequired();
  void manUpUpdateAvailable();
  void manUpMaintenanceMode();
  void manUpFinishedValidation();
}
