part of manup;

class ManUpWidget extends StatefulWidget {
  final ManUpService service;
  final Widget child;
  final bool Function() shouldShowAlert;
  final void Function(bool) onComplete;
  final void Function(dynamic) onError;
  //
  ManUpWidget(
      {Key key,
      @required this.child,
      @required this.service,
      @required this.shouldShowAlert,
      @required this.onComplete,
      @required this.onError})
      : super(key: key);

  @override
  _ManUpWidgetState createState() => _ManUpWidgetState();
}

class _ManUpWidgetState extends State<ManUpWidget>
    with ManupDelegate, ManupDelegateMixin {
  @override
  void initState() {
    super.initState();
    widget.service.delegate = this;
    widget.service.validate().catchError((e) => widget?.onError(e));
  }

  @override
  Widget build(BuildContext context) => widget?.child;

  // man up delegate
  @override
  BuildContext get buildContext => context;
  @override
  bool get shouldShowManupAlert =>
      this?.widget?.shouldShowAlert?.call() ?? true;
  @override
  void manUpFinishedValidation() => this.widget?.onComplete?.call(true);
//
  @override
  void dispose() {
    widget.service.close();
    super.dispose();
  }
}
