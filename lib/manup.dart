library manup;

import 'package:manup/src/ui/manup_app_dialog.dart';
import 'package:manup/src/manup_delegate.dart';
import 'package:package_info/package_info.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

part 'src/exception.dart';
part 'src/metadata.dart';
part 'src/manup_status.dart';
part 'src/manup_service.dart';
part 'src/package_info_provider.dart';
