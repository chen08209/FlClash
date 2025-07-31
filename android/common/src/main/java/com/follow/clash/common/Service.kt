package com.follow.clash.common

import android.content.Intent
import android.os.IBinder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeout
import java.util.concurrent.atomic.AtomicBoolean

class ServiceDelegate<T>(
    private val intent: Intent,
    private val onServiceDisconnected: ((String) -> Unit)? = null,
    private val interfaceCreator: (IBinder) -> T,
) : CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {

    private val _bindingState = AtomicBoolean(false)

    private var _serviceState = MutableStateFlow<Pair<T?, String>?>(null)

    val serviceState: StateFlow<Pair<T?, String>?> = _serviceState
    private var job: Job? = null

    private fun handleBind(data: Pair<IBinder?, String>) {
        data.first?.let {
            _serviceState.value = Pair(interfaceCreator(it), data.second)
        } ?: run {
            _serviceState.value = Pair(null, data.second)
            unbind()
            onServiceDisconnected?.invoke(data.second)
            _bindingState.set(false)
        }
    }

    fun bind() {
        if (_bindingState.compareAndSet(false, true)) {
            job?.cancel()
            job = null
            _serviceState.value = null
            job = launch {
                GlobalState.application.bindServiceFlow<IBinder>(intent).collect { handleBind(it) }
            }
        }
    }

    suspend inline fun <R> useService(
        timeoutMillis: Long = 5000, crossinline block: (T) -> R
    ): Result<R> {
        return runCatching {
            withTimeout(timeoutMillis) {
                val state = serviceState.filterNotNull().first()
                state.first?.let {
                    block(it)
                } ?: throw Exception(state.second)
            }
        }
    }

    fun unbind() {
        if (_bindingState.compareAndSet(true, false)) {
            job?.cancel()
            job = null
            _serviceState.value = null
        }
    }
}