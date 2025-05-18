package com.example.dom_affrikia_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class ApkInstallReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val status = intent?.getIntExtra("android.content.pm.extra.STATUS", -1)
        val message = intent?.getStringExtra("android.content.pm.extra.STATUS_MESSAGE")

        when (status) {
            0 -> { // STATUS_SUCCESS
                Log.d("ApkInstallReceiver", "Install succeeded")
                context?.let { ApkDownloader.sendInstallDoneBroadcast(it) }
            }
            else -> {
                Log.e("ApkInstallReceiver", "Install failed: $message")
                context?.let { ApkDownloader.sendInstallErrorBroadcast(it, message ?: "Unknown error") }
            }
        }
    }
}