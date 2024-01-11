import 'dart:async';
import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseRemoteConfig extends Mock implements FirebaseRemoteConfig {
  final String? responseJsonString;

  MockFirebaseRemoteConfig({
    this.responseJsonString,
  });

  Future<bool> activate() {
    return Future.value(true);
  }

  Future<bool> fetchAndActivate() {
    return Future.value(true);
  }

  Stream<RemoteConfigUpdate> mockRemoteConfigUpdateStream() async* {}

  Stream<RemoteConfigUpdate> get onConfigUpdated =>
      mockRemoteConfigUpdateStream();

  RemoteConfigValue getValue(String key) {
    final encoded = Utf8Codec().encode((responseJsonString ?? ''));
    return RemoteConfigValue(encoded, ValueSource.valueDefault);
  }
}
