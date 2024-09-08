package com.follow.clash.models

import android.net.NetworkCapabilities
import android.os.Build

val TRANSPORT_PRIORITY = sequence {
    yield(NetworkCapabilities.TRANSPORT_CELLULAR)

    if (Build.VERSION.SDK_INT >= 27) {
        yield(NetworkCapabilities.TRANSPORT_LOWPAN)
    }

    yield(NetworkCapabilities.TRANSPORT_BLUETOOTH)

    if (Build.VERSION.SDK_INT >= 26) {
        yield(NetworkCapabilities.TRANSPORT_WIFI_AWARE)
    }

    yield(NetworkCapabilities.TRANSPORT_WIFI)

    if (Build.VERSION.SDK_INT >= 31) {
        yield(NetworkCapabilities.TRANSPORT_USB)
    }

    yield(NetworkCapabilities.TRANSPORT_ETHERNET)
}.toList()