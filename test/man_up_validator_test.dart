import 'package:flutter_test/flutter_test.dart';
import 'package:manup/manup.dart';

void main() {
  test('validate platform returns disabled status', () async {
    final status = await validatePlatformData(
        version: '0.0.1',
        platformData: PlatformData(
            minVersion: '0.0.1',
            latestVersion: '0.0.1',
            enabled: false,
            updateUrl: 'example.com'));

    expect(status, ManUpStatus.disabled);
  });

  test('disabled status takes precedence', () async {
    final status = await validatePlatformData(
        version: '0.0.1',
        platformData: PlatformData(
            minVersion: '0.1.0',
            latestVersion: '0.1.0',
            enabled: false,
            updateUrl: 'example.com'));

    expect(status, ManUpStatus.disabled);
  });

  test('validate platform returns unsupported version', () async {
    final status = await validatePlatformData(
        version: '0.0.1',
        platformData: PlatformData(
            minVersion: '0.1.0',
            latestVersion: '0.0.1',
            enabled: true,
            updateUrl: 'example.com'));

    expect(status, ManUpStatus.unsupported);
  });

  test('unsupported takes precedence over min', () async {
    final status = await validatePlatformData(
        version: '0.0.1',
        platformData: PlatformData(
            minVersion: '0.1.0',
            latestVersion: '0.1.0',
            enabled: true,
            updateUrl: 'example.com'));

    expect(status, ManUpStatus.unsupported);
  });

  test('validate platform returns supported version', () async {
    final status = await validatePlatformData(
        version: '0.0.1',
        platformData: PlatformData(
            minVersion: '0.0.1',
            latestVersion: '0.1.1',
            enabled: true,
            updateUrl: 'example.com'));

    expect(status, ManUpStatus.supported);
  });

  test('validate platform returns latest version if versions are the same',
      () async {
    final status = await validatePlatformData(
        version: '0.0.1',
        platformData: PlatformData(
            minVersion: '0.0.1',
            latestVersion: '0.0.1',
            enabled: true,
            updateUrl: 'example.com'));

    expect(status, ManUpStatus.latest);
  });

  test('validate platform returns latest version', () async {
    final status = await validatePlatformData(
        version: '0.0.2',
        platformData: PlatformData(
            minVersion: '0.0.1',
            latestVersion: '0.0.1',
            enabled: true,
            updateUrl: 'example.com'));

    expect(status, ManUpStatus.latest);
  });
}
