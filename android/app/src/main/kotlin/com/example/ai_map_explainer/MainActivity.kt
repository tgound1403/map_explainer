package com.example.ai_map_explainer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.ai_map_explainer/intent_channel";
    private var clientPackage: String? = null;
    private var callbackAction: String? = null;
    
    companion object {
        val TAG = "Duong-Flutter";
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.ai_map_explainer/intent_channel").setMethodCallHandler { call, result ->
            when (call.method) {
                "sendStatus" -> {
                    Log.d(TAG, "configureFlutterEngine: ${call.arguments}")
                    sendBroadcastToSender(call.arguments as Map<String, String>)
                    result.success(true)
                }
                else -> {
                    Log.d(TAG, "configureFlutterEngine: ${call.method}")
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Lưu thông tin sender từ Intent
        clientPackage = intent.getStringExtra("clientPackage")
        callbackAction = intent.getStringExtra("callbackAction")
        // Gửi Intent lên Flutter
        sendIntentToFlutter(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        print("[DUONG] ${intent.getStringExtra(" clientPackage ")}")
        // Cập nhật thông tin sender
        clientPackage = intent.getStringExtra("clientPackage")
        callbackAction = intent.getStringExtra("callbackAction")
        sendIntentToFlutter(intent)
    }

    private fun sendIntentToFlutter(intent: Intent?) {
        val channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
        val intentData = handleIntent(intent)
        channel.invokeMethod("handleIntent", intentData)
    }

    private fun handleIntent(intent: Intent?): Map<String, Any?> {
        val intentData = mutableMapOf<String, Any?>()
        intentData["action"] = intent?.action
        intentData["data"] = intent?.dataString
        intentData["extras"] = intent?.extras?.let { extras ->
            val extrasMap = mutableMapOf<String, Any?>()
            extras.keySet().forEach { key ->
                extrasMap[key] = extras.get(key)
            }
            extrasMap
        }
        return intentData
    }

    private fun sendBroadcastToSender(status: Map<String, String>) {
        if (clientPackage != null && callbackAction != null) {
            val broadcastIntent = Intent(callbackAction).apply {
                putExtra("orderId", status["orderId"])
                putExtra("payRequestId", status["payRequestId"])
                putExtra("amountPaid", status["amountPaid"])
                putExtra("resultCode", status["resultCode"])
                setPackage(clientPackage)
            }
            try {
                sendBroadcast(broadcastIntent)
                Log.d(TAG, "sendBroadcastToSender: send DONE")
            } catch (e: Exception) {
                Log.d(TAG, "sendBroadcastToSender:  exception: ${e.message}")

            }
        }
    }
}