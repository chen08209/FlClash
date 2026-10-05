package com.follow.clash.service.modules

import android.app.AppOpsManager
import android.app.Service
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.os.Build
import com.follow.clash.common.GlobalState
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

internal class SceneLinkageModule(
    private val service: Service,
    private val scope: CoroutineScope,
) : ServiceModule {

    private var pollJob: Job? = null

    override fun start() {
        if (pollJob != null) return
        pollJob = scope.launch {
            var lastCandidatePackage: String? = null
            var candidateStartTime = 0L

            while (isActive) {
                delay(1000)
                if (!hasUsageStatsPermission()) continue
                val fgPackage = getForegroundPackage() ?: continue
                val now = System.currentTimeMillis()

                if (lastCandidatePackage != fgPackage) {
                    lastCandidatePackage = fgPackage
                    candidateStartTime = now
                    continue
                }

                if (now - candidateStartTime >= 1500) {
                    // Validated foreground application residence
                }
            }
        }
    }

    override fun stop() {
        pollJob?.cancel()
        pollJob = null
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = service.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager ?: return false
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                service.packageName,
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                service.packageName,
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getForegroundPackage(): String? {
        val usm = service.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager ?: return null
        val time = System.currentTimeMillis()
        val stats = usm.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, time - 10000, time)
        if (stats.isNullOrEmpty()) return null
        var recentApp: UsageStats? = null
        for (usageStats in stats) {
            if (recentApp == null || usageStats.lastTimeUsed > recentApp.lastTimeUsed) {
                recentApp = usageStats
            }
        }
        return recentApp?.packageName
    }
}
