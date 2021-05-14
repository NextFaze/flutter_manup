part of manup;

// Show app dialog based on manUp status
mixin DialogMixin<T extends StatefulWidget> on State<T> {
  Future<bool> _launchUrl(String launchUrl) {
    return canLaunch(launchUrl).then(
        (canLaunch) => canLaunch ? launch(launchUrl) : Future.value(canLaunch));
  }

  // It will emit `true` if updateLater is selected
  Future<bool> showManUpDialog(
    ManUpStatus status,
    String? message,
    String? updateUrl,
  ) async {
    ManUpAppDialog _dialog = ManUpAppDialog();
    switch (status) {
      case ManUpStatus.latest:
        return Future.value(true);
      case ManUpStatus.supported:
        return _dialog
            .showAlertDialog(
                context: context,
                message: message,
                trueText: "Update",
                falseText: "Later")
            .then((shouldUpdate) =>
                shouldUpdate! ? _launchUrl(updateUrl!) : false)
            .then((isLaunched) => !(isLaunched as bool));
      case ManUpStatus.unsupported:
        return _dialog
            .showAlertDialog(
                context: context, message: message, trueText: "Update")
            .then((_) => _launchUrl(updateUrl!))
            .then((_) => false);

      case ManUpStatus.disabled:
        return _dialog
            .showAlertDialog(context: context, message: message)
            .then((_) => exit(0))
            .then(((_) => false));
    }
  }
}
