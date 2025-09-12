package com.follow.clash

import com.follow.clash.common.ServiceDelegate
import com.follow.clash.common.formatString
import com.follow.clash.common.intent
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
                    override fun onResult(result: ByteArray?, isSuccess: Boolean) {
                        res.add(result ?: byteArrayOf())
                        if (isSuccess) {
                            cb(res.formatString())
                        }
                    }
                })
        }
    }

    suspend fun setEventListener(
        cb: (result: String?) -> Unit
    ): Result<Unit> {
        val results = HashMap<String, MutableList<ByteArray>>()
        return delegate.useService {
            it.setEventListener(object : IEventInterface.Stub() {
                override fun onEvent(
                    id: String, data: ByteArray?, isSuccess: Boolean
                ) {
                    if (results[id] == null) {
                        results[id] = mutableListOf()
                    }
                    results[id]?.add(data ?: byteArrayOf())
                    if (isSuccess) {
                        cb(results[id]?.formatString())
                        results.remove(id)
                    }
                }
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
    ): Unit = suspendCancellableCoroutine { continuation ->
        val callback = object : IResultInterface.Stub() {
            override fun onResult() {
                if (continuation.isActive) {
                    continuation.resume(Unit)
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


    suspend fun startService(options: VpnOptions, inApp: Boolean) {
        delegate.useService {
            awaitIResultInterface { callback ->
                it.startService(options, inApp, callback)
            }
        }
    }

    suspend fun stopService() {
        delegate.useService {
            awaitIResultInterface { callback ->
                it.stopService(callback)
            }
        }
    }
}