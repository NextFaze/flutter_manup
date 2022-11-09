## Example

```dart
class ManUpExample extends StatefulWidget {
  ManUpExample({Key key}) : super(key: key);

  @override
  _ManUpExampleState createState() => _ManUpExampleState();
}

class _ManUpExampleState extends State<ManUpExample>
    with ManUpDelegate, ManUpDelegateMixin, DialogMixin {
  ManUpService service;
  @override
  void initState() {
    super.initState();
    service = ManUpService("https://example.com/manup.json",
        http: http.Client(), os: Platform.operatingSystem);
    service.delegate = this;
    service.validate();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void manUpStatusChanged(ManUpStatus status) {
    // handle status or show default dialog
    showManUpDialog(status, service.getMessage(forStatus: status),
        service.configData.updateUrl);
  }

  @override
  void dispose() {
    service?.close();
    super.dispose();
  }
}
```
