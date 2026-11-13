package com.follow.clash.plugins

import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Handler
import android.os.Looper
import com.follow.clash.common.GlobalState

// `activeNetwork` can name the previous default for seconds after the callbacks moved on.
class DefaultNetworkWatcher(
    private val connectivity: ConnectivityManager,
    private val onChanged: (Map<String, Boolean>) -> Unit,
) {
    private val handler = Handler(Looper.getMainLooper())
    private val report = Runnable { onChanged(state()) }
    private var registered = false

    @Volatile
    private var current: Pair<Network, NetworkCapabilities>? = null

    private val callback = object : ConnectivityManager.NetworkCallback() {
        override fun onAvailable(network: Network) = schedule()

        override fun onCapabilitiesChanged(network: Network, capabilities: NetworkCapabilities) {
            current = network to capabilities
            schedule()
        }

        override fun onLost(network: Network) {
            if (current?.first == network) current = null
            schedule()
        }
    }

    fun start() {
        if (registered) return
        current = connectivity.activeNetwork?.let { network ->
            connectivity.getNetworkCapabilities(network)?.let { network to it }
        }
        runCatching { connectivity.registerDefaultNetworkCallback(callback) }
            .onSuccess { registered = true }
            .onFailure { error -> GlobalState.log("Unable to watch the default network: $error") }
        handler.post(report)
    }

    fun stop() {
        handler.removeCallbacks(report)
        if (!registered) return
        runCatching { connectivity.unregisterNetworkCallback(callback) }
        registered = false
    }

    private fun schedule() {
        handler.removeCallbacks(report)
        handler.postDelayed(report, SETTLE_MILLIS)
    }

    private fun state(): Map<String, Boolean> {
        val capabilities = current?.second
        fun has(transport: Int) = capabilities?.hasTransport(transport) == true
        return mapOf(
            "wifi" to (has(NetworkCapabilities.TRANSPORT_WIFI) ||
                has(NetworkCapabilities.TRANSPORT_WIFI_AWARE)),
            "vpn" to has(NetworkCapabilities.TRANSPORT_VPN),
        )
    }
}

private const val SETTLE_MILLIS = 500L
