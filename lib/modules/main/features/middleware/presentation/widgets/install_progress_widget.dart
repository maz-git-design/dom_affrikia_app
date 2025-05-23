import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class InstallProgressWidget extends StatefulWidget {
  const InstallProgressWidget({super.key});

  @override
  State<InstallProgressWidget> createState() => _InstallProgressWidgetState();
}

class _InstallProgressWidgetState extends State<InstallProgressWidget> {
  int progress = 0;

  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      log("data received from download: $data");
      final dynamic newProgress = data["installProgress"];

      if (newProgress != null) {
        setState(() {
          progress = newProgress;
        });
      }
    }
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
    final percentageFraction = progress / 100;

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
          const Text(
            "Installation en cours...",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            borderRadius: BorderRadius.circular(4),
            value: percentageFraction,
            minHeight: 10,
            backgroundColor: Colors.grey[300],
            color: Colors.blue,
          ),
          const SizedBox(height: 10),
          Text(
            "$progress%",
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
