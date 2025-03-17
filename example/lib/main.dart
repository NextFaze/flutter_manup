import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:manup/manup.dart';

// See /examples for more examples
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ManUpWidget(
        // Alternatively, use [FireBaseRemoteConfigManUpService] or implement
        // your own [ManUpService]
        service: HttpManUpService('https://example.com/my_config.json',
            http: Client()),
        child: const Scaffold(body: Center(child: Text('My App'))),
        // Optionals
        onComplete: (_) {
          debugPrint('ManUp validation complete');
        },
        onError: (_) {
          debugPrint('ManUp validation error');
        },
        onStatusChanged: (status) {
          debugPrint('ManUp status is "$status"');
        },
        shouldShowAlert: () => true,
      ),
    );
  }
}
