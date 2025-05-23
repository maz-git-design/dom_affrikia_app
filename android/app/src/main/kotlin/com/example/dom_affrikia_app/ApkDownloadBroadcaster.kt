package com.example.dom_affrikia_app

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.content.pm.PackageInstaller
import java.io.*
import java.net.URL
import javax.net.ssl.HttpsURLConnection
import java.net.HttpURLConnection
import android.app.AlarmManager

class ApkDownloader {
    companion object {

        fun installApk(context: Context, apkFile: File) {
            Thread {
                try {
                    sendInstallStartBroadcast(context)
                    //sendInstallProgressBroadcast(context, 5)

                    val packageInstaller = context.packageManager.packageInstaller
                    val input = FileInputStream(apkFile)

                    val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
                    val sessionId = packageInstaller.createSession(params)
                    val session = packageInstaller.openSession(sessionId)
                    val out = session.openWrite("app_update", 0, -1)

                    val buffer = ByteArray(8 * 1024)
                    var c: Int
                    var writtenBytes = 0L
                    val totalBytes = apkFile.length()

                    var lastProgress = -1

                    while (input.read(buffer).also { c = it } != -1) {
                        out.write(buffer, 0, c)
                        writtenBytes += c

                        val progress = (writtenBytes * 100 / totalBytes).toInt()
                        if (progress % 2 == 0 && progress != lastProgress) {
                            lastProgress = progress
                            sendInstallProgressBroadcast(context, progress)
                        }
                    }

                    session.fsync(out)
                    input.close()
                    out.close()

                    sendInstallProgressBroadcast(context, 100)
                    sendInstallDoneBroadcast(context)

                    // Delay before committing the session
                    Thread.sleep(8000) // Delay for 5 seconds

                    val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                    val pendingRestart = PendingIntent.getActivity(
                        context,
                        0,
                        launchIntent,
                        PendingIntent.FLAG_CANCEL_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )

                    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    alarmManager.set(
                        AlarmManager.RTC,
                        System.currentTimeMillis() + 5000, // 5 seconds later
                        pendingRestart
                    )

                    val intent = Intent(context, ApkInstallReceiver::class.java)
                    val pendingIntent = PendingIntent.getBroadcast(
                        context,
                        sessionId,
                        intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
                    )

                    session.commit(pendingIntent.intentSender)
                    session.close()

                } catch (e: Exception) {
                    Log.e("ApkDownloader", "Install error", e)
                    sendInstallErrorBroadcast(context, e.message ?: "Unknown install error")
                }
            }.start()
        }

        // --- Install status broadcasts ---
        private fun sendInstallStartBroadcast(context: Context) {
            Log.d("ApkDownloader", "APK installation started")
            val intent = Intent("com.example.dom_affrikia_app.APK_INSTALL_STARTED")
            intent.setClass(context, ApkInstallReceiver::class.java)
            context.sendBroadcast(intent)
        }

        private fun sendInstallProgressBroadcast(context: Context, progress: Int) {
            Log.d("ApkDownloader", "Progress install inside: $progress")

            val intent = Intent("com.example.dom_affrikia_app.APK_INSTALL_PROGRESS")
            intent.setClass(context, ApkInstallReceiver::class.java)
            intent.putExtra("progress", progress)
            context.sendBroadcast(intent)
        }

        private fun sendInstallDoneBroadcast(context: Context) {
            Log.d("ApkDownloader", "APK installation done")
            val intent = Intent("com.example.dom_affrikia_app.APK_INSTALL_DONE")
            intent.setClass(context, ApkInstallReceiver::class.java)
            context.sendBroadcast(intent)
        }

        private fun sendInstallErrorBroadcast(context: Context, message: String) {
            Log.e("ApkDownloader", "APK installation error: $message")

            val intent = Intent("com.example.dom_affrikia_app.APK_INSTALL_ERROR")
            intent.setClass(context, ApkInstallReceiver::class.java)
            intent.putExtra("error", message)
            context.sendBroadcast(intent)
        }
    }
}