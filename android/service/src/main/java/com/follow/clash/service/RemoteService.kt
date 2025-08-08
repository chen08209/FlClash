package com.follow.clash.service

import android.app.Service
import android.content.Intent
import android.os.IBinder
import com.follow.clash.core.Core
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions

class RemoteService : Service() {
    private val binder: IRemoteInterface.Stub = object : IRemoteInterface.Stub() {
        override fun invokeAction(data: String?, callback: ICallbackInterface?) {
            if (data == null) {
                return
            }
            Core.invokeAction(data) {
                callback?.onResult(it)
            }
        }

        override fun syncVpnOptions(options: VpnOptions?) {
            State.options = options
        }

        override fun updateNotificationParams(params: NotificationParams?) {
            State.notificationParamsFlow.tryEmit(params)
        }
    }

    override fun onBind(intent: Intent?): IBinder {
        return binder
    }
}