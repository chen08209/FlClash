package com.follow.clash.service

import android.net.TrafficStats
import android.os.Process
import android.os.SystemClock
import com.follow.clash.core.Core
import com.follow.clash.service.models.Traffic
import com.follow.clash.service.models.getSpeedTrafficText
import com.follow.clash.service.models.speedText

// The Core rates each second on its own ticker, so moved bytes can show a second late.
internal const val QUIET_MILLIS = 2_000L

internal val idleSpeedText = Traffic(up = 0, down = 0).speedText

internal class SpeedTextReader(
    private val uidBytes: () -> Long = ::ownUidBytes,
    private val readText: (Boolean) -> String = Core::getSpeedTrafficText,
    private val clock: () -> Long = SystemClock::elapsedRealtime,
) {
    private var bytes = Long.MIN_VALUE
    private var movedAt = 0L
    private var text: String? = null

    fun read(onlyStatisticsProxy: Boolean): String {
        val now = clock()
        val current = uidBytes()
        if (current == TrafficStats.UNSUPPORTED.toLong() || current != bytes) {
            bytes = current
            movedAt = now
        }
        val shown = text
        if (shown == idleSpeedText && now - movedAt >= QUIET_MILLIS) return shown
        return readText(onlyStatisticsProxy).also { text = it }
    }
}

private fun ownUidBytes(): Long {
    val uid = Process.myUid()
    val rx = TrafficStats.getUidRxBytes(uid)
    val tx = TrafficStats.getUidTxBytes(uid)
    if (rx == TrafficStats.UNSUPPORTED.toLong() || tx == TrafficStats.UNSUPPORTED.toLong()) {
        return TrafficStats.UNSUPPORTED.toLong()
    }
    return rx + tx
}
