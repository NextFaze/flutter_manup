import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:manup/src/firebase_remote_config_man_up_service.dart';

// generated with flutterfire_cli
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FireBaseRemoteConfigManUpService service;

  String statusStr = 'default';
  String latestVersion = '';

  @override
  void initState() {
    super.initState();
    service = FireBaseRemoteConfigManUpService(
      remoteConfig: FirebaseRemoteConfig.instance,
      // Parameter name (key) in remote config
      paramName: 'mockManUpConfig',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      home: Scaffold(
        body: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Status: $statusStr'),
            Text('Latest version: $latestVersion'),
          ],
        )),
        floatingActionButton: FloatingActionButton(
          child: const Text('Validate'),
          onPressed: () {
            service.validate().then((status) {
              setState(() {
                statusStr = status.name;
                latestVersion = service
                    .setting(
                      key: 'latest',
                      orElse: '',
                      os: 'ios',
                    )
                    .toString();
              });
            }).catchError((error) {
              debugPrint('error: $error');
            });
          },
        ),
      ),
    );
  }
}
