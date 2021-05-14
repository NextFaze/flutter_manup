# Manup

[![Build Status](https://travis-ci.org/NextFaze/flutter_manup.svg?branch=master)](https://travis-ci.org/NextFaze/flutter_manup) [![Coverage Status](https://coveralls.io/repos/github/NextFaze/flutter_manup/badge.svg?branch=master)](https://coveralls.io/github/NextFaze/flutter_manup?branch=master)

Sometimes you have an app which talks to services in the cloud. Sometimes,
those services change, and your app no longer works. Wouldn't it be great if
the app could let the user know there's an update? That's what this module
does.

## Usage

### Remote File

You need a hosted json file that contains the version metadata. This _could_ be part of your API. However,
often the reason for maintenance mode is because your API is down. An s3 bucket may be a safer bet,
even though it means a little more work in maintaining the file.

```json
{
  "ios": {
    "latest": "2.4.1",
    "minimum": "2.1.0",
    "url": "http://example.com/myAppUpdate",
    "enabled": true
  },
  "android": {
    "latest": "2.5.1",
    "minimum": "2.1.0",
    "url": "http://example.com/myAppUpdate/android",
    "enabled": true
  }
}
```

### Using the Service Directly

You can use `ManUpService` directly in your code. As part of your app startup logic, use the service to validate the running version.

```dart
ManUpService service = ManUpService('https://example.com/manup.json');
ManUpStatus result = await service.validate();
service.close();
```

`ManUpStatus` will let you know how the version of the app running compares to the metadata:

- `latest`: The app is the latest version
- `supported`: The app is a supported version, but not the latest
- `unsupported`: The app is an unsupported version and should not run
- `disabled`: The app has been marked as disabled and should not run

### Using the Service with Delegate

Implement `ManUpDelegate` or use `ManUpDelegateMixin` mixin which has default implementation.

- `manUpConfigUpdateStarting()` : will be called before starting to validate
- `manUpStatusChanged(ManUpStatus status)` : will be called every time status changes
- `manUpUpdateAvailable()` : will be called when ManUpStatus changes to supported
- `manUpUpdateRequired()` : will be called when ManUpStatus changes to unsupported
- `manUpMaintenanceMode()`: will be called when ManUpStatus changes to disabled

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

### Using the Service with Helper Widget

Wrap your widget with `ManUpWidget` to automatically handle every thing.

```dart
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ManUpWidget(
          service: manUpService,
          shouldShowAlert: () => true,
          onComplete: (bool isComplete) => print(isComplete),
          onError: (dynamic e) => print(e.toString()),
          child: Container()),
    );
  }
```

### Exception Handling

`validate` will throw a `ManUpException` if the lookup failed for any reason. Most likely, this will be caused
by the device being offline and unable to retrieve the metadata. It is up to you how you want to handle this in your app. Some apps, where a supported version is critical, should probably not run unless the version was validated successfully. However, for other apps, there's probably no problem and the app should continue running.
