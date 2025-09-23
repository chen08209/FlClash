package com.follow.clash

import com.follow.clash.common.ServiceDelegate
import com.follow.clash.common.formatString
import com.follow.clash.common.intent
import com.follow.clash.service.IAckInterface
import com.follow.clash.service.ICallbackInterface
import com.follow.clash.service.IEventInterface
import com.follow.clash.service.IRemoteInterface
import com.follow.clash.service.IResultInterface
import com.follow.clash.service.RemoteService
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

object Service {
    private val delegate by lazy {
        ServiceDelegate<IRemoteInterface>(
            RemoteService::class.intent, ::handleServiceDisconnected
        ) {
            IRemoteInterface.Stub.asInterface(it)
        }
    }

    var onServiceDisconnected: ((String) -> Unit)? = null

    private fun handleServiceDisconnected(message: String) {
        onServiceDisconnected?.let {
            it(message)
        }
    }

    fun bind() {
        delegate.bind()
    }

    fun unbind() {
        delegate.unbind()
    }

    suspend fun invokeAction(data: String, cb: (result: String) -> Unit): Result<Unit> {
        val res = mutableListOf<ByteArray>()
        return delegate.useService {
            it.invokeAction(
                data, object : ICallbackInterface.Stub() {
                    override fun onResult(
                        result: ByteArray?, isSuccess: Boolean, ack: IAckInterface?
                    ) {
                        res.add(result ?: byteArrayOf())
                        ack?.onAck()
                        if (isSuccess) {
                            cb(res.formatString())
                        }
                    }
                })
        }
    }

    suspend fun setEventListener(
        cb: ((result: String?) -> Unit)?
    ): Result<Unit> {
        val results = HashMap<String, MutableList<ByteArray>>()
        return delegate.useService {
            it.setEventListener(
                when (cb != null) {
                true -> object : IEventInterface.Stub() {
                    override fun onEvent(
                        id: String, data: ByteArray?, isSuccess: Boolean, ack: IAckInterface?
                    ) {
                        if (results[id] == null) {
                            results[id] = mutableListOf()
                        }
                        results[id]?.add(data ?: byteArrayOf())
                        ack?.onAck()
                        if (isSuccess) {
                            cb(results[id]?.formatString())
                            results.remove(id)
                        }
                    }
                }

                false -> null
            })
        }
    }

    suspend fun updateNotificationParams(
        params: NotificationParams
    ): Result<Unit> {
        return delegate.useService {
            it.updateNotificationParams(params)
        }
    }

    suspend fun setCrashlytics(
        enable: Boolean
    ): Result<Unit> {
        return delegate.useService {
            it.setCrashlytics(enable)
        }
    }

    private suspend fun awaitIResultInterface(
        block: (IResultInterface) -> Unit
    ): Long = suspendCancellableCoroutine { continuation ->
        val callback = object : IResultInterface.Stub() {
            override fun onResult(time: Long) {
                if (continuation.isActive) {
                    continuation.resume(time)
                }
            }
        }

        try {
            block(callback)
        } catch (e: Exception) {
            if (continuation.isActive) {
                continuation.resumeWithException(e)
            }
        }
    }


    suspend fun startService(options: VpnOptions, runTime: Long): Long {
        return delegate.useService {
            awaitIResultInterface { callback ->
                it.startService(options, runTime, callback)
            }
        }.getOrNull() ?: 0L
    }

    suspend fun stopService(): Long {
        return delegate.useService {
            awaitIResultInterface { callback ->
                it.stopService(callback)
            }
        }.getOrNull() ?: 0L
    }

    suspend fun getRunTime(): Long {
        return delegate.useService {
            it.runTime
        }.getOrNull() ?: 0L
    }
}