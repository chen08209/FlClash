package com.follow.clash

import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import androidx.core.graphics.drawable.toBitmap
import com.follow.clash.common.GlobalState
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.TimeUnit
import kotlin.coroutines.resume

private const val ICON_TTL_DAYS = 1L

suspend fun PackageManager.getPackageIconPath(packageName: String): String =
    withContext(Dispatchers.IO) {
        val cacheDir = GlobalState.application.cacheDir
        val iconDir = File(cacheDir, "icons").apply { mkdirs() }
        return@withContext try {
            val pkgInfo = getPackageInfo(packageName, 0)
            val lastUpdateTime = pkgInfo.lastUpdateTime
            val iconFile = File(iconDir, "${packageName}_${lastUpdateTime}.webp")
            if (iconFile.exists() && !isExpired(iconFile)) {
                return@withContext iconFile.absolutePath
            }
            iconDir.listFiles()?.forEach { file ->
                if (file.name.startsWith(packageName + "_")) file.delete()
            }
            val icon = getApplicationIcon(packageName)
            saveDrawableToFile(icon, iconFile)
            iconFile.absolutePath
        } catch (_: Exception) {
            val defaultIconFile = File(iconDir, "default_icon.webp")
            if (!defaultIconFile.exists()) {
                saveDrawableToFile(defaultActivityIcon, defaultIconFile)
            }
            defaultIconFile.absolutePath
        }
    }

private fun saveDrawableToFile(drawable: Drawable, file: File) {
    val bitmap = drawable.toBitmap()
    try {
        val format = when {
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.R -> {
                Bitmap.CompressFormat.WEBP_LOSSY
            }

            else -> {
                Bitmap.CompressFormat.WEBP
            }
        }
        FileOutputStream(file).use { fos ->
            bitmap.compress(format, 90, fos)
        }
    } finally {
        if (!bitmap.isRecycled) bitmap.recycle()
    }
}

private fun isExpired(file: File): Boolean {
    val now = System.currentTimeMillis()
    val age = now - file.lastModified()
    return age > TimeUnit.DAYS.toMillis(ICON_TTL_DAYS)
}

suspend fun <T> MethodChannel.awaitResult(
    method: String, arguments: Any? = null
): T? = withContext(Dispatchers.Main) {
    suspendCancellableCoroutine { continuation ->
        invokeMethod(method, arguments, object : MethodChannel.Result {
            override fun success(result: Any?) {
                @Suppress("UNCHECKED_CAST") continuation.resume(result as T?)
            }

            override fun error(code: String, message: String?, details: Any?) {
                continuation.resume(null)
            }

            override fun notImplemented() {
                continuation.resume(null)
            }
        })
    }
}

inline fun <reified T : FlutterPlugin> FlutterEngine.plugin(): T? {
    return plugins.get(T::class.java) as T?
}


fun <T> MethodChannel.invokeMethodOnMainThread(
    method: String, arguments: Any? = null, callback: ((Result<T>) -> Unit)? = null
) {
    Handler(Looper.getMainLooper()).post {
        invokeMethod(method, arguments, object : MethodChannel.Result {
            override fun success(result: Any?) {
                @Suppress("UNCHECKED_CAST") callback?.invoke(Result.success(result as T))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                val exception = Exception("MethodChannel error: $errorCode - $errorMessage")
                callback?.invoke(Result.failure(exception))
            }

            override fun notImplemented() {
                val exception = NotImplementedError("Method not implemented: $method")
                callback?.invoke(Result.failure(exception))
            }
        })
    }
}