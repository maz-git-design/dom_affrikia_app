package com.example.dom_affrikia_app

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log



class AdminActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "com.example.dom_affrikia_app.ACTION_ADMIN") {
            val action = intent.getStringExtra("action")
            Log.d("AdminActionReceiver", "Received action: $action")

            when (action) {
                "enableKioskMode" -> {
                    val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                    val compName = ComponentName(context, MyDeviceAdminReceiver::class.java)

                    if (!dpm.isDeviceOwnerApp(context.packageName)) {
                        Log.e("AdminActionReceiver", "Not device owner. Cannot enable kiosk mode.")
                        return
                    }

                    val launchIntent = Intent(context, MainActivity::class.java)
                    launchIntent.putExtra("action", "enableKioskMode")
                    launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(launchIntent)

                    Log.d("AdminActionReceiver", "MainActivity launched with kiosk action.")
                }

                "installApk" -> {
                    val apkUrl = intent.getStringExtra("apkUrl")
                    if (apkUrl.isNullOrEmpty()) {
                        Log.e("AdminActionReceiver", "APK URL is missing for installApk action.")
                        return
                    }

                    ApkDownloader.downloadAndInstallApk(context, apkUrl)
                    Log.d("AdminActionReceiver", "Started APK download from URL: $apkUrl")
                }

                else -> {
                    Log.w("AdminActionReceiver", "Unknown action received: $action")
                }
            }
        }
    }
}