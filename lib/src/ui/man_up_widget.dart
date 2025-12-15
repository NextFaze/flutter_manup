part of manup;

class ManUpWidget extends StatefulWidget {
  final ManUpService service;
  final Widget child;
  final bool Function()? shouldShowAlert;
  final void Function(bool)? onComplete;
  final void Function(dynamic e)? onError;
  final void Function(ManUpStatus status)? onStatusChanged;

  /// After the app has been backgrounded for this duration, check for updates again.
  final Duration checkAfterBackgroundDuration;

  @visibleForTesting
  final DateTime Function() now;

  ManUpWidget({
    Key? key,
    required this.child,
    required this.service,
    this.shouldShowAlert,
    this.onComplete,
    this.onError,
    this.onStatusChanged,
    this.checkAfterBackgroundDuration = Duration.zero,
    @visibleForTesting DateTime Function()? now,
  })  : now = now ?? DateTime.now,
        super(key: key);

  @override
  _ManUpWidgetState createState() => _ManUpWidgetState();
}

class _ManUpWidgetState extends State<ManUpWidget>
    with
        ManUpDelegate,
        ManUpDelegateMixin,
        DialogMixin,
        WidgetsBindingObserver {
  ManUpStatus? alertDialogType;

  DateTime? pausedAt;

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
      widget.onError?.call(error);
    }
  }

  bool get shouldShowManUpAlert => this.widget.shouldShowAlert?.call() ?? true;

  @override
  void manUpStatusChanged(ManUpStatus status) {
    widget.onStatusChanged?.call(status);

    // Already showing a dialog for this status - nothing to do
    if (alertDialogType == status) {
      return;
    }
    // Showing an alert dialog for a different status - close it to show the new status
    if (alertDialogType != null) {
      Navigator.of(context, rootNavigator: true).pop();
      alertDialogType = null;
    }

    if (status == ManUpStatus.latest) {
      this.widget.onComplete?.call(true);
      return;
    }

    final updateUrl = widget.service.configData?.updateUrl;
    if (this.shouldShowManUpAlert) {
      final message = widget.service.getMessage(forStatus: status);
      alertDialogType = status;
      showManUpDialog(status, message, updateUrl).then((isUpdateLater) {
        alertDialogType = null;
        if (isUpdateLater) this.widget.onComplete?.call(true);
        return false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final inBackgroundFor =
          pausedAt?.difference(widget.now()).abs() ?? Duration.zero;
      if (inBackgroundFor >= widget.checkAfterBackgroundDuration) {
        validateManUp();
      }
      pausedAt = null;
    } else if (state == AppLifecycleState.paused) {
      pausedAt = widget.now();
    }
  }

  @override
  void dispose() {
    widget.service.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
