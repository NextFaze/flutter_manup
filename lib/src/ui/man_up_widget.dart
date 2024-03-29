part of manup;

class ManUpWidget extends StatefulWidget {
  final ManUpService service;
  final Widget child;
  final bool Function() shouldShowAlert;
  final void Function(bool) onComplete;
  final void Function(dynamic) onError;

  ManUpWidget(
      {Key? key,
      required this.child,
      required this.service,
      required this.shouldShowAlert,
      required this.onComplete,
      required this.onError})
      : super(key: key);

  @override
  _ManUpWidgetState createState() => _ManUpWidgetState();
}

class _ManUpWidgetState extends State<ManUpWidget>
    with
        ManUpDelegate,
        ManUpDelegateMixin,
        DialogMixin,
        WidgetsBindingObserver {
  bool isShowingManUpAlert = false;

  @override
  void initState() {
    super.initState();
    widget.service.delegate = this;
    validateManUp();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) => widget.child;

  validateManUp() async {
    try {
      await widget.service.validate();
    } catch (error) {
      widget.onError(error);
    }
  }

  bool get shouldShowManUpAlert => this.widget.shouldShowAlert.call();

  @override
  void manUpStatusChanged(ManUpStatus status) {
    if (status == ManUpStatus.latest) {
      this.widget.onComplete.call(true);
      return;
    }
    final updateUrl = widget.service.configData?.updateUrl;
    if (this.shouldShowManUpAlert) {
      final message = widget.service.getMessage(forStatus: status);
      isShowingManUpAlert = true;
      showManUpDialog(status, message, updateUrl)
          .then((isUpdateLater) =>
              isUpdateLater ? this.widget.onComplete.call(true) : isUpdateLater)
          .then((_) => isShowingManUpAlert = false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!isShowingManUpAlert && state == AppLifecycleState.resumed) {
      validateManUp();
    }
  }

  @override
  void dispose() {
    widget.service.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
