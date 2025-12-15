# manUp

## [9.4.0]

- Allow custom background duration check timeout

## [9.3.2]

- Launch url in external browser

## [9.3.1]

- Fix update url not being passed to dialog callback

## [9.3.0]

- Support `firebase_remote_config` v6 and `firebase_analytics` v12

## [9.2.2]

- Fix an issue that would prevent os from detecting correctly

## [9.2.1]

- Add missing `barrierDismissible` to required default dialogs

## [9.2.0]

- Add a new `error` ManUpStatus that can be handled via the `ManUpService` `ChangeNotifier`

## [9.1.0]

- `ManUpService` now implements `ChangeNotifier` and the most recent status can be retrieved from the `status` getter
- `onComplete`, `onError` and `shouldShowAlert` on `ManUpWidget` are now optional (`shouldShowAlert` defaults to `() => true`)
- `ManUpWidget` now exposes an optional `onStatusChanged`
- "Kill switch" (`disabled`) and required update alert dialogs are no longer barrier dismissible.
- Changes to status will now show updated dialogs
- Update examples

## [9.0.1]

- Relax version requirements for firebase

## [9.0.0]

- Support `package_info_plus` up to version 10 (relax version requirements)

## [8.0.0]

- Update `package_info_plus` from v4 to v6

## [7.0.0]

- **Breaking change** Separate service into `HttpManUpService` and `FireBaseRemoteConfigManUpService`

  - Extract `HttpManUpService` from `ManUpService` and create `FireBaseRemoteConfigManUpService` to support fetching app config with HTTP and Firebase remote config
  - Now, the user who use `ManUpService` in previous release

    ```dart
    ManUpService service = ManUpService('https://example.com/manup.json', client: http.Client());
    ```

    will need to change to

    ```dart
    HttpManUpService service = HttpManUpService('https://example.com/manup.json', client: http.Client());
    ```

## [6.0.0]

- **Breaking change** Update version check logic
  - Previously, if the app version was higher than the latest version, the minVersion check was effectively ignored.
  - Now, all version checks are run individually and `latest` is only returned if everything passes.
- Add initial support for web platform
  - Running on web now looks for the `web` key in the `manup.json` file instead of outright failing

## [5.0.1]

- Use less strict http version

## [5.0.0]

- **Breaking change** Update http to `1.x.y` and package_info_plus to `4.x.x`
  - A result of this (due to `package_info_plus` update) is now minimum Android API 19 and iOS version 11
  - See the respective packages for any further breaking changes

## [4.0.2]

- Move example to example directory
- Update description to follow dart conventions
- Added JSON file property descriptions and data types

## [4.0.1]

- Update all dependencies

## [4.0.0]

- **Breaking change** Added ability to continue without overlay if platform is not defined within json file.

## [3.1.1]

- Bump url launcher dependency (method call was updated for linting errors but the method was only added in 6.1.0 and does not exist in 6.0.x)

## [3.1.0]

- Custom settings can now be platform specific in addition to the root settings.
- Add some extra documentation.

## [3.0.0]

- **Breaking change** Add default value if setting is missing
- **Breaking change** Update all dependencies

## [2.0.2]

Separate manUp validator function to use it alone.

## [2.0.1]

Minor code changes.
Making some variables required.
Continue renaming some more files.

## [2.0.0]

Migrate to null safety.
**Breaking changes** Renaming some files.

## [1.0.4]

Make get setting method visible

## [1.0.3]

Add support for desktop platforms

## [1.0.2]

pub spec upgrade

Stop throwing reading file exception.

## [1.0.1]

Add capability to store and retrieve man up config.

## [1.0.0]

### First major release

Added Delegate support with `ManUpDelegate`

Added Helper Widget with `ManUpWidget`

Check `README` file for full details.

## [0.0.3]

First manup release
