import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:manup/manup.dart';

class HttpManUpService extends ManUpService {
  final String url;
  final PackageInfoProvider packageInfoProvider;
  final Client http;
  final String? os;

  ManUpDelegate? delegate;

  HttpManUpService(
    this.url, {
    required this.http,
    this.os,
    this.packageInfoProvider = const DefaultPackageInfoProvider(),
    ConfigStorage storage = const ConfigStorage(),
    this.delegate,
  }) : super(
          delegate: delegate,
          os: os,
          packageInfoProvider: packageInfoProvider,
          storage: storage,
        );

  Future<Metadata> getMetadata() async {
    try {
      final uri = Uri.parse(this.url);
      var data = await http.get(uri);
      Map<String, dynamic>? json = jsonDecode(data.body);
      return Metadata(data: json);
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
    http.close();
    super.close();
  }
}
