package com.example.dom_affrikia_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import java.io.File
import com.pravera.flutter_foreground_task.service.ForegroundService


class ApkInstallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action
        val apkPath = intent.getStringExtra("apkPath")
        val data = hashMapOf<String, Any>(
            "apk_event" to (action ?: "UNKNOWN")
        )

        if (apkPath != null) {
            data["apkPath"] = apkPath
        }

        when (action) {
            "com.example.dom_affrikia_app.APK_ACTION_TEST" -> {
                Log.e("ApkInstallReceiver", "Received test action from foreground service")
            }
            "com.example.dom_affrikia_app.APK_INSTALL_TRIGGERED" -> {
                if (apkPath != null) {
                    Log.d("ApkInstallReceiver", "Installing from: $apkPath")
                    ApkDownloader.installApk(context, File(apkPath))
                } else {
                    Log.e("ApkInstallReceiver", "No apkPath received for install!")
                    data["error"] = "No apkPath received"
                }
            }

            "com.example.dom_affrikia_app.APK_INSTALL_STARTED" -> {
                Log.d("ApkInstallReceiver", "APK installation started")
                data["status"] = "started"
            }

            "com.example.dom_affrikia_app.APK_INSTALL_PROGRESS" -> {
                val progress = intent.getIntExtra("progress", 0)
                Log.d("ApkInstallReceiver", "APK installation progress: $progress%")
                data["progress"] = progress
                data["status"] = "progress"
            }

            "com.example.dom_affrikia_app.APK_INSTALL_DONE" -> {
                Log.d("ApkInstallReceiver", "APK installation completed")
                data["status"] = "done"
            }

            "com.example.dom_affrikia_app.APK_INSTALL_ERROR" -> {
                val errorMsg = intent.getStringExtra("error") ?: "Unknown error"
                Log.e("ApkInstallReceiver", "Installation error: $errorMsg")
                data["error"] = errorMsg
            }

            else -> {
                Log.w("ApkInstallReceiver", "Unhandled action: $action")
            }
        }

        // ✅ Always send broadcast data to Flutter ForegroundService
        ForegroundService.sendData(data)
    }
}