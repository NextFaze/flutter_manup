part of manup;

class ManUpAppDialog {
  static Future<bool?> showAlertDialog(
      {String? message,
      String trueText = "OK",
      String? falseText,
      bool barrierDismissible = false,
      required BuildContext context}) {
    bool hasCancelText = falseText != null && falseText.isNotEmpty;
    return showDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: (BuildContext context) {
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
  }
}
