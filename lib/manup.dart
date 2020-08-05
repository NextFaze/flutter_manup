library manup;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';

part 'src/exception.dart';
part 'src/metadata.dart';
part 'src/manup_status.dart';
part 'src/manup_service.dart';
part 'src/package_info_provider.dart';
part 'src/manup_delegate.dart';
part 'src/ui/manup_app_dialog.dart';
part 'src/ui/manup_widget.dart';
part 'src/mixin/manup_delegate_mixin.dart';
part 'src/mixin/manup_dialog_mixin.dart';
