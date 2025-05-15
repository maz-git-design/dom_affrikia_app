package com.example.dom_affrikia_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log

class BackgroundService : Service() {

    override fun onCreate() {
        super.onCreate()
        Log.d("BackgroundService", "Service created")
        startForegroundServiceCompat()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("BackgroundService", "Background service started.")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "BackgroundServiceChannel"
            val channelName = "Kiosk Mode Service"
            val importance = NotificationManager.IMPORTANCE_LOW

            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = "Keeps the Kiosk Mode active"
            }

            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)

            val notification = Notification.Builder(this, channelId)
                .setContentTitle("Kiosk Mode Active")
                .setContentText("Your device is in Kiosk Mode and restricted")
                .setSmallIcon(android.R.drawable.ic_lock_lock)
                .setOngoing(true)
                .build()

            startForeground(1, notification)
        }

        return START_STICKY
    }

    private fun startForegroundServiceCompat() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceIntent = Intent(applicationContext, BackgroundService::class.java)
            try {
                applicationContext.startForegroundService(serviceIntent)
            } catch (e: SecurityException) {
                Log.e("BackgroundService", "SecurityException: Missing permissions! ${e.message}")
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.w("BackgroundService", "Background service was destroyed! Restarting...")

        val restartServiceIntent = Intent(applicationContext, BackgroundService::class.java)
        startService(restartServiceIntent)
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}