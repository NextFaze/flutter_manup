import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manup/manup.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const DebugApp());
}

class DebugApp extends StatefulWidget {
  const DebugApp({super.key});

  @override
  State<DebugApp> createState() => _DebugAppState();
}

class _DebugAppState extends State<DebugApp> {
  late final MockPackageInfoProvider provider;

  /// Alternatively, use the built-in [HttpManUpService] or [FireBaseRemoteConfigManUpService]
  late final MockManUpService manUpService;

  final versionController = TextEditingController(text: '1.0.0');
  final latestController = TextEditingController(text: '1.0.0');
  final minimumController = TextEditingController(text: '1.0.0');
  bool enabled = true;

  String latestVersion = '-';

  @override
  void initState() {
    super.initState();

    provider = MockPackageInfoProvider(version: '1.0.0');
    manUpService = MockManUpService(
      // By default, this would be be based on the current OS
      os: 'ios',
      // By default, this would be fetched via package_info_plus
      packageInfoProvider: provider,
    );
  }

  @override
  void dispose() {
    super.dispose();
    versionController.dispose();
    latestController.dispose();
    minimumController.dispose();
  }

  _updateData() {
    provider.version = versionController.text;
    manUpService.metadata = Metadata(data: {
      'ios': {
        "latest": latestController.text.trim(),
        "minimum": minimumController.text.trim(),
        "url": "http://example.com",
        "enabled": enabled
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.grey.shade100,
              body: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 12,
                    ),
                    const Text(
                      'Config',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Text('Change settings and press "Revalidate"'),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Latest:'),
                              TextField(
                                onChanged: (_) {
                                  _updateData();
                                },
                                controller: latestController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Minimum:'),
                              TextField(
                                onChanged: (_) {
                                  _updateData();
                                },
                                controller: minimumController,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Flexible(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('App version:'),
                            TextField(
                              onChanged: (_) {
                                _updateData();
                              },
                              controller: versionController,
                            ),
                          ],
                        ))
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('App enabled:'),
                    Checkbox(
                        value: enabled,
                        onChanged: (newValue) {
                          setState(() {
                            enabled = newValue ?? true;
                            _updateData();
                          });
                        }),
                    const SizedBox(height: 12),
                    ElevatedButton(
                        onPressed: () {
                          manUpService.validate();
                        },
                        child: const Text('Re-validate'))
                  ],
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.teal),
            ),
            child: ExampleApp(manUpService: manUpService),
          ),
        ),
      ],
    );
  }
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key, required this.manUpService});

  final MockManUpService manUpService;

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  String statusStr = 'unknown';

  @override
  initState() {
    super.initState();
    widget.manUpService.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          statusStr = widget.manUpService.status?.name ?? 'unknown';
          loading = widget.manUpService.loading;
        });
      });
    });
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      debugShowCheckedModeBanner: false,
      home: ManUpWidget(
        service: widget.manUpService,
        shouldShowAlert: () => true,
        child: Scaffold(
          body: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                  child: Column(
                children: [
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'My App',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text('Status: $statusStr'),
                ],
              )),
              if (loading) ...[
                ModalBarrier(
                  color: Colors.black.withAlpha(100),
                ),
                const CircularProgressIndicator()
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class MockPackageInfoProvider extends PackageInfoProvider {
  String version;

  MockPackageInfoProvider({required this.version});

  @override
  Future<PackageInfo> getInfo() async {
    return PackageInfo(
        appName: 'ManUpTest',
        packageName: 'com.example.manUpTest',
        version: version,
        buildNumber: '123');
  }
}

class MockManUpService extends ManUpService {
  bool loading = false;
  MockManUpService({super.os, super.packageInfoProvider});

  Metadata metadata = Metadata(data: {});

  @override
  Future<Metadata> getMetadata() async {
    // Simulate network
    await Future.delayed(const Duration(seconds: 1));
    return metadata;
  }

  @override
  Future<ManUpStatus> validate([Metadata? metadata]) async {
    loading = true;
    notifyListeners();
    final status = await super.validate(metadata);
    loading = false;
    notifyListeners();
    return status;
  }
}
