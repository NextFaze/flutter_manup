import 'package:flutter/material.dart';

class ManupAppDialog {
  Future<bool> showConfirmDialog(
      {String message = " ",
      String trueText = "ok",
      String falseText = "cancel",
      bool barrierDismissible = false,
      @required BuildContext context}) {
    return showDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(falseText),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text(trueText,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ],
          );
        });
  }

  Future<bool> showErrorDialog(
      {String message = " ",
      String trueText = "ok",
      bool barrierDismissible = false,
      @required BuildContext context}) {
    return showDialog(
        barrierDismissible: barrierDismissible,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message),
            actions: <Widget>[
              FlatButton(
                child: Text(trueText,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ],
          );
        });
  }
}
