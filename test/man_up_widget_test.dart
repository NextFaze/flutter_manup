import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manup/manup.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  const os = 'ios';

  Future<MockManUpService> buildTestCase(WidgetTester tester,
      {Metadata? metadata,
      String? version,
      Duration checkAfterBackgroundDuration = Duration.zero,
      DateTime Function()? now}) async {
    final manUpService = MockManUpService(
        os: os,
        packageInfoProvider:
            MockPackageInfoProvider(version: version ?? '0.0.0'));

    if (metadata != null) {
      manUpService.metadata = metadata;
    }
    await tester.pumpWidget(MaterialApp(
      home: ManUpWidget(
        child: Container(),
        service: manUpService,
        checkAfterBackgroundDuration: checkAfterBackgroundDuration,
        now: now,
      ),
    ));
    return manUpService;
  }

  testWidgets('shows nothing by default', (tester) async {
    await buildTestCase(tester);

    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('shows nothing for "latest" status', (tester) async {
    await buildTestCase(tester,
        version: '2.4.1',
        metadata: Metadata(data: {
          os: {
            "latest": "2.4.1",
            "minimum": "2.1.0",
            "url": "http://example.com/myAppUpdate",
            "enabled": true
          },
        }));

    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('shows dialog for optional update', (tester) async {
    await buildTestCase(tester,
        version: '2.4.0',
        metadata: Metadata(data: {
          os: {
            "latest": "2.4.1",
            "minimum": "2.1.0",
            "url": "http://example.com/myAppUpdate",
            "enabled": true
          },
        }));

    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('There is an update available.'), findsOneWidget);
  });

  testWidgets('shows dialog for required update', (tester) async {
    await buildTestCase(tester,
        version: '2.0.0',
        metadata: Metadata(data: {
          os: {
            "latest": "2.4.1",
            "minimum": "2.1.0",
            "url": "http://example.com/myAppUpdate",
            "enabled": true
          },
        }));

    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'This version is no longer supported. Please update to the latest version.'),
        findsOneWidget);
  });

  testWidgets('shows dialog for kill-switch mode', (tester) async {
    await buildTestCase(tester,
        version: '2.0.0',
        metadata: Metadata(data: {
          os: {
            "latest": "2.4.1",
            "minimum": "2.1.0",
            "url": "http://example.com/myAppUpdate",
            "enabled": false
          },
        }));

    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'The app is currently in maintenance, please check again shortly.'),
        findsOneWidget);
  });

  testWidgets('re-fetches on lifecycle change', (tester) async {
    final service = await buildTestCase(tester);

    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    service.metadata = Metadata(data: {
      os: {
        "latest": "2.4.1",
        "minimum": "2.1.0",
        "url": "http://example.com/myAppUpdate",
        "enabled": false
      },
    });

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(service.validateCallCount, 2);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'The app is currently in maintenance, please check again shortly.'),
        findsOneWidget);
  });

  testWidgets(
      'skips resume re-check when background duration is below custom threshold',
      (tester) async {
    var now = DateTime(2020, 1, 1, 0, 0, 0);
    final service = await buildTestCase(
      tester,
      checkAfterBackgroundDuration: Duration(minutes: 5),
      now: () => now,
    );

    await tester.pumpAndSettle();
    expect(service.validateCallCount, 1);
    expect(find.byType(AlertDialog), findsNothing);

    service.metadata = Metadata(data: {
      os: {
        "latest": "2.4.1",
        "minimum": "2.1.0",
        "url": "http://example.com/myAppUpdate",
        "enabled": false
      },
    });

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    now = now.add(Duration(minutes: 4));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(service.validateCallCount, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
      're-checks on resume when background duration meets custom threshold',
      (tester) async {
    var now = DateTime(2020, 1, 1, 0, 0, 0);
    final service = await buildTestCase(
      tester,
      checkAfterBackgroundDuration: Duration(minutes: 5),
      now: () => now,
    );

    await tester.pumpAndSettle();
    expect(service.validateCallCount, 1);
    expect(find.byType(AlertDialog), findsNothing);

    service.metadata = Metadata(data: {
      os: {
        "latest": "2.4.1",
        "minimum": "2.1.0",
        "url": "http://example.com/myAppUpdate",
        "enabled": false
      },
    });

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    now = now.add(Duration(minutes: 6));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(service.validateCallCount, 2);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'The app is currently in maintenance, please check again shortly.'),
        findsOneWidget);
  });

  testWidgets('shows an updated dialog when metadata changes', (tester) async {
    final service = await buildTestCase(tester,
        version: '2.0.0',
        metadata: Metadata(data: {
          os: {
            "latest": "2.4.1",
            "minimum": "2.1.0",
            "url": "http://example.com/myAppUpdate",
            "enabled": true
          },
        }));

    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'This version is no longer supported. Please update to the latest version.'),
        findsOneWidget);

    service.metadata = Metadata(data: {
      os: {
        "latest": "2.4.1",
        "minimum": "2.1.0",
        "url": "http://example.com/myAppUpdate",
        "enabled": false
      },
    });

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.text(
            'The app is currently in maintenance, please check again shortly.'),
        findsOneWidget);
  });
}

class MockPackageInfoProvider extends PackageInfoProvider {
  final String version;

  MockPackageInfoProvider({required this.version});

  Future<PackageInfo> getInfo() async {
    return PackageInfo(
        appName: 'ManUpTest',
        packageName: 'com.example.manUpTest',
        version: version,
        buildNumber: '123');
  }
}

class MockManUpService extends ManUpService {
  MockManUpService({super.os, super.packageInfoProvider});

  Metadata metadata = Metadata(data: {});
  int validateCallCount = 0;

  @override
  Future<ManUpStatus> validate([Metadata? metadata]) {
    validateCallCount += 1;
    return super.validate(metadata);
  }

  @override
  Future<Metadata> getMetadata() async => metadata;
}
