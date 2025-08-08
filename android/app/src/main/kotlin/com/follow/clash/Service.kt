package com.follow.clash

import android.app.Application
import android.content.ComponentName
import android.content.Context
import android.content.ServiceConnection
import android.os.IBinder
import com.follow.clash.common.intent
import com.follow.clash.service.ICallbackInterface
import com.follow.clash.service.IRemoteInterface
import com.follow.clash.service.RemoteService

class Service(private val context: Application) {

    var remote: IRemoteInterface? = null

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            remote = IRemoteInterface.Stub.asInterface(service)
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            remote = null
        }
    }

    fun invokeAction(
        data: String,
        cb: (result: String?) -> Unit
    ) {
        remote?.invokeAction(data, object : ICallbackInterface.Stub() {
            override fun onResult(result: String?) {
                cb(result)
            }
        })
    }

    fun bind() {
        context.bindService(
            RemoteService::class.intent,
            connection,
            Context.BIND_AUTO_CREATE
        )
    }

    fun unbind() {
        context.unbindService(connection)
    }
}