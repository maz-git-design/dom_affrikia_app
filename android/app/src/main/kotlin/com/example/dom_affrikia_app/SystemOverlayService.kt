// package com.example.dom_affrikia_app

// import android.app.Service
// import android.content.Context
// import android.content.Intent
// import android.graphics.PixelFormat
// import android.os.IBinder
// import android.view.Gravity
// import android.view.LayoutInflater
// import android.view.View
// import android.view.WindowManager

// class SystemOverlayService : Service() {

//     private lateinit var overlayView: View
//     private lateinit var windowManager: WindowManager

//     override fun onCreate() {
//         super.onCreate()
//         windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

//         val params = WindowManager.LayoutParams(
//             WindowManager.LayoutParams.MATCH_PARENT,
//             WindowManager.LayoutParams.WRAP_CONTENT,
//             WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
//             WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
//             PixelFormat.TRANSLUCENT
//         )

//         params.gravity = Gravity.TOP
//        // overlayView = LayoutInflater.from(this).inflate(R.layout.overlay_blocker, null)

//         windowManager.addView(overlayView, params)
//     }

//     override fun onDestroy() {
//         super.onDestroy()
//         windowManager.removeView(overlayView)
//     }

//     override fun onBind(intent: Intent?): IBinder? {
//         return null
//     }

//     companion object {
//         fun stopService(context: Context) {
//             val intent = Intent(context, SystemOverlayService::class.java)
//             context.stopService(intent)
//         }
//     }
// }