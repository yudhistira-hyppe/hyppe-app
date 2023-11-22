package com.hyppe.hyppeapp

import android.os.Bundle
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var featureType: String? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = intent
        if (intent != null) {
            handleSendText(intent) // Handle text being sent
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.channel.shared.data").setMethodCallHandler {
        call, result ->
            if(call.method == "getFeatureType") {
                result.success(featureType)
                featureType = null
            }
            else {
                result.notImplemented()
            }
        }
    }

    private fun handleSendText(intent: Intent) {
        featureType = intent.getStringExtra(Intent.EXTRA_TEXT)
    }
}