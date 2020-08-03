import 'package:flutter/material.dart';

/// `ManupDelegate` class has required methods.
/// Need  `appContext` and `shouldShowAlert` to show dialog.
/// Other methods are optional.
/// Default implemetation is in `ManupDelegateMixin` file.
abstract class ManupDelegate {
  BuildContext appContext();
  bool shouldShowAlert();
  // informative
  void manUpConfigUpdateStarting();
  void manUpUpdateRequired();
  void manUpUpdateAvailable();
  void manUpMaintenanceMode();
}
