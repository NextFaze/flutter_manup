import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:manup/manup.dart';

import 'mandatory_update_test.mocks.dart' as Mocks;

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                                                                    //
//      RUN `flutter pub run build_runner build` ON Terminal          //
//                                                                    //
//                                                                    //
////////////////////////////////////////////////////////////////////////
var osGetter = () => "ios";
const String _manUpFile = "man_up_config.json";

class MockPackageInfo extends PackageInfoProvider {
  String version;
  MockPackageInfo(this.version);
  @override
  Future<PackageInfo> getInfo() {
    return Future.value(PackageInfo(
        appName: "Test App",
        version: this.version,
        buildNumber: '0',
        packageName: 'com.nextfaze.manup.test'));
  }
}

///
// Generate a MockClient using the Mockito package.
// Create new instances of this class in each test.
@GenerateMocks([ConfigStorage])
void main() {
  group('ManUpService', () {
    final mockFileStorage = Mocks.MockConfigStorage();

    test('parseJson converts to a PlatformData object', () {
      Map<String, dynamic> json = jsonDecode('''
      {
    "latest": "2.4.1",
    "minimum": "2.1.0",
    "url": "http://example.com/myAppUpdate",
    "enabled": true
  }''');

      var data = PlatformData.fromData(json);
      expect(data.enabled, true);
      expect(data.latestVersion, "2.4.1");
      expect(data.minVersion, "2.1.0");
      expect(data.updateUrl, "http://example.com/myAppUpdate");
    });

    group('getMetadata', () {
      http.Client client;

      setUp(() {
        when(mockFileStorage.storeFile(
                filename: _manUpFile, fileData: anyNamed('fileData')))
            .thenAnswer((_) => Future.value(true));
      });

      test('It fetches and returns metadata', () async {
        var response = http.Response('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            },
            "android": {
              "latest": "2.5.1",
              "minimum": "1.9.0",
              "url": "http://example.com/myAppUpdate/android",
              "enabled": false 
            }
          }
          ''', 200);
        client = MockClient((r) => Future.value(response));
        var service = ManUpService('https://example.com/manup.json',
            http: client, os: osGetter(), storage: mockFileStorage);

        var metadata = await service.getMetadata();

        expect(metadata.ios != null, true);
        var iosMetaData = metadata.ios!;
        expect(iosMetaData.enabled, true);
        expect(iosMetaData.latestVersion, "2.4.1");
        expect(iosMetaData.minVersion, "2.1.0");
        expect(iosMetaData.updateUrl, "http://example.com/myAppUpdate");
        //
        expect(metadata.android != null, true);
        var androidMetaData = metadata.android!;
        expect(androidMetaData.enabled, false);
        expect(androidMetaData.latestVersion, "2.5.1");
        expect(androidMetaData.minVersion, "1.9.0");
        expect(androidMetaData.updateUrl,
            "http://example.com/myAppUpdate/android");
        //
        expect(metadata.windows, null);
        expect(metadata.macos, null);
        expect(metadata.linux, null);
        //
        expect(metadata.rawSetting(key: "ios") != null, true);
        expect(metadata.rawSetting(key: "windows"), null);
        expect(metadata.rawSetting(key: "anything"), null);
        //
        expect(
            metadata.setting<Map<String, dynamic>?>(key: "ios", orElse: null) !=
                null,
            true);
        expect(metadata.setting<String?>(key: "ios", orElse: null), null);
      });

      test('Read custom properties from configuration', () async {
        var packageInfo = MockPackageInfo("1.1.0");
        MockClient client;
        var response = http.Response('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            },
            "android": {
              "latest": "2.5.1",
              "minimum": "1.9.0",
              "url": "http://example.com/myAppUpdate/android",
              "enabled": false 
            },
            "api-base": "http://api.example.com/",
            "number-of-coins": 12
          }
          ''', 200);
        client = MockClient((r) => Future.value(response));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo,
            http: client,
            os: osGetter(),
            storage: mockFileStorage);

        await service.validate();
        //
        expect(service.setting<String>(key: "api-base", orElse: 'not-valid'),
            "http://api.example.com/");
        expect(service.setting<int?>(key: "api-base", orElse: null), null);

        expect(service.setting<String?>(key: "number-of-coins", orElse: null),
            null);
        expect(service.setting<int>(key: "number-of-coins", orElse: 0), 12);
        expect(
            service.setting<int?>(key: "number-of-coin", orElse: null), null);
      });
    });

    group("validate", () {
      test('an unsupported version', () async {
        var packageInfo = MockPackageInfo("1.1.0");
        var client;
        var response = http.Response('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            },
            "android": {
              "latest": "2.5.1",
              "minimum": "1.9.0",
              "url": "http://example.com/myAppUpdate/android",
              "enabled": false 
            }
          }
          ''', 200);
        client = MockClient((r) => Future.value(response));
        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo,
            http: client,
            os: osGetter(),
            storage: mockFileStorage);
        var result = await service.validate();
        expect(result, ManUpStatus.unsupported);
      });
      test('the minimum version version', () async {
        var packageInfo = MockPackageInfo("2.1.0");
        var client;
        var response = http.Response('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            },
            "android": {
              "latest": "2.5.1",
              "minimum": "1.9.0",
              "url": "http://example.com/myAppUpdate/android",
              "enabled": false 
            }
          }
          ''', 200);
        client = MockClient((r) => Future.value(response));
        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo,
            http: client,
            os: osGetter(),
            storage: mockFileStorage);

        var result = await service.validate();
        expect(result, ManUpStatus.supported);
      });
      test('some supported version', () async {
        var packageInfo = MockPackageInfo("2.3.3");
        var client;
        var response = http.Response('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            }
          }
          ''', 200);
        client = MockClient((r) => Future.value(response));
        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo,
            http: client,
            os: osGetter(),
            storage: mockFileStorage);

        var result = await service.validate();
        expect(result, ManUpStatus.supported);
      });
      test('the latest version', () async {
        var packageInfo = MockPackageInfo("2.4.1");
        var response = http.Response('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            }
          }
          ''', 200);
        var client = MockClient((r) => Future.value(response));
        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo,
            http: client,
            os: osGetter(),
            storage: mockFileStorage);
        var result = await service.validate();
        expect(result, ManUpStatus.latest);
      });
      test('allow greater than latest version', () async {
        var packageInfo = MockPackageInfo("3.4.1");
        var response = http.Response('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            }
          }
          ''', 200);
        var client = MockClient((r) => Future.value(response));
        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo,
            http: client,
            os: osGetter(),
            storage: mockFileStorage);
        var result = await service.validate();
        expect(result, ManUpStatus.latest);
      });
      test('marked as disabled', () async {
        var packageInfo = MockPackageInfo("2.4.1");
        var response = http.Response('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": false 
            }
          }
          ''', 200);
        var client = MockClient((r) => Future.value(response));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo,
            http: client,
            os: osGetter(),
            storage: mockFileStorage);
        var result = await service.validate();
        expect(result, ManUpStatus.disabled);
      });
      test('throws an exception if the lookup failed', () async {
        var packageInfo = MockPackageInfo("2.4.1");
        var client = MockClient((r) => Future.error(Exception("text error")));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo,
            http: client,
            os: osGetter(),
            storage: mockFileStorage);
        expect(() => service.validate(), throwsException);
      });
    });
  });
  group("ManUpService: store service", () {
    final mockFileStorage = Mocks.MockConfigStorage();

    test('store file should get call', () async {
      //mockFileStorage.stx
      when(mockFileStorage.storeFile(
              filename: _manUpFile, fileData: anyNamed('fileData')))
          .thenAnswer((_) => Future.value(true));

      var packageInfo = MockPackageInfo("2.4.1");
      var response = http.Response('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            }
          }
          ''', 200);
      var client = MockClient((r) => Future.value(response));

      var service = ManUpService('https://example.com/manup.json',
          packageInfoProvider: packageInfo,
          http: client,
          os: osGetter(),
          storage: mockFileStorage);

      var result = await service.validate();
      expect(result, ManUpStatus.latest);
      //
      verify(mockFileStorage.storeFile(
              fileData: anyNamed('fileData'), filename: _manUpFile))
          .called(1);
    });
    test('read file should get call', () async {
      when(mockFileStorage.storeFile(
              filename: _manUpFile, fileData: anyNamed('fileData')))
          .thenAnswer((_) => Future.value(true));
      when(mockFileStorage.readFile(filename: _manUpFile))
          .thenAnswer((_) async {
        return '''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            }
          }
          ''';
      });

      var packageInfo = MockPackageInfo("2.4.1");
      var response = http.Response('', 500);
      var client = MockClient((r) => Future.value(response));
      var service = ManUpService('https://example.com/manup.json',
          packageInfoProvider: packageInfo,
          http: client,
          os: osGetter(),
          storage: mockFileStorage);
      // pre validation test
      expect(service.configData, null);

      ///
      var result = await service.validate();
      // post validation test
      expect(result, ManUpStatus.latest);
      expect(service.configData != null, true);
      //
      verify(mockFileStorage.readFile(filename: _manUpFile)).called(1);
    });
  });
}
