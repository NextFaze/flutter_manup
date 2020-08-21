import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:package_info/package_info.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:manup/manup.dart';

class MockClient extends Mock implements http.Client {}

var osGetter = () => "ios";

class MockPackageInfo extends PackageInfoProvider {
  String version;
  MockPackageInfo(this.version);
  @override
  Future<PackageInfo> getInfo() {
    return Future.value(
        PackageInfo(appName: "Test App", version: this.version));
  }
}

class MockConfigStorage extends Mock implements ConfigStorage {}

void main() {
  group('ManUpService', () {
    final mockfilestorage = MockConfigStorage();

    setUp(() {
      when(mockfilestorage.storeFile(
              fileData: anyNamed("fileData"), filename: "manup_config.json"))
          .thenAnswer((_) => Future.value(true));
      when(mockfilestorage.readfile(filename: "manup_config.json"))
          .thenThrow(Exception("unwated call"));
    });
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
      test('It fetches and returns metadata', () async {
        var client = MockClient();
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
        when(client.get("https://example.com/manup.json"))
            .thenAnswer((Invocation i) => Future.value(response));
        var service = ManUpService('https://example.com/manup.json',
            http: client, os: osGetter());
        service.fileStorage = mockfilestorage;

        var metadata = await service.getMetadata();
        verify(client.get("https://example.com/manup.json")).called(1);

        expect(metadata.ios.enabled, true);
        expect(metadata.ios.latestVersion, "2.4.1");
        expect(metadata.ios.minVersion, "2.1.0");
        expect(metadata.ios.updateUrl, "http://example.com/myAppUpdate");

        expect(metadata.android.enabled, false);
        expect(metadata.android.latestVersion, "2.5.1");
        expect(metadata.android.minVersion, "1.9.0");
        expect(metadata.android.updateUrl,
            "http://example.com/myAppUpdate/android");
      });

      test('Read custom properties from configuration', () async {
        var packageInfo = MockPackageInfo("1.1.0");
        var client = MockClient();
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
        when(client.get("https://example.com/manup.json"))
            .thenAnswer((Invocation i) => Future.value(response));
        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo, http: client, os: osGetter());
        service.fileStorage = mockfilestorage;
        await service.validate();
        verify(client.get("https://example.com/manup.json")).called(1);

        expect(service.setting<String>(key: "api-base"),
            "http://api.example.com/");
        expect(service.setting<int>(key: "api-base"), null);

        expect(service.setting<String>(key: "number-of-coins"), null);
        expect(service.setting<int>(key: "number-of-coins"), 12);
        expect(service.setting<int>(key: "number-of-coin"), null);
      });
    });

    group("validate", () {
      test('an unsupported version', () async {
        var packageInfo = MockPackageInfo("1.1.0");
        var client = MockClient();
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
        when(client.get("https://example.com/manup.json"))
            .thenAnswer((Invocation i) => Future.value(response));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo, http: client, os: osGetter());
        service.fileStorage = mockfilestorage;
        var result = await service.validate();
        expect(result, ManUpStatus.unsupported);
      });
      test('the minimum version version', () async {
        var packageInfo = MockPackageInfo("2.1.0");
        var client = MockClient();
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
        when(client.get("https://example.com/manup.json"))
            .thenAnswer((Invocation i) => Future.value(response));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo, http: client, os: osGetter());
        service.fileStorage = mockfilestorage;
        var result = await service.validate();
        expect(result, ManUpStatus.supported);
      });
      test('some supported version', () async {
        var packageInfo = MockPackageInfo("2.3.3");
        var client = MockClient();
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
        when(client.get("https://example.com/manup.json"))
            .thenAnswer((Invocation i) => Future.value(response));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo, http: client, os: osGetter());
        service.fileStorage = mockfilestorage;
        var result = await service.validate();
        expect(result, ManUpStatus.supported);
      });
      test('the latest version', () async {
        var packageInfo = MockPackageInfo("2.4.1");
        var client = MockClient();
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
        when(client.get("https://example.com/manup.json"))
            .thenAnswer((Invocation i) => Future.value(response));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo, http: client, os: osGetter());
        service.fileStorage = mockfilestorage;
        var result = await service.validate();
        expect(result, ManUpStatus.latest);
      });
      test('allow greater than latest version', () async {
        var packageInfo = MockPackageInfo("3.4.1");
        var client = MockClient();
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
        when(client.get("https://example.com/manup.json"))
            .thenAnswer((Invocation i) => Future.value(response));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo, http: client, os: osGetter());
        service.fileStorage = mockfilestorage;
        var result = await service.validate();
        expect(result, ManUpStatus.latest);
      });
      test('marked as disabled', () async {
        var packageInfo = MockPackageInfo("2.4.1");
        var client = MockClient();
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
        when(client.get("https://example.com/manup.json"))
            .thenAnswer((Invocation i) => Future.value(response));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo, http: client, os: osGetter());
        service.fileStorage = mockfilestorage;
        var result = await service.validate();
        expect(result, ManUpStatus.disabled);
      });
      test('throws an exception if the lookup failed', () async {
        var packageInfo = MockPackageInfo("2.4.1");
        var client = MockClient();
        when(client.get("https://example.com/manup.json"))
            .thenThrow(Exception('test error'));

        var service = ManUpService('https://example.com/manup.json',
            packageInfoProvider: packageInfo, http: client, os: osGetter());
        service.fileStorage = mockfilestorage;
        expect(() => service.validate(), throwsException);
      });
    });
  });
  group("ManUpService: store service", () {
    final mockfilestorage = MockConfigStorage();
    setUp(() {});

    test('store file should get call', () async {
      when(mockfilestorage.storeFile(
              fileData: anyNamed("fileData"), filename: "manup_config.json"))
          .thenAnswer((_) => Future.value(true));
      when(mockfilestorage.readfile(filename: "manup_config.json"))
          .thenThrow(Exception("unwated call"));
      var packageInfo = MockPackageInfo("2.4.1");
      var client = MockClient();
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
      when(client.get("https://example.com/manup.json"))
          .thenAnswer((Invocation i) => Future.value(response));
      var service = ManUpService('https://example.com/manup.json',
          packageInfoProvider: packageInfo, http: client, os: osGetter());
      service.fileStorage = mockfilestorage;
      var result = await service.validate();
      expect(result, ManUpStatus.latest);
      //
      verify(mockfilestorage.storeFile(
              fileData: anyNamed("fileData"), filename: "manup_config.json"))
          .called(1);
    });
    test('read file should get call', () async {
      when(mockfilestorage.storeFile(
              fileData: anyNamed("fileData"), filename: "manup_config.json"))
          .thenAnswer((_) => Future.value(true));
      when(mockfilestorage.readfile(filename: "manup_config.json"))
          .thenAnswer((_) => Future.value('''
          {
            "ios": {
              "latest": "2.4.1",
              "minimum": "2.1.0",
              "url": "http://example.com/myAppUpdate",
              "enabled": true
            }
          }
          '''));

      var packageInfo = MockPackageInfo("2.4.1");
      var client = MockClient();
      var response = http.Response('', 500);
      when(client.get("https://example.com/manup.json"))
          .thenAnswer((Invocation i) => Future.value(response));
      var service = ManUpService('https://example.com/manup.json',
          packageInfoProvider: packageInfo, http: client, os: osGetter());
      service.fileStorage = mockfilestorage;
      var result = await service.validate();
      expect(result, ManUpStatus.latest);
      //
      verify(mockfilestorage.readfile(filename: "manup_config.json")).called(1);
    });
  });
}
