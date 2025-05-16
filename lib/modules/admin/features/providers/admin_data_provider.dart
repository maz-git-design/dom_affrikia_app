import 'dart:async';

import 'package:dom_affrikia_app/modules/admin/features/domain/entities/admin_config.dart';
import 'package:get_it/get_it.dart';

class AdminDataProvider extends Disposable {
  @override
  FutureOr onDispose() {
    return Future(() {});
  }

  List<AdminConfig> adminConfigs = [];
  bool isForegroundServiceRunning = true;
}
