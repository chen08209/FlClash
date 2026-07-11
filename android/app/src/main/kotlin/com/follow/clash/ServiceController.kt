package com.follow.clash

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import com.follow.clash.common.GlobalState
import com.follow.clash.common.intent
import com.follow.clash.core.Core
import com.follow.clash.service.ManagedService
import com.follow.clash.service.ProxyService
import com.follow.clash.service.ServiceConfig
import com.follow.clash.service.VpnService
import com.follow.clash.service.models.VpnOptions
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import kotlin.coroutines.resume

object ServiceController {
    private val lock = Mutex()
    private var binding: ManagedServiceBinding? = null
    @Volatile
    private var runTimeMillis = 0L

    suspend fun unbind() = lock.withLock {
        clearBinding()
    }

    private fun clearBinding() {
        binding?.unbind()
        binding = null
    }

    fun invokeMethod(data: String, callback: ((String) -> Unit)?): Result<Unit> = runCatching {
        Core.invokeMethod(data) { result ->
            callback?.invoke(result.orEmpty())
        }
    }

    suspend fun quickSetup(
        initParams: String,
        setupParams: String,
    ): Result<String> = runCatching {
        suspendCancellableCoroutine { continuation ->
            Core.quickSetup(initParams, setupParams) { result ->
                continuation.resume(result.orEmpty())
            }
        }
    }

    fun setEventListener(callback: ((String?) -> Unit)?): Result<Unit> = runCatching {
        Core.updateEventListener(callback)
    }

    suspend fun start(options: VpnOptions, previousRunTimeMillis: Long): Long = lock.withLock {
        ServiceConfig.updateVpnOptions(options)
        val nextIntent = if (options.enable) {
            VpnService::class.intent
        } else {
            ProxyService::class.intent
        }

        if (binding?.component != nextIntent.component) {
            clearBinding()
            lateinit var nextBinding: ManagedServiceBinding
            nextBinding = ManagedServiceBinding(nextIntent) { message ->
                handleServiceDisconnected(nextBinding, message)
            }
            binding = nextBinding
            nextBinding.bind().onFailure { error ->
                GlobalState.log("Unable to bind background service: $error")
                clearBinding()
                return@withLock 0L
            }
        }

        val currentBinding = binding ?: return@withLock 0L
        val result = currentBinding.useService { service -> service.start() }
        if (result.isFailure) {
            GlobalState.log("Unable to start background service: ${result.exceptionOrNull()}")
            clearBinding()
            return@withLock 0L
        }

        runTimeMillis = previousRunTimeMillis.takeIf { it != 0L }
            ?: System.currentTimeMillis()
        runTimeMillis
    }

    suspend fun stop(): Long = lock.withLock {
        binding?.useService { service -> service.stop() }
            ?.onFailure { error ->
                GlobalState.log("Unable to stop background service: $error")
            }
        clearBinding()
        runTimeMillis = 0L
        runTimeMillis
    }

    fun getRunTimeMillis(): Long = runTimeMillis

    private fun handleServiceDisconnected(
        disconnectedBinding: ManagedServiceBinding,
        message: String,
    ) {
        GlobalState.launch {
            lock.withLock {
                if (binding !== disconnectedBinding) {
                    return@withLock
                }
                GlobalState.log("Background service disconnected: $message")
                clearBinding()
                runTimeMillis = 0L
            }
        }
    }
}

private class ManagedServiceBinding(
    private val intent: Intent,
    private val onDisconnected: (String) -> Unit,
) : ServiceConnection {
    val component: ComponentName?
        get() = intent.component

    private val serviceState = MutableStateFlow<Result<ManagedService>?>(null)

    @Volatile
    private var isBound = false

    suspend fun bind(): Result<Unit> = runCatching {
        withContext(Dispatchers.Main.immediate) {
            serviceState.value = null
            isBound = GlobalState.application.bindService(
                intent,
                this@ManagedServiceBinding,
                Context.BIND_AUTO_CREATE,
            )
            check(isBound) { "bindService() failed" }
        }
    }

    suspend fun <R> useService(
        timeoutMillis: Long = 5_000,
        block: suspend (ManagedService) -> R,
    ): Result<R> = runCatching {
        withTimeout(timeoutMillis) {
            val service = serviceState.filterNotNull().first().getOrThrow()
            withContext(Dispatchers.Default) {
                block(service)
            }
        }
    }

    fun unbind() {
        serviceState.value = null
        if (!isBound) return
        isBound = false
        Handler(Looper.getMainLooper()).post {
            runCatching {
                GlobalState.application.unbindService(this)
            }.onFailure { error ->
                GlobalState.log("Unable to unbind background service: $error")
            }
        }
    }

    override fun onServiceConnected(name: ComponentName?, binder: IBinder?) {
        runCatching {
            when (binder) {
                is VpnService.LocalBinder -> binder.service
                is ProxyService.LocalBinder -> binder.service
                null -> error("Binder is empty")
                else -> error("Unsupported service binder: ${binder.javaClass.name}")
            }
        }.onSuccess { service ->
            serviceState.value = Result.success(service)
        }.onFailure { error ->
            disconnect(error.message.orEmpty())
        }
    }

    override fun onServiceDisconnected(name: ComponentName?) {
        disconnect("Service disconnected")
    }

    override fun onBindingDied(name: ComponentName?) {
        disconnect("Service binding died")
    }

    override fun onNullBinding(name: ComponentName?) {
        disconnect("Service returned an empty binder")
    }

    private fun disconnect(message: String) {
        serviceState.value = Result.failure(IllegalStateException(message))
        onDisconnected(message)
    }
}
