library manup;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

part 'src/exception.dart';
part 'src/metadata.dart';
part 'src/man_up_status.dart';
part 'src/man_up_service.dart';
part 'src/man_up_validator.dart';
part 'src/package_info_provider.dart';
part 'src/man_up_delegate.dart';
part 'src/ui/man_up_app_dialog.dart';
part 'src/ui/man_up_widget.dart';
part 'src/mixin/man_up_delegate_mixin.dart';
part 'src/mixin/man_up_dialog_mixin.dart';
part 'src/config_storage.dart';
