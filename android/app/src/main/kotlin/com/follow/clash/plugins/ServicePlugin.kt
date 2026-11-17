package com.follow.clash.plugins

import com.follow.clash.ServiceController
import com.follow.clash.ServiceState
import com.follow.clash.StartFailure
import com.follow.clash.common.Components
import com.follow.clash.common.GlobalState
import com.follow.clash.core.Core
import com.follow.clash.core.NativeCore
import com.follow.clash.models.SharedState
import com.follow.clash.service.NetworkObserver
import com.google.gson.Gson
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class ServicePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var messenger: BinaryMessenger
    private lateinit var channel: MethodChannel
    private lateinit var coreChannel: MethodChannel
    private lateinit var scope: CoroutineScope
    private val gson = Gson()
    private var commandRevision = 0

    @Volatile
    private var dartSession = 0L

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
        // The main thread is also Flutter's UI thread, where "init" would load it.
        scope.launch {
            runCatching { Core.load() }
                .onFailure { error -> GlobalState.log("Unable to load the Core: $error") }
        }
        messenger = binding.binaryMessenger
        channel = MethodChannel(messenger, SERVICE_CHANNEL)
        channel.setMethodCallHandler(this)
        // Serial: watchRoute keeps the latest intent by the order calls reach the Core.
        coreChannel = MethodChannel(
            messenger,
            CORE_CHANNEL,
            StandardMethodCodec.INSTANCE,
            messenger.makeBackgroundTaskQueue(),
        )
        coreChannel.setMethodCallHandler(::onCoreMethodCall)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        coreChannel.setMethodCallHandler(null)
        scope.cancel()
        ServiceController.setEventListener(null)
        closeDartSession()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> initialize(call, result)
            "session" -> attachSession(call, result)
            "shutdown" -> shutdown(result)
            "getRunTime" -> getRunTime(result)
            "syncState" -> syncState(call, result)
            "start" -> start(call, result)
            "stop" -> stop(call, result)
            else -> result.notImplemented()
        }
    }

    private fun onCoreMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "send" -> sendFrame(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(call: MethodCall, result: MethodChannel.Result) {
        NetworkObserver.start()
        if (call.arguments == FRAMES_FFI) {
            scope.launch {
                runCatching { Core.load() }
                    .onSuccess { result.success("") }
                    .onFailure { error -> result.success(error.message.orEmpty()) }
            }
            return
        }
        ServiceController.setEventListener(::sendEvent)
            .onSuccess { result.success("") }
            .onFailure { error -> result.success(error.message.orEmpty()) }
    }

    private fun attachSession(call: MethodCall, result: MethodChannel.Result) {
        dartSession = (call.arguments as? Number)?.toLong() ?: 0L
        result.success(null)
    }

    private fun closeDartSession() {
        val session = dartSession
        dartSession = 0L
        if (session != 0L) NativeCore.close(session)
    }

    private fun shutdown(result: MethodChannel.Result) {
        ServiceController.setEventListener(null)
        result.success(true)
    }

    private fun sendFrame(call: MethodCall, result: MethodChannel.Result) {
        val data = call.arguments as? ByteArray
        if (data == null) {
            result.error("INVALID_ARGUMENT", "A frame must be a byte array", null)
            return
        }
        ServiceController.sendFrame(data)
            .onSuccess { result.success(null) }
            .onFailure { error -> result.error("CORE_ERROR", error.message, null) }
    }

    private fun getRunTime(result: MethodChannel.Result) {
        scope.launch {
            result.success(ServiceState.awaitRunTime())
        }
    }

    private fun syncState(call: MethodCall, result: MethodChannel.Result) {
        val data = call.arguments as? String
        scope.launch {
            val state = runCatching {
                gson.fromJson(data, SharedState::class.java)
            }.getOrNull()
            if (state == null) {
                result.success("Invalid shared state")
                return@launch
            }
            ServiceState.syncSharedState(state)
            result.success("")
        }
    }

    private fun start(call: MethodCall, result: MethodChannel.Result) {
        commandRevision = call.arguments as? Int ?: commandRevision
        ServiceState.requestStart()
        result.success(true)
    }

    private fun stop(call: MethodCall, result: MethodChannel.Result) {
        commandRevision = call.arguments as? Int ?: commandRevision
        ServiceState.requestStop()
        result.success(true)
    }

    // Read on the platform thread, where start and stop arrive: revision and intent are one instant.
    internal fun notifyStopped(failure: StartFailure?) {
        scope.launch(Dispatchers.Main) {
            if (!ServiceState.isRunRequested) {
                channel.invokeMethod(
                    "stopped",
                    mapOf("revision" to commandRevision, "failure" to failure?.code),
                )
            }
        }
    }

    private fun sendEvent(value: ByteArray) {
        val message = StandardMethodCodec.INSTANCE.encodeMethodCall(MethodCall("event", value))
        scope.launch(Dispatchers.Main) {
            messenger.send(SERVICE_CHANNEL, message)
        }
    }

    private companion object {
        val SERVICE_CHANNEL = "${Components.PACKAGE_NAME}/service"
        val CORE_CHANNEL = "${Components.PACKAGE_NAME}/core"
        const val FRAMES_FFI = "ffi"
    }
}
