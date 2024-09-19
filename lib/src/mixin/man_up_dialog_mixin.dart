part of manup;

/// Show app dialog based on manUp status
mixin DialogMixin<T extends StatefulWidget> on State<T> {
  Future<bool> _launchUrl(String uri) {
    return canLaunchUrl(Uri.parse(uri)).then((canLaunch) =>
        canLaunch ? launchUrl(Uri.parse(uri)) : Future.value(canLaunch));
  }

  Future<bool> showManUpDialog(
    ManUpStatus status,
    String? message,
    String? updateUrl,
  ) async {
    switch (status) {
      case ManUpStatus.latest:
        return Future.value(true);
      case ManUpStatus.supported:
        return ManUpAppDialog.showAlertDialog(
                context: context,
                message: message,
                trueText: "Update",
                falseText: "Later")
            .then((shouldUpdate) =>
                shouldUpdate == true ? _launchUrl(updateUrl!) : false)
            .then((isLaunched) => !(isLaunched as bool));
      case ManUpStatus.unsupported:
        return ManUpAppDialog.showAlertDialog(
                barrierDismissible: false,
                context: context,
                message: message,
                trueText: "Update")
            .then((shouldLaunch) {
          if (shouldLaunch == true) {
            _launchUrl(updateUrl!);
          }
        }).then((_) => false);

      case ManUpStatus.disabled:
        return ManUpAppDialog.showAlertDialog(
                barrierDismissible: false, context: context, message: message)
            .then((shouldClose) {
          if (shouldClose == true) {
            exit(0);
          }
        }).then(((_) => false));
    }
  }
}
