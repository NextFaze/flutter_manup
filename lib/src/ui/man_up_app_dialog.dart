part of manup;

class ManUpAppDialog {
  /// All currently shown ManUp dialogs. Flutter [does not
  /// currently](https://github.com/flutter/flutter/issues/62960) provide a way
  /// to dismiss a specific dialog, and using [Navigator.pop] is dangerous as if
  /// the dialog is dismissed for another reason elsewhere, the pop call would
  /// pop a view.
  static List<DialogRoute> _activeDialogRoutes = [];

  /// Remove any existing ManUpDialog routes - ideally call before calling
  /// [showDialogForStatus] unless there is a particular need to show multiple
  /// dialogs on top of each other.
  static clearActiveDialogs(BuildContext context) {
    _activeDialogRoutes
      ..forEach((route) {
        if (route.isActive) {
          Navigator.of(context, rootNavigator: true).removeRoute(route);
        }
      })
      ..clear();
  }

  /// Show an appropriate dialog for the given [ManUpStatus].
  static Future<bool> showDialogForStatus({
    required BuildContext context,
    required ManUpStatus status,

    /// Called when the user selects the "Update" option in the dialog.
    required void Function(String url) onUpdateConfirmed,

    /// Called when the user confirms the dialog that the app is disabled.
    required void Function() onDisabledConfirmed,
    String? message,
    String? updateUrl,
  }) async {
    switch (status) {
      case ManUpStatus.latest:
        return Future.value(true);
      case ManUpStatus.error:
        // Default configuration is to not prevent the user from using the app
        // in the event of connectivity issues etc.
        return Future.value(true);
      case ManUpStatus.supported:
        final confirmed = await ManUpAppDialog.showAlertDialog(
          barrierDismissible: true,
          context: context,
          message: message,
          trueText: "Update",
          falseText: "Later",
        );

        if (confirmed == true) {
          onUpdateConfirmed(updateUrl!);
        }
        return confirmed ?? false;
      case ManUpStatus.unsupported:
        final confirmed = await ManUpAppDialog.showAlertDialog(
          barrierDismissible: false,
          context: context,
          message: message,
          trueText: "Update",
        );
        if (confirmed == true) {
          onUpdateConfirmed(updateUrl!);
        }
        return confirmed ?? false;
      case ManUpStatus.disabled:
        final confirmed = await ManUpAppDialog.showAlertDialog(
          barrierDismissible: false,
          context: context,
          message: message,
        );
        if (confirmed == true) {
          onDisabledConfirmed();
        }
        return confirmed ?? false;
    }
  }

  /// Show a generic dialog and store it in [_activeDialogRoutes] so that it can
  /// be selectively dismissed.
  static Future<bool?> showAlertDialog({
    required BuildContext context,
    String? message,
    String trueText = "OK",
    String? falseText,
    bool barrierDismissible = false,
  }) {
    bool hasCancelText = falseText != null && falseText.isNotEmpty;
    final route = DialogRoute<bool?>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return PopScope(
            onPopInvokedWithResult: (didPop, result) =>
                Future.value(barrierDismissible),
            child: AlertDialog(
              title: Text(message ?? ""),
              actions: <Widget>[
                hasCancelText
                    ? TextButton(
                        child: Text(falseText),
                        onPressed: () => Navigator.of(context).pop(false),
                      )
                    : Container(),
                TextButton(
                  child: Text(trueText,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );
        });

    _activeDialogRoutes.add(route);
    return Navigator.of(context, rootNavigator: true).push<bool?>(route);
  }
}
