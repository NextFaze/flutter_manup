import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:manup/manup.dart';

class FireBaseRemoteConfigManUpService extends ManUpService {
  final FirebaseRemoteConfig remoteConfig;
  late StreamSubscription remoteConfigSubscription;
  final PackageInfoProvider packageInfoProvider;
  final String? os;
  final String paramName;

  ManUpDelegate? delegate;

  FireBaseRemoteConfigManUpService({
    required this.remoteConfig,
    required this.paramName,
    this.os,
    this.packageInfoProvider = const DefaultPackageInfoProvider(),
    ConfigStorage storage = const ConfigStorage(),
    this.delegate,
  }) : super(
          delegate: delegate,
          os: os,
          packageInfoProvider: packageInfoProvider,
          storage: storage,
        ) {
    // Listen for updates in real time
    remoteConfigSubscription =
        remoteConfig.onConfigUpdated.listen((RemoteConfigUpdate event) async {
      await remoteConfig.activate();

      // Use the new config values here.
      final remoteConfigValue = remoteConfig.getValue(paramName);
      final data = remoteConfigValue.asString();
      Map<String, dynamic>? json = jsonDecode(data);
      validate(Metadata(data: json));
    });
  }

  Future<Metadata> getMetadata() async {
    try {
      await remoteConfig.fetchAndActivate();
      final remoteConfigValue = remoteConfig.getValue(paramName);
      final data = remoteConfigValue.asString();
      Map<String, dynamic>? json = jsonDecode(data);
      final Metadata metaData = Metadata(data: json);
      return metaData;
    } catch (exception) {
      if (kIsWeb) throw exception;
      try {
        var metadata = await readManUpFile();
        return metadata;
      } catch (e) {
        throw ManUpException(exception.toString());
      }
    }
  }

  void close() {
    remoteConfigSubscription.cancel();
    super.close();
  }
}
