package com.follow.clash.service

import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import kotlinx.coroutines.flow.MutableStateFlow

object State {
    var options: VpnOptions? = null
    var inApp: Boolean = false
    var notificationParamsFlow: MutableStateFlow<NotificationParams?> = MutableStateFlow(
        NotificationParams()
    )
}