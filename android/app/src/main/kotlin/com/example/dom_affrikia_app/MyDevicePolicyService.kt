package com.example.dom_affrikia_app

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.provider.Settings
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.app.ActivityManager
import android.os.UserManager
import android.app.KeyguardManager
import android.os.Bundle
import android.os.Build
import android.Manifest
import android.content.pm.PackageManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.ActivityCompat



class MyDevicePolicyService(private val context: Context) {
 
    
    private val dpm: DevicePolicyManager =
        context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
    private val adminComponent: ComponentName =
        ComponentName(context, MyDeviceAdminReceiver::class.java)

    private fun isDebug(): Boolean {
        return context.applicationInfo.flags and
                android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE != 0
    }

    fun applyPermissionPolicyAndGrants() {

        if (!dpm.isAdminActive(adminComponent)) return
        // Automatically grant runtime permissions
        dpm.setPermissionPolicy(adminComponent, DevicePolicyManager.PERMISSION_POLICY_AUTO_GRANT)

        val permissions = listOf(
            Manifest.permission.CAMERA,
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.READ_PHONE_STATE,
            Manifest.permission.PACKAGE_USAGE_STATS,
            Manifest.permission.SYSTEM_ALERT_WINDOW,
            Manifest.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
            Manifest.permission.ACCESS_NOTIFICATION_POLICY,
            Manifest.permission.POST_NOTIFICATIONS
            // Add others if needed and if runtime-grantable
        )

        permissions.forEach { permission ->
            try {
                dpm.setPermissionGrantState(
                    adminComponent,
                    context.packageName,
                    permission,
                    DevicePolicyManager.PERMISSION_GRANT_STATE_GRANTED
                )
            } catch (e: SecurityException) {
                Log.w("DPC", "Could not grant permission: $permission. ${e.message}")
            }
        }
    }

    fun getIMEI(): String? {
        Log.d("IMEI", "In getIMEI function")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            if (ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
                val imei = telephonyManager.imei
                Log.d("IMEI", "Device IMEI: $imei")
                return imei
            } else {
                Log.e("IMEI", "Permission not granted")
            }
        } else {
            Log.e("IMEI", "SDK version < O, not supported")
        }
        return null
    }

    fun setRestrictions(enable: Boolean) {
        if (!dpm.isAdminActive(adminComponent)) return
    
        // val restrictions = listOf(
        //     UserManager.DISALLOW_FACTORY_RESET,
        //     UserManager.DISALLOW_USB_FILE_TRANSFER,
        //     UserManager.DISALLOW_UNINSTALL_APPS,
        //     UserManager.DISALLOW_SAFE_BOOT,
        //     UserManager.DISALLOW_CONFIG_TETHERING,
        //     UserManager.DISALLOW_ADD_USER,
        //     UserManager.DISALLOW_CONFIG_DATE_TIME,
        //     UserManager.DISALLOW_DEBUGGING_FEATURES,
        //     UserManager.DISALLOW_APPS_CONTROL
        // )

        val restrictions = listOf(
            //UserManager.DISALLOW_FACTORY_RESET,
            //UserManager.DISALLOW_USB_FILE_TRANSFER,
            UserManager.DISALLOW_UNINSTALL_APPS,
            //UserManager.DISALLOW_SAFE_BOOT,
            UserManager.DISALLOW_CONFIG_TETHERING,
            UserManager.DISALLOW_ADD_USER,
            UserManager.DISALLOW_CONFIG_DATE_TIME,
            //UserManager.DISALLOW_DEBUGGING_FEATURES,
            UserManager.DISALLOW_APPS_CONTROL
        )
    
        for (restriction in restrictions) {
            if (enable) {
                dpm.addUserRestriction(adminComponent, restriction)
            } else {
                dpm.clearUserRestriction(adminComponent, restriction)
            }
        }
    }


    fun enableAdmin() {
        val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN).apply {
            putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, adminComponent)
        }
        context.startActivity(intent)

         preventUninstall() // Prevent uninstallation
    }

    fun lockDevice() {
        if (dpm.isAdminActive(adminComponent)) {
            dpm.lockNow()
        }
    }

    fun unlockDevice() {
        if (dpm.isAdminActive(adminComponent)) {
            dpm.resetPassword("", 0)
        }
    }

    fun wipeDevice() {
        if (dpm.isAdminActive(adminComponent)) {
            dpm.wipeData(DevicePolicyManager.WIPE_EXTERNAL_STORAGE)
        }
    }

    fun rebootDevice() {
        if (!dpm.isAdminActive(adminComponent)) {
            Log.e("DPC", "Cannot reboot: admin not active")
            return
        }
        if (!dpm.isDeviceOwnerApp(context.packageName)) {
            Log.e("DPC", "Cannot reboot: app is not device owner")
            return
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            Log.e("DPC", "Cannot reboot: requires Android N+")
            return
        }
        try {
            dpm.reboot(adminComponent)
        } catch (t: Throwable) {
            Log.e("DPC", "Device reboot failed", t)
        }
    }

    fun disableAdmin() {
        dpm.removeActiveAdmin(adminComponent)
    }

    fun enableKioskMode() {
        if (dpm.isAdminActive(adminComponent)) {
            dpm.setLockTaskPackages(adminComponent, arrayOf(context.packageName))
            (context as Activity).startLockTask()

            // Show Activation Screen
            // val intent = Intent(context, ActivationScreen::class.java)
            // intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            // context.startActivity(intent)
        }
    }

    fun exitKioskMode() {
        if (dpm.isAdminActive(adminComponent)) {
            dpm.setLockTaskPackages(adminComponent, emptyArray()) // Exits Kiosk Mode
        }
    }


    fun blockFactoryReset() {
        if (dpm.isAdminActive(adminComponent)) {
            dpm.setFactoryResetProtectionPolicy(adminComponent, null)
        }
    }

    // fun preventUSBTransfer() {
    //     if (dpm.isAdminActive(adminComponent)) {
    //         dpm.setUsbDataSignalingEnabled(false)
    //     }
    // }

    // Block File Transfer via USB
    fun blockFileTransfer() {
        val command = "svc usb setFunctions none"
        Runtime.getRuntime().exec(command)
    }

    fun restrictSettings() {
        val intent = Intent(Settings.ACTION_SETTINGS)
        intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK
        context.startActivity(intent)
    }

    fun autoStartOnBoot() {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }

    // fun preventUninstall() {
    //     val intent = Intent(Settings.ACTION_SECURITY_SETTINGS)
    //     context.startActivity(intent)
    // }

    fun preventUninstall() {
        if (dpm.isAdminActive(adminComponent)) {
            dpm.setUninstallBlocked(adminComponent, context.packageName, true)
        }
    }


    fun isAdminEnabled(): Boolean {
        return dpm.isAdminActive(adminComponent)
    }

    fun isDeviceLocked(): Boolean {
        val km = context.getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        return km.isDeviceLocked
    }

    fun isInKioskMode(): Boolean {
        val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return am.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
    }

    fun isSettingsRestricted(): Boolean {
        return true
    }

    fun isUninstallBlocked(): Boolean {
        return dpm.isUninstallBlocked(adminComponent, context.packageName)
    }

    fun isFactoryResetBlocked(): Boolean {
        return dpm.getUserRestrictions(adminComponent)
            .getBoolean(UserManager.DISALLOW_FACTORY_RESET, false)
    }
    
    fun isUsbTransferBlocked(): Boolean {
        return dpm.getUserRestrictions(adminComponent)
            .getBoolean(UserManager.DISALLOW_USB_FILE_TRANSFER, false)
    }
    
    fun isInstallAppsBlocked(): Boolean {
        return dpm.getUserRestrictions(adminComponent)
            .getBoolean(UserManager.DISALLOW_INSTALL_APPS, false)
    }
    
    fun isUninstallAppsBlocked(): Boolean {
        return dpm.getUserRestrictions(adminComponent)
            .getBoolean(UserManager.DISALLOW_UNINSTALL_APPS, false)
    }
    
    fun isSafeBootBlocked(): Boolean {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            dpm.getUserRestrictions(adminComponent)
                .getBoolean(UserManager.DISALLOW_SAFE_BOOT, false)
        } else false
    }
    
    fun isTetheringBlocked(): Boolean {
        return dpm.getUserRestrictions(adminComponent)
            .getBoolean(UserManager.DISALLOW_CONFIG_TETHERING, false)
    }
    
    fun isAddUserBlocked(): Boolean {
        return dpm.getUserRestrictions(adminComponent)
            .getBoolean(UserManager.DISALLOW_ADD_USER, false)
    }

    fun isModifyingDateBlocked(): Boolean {
        return dpm.getUserRestrictions(adminComponent)
            .getBoolean(UserManager.DISALLOW_CONFIG_DATE_TIME, false)
    }

    fun isAdbDebuggingBlocked(): Boolean {
        return Settings.Global.getInt(context.contentResolver, Settings.Global.ADB_ENABLED, 0) == 0
    }

     fun isAdbFeaturesBlocked(): Boolean {
        return dpm.getUserRestrictions(adminComponent)
            .getBoolean(UserManager.DISALLOW_DEBUGGING_FEATURES, false)
    }
    
    fun isAppsControlBlocked(): Boolean {
        return dpm.getUserRestrictions(adminComponent)
            .getBoolean(UserManager.DISALLOW_APPS_CONTROL, false)
    }

    // Generic methods
    private fun enableRestriction(restriction: String) {
        if (dpm.isAdminActive(adminComponent)) {
            dpm.addUserRestriction(adminComponent, restriction)
        }
    }

    private fun disableRestriction(restriction: String) {
        if (dpm.isAdminActive(adminComponent)) {
            dpm.clearUserRestriction(adminComponent, restriction)
        }
    }

    fun enableKioskModeFull() {
        if (!dpm.isAdminActive(adminComponent)) return

        // Set lock task package
        dpm.setLockTaskPackages(adminComponent, arrayOf(context.packageName))
        (context as? Activity)?.startLockTask()

        // Set restrictions
        setRestrictions(true)  // Enable all restrictions
        

        // Prevent USB debugging (optional)
        // if (isDebug()) {
        //     Settings.Global.putInt(context.contentResolver, Settings.Global.ADB_ENABLED, 1)
        // } else {
        //     Settings.Global.putInt(context.contentResolver, Settings.Global.ADB_ENABLED, 0)
        // }
        

        // Block uninstallation of your app
        dpm.setUninstallBlocked(adminComponent, context.packageName, true)
    }

    fun disableKioskMode() {
        if (!dpm.isAdminActive(adminComponent)) return

        // Remove lock task mode
        dpm.setLockTaskPackages(adminComponent, emptyArray())
        (context as? Activity)?.stopLockTask()

        // Clear restrictions
        //setRestrictions(false) // Disable all restrictions

        val restrictions = listOf(
            UserManager.DISALLOW_USB_FILE_TRANSFER,
            UserManager.DISALLOW_UNINSTALL_APPS,
            UserManager.DISALLOW_CONFIG_TETHERING,
        )
    
        for (restriction in restrictions) {
            dpm.clearUserRestriction(adminComponent, restriction)
        }

        // Allow USB debugging again (optional)
        if (isDebug()) {
            Settings.Global.putInt(context.contentResolver, Settings.Global.ADB_ENABLED, 1)
        } else {
            Settings.Global.putInt(context.contentResolver, Settings.Global.ADB_ENABLED, 0)
        }

        // Allow app uninstallation
        //dpm.setUninstallBlocked(adminComponent, context.packageName, false)
    }

    fun disableKioskModeFull() {
        if (!dpm.isAdminActive(adminComponent)) return

        // Remove lock task mode
        dpm.setLockTaskPackages(adminComponent, emptyArray())
        (context as? Activity)?.stopLockTask()

        // Clear restrictions
        setRestrictions(false) // Disable all restrictions

        // Allow USB debugging again (optional)
        Settings.Global.putInt(context.contentResolver, Settings.Global.ADB_ENABLED, 1)

        // Allow app uninstallation
        //dpm.setUninstallBlocked(adminComponent, context.packageName, false)
    }


    // 1. Factory Reset
    fun blockFactoryReset2() = enableRestriction(UserManager.DISALLOW_FACTORY_RESET)
    fun allowFactoryReset() = disableRestriction(UserManager.DISALLOW_FACTORY_RESET)

    // 2. USB File Transfer
    fun blockUsbTransfer() = enableRestriction(UserManager.DISALLOW_USB_FILE_TRANSFER)
    fun allowUsbTransfer() = disableRestriction(UserManager.DISALLOW_USB_FILE_TRANSFER)

    // 3. Install Apps
    fun blockInstallApps() = enableRestriction(UserManager.DISALLOW_INSTALL_APPS)
    fun allowInstallApps() = disableRestriction(UserManager.DISALLOW_INSTALL_APPS)

    // 4. Uninstall Apps
    fun blockUninstallApps() = enableRestriction(UserManager.DISALLOW_UNINSTALL_APPS)
    fun allowUninstallApps() = disableRestriction(UserManager.DISALLOW_UNINSTALL_APPS)

    fun blockAdbDebugging() {
        Settings.Global.putInt(context.contentResolver, Settings.Global.ADB_ENABLED, 0)
    }
    fun allowAdbDebugging() {
        Settings.Global.putInt(context.contentResolver, Settings.Global.ADB_ENABLED, 1)
    }

    // 5. Safe Boot (API 28+ only)
    fun blockSafeBoot() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            enableRestriction(UserManager.DISALLOW_SAFE_BOOT)
        }
    }

    // 4. Modifying date and time
    fun blockModifyingDatetime() = enableRestriction(UserManager.DISALLOW_CONFIG_DATE_TIME)
    fun allowModifyingDatetime() = disableRestriction(UserManager.DISALLOW_CONFIG_DATE_TIME)

    fun allowSafeBoot() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
            disableRestriction(UserManager.DISALLOW_SAFE_BOOT)
        }
    }

    // 6. Tethering
    fun blockTethering() = enableRestriction(UserManager.DISALLOW_CONFIG_TETHERING)
    fun allowTethering() = disableRestriction(UserManager.DISALLOW_CONFIG_TETHERING)

    // 7. Add User
    fun blockAddUser() = enableRestriction(UserManager.DISALLOW_ADD_USER)
    fun allowAddUser() = disableRestriction(UserManager.DISALLOW_ADD_USER)
    fun blockAdbFeatures() = enableRestriction(UserManager.DISALLOW_DEBUGGING_FEATURES)
    fun allowAdbFeatures() = disableRestriction(UserManager.DISALLOW_DEBUGGING_FEATURES)
    fun blockAppsControl() = enableRestriction(UserManager.DISALLOW_APPS_CONTROL)
    fun allowAppsControl() = disableRestriction(UserManager.DISALLOW_APPS_CONTROL)


    
}
