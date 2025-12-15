part of manup;

/// Show app dialog based on manUp status
mixin DialogMixin<T extends StatefulWidget> on State<T> {
  Future<bool> _launchUrl(String uri) {
    return canLaunchUrl(Uri.parse(uri)).then((canLaunch) =>
        canLaunch ? launchUrl(Uri.parse(uri)) : Future.value(canLaunch));
  }

  /// Show an appropriate dialog for the given [ManUpStatus]. Can be overridden to show custom dialogs.
  Future<bool> showManUpDialog(
    ManUpStatus status,
    String? message,
    String? updateUrl,
  ) async {
    ManUpAppDialog.clearActiveDialogs(context);
    return ManUpAppDialog.showDialogForStatus(
      status: status,
      context: context,
      message: message,
      updateUrl: updateUrl,
      onUpdateConfirmed: (url) {
        _launchUrl(updateUrl!);
      },
      onDisabledConfirmed: () {
        exit(0);
      },
    );
  }
}
