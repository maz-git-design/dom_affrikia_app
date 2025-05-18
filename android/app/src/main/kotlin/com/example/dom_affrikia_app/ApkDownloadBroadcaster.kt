package com.example.dom_affrikia_app

import android.app.PendingIntent
import android.app.PackageInstaller
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.io.*
import java.net.URL

class ApkDownloader {
    companion object {
        fun downloadAndInstallApk(context: Context, apkUrl: String) {
            Thread {
                try {
                    sendDownloadStartBroadcast(context)

                    val apkFile = File(context.cacheDir, "update.apk")
                    val urlConnection = URL(apkUrl).openConnection()
                    val totalSize = urlConnection.contentLength
                    val input = urlConnection.getInputStream()
                    val output = FileOutputStream(apkFile)

                    val buffer = ByteArray(8 * 1024)
                    var bytesRead: Int
                    var downloadedSize = 0
                    var lastProgress = 0

                    while (input.read(buffer).also { bytesRead = it } != -1) {
                        output.write(buffer, 0, bytesRead)
                        downloadedSize += bytesRead

                        val progress = (downloadedSize * 100) / totalSize
                        if (progress != lastProgress) {
                            sendDownloadProgressBroadcast(context, progress)
                            lastProgress = progress
                        }
                    }

                    output.flush()
                    output.close()
                    input.close()
                    
                    sendDownloadDoneBroadcast(context)
                    installApk(context, apkFile)

                } catch (e: Exception) {
                    Log.e("ApkDownloader", "Download error", e)
                    sendDownloadErrorBroadcast(context, e.message ?: "Unknown download error")
                }
            }.start()
        }

        private fun installApk(context: Context, apkFile: File) {
            try {
                sendInstallStartBroadcast(context)
                sendInstallProgressBroadcast(context, 5) // Simulate progress starting

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

                while (input.read(buffer).also { c = it } != -1) {
                    out.write(buffer, 0, c)
                    writtenBytes += c

                    val progress = (writtenBytes * 100 / totalBytes).toInt()
                    sendInstallProgressBroadcast(context, progress.coerceIn(0, 100))
                }

                session.fsync(out)
                input.close()
                out.close()

                sendInstallProgressBroadcast(context, 100)
                sendInstallDoneBroadcast(context)

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
        }

        // --- Download status broadcasts ---
        private fun sendDownloadStartBroadcast(context: Context) {
            context.sendBroadcast(Intent("com.example.dom_affrikia_app.APK_DOWNLOAD_STARTED"))
        }

        private fun sendDownloadProgressBroadcast(context: Context, progress: Int) {
            val intent = Intent("com.example.dom_affrikia_app.APK_DOWNLOAD_PROGRESS")
            intent.putExtra("progress", progress)
            context.sendBroadcast(intent)
        }

        private fun sendDownloadDoneBroadcast(context: Context) {
            val intent = Intent("com.example.dom_affrikia_app.APK_DOWNLOAD_DONE")
            context.sendBroadcast(intent)
        }

        private fun sendDownloadErrorBroadcast(context: Context, message: String) {
            val intent = Intent("com.example.dom_affrikia_app.APK_DOWNLOAD_ERROR")
            intent.putExtra("error", message)
            context.sendBroadcast(intent)
        }

        // --- Install status broadcasts ---
        private fun sendInstallStartBroadcast(context: Context) {
            context.sendBroadcast(Intent("com.example.dom_affrikia_app.APK_INSTALL_STARTED"))
        }

        private fun sendInstallProgressBroadcast(context: Context, progress: Int) {
            val intent = Intent("com.example.dom_affrikia_app.APK_INSTALL_PROGRESS")
            intent.putExtra("progress", progress)
            context.sendBroadcast(intent)
        }

        fun sendInstallDoneBroadcast(context: Context) {
            context.sendBroadcast(Intent("com.example.dom_affrikia_app.APK_INSTALL_DONE"))
        }

        fun sendInstallErrorBroadcast(context: Context, message: String) {
            val intent = Intent("com.example.dom_affrikia_app.APK_INSTALL_ERROR")
            intent.putExtra("error", message)
            context.sendBroadcast(intent)
        }
    }
}