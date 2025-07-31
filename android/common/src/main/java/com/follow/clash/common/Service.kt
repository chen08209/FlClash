package com.follow.clash.common

import android.content.Intent
import android.os.IBinder
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull

class ServiceDelegate<T>(
    private val intent: Intent,
    private val onServiceCrash: (() -> Unit)? = null,
    private val interfaceCreator: (IBinder) -> T,
) : CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {

    private val _service = MutableStateFlow<T?>(null)

    val service: StateFlow<T?> = _service

    private var bindJob: Job? = null
    private fun handleBindEvent(event: BindServiceEvent<IBinder>) {
        when (event) {
            is BindServiceEvent.Connected -> {
                _service.value = event.binder.let(interfaceCreator)
            }

            is BindServiceEvent.Disconnected -> {
                _service.value = null
            }

            is BindServiceEvent.Crashed -> {
                _service.value = null
                onServiceCrash?.invoke()
            }
        }
    }

    fun bind() {
        unbind()
        bindJob = launch {
            GlobalState.application.bindServiceFlow<IBinder>(intent).collect { it ->
                handleBindEvent(it)
            }
        }
    }

    suspend inline fun <R> useService(crossinline block: (T) -> R): Result<R> {
        return withTimeoutOrNull(10_000) {
            service.first { it != null }
        }?.let { service ->
            try {
                Result.success(block(service))
            } catch (e: Exception) {
                Result.failure(e)
            }
        } ?: Result.failure(Exception("Service connection timeout"))
    }

    fun unbind() {
        _service.value = null
        bindJob?.cancel()
        bindJob = null
    }
}