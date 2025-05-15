package com.example.dom_affrikia_app

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugins.GeneratedPluginRegistrant
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "device_admin"
    private lateinit var policyService: MyDevicePolicyService

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        policyService = MyDevicePolicyService(this)

            // 👇 Handle intent action from BroadcastReceiver
        val action = intent?.getStringExtra("action")
        if (action == "enableKioskMode") {
            Log.d("MainActivity", "Received action to enable kiosk mode")
            policyService.enableKioskModeFull()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
    
        val action = intent?.getStringExtra("action")
        if (action == "enableKioskMode") {
            Log.d("MainActivity", "onNewIntent received action to enable kiosk mode")
            policyService.enableKioskModeFull()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        Log.d("MainActivity", "configureFlutterEngine CALLED") 
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableAdmin" -> {
                    policyService.enableAdmin()
                    result.success("Admin Enabled")
                }
                "lockDevice" -> {
                    policyService.lockDevice()
                    result.success("Device Locked")
                }
                "unlockDevice" -> {
                    policyService.unlockDevice()
                    result.success("Device Unlocked")
                }
                "wipeDevice" -> {
                    policyService.wipeDevice()
                    result.success("Device Wiped")
                }
                "disableAdmin" -> {
                    policyService.disableAdmin()
                    result.success("Admin Disabled")
                }
                "enableKioskMode" -> {
                    policyService.enableKioskModeFull()
                    result.success("Kiosk Mode Enabled")
                }
                "disableKioskMode" -> {
                    policyService.disableKioskModeFull()
                    result.success("Kiosk Mode Disabled")
                }
                "blockFactoryReset" -> {
                    policyService.blockFactoryReset()
                    result.success("Factory Reset Blocked")
                }
                "preventUSBTransfer" -> {
                    policyService.preventUSBTransfer()
                    result.success("USB Transfer Blocked")
                }
                "restrictSettings" -> {
                    policyService.restrictSettings()
                    result.success("Settings Restricted")
                }
                "autoStartOnBoot" -> {
                    policyService.autoStartOnBoot()
                    result.success("Auto Start Enabled")
                }
                "preventUninstall" -> {
                    policyService.preventUninstall()
                    result.success("Uninstall Blocked")
                }
                "getAdminStatus" -> result.success(policyService.isAdminEnabled())
                "getKioskStatus" -> result.success(policyService.isInKioskMode())
                "getFactoryResetStatus" -> result.success(policyService.isFactoryResetBlocked())
                "getUsbTransferStatus" -> result.success(policyService.isUsbTransferBlocked())
                "getSettingsRestricted" -> result.success(policyService.isSettingsRestricted())
                "getUninstallStatus" -> result.success(policyService.isUninstallBlocked())
                "getInstallAppsStatus" -> result.success(policyService.isInstallAppsBlocked())
                "getUninstallAppsStatus" -> result.success(policyService.isUninstallAppsBlocked())
                "getSafeBootStatus" -> result.success(policyService.isSafeBootBlocked())
                "getTetheringStatus" -> result.success(policyService.isTetheringBlocked())
                "getAddUserStatus" -> result.success(policyService.isAddUserBlocked())
                "exitKioskMode" -> {
                    policyService.exitKioskMode()
                    result.success("Exited Kiosk Mode")
                }
                "blockFactoryReset2" -> {
                    policyService.blockFactoryReset2()
                    result.success("Factory Reset Blocked")
                }
                "allowFactoryReset" -> {
                    policyService.allowFactoryReset()
                    result.success("Factory Reset Allowed")
                }
                "blockUsbTransfer" -> {
                    policyService.blockUsbTransfer()
                    result.success("USB Transfer Blocked")
                }
                "allowUsbTransfer" -> {
                    policyService.allowUsbTransfer()
                    result.success("USB Transfer Allowed")
                }
                "blockInstallApps" -> {
                    policyService.blockInstallApps()
                    result.success("Install Apps Blocked")
                }
                "allowInstallApps" -> {
                    policyService.allowInstallApps()
                    result.success("Install Apps Allowed")
                }
                "blockUninstallApps" -> {
                    policyService.blockUninstallApps()
                    result.success("Uninstall Apps Blocked")
                }
                "allowUninstallApps" -> {
                    policyService.allowUninstallApps()
                    result.success("Uninstall Apps Allowed")
                }
                "blockSafeBoot" -> {
                    policyService.blockSafeBoot()
                    result.success("Safe Boot Blocked")
                }
                "allowSafeBoot" -> {
                    policyService.allowSafeBoot()
                    result.success("Safe Boot Allowed")
                }
                "blockTethering" -> {
                    policyService.blockTethering()
                    result.success("Tethering Blocked")
                }
                "allowTethering" -> {
                    policyService.allowTethering()
                    result.success("Tethering Allowed")
                }
                "blockAddUser" -> {
                    policyService.blockAddUser()
                    result.success("Add User Blocked")
                }
                "allowAddUser" -> {
                    policyService.allowAddUser()
                    result.success("Add User Allowed")
                }
                else -> result.notImplemented()
            }
        }
    }
}


    
    // fun startStatusBarBlocker() {
    //     val intent = Intent(this, SystemOverlayService::class.java)
    //     startService(intent)
    // }

    // fun stopStatusBarBlocker() {
    //     SystemOverlayService.stopService(this)
    // }

