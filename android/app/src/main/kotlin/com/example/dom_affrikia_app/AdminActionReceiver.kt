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

            if (action == "enableKioskMode") {
                val dpm = context?.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                val compName = ComponentName(context, MyDeviceAdminReceiver::class.java)

                // Check device owner
                if (!dpm.isDeviceOwnerApp(context.packageName)) {
                    Log.e("AdminActionReceiver", "Not device owner. Cannot enable kiosk mode.")
                    return
                }

                // Launch MainActivity and enable lock task from there
                val launchIntent = Intent(context, MainActivity::class.java)
                launchIntent.putExtra("action", "enableKioskMode")
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(launchIntent)

                Log.d("AdminActionReceiver", "MainActivity launched with kiosk action.")
            }
        }
    }
}