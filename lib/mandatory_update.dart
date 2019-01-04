library mandatory_update;

import 'package:package_info/package_info.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'dart:convert';
import 'package:meta/meta.dart';

part 'src/exception.dart';
part 'src/metadata.dart';
part 'src/manup_status.dart';
part 'src/manup_service.dart';
part 'src/package_info_provider.dart';
