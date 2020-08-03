import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:package_info/package_info.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:manup/manup.dart';

class MockClient extends Mock implements http.Client {}

var osGetter = () => Platform.operatingSystem;

class MockPackageInfo extends PackageInfoProvider {
  String version;
  MockPackageInfo(this.version);
  @override
  Future<PackageInfo> getInfo() {
    return Future.value(
        PackageInfo(appName: "Test App", version: this.version));
  }
}

void main() {
  group('ManUpService', () {
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
        var service =
            ManUpService('https://example.com/manup.json', http: client);
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
        OSGetter os = () => 'ios';
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
            http: client, packageInfoProvider: packageInfo, os: os);
        await service.validate();
        verify(client.get("https://example.com/manup.json")).called(1);

        expect(service.setting<String>(key: "api-base"), "http://api.example.com/");
        expect(service.setting<int>(key: "api-base"), null);

        expect(service.setting<String>(key: "number-of-coins"), null);
        expect(service.setting<int>(key: "number-of-coins"), 12);
      });
    });

    group("validate", () {
      test('an unsupported version', () async {
        var packageInfo = MockPackageInfo("1.1.0");
        OSGetter os = () => 'ios';
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
            http: client, packageInfoProvider: packageInfo, os: os);

        var result = await service.validate();
        expect(result, ManUpStatus.unsupported);
      });
      test('the minimum version version', () async {
        var packageInfo = MockPackageInfo("2.1.0");
        OSGetter os = () => 'ios';
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
            http: client, packageInfoProvider: packageInfo, os: os);

        var result = await service.validate();
        expect(result, ManUpStatus.supported);
      });
      test('some supported version', () async {
        var packageInfo = MockPackageInfo("2.3.3");
        OSGetter os = () => 'ios';
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
            http: client, packageInfoProvider: packageInfo, os: os);

        var result = await service.validate();
        expect(result, ManUpStatus.supported);
      });
      test('the latest version', () async {
        var packageInfo = MockPackageInfo("2.4.1");
        OSGetter os = () => 'ios';
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
            http: client, packageInfoProvider: packageInfo, os: os);

        var result = await service.validate();
        expect(result, ManUpStatus.latest);
      });
      test('allow greater than latest version', () async {
        var packageInfo = MockPackageInfo("3.4.1");
        OSGetter os = () => 'ios';
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
            http: client, packageInfoProvider: packageInfo, os: os);

        var result = await service.validate();
        expect(result, ManUpStatus.latest);
      });
      test('marked as disabled', () async {
        var packageInfo = MockPackageInfo("2.4.1");
        OSGetter os = () => 'ios';
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
            http: client, packageInfoProvider: packageInfo, os: os);

        var result = await service.validate();
        expect(result, ManUpStatus.disabled);
      });
      test('throws an exception if the lookup failed', () async {
        var packageInfo = MockPackageInfo("2.4.1");
        OSGetter os = () => 'ios';
        var client = MockClient();
        when(client.get("https://example.com/manup.json"))
            .thenThrow(Exception('test error'));

        var service = ManUpService('https://example.com/manup.json',
            http: client, packageInfoProvider: packageInfo, os: os);

        expect(() => service.validate(), throwsException);
      });
    });
  });
}
