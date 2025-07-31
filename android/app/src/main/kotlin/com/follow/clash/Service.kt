package com.follow.clash

import com.follow.clash.common.ServiceDelegate
import com.follow.clash.common.intent
import com.follow.clash.service.ICallbackInterface
import com.follow.clash.service.IMessageInterface
import com.follow.clash.service.IRemoteInterface
import com.follow.clash.service.RemoteService
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions

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

    suspend fun invokeAction(
        data: String, cb: (result: ByteArray?, isSuccess: Boolean) -> Unit
    ): Result<Unit> {
        return delegate.useService {
            it.invokeAction(data, object : ICallbackInterface.Stub() {
                override fun onResult(result: ByteArray?, isSuccess: Boolean) {
                    cb(result, isSuccess)
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

    suspend fun setMessageCallback(
        cb: (result: String?) -> Unit
    ): Result<Unit> {
        return delegate.useService {
            it.setMessageCallback(object : IMessageInterface.Stub() {
                override fun onResult(result: String?) {
                    cb(result)
                }
            })
        }
    }

    suspend fun startService(options: VpnOptions, inApp: Boolean) {
        delegate.useService { it.startService(options, inApp) }
    }

    suspend fun stopService() {
        delegate.useService { it.stopService() }
    }
}