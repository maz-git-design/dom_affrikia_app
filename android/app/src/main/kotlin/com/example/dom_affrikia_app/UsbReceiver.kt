package com.example.dom_affrikia_app

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class UsbReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "android.hardware.usb.action.USB_STATE") {
            val dpm = context?.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
            val adminComponent = ComponentName(context, MyDeviceAdminReceiver::class.java)

            if (dpm.isAdminActive(adminComponent)) {
                dpm.setUsbDataSignalingEnabled(false) // Disable USB data transfer
            }
        }
    }
}
