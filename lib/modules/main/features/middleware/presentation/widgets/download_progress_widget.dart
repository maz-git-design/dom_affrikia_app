import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class DownloadProgressWidget extends StatefulWidget {
  const DownloadProgressWidget({super.key});

  @override
  State<DownloadProgressWidget> createState() => _DownloadProgressWidgetState();
}

class _DownloadProgressWidgetState extends State<DownloadProgressWidget> {
  double progress = 0.0;
  bool hasTimeRemaining = false;
  bool hasExpectedSize = false;
  int expectedSize = 0;
  String timeRemaining = "";

  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      log("data received from download: $data");
      final dynamic newProgress = data["progress"];

      final dynamic newHasTimeRemaining = data["hasTimeRemaining"];
      final dynamic newHasExpectedSize = data["hasExpectedSize"];
      final dynamic newExpectedSize = data["expectedSize"];
      final dynamic newTimeRemaining = data["timeRemaining"];

      if (newProgress != null) {
        if (newHasExpectedSize != null && newHasExpectedSize) {
          expectedSize = newExpectedSize;
        }
        if (newTimeRemaining != null && newHasTimeRemaining) {
          timeRemaining = newTimeRemaining;
        }

        if (newProgress > progress) {
          setState(() {
            progress = newProgress;
          });
        }
      }
    }
  }

  getInMB(int size) {
    if (size == 0) {
      return 0;
    }
    return (size / (1024 * 1024)).toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Téléchargement en cours... ( dans $timeRemaining)",
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            "Taille: ${expectedSize == 0 ? "Inconnu" : getInMB(expectedSize)} (MB)",
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            borderRadius: BorderRadius.circular(4),
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
          ),
          const SizedBox(height: 10),
          Text(
            "$percentage%",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
