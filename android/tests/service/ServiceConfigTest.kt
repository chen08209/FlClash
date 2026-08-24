package com.follow.clash.service

import com.follow.clash.common.AccessControlMode
import com.follow.clash.service.models.AccessControlProps
import com.follow.clash.service.models.NotificationParams
import com.follow.clash.service.models.VpnOptions
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertSame
import org.junit.Test

private fun vpnOptions(port: Int) = VpnOptions(
    enable = true,
    port = port,
    ipv6 = false,
    dnsHijacking = true,
    accessControlProps = AccessControlProps(
        enable = true,
        mode = AccessControlMode.REJECT_SELECTED,
        acceptList = listOf("com.example.accepted"),
        rejectList = listOf("com.example.rejected"),
    ),
    allowBypass = true,
    systemProxy = false,
    bypassDomain = listOf("example.test"),
    stack = "system",
    routeAddress = listOf("0.0.0.0/0"),
)

class ServiceConfigTest {
    @Test
    fun `notification params default to the app name and stop label`() {
        val defaults = NotificationParams()

        assertEquals("FlClash", defaults.title)
        assertEquals("STOP", defaults.stopText)
        assertEquals(false, defaults.onlyStatisticsProxy)
    }

    @Test
    fun `updateVpnOptions publishes the latest options`() {
        ServiceConfig.updateVpnOptions(vpnOptions(7890))
        assertEquals(7890, ServiceConfig.vpnOptions?.port)

        val latest = vpnOptions(7891)
        ServiceConfig.updateVpnOptions(latest)

        assertSame(latest, ServiceConfig.vpnOptions)
    }

    @Test
    fun `updateNotificationParams emits through the state flow`() = runTest {
        val params = NotificationParams(
            title = "Profile",
            stopText = "Halt",
            onlyStatisticsProxy = true,
        )

        ServiceConfig.updateNotificationParams(params)

        assertSame(params, ServiceConfig.notificationParams.value)
    }

    @Test
    fun `notification params state flow keeps the newest value`() = runTest {
        val first = NotificationParams(title = "first")
        val second = NotificationParams(title = "second")

        ServiceConfig.updateNotificationParams(first)
        ServiceConfig.updateNotificationParams(second)

        assertSame(second, ServiceConfig.notificationParams.value)
        assertNotSame(first, ServiceConfig.notificationParams.value)
    }
}
