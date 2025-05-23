import 'dart:developer';

import 'package:background_downloader/background_downloader.dart';
import 'package:dom_affrikia_app/injection_container.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<void> initDownload() async {
  await sl<FlutterSecureStorage>().write(key: "updateStatus", value: "NoUpdate");
  var allDownloadTasks = await FileDownloader().allTaskIds();
  log("allTasks $allDownloadTasks");

  FileDownloader().cancelTasksWithIds(allDownloadTasks);
}
