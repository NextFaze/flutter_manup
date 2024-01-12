# Manup

[![pub package](https://img.shields.io/pub/v/manup.svg)](https://pub.dartlang.org/packages/manup) [![Build Status](https://travis-ci.org/NextFaze/flutter_manup.svg?branch=master)](https://travis-ci.org/NextFaze/flutter_manup) [![Coverage Status](https://coveralls.io/repos/github/NextFaze/flutter_manup/badge.svg?branch=master)](https://coveralls.io/github/NextFaze/flutter_manup?branch=master)

Sometimes you have an app which talks to services in the cloud. Sometimes,
those services change, and your app no longer works. Wouldn't it be great if
the app could let the user know there's an update? That's what this module
does.

## Usage

You can select the method to store and fetch app config file with the following options

- HTTP (`HttpManUpService`)
  - you need a hosted json file that contains the version metadata. This _could_ be part of your API. However,
    often the reason for maintenance mode is because your API is down. An s3 bucket may be a safer bet,
    even though it means a little more work in maintaining the file.
- Firebase remote config (`FireBaseRemoteConfigManUpService`)
  - you need to setup firebase project and remote config, then [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup?platform=ios).

App config file structure

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

- `"ios" or "android : <string>` - device operating system
- `latest : <string>` - the latest application version - running a lower version prompts to update (based on `url`)
- `minimum : <string>` - the minimum required application version - running a lower version prevents the app from running (prompting to update based on `url`)
- `url : <string>` - url of where to download application update
- `enabled : <bool>` - whether or not the application is enabled - `false` completely prevents app use

If `"ios"` or `"android"` configurations are omitted, it will treat the device as having the latest version of the app installed.

### Using the Service Directly

You can use service directly in your code. As part of your app startup logic, use the service to validate the running version.

- `HttpManUpService`

  ```dart
  HttpManUpService service = HttpManUpService('https://example.com/manup.json', client: http.Client());
  ManUpStatus result = await service.validate();
  service.close();
  ```

- `FireBaseRemoteConfigManUpService`

  ```dart
  FireBaseRemoteConfigManUpService service = FireBaseRemoteConfigManUpService(
      remoteConfig: FirebaseRemoteConfig.instance,
      // Parameter name (key) in remote config
      paramName: 'configName',
    );
  ManUpStatus result = await service.validate();
  service.close();
  ```

`ManUpStatus` will let you know how the version of the app running compares to the metadata:

- `latest`: The app is the latest version
- `supported`: The app is a supported version, but not the latest
- `unsupported`: The app is an unsupported version and should not run
- `disabled`: The app has been marked as disabled and should not run

### Fetching other Settings and Feature Flags

You may want to have other remote configuration in your ManUp file - such as
feature flags. To fetch these settings you can use
`service.setting(key:'myKey')` after successfully running `validate()` to load
the config from the json file. By default, ManUp will look to the the current os
for the key and fallback to the root:

```json
{
  "ios": {
    "latest": "2.4.1",
    // ... other config
    "myFeatureEnabled": true // <- used on iOS
  },
  "myFeatureEnabled": false // <- Fallback used for other platforms
}
```

```dart
// In this case will be `true` on iOS and `false` on Android/Web etc.
final enableMyFeature = service.setting<bool>(key: 'myFeatureEnabled',
// fallback value if getter fails for some reason
  orElse: false);
```

### Using the Service with Delegate

Implement `ManUpDelegate` or use `ManUpDelegateMixin` mixin which has default implementation.

- `manUpConfigUpdateStarting()` : will be called before starting to validate
- `manUpStatusChanged(ManUpStatus status)` : will be called every time status changes
- `manUpUpdateAvailable()` : will be called when ManUpStatus changes to supported
- `manUpUpdateRequired()` : will be called when ManUpStatus changes to unsupported
- `manUpMaintenanceMode()`: will be called when ManUpStatus changes to disabled

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
