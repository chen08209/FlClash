package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.follow.clash.common.GlobalState
import com.follow.clash.common.ServiceDelegate
import com.follow.clash.common.chunkedForAidl
import com.follow.clash.common.intent
import com.follow.clash.core.Core
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.util.UUID

class RemoteService : Service(),
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {
    private var delegate: ServiceDelegate<IBaseService>? = null
    private var intent: Intent? = null

    private fun handleStopService(result: IResultInterface) {
        launch {
            delegate?.useService { service ->
                service.stop()
                delegate?.unbind()
            }
            result.onResult()
        }
    }

    private fun handleServiceDisconnected(message: String) {
        intent = null
        delegate = null
    }

    private fun handleStartService(result: IResultInterface) {
        launch {
            val nextIntent = when (State.options?.enable == true) {
                true -> VpnService::class.intent
                false -> CommonService::class.intent
            }
            if (intent != nextIntent) {
                delegate?.unbind()
                delegate = ServiceDelegate(nextIntent, ::handleServiceDisconnected) { binder ->
                    when (binder) {
                        is VpnService.LocalBinder -> binder.getService()
                        is CommonService.LocalBinder -> binder.getService()
                        else -> throw IllegalArgumentException("Invalid binder type")
                    }
                }
                intent = nextIntent
                delegate?.bind()
            }
            delegate?.useService { service ->
                service.start()
            }
            result.onResult()
        }
    }

    private val binder = object : IRemoteInterface.Stub() {
        override fun invokeAction(data: String, callback: ICallbackInterface) {
            Core.invokeAction(data) {
                runCatching {
                    val chunks = it?.chunkedForAidl() ?: listOf()
                    val totalSize = chunks.size
                    chunks.forEachIndexed { index, chunk ->
                        callback.onResult(chunk, totalSize - 1 == index)
                    }
                }
            }
        }

        override fun updateNotificationParams(params: NotificationParams?) {
            State.notificationParamsFlow.tryEmit(params)
        }

        override fun startService(
            options: VpnOptions, inApp: Boolean, result: IResultInterface
        ) {
            State.options = options
            State.inApp = inApp
            handleStartService(result)
        }

        override fun stopService(result: IResultInterface) {
            handleStopService(result)
        }

        override fun setEventListener(event: IEventInterface) {
            Core.setMessageCallback {
                runCatching {
                    val id = UUID.randomUUID().toString()
                    val chunks = it?.chunkedForAidl() ?: listOf()
                    val totalSize = chunks.size
                    chunks.forEachIndexed { index, chunk ->
                        event.onEvent(id, chunk, totalSize - 1 == index)
                    }
                }
            }
        }

        override fun setCrashlytics(enable: Boolean) {
            GlobalState.setCrashlytics(enable)
        }
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }
}