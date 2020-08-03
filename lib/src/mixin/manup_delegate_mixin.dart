import 'package:flutter/material.dart';

/// Default implemetation of [ManupDelegate], just override `appContext` to show app alerts.
mixin ManupDelegateMixin {
  BuildContext appContext() => null;
  bool shouldShowAlert() => true;
  // informative
  void manUpConfigUpdateStarting() {}
  void manUpUpdateRequired() {}
  void manUpUpdateAvailable() {}
  void manUpMaintenanceMode() {}
}
