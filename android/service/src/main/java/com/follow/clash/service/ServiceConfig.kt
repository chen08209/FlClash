package com.follow.clash.service

import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow

object ServiceConfig {
    @Volatile
    private var currentVpnOptions: VpnOptions? = null
    private val mutableNotificationParams = MutableStateFlow(NotificationParams())
    private val mutableMitm = MutableStateFlow(false)

    val vpnOptions: VpnOptions?
        get() = currentVpnOptions

    val notificationParams = mutableNotificationParams.asStateFlow()

    val mitm = mutableMitm.asStateFlow()

    fun updateVpnOptions(options: VpnOptions) {
        currentVpnOptions = options
    }

    fun updateNotificationParams(params: NotificationParams) {
        mutableNotificationParams.value = params
    }

    fun updateMitm(enabled: Boolean) {
        mutableMitm.value = enabled
    }
}
