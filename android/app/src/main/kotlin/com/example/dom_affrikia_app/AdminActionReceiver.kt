package com.example.dom_affrikia_app

import android.app.admin.DevicePolicyManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class AdminActionReceiver : BroadcastReceiver() {
    private fun saveStatus(context: Context, key: String, value: Boolean) {
        val ts = System.currentTimeMillis().toString()

        // Flutter SharedPreferences storage (Dart reads from this)
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .edit()
            .putBoolean("flutter.$key", value)
            .putString("flutter.${key}_ts", ts)
            .apply()

        // Optional native mirror for debugging
        context.getSharedPreferences("admin_live_state", Context.MODE_PRIVATE)
            .edit()
            .putBoolean(key, value)
            .putLong("${key}_ts", System.currentTimeMillis())
            .apply()
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != "com.example.dom_affrikia_app.ACTION_ADMIN") return

        val action = intent.getStringExtra("action")
        Log.d("AdminActionReceiver", "Received action: $action")
        val policyService = MyDevicePolicyService(context)

        try {
            when (action) {
                "enableKioskMode" -> {
                    val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                    if (!dpm.isDeviceOwnerApp(context.packageName)) {
                        Log.e("AdminActionReceiver", "Not device owner. Cannot enable kiosk mode.")
                        return
                    }
                    val launchIntent = Intent(context, MainActivity::class.java)
                    launchIntent.putExtra("action", "enableKioskMode")
                    launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(launchIntent)
                }

                // Command execution actions
                "disableKioskModePartially" -> policyService.disableKioskMode()
                "disableKioskMode" -> policyService.disableKioskModeFull()
                "wipeDevice" -> policyService.wipeDevice()
                "rebootDevice" -> policyService.rebootDevice()
                "allowFactoryReset" -> policyService.allowFactoryReset()
                "blockFactoryReset2" -> policyService.blockFactoryReset2()
                "allowAdbDebugging" -> policyService.allowAdbDebugging()
                "blockAdbDebugging" -> policyService.blockAdbDebugging()
                "allowUsbTransfer" -> policyService.allowUsbTransfer()
                "blockUsbTransfer" -> policyService.blockUsbTransfer()
                "allowUninstallApps" -> policyService.allowUninstallApps()
                "blockUninstallApps" -> policyService.blockUninstallApps()
                "allowInstallApps" -> policyService.allowInstallApps()
                "blockInstallApps" -> policyService.blockInstallApps()
                "allowSafeBoot" -> policyService.allowSafeBoot()
                "blockSafeBoot" -> policyService.blockSafeBoot()
                "allowTethering" -> policyService.allowTethering()
                "blockTethering" -> policyService.blockTethering()
                "allowAddUser" -> policyService.allowAddUser()
                "blockAddUser" -> policyService.blockAddUser()
                "allowDateConfig" -> policyService.allowModifyingDatetime()
                "blockDateConfig" -> policyService.blockModifyingDatetime()
                "allowAdbFeatures" -> policyService.allowAdbFeatures()
                "blockAdbFeatures" -> policyService.blockAdbFeatures()
                "allowAppsControl" -> policyService.allowAppsControl()
                "blockAppsControl" -> policyService.blockAppsControl()
                "disableAdmin" -> policyService.disableAdmin()

                // Live status actions
                "getFactoryResetStatus" -> saveStatus(context, "getFactoryResetStatus", policyService.isFactoryResetBlocked())
                "getKioskStatus" -> saveStatus(context, "getKioskStatus", policyService.isInKioskMode())
                "getAdbDebuggingStatus" -> saveStatus(context, "getAdbDebuggingStatus", policyService.isAdbDebuggingBlocked())
                "getUsbTransferStatus" -> saveStatus(context, "getUsbTransferStatus", policyService.isUsbTransferBlocked())
                "getUninstallAppsStatus" -> saveStatus(context, "getUninstallAppsStatus", policyService.isUninstallAppsBlocked())
                "getInstallAppsStatus" -> saveStatus(context, "getInstallAppsStatus", policyService.isInstallAppsBlocked())
                "getSafeBootStatus" -> saveStatus(context, "getSafeBootStatus", policyService.isSafeBootBlocked())
                "getTetheringStatus" -> saveStatus(context, "getTetheringStatus", policyService.isTetheringBlocked())
                "getAddUserStatus" -> saveStatus(context, "getAddUserStatus", policyService.isAddUserBlocked())
                "getDateTimeStatus" -> saveStatus(context, "getDateTimeStatus", policyService.isModifyingDateBlocked())
                "getAdbFeaturesStatus" -> saveStatus(context, "getAdbFeaturesStatus", policyService.isAdbFeaturesBlocked())
                "getAppsControlStatus" -> saveStatus(context, "getAppsControlStatus", policyService.isAppsControlBlocked())

                else -> Log.w("AdminActionReceiver", "Unknown action received: $action")
            }
        } catch (t: Throwable) {
            Log.e("AdminActionReceiver", "Failed action=$action", t)
        }
    }
}
