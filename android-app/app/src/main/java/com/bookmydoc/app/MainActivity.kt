package com.bookmydoc.app

import android.os.Bundle
import android.webkit.WebView
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // Enable debugging in development
        WebView.setWebContentsDebuggingEnabled(true)
    }

    companion object {
        // For Android Emulator (10.0.2.2 is the special IP for host machine's localhost)
        // NOTE: localhost won't work on Android - use 10.0.2.2 instead
        const val BASE_URL = "http://10.0.2.2:7000"

        // For physical device on same WiFi network, use your computer's IP:
        // const val BASE_URL = "http://192.168.1.X:7000"

        // For production:
        // const val BASE_URL = "https://your-production-url.com"
    }
}
