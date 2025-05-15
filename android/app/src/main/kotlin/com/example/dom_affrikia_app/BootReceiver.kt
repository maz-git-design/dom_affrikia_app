package com.example.dom_affrikia_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Boot completed detected. Restarting services...")

            // Verify Device Owner Status
            val dpm = context?.getSystemService(Context.DEVICE_POLICY_SERVICE) as android.app.admin.DevicePolicyManager
            if (!dpm.isDeviceOwnerApp(context.packageName)) {
                Log.e("BootReceiver", "Device Owner status lost! Reset required.")
                return
            }

            // Restart Background Service
            val serviceIntent = Intent(context, BackgroundService::class.java)
            context?.startForegroundService(serviceIntent)

            // Restart Main Activity
            val mainIntent = Intent(context, MainActivity::class.java)
            mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context?.startActivity(mainIntent)
        }
    }
}