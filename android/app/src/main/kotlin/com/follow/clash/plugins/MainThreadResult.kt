package com.follow.clash.plugins

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel

/**
 * Delivers a [MethodChannel.Result] on the main thread, which is where Flutter
 * requires it, from handlers that finish on a background dispatcher.
 *
 * The hop goes through the main looper rather than the plugin's coroutine scope:
 * that scope is cancelled when the engine detaches, and a reply dropped by a
 * cancelled scope leaves the Dart future waiting forever. A reply posted after
 * the engine is gone is the messenger's problem to ignore, and it does.
 */
internal class MainThreadResult(
    private val delegate: MethodChannel.Result,
) : MethodChannel.Result {
    override fun success(result: Any?) = post { delegate.success(result) }

    override fun error(code: String, message: String?, details: Any?) =
        post { delegate.error(code, message, details) }

    override fun notImplemented() = post { delegate.notImplemented() }

    private fun post(block: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            block()
        } else {
            mainHandler.post(block)
        }
    }

    private companion object {
        val mainHandler = Handler(Looper.getMainLooper())
    }
}
