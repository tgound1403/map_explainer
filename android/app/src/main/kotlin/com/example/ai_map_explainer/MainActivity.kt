package com.example.ai_map_explainer

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.os.Bundle

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.ai_map_explainer/intent_channel"
    private var senderPackage: String? = null
    private var broadcastAction: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendStatus" -> {
                    // Nhận trạng thái từ Flutter và gửi broadcast về App A
                    val status = call.argument<String>("status")
                    sendBroadcastToSender(status)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Lưu thông tin sender từ Intent
        senderPackage = intent.getStringExtra("sender_package")
        broadcastAction = intent.getStringExtra("broadcast_action")
        // Gửi Intent lên Flutter
        sendIntentToFlutter(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        print(intent.getStringExtra("sender_package"))
        // Cập nhật thông tin sender
        senderPackage = intent.getStringExtra("sender_package")
        broadcastAction = intent.getStringExtra("broadcast_action")
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

    private fun sendBroadcastToSender(status: String?) {
        if (senderPackage != null && broadcastAction != null) {
            val broadcastIntent = Intent(broadcastAction).apply {
                putExtra("status", status)
                setPackage(senderPackage) // Gửi broadcast tới App A
            }
            sendBroadcast(broadcastIntent)
        }
    }
}