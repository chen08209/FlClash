package com.follow.clash

import android.os.Bundle
import android.webkit.WebSettings
import android.webkit.WebView

import io.flutter.plugin.common.MethodChannel
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.ProxyPlugin
import com.follow.clash.plugins.TilePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tom.cla/ua"
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GlobalState.flutterEngine?.destroy()
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(AppPlugin())
        flutterEngine.plugins.add(ProxyPlugin())
        flutterEngine.plugins.add(TilePlugin())
        GlobalState.flutterEngine = flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getUserAgent") {
                val userAgent = getUserAgent()
                result.success(userAgent)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        GlobalState.flutterEngine = null
        super.onDestroy()
    }
    
    private fun getUserAgent(): String {
        val webView = WebView(this)
        val webSettings = webView.settings
        return webSettings.userAgentString
    }
}