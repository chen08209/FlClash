package com.follow.clash

import android.app.Application
import android.content.Context.MODE_PRIVATE
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import androidx.core.graphics.drawable.toBitmap
import com.follow.clash.common.GlobalState
import com.follow.clash.models.SharedState
import com.google.gson.Gson
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import java.util.concurrent.TimeUnit

private const val ICON_TTL_DAYS = 1L

val Application.sharedState: SharedState
    get() = try {
        val preferences = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val json = preferences.getString("flutter.sharedState", null)
        Gson().fromJson(json, SharedState::class.java) ?: SharedState()
    } catch (_: Exception) {
        SharedState()
    }

private var lastToast: Toast? = null

fun Application.showToast(text: String?) {
    if (text.isNullOrEmpty()) return
    Handler(Looper.getMainLooper()).post {
        lastToast?.cancel()
        lastToast = Toast.makeText(this, text, Toast.LENGTH_LONG).apply {
            show()
        }
    }
}

suspend fun PackageManager.getPackageIconPath(packageName: String): String =
    withContext(Dispatchers.IO) {
        val cacheDir = GlobalState.application.cacheDir
        val iconDir = File(cacheDir, "icons").apply { mkdirs() }
        return@withContext try {
            val lastUpdateTime = getPackageInfo(packageName, 0).lastUpdateTime
            val iconFile = File(iconDir, "${packageName}_${lastUpdateTime}.webp")
            if (iconFile.exists() && !isExpired(iconFile)) {
                return@withContext iconFile.absolutePath
            }
            iconDir.listFiles { f -> f.name.startsWith("${packageName}_") }?.forEach(File::delete)

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

private suspend fun saveDrawableToFile(drawable: Drawable, file: File) {
    val bitmap = withContext(Dispatchers.Default) {
        drawable.toBitmap(width = 128, height = 128)
    }
    try {
        @Suppress("DEPRECATION")
        val format = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            Bitmap.CompressFormat.WEBP_LOSSY
        } else {
            Bitmap.CompressFormat.WEBP
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

inline fun <reified T : FlutterPlugin> FlutterEngine.plugin(): T? {
    return plugins.get(T::class.java) as T?
}

fun MethodChannel.invokeMethodOnMainThread(method: String, arguments: Any? = null) {
    Handler(Looper.getMainLooper()).post {
        invokeMethod(method, arguments)
    }
}
