import 'dart:developer';

import 'package:background_downloader/background_downloader.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> initDownload() async {
  final secureStorage = sl<FlutterSecureStorage>();
  final existingStatus = await secureStorage.read(key: "updateStatus");
  if (existingStatus == null || existingStatus.isEmpty) {
    await secureStorage.write(key: "updateStatus", value: "NoUpdate");
  }
  var allDownloadTasks = await FileDownloader().allTaskIds();
  log("allTasks $allDownloadTasks");

  FileDownloader().cancelTasksWithIds(allDownloadTasks);
}
