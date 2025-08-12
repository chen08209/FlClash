package com.follow.clash.service.models

import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class NotificationParams(
    val title: String = "FlClash",
    val contentText: String? = null,
    val subText: String? = null,
    val stopText: String = "STOP",
) : Parcelable