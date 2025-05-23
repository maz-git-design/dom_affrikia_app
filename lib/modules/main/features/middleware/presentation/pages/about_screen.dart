import 'dart:developer';

import 'package:dom_affrikia_app/injection_container.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/widgets/download_progress_widget.dart';
import 'package:dom_affrikia_app/modules/main/features/middleware/presentation/widgets/install_progress_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  static const routeName = '/about-screen';
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? packageInfo;
  double progress = 0.0;
  String updateStatus = "NoUpdate";

  void _onReceiveTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      log("data received from updateStatus: $data");
      if (data.containsKey('updateStatus')) {
        final String newStatus = data["updateStatus"] as String;

        setState(() {
          updateStatus = newStatus;
        });
      }
    }
  }

  void _getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  void _checkUpdate() async {
    final update = await sl<FlutterSecureStorage>().read(key: "updateStatus");
    if (update != null) {
      updateStatus = update;
    } else {
      updateStatus = "NoUpdate";
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
    _getPackageInfo();
    _checkUpdate();
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A propos'),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'A propos de l\'application',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify,
                  ),
                  Text(
                    packageInfo != null ? packageInfo!.appName : "...",
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    ),
                    child: const Text(
                      'Afrfikia DM (Device Manager) est une application conçue pour la gestion sécurisée des téléphones loués de la marque Afrrikia. Elle permet aux fournisseurs de contrôler à distance les appareils mis à disposition des clients, tout en garantissant le respect des conditions de location.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Version de l\'application : ${packageInfo != null ? packageInfo?.version : "--"}+${packageInfo != null ? packageInfo?.buildNumber : "--"}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mise à jour disponible',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  if (updateStatus == "HasUpdate")
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Une nouvelle version est disponible",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 14),
                          ),
                          Text(
                            "Le téléchargement va commencer...",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  if (updateStatus == "UpdateDownloading" || updateStatus == "UpdateDownloaded")
                    const DownloadProgressWidget(),
                  if (updateStatus == "UpdateInstalling") const InstallProgressWidget(),
                  if (updateStatus == "UpdateInstalled" || updateStatus == "NoUpdate")
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      ),
                      child: const Text(
                        'Appareil à jour avec la dernière version',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey.shade200,
                child: Row(
                  children: [
                    const Text(
                      '© 2025 SIX. Tous droits réservés.',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: Image.asset(
                        'assets/logo/six-logo.png',
                        fit: BoxFit.contain,
                        height: 70.h,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
