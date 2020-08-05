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
    with
        ManupDelegate,
        ManupDelegateMixin,
        DialogMixin,
        WidgetsBindingObserver {
  bool isshowingManupAlert = false;
  //
  @override
  void initState() {
    super.initState();
    widget.service.delegate = this;
    validateManup();
    WidgetsBinding.instance?.addObserver(this);
  }

  validateManup() {
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
  void manUpStatusChanged(ManUpStatus status) {
    if (status == ManUpStatus.latest) {
      this.widget?.onComplete?.call(true);
      return;
    }
    if (this.shouldShowManupAlert) {
      isshowingManupAlert = true;
      showManupDialog(status, widget.service.getMessage(forStatus: status),
              widget.service.configData.updateUrl)
          .then((isUpdateLater) => isUpdateLater
              ? this.widget?.onComplete?.call(true)
              : isUpdateLater)
          .then((_) => isshowingManupAlert = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isshowingManupAlert && state == AppLifecycleState.resumed) {
      validateManup();
    }
  }

//
  @override
  void dispose() {
    widget.service.close();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
