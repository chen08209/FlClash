package com.follow.clash.models

import com.follow.clash.common.AccessControlMode
import com.google.gson.Gson
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * `SharedState` is written by Flutter into `FlutterSharedPreferences` and read back here, so the
 * JSON spelling of every field is a cross-language contract rather than an implementation detail.
 */
class SharedStateTest {
    private val gson = Gson()

    @Test
    fun `setup params use the kebab-case spelling Flutter writes`() {
        val json = """{"test-url":"https://example.test/204","selected-map":{"GLOBAL":"auto"}}"""

        val params = gson.fromJson(json, SetupParams::class.java)

        assertEquals("https://example.test/204", params.testUrl)
        assertEquals(mapOf("GLOBAL" to "auto"), params.selectedMap)
    }

    @Test
    fun `setup params serialize back to the same spelling`() {
        val encoded = gson.toJson(
            SetupParams(testUrl = "https://example.test", selectedMap = emptyMap()),
        )

        assertTrue(encoded.contains("\"test-url\""))
        assertTrue(encoded.contains("\"selected-map\""))
        assertTrue(!encoded.contains("testUrl"))
        assertTrue(!encoded.contains("selectedMap"))
    }

    @Test
    fun `a full payload round-trips including nested vpn options`() {
        val json = """
            {
              "startTip": "Starting",
              "stopTip": "Stopping",
              "crashlytics": false,
              "currentProfileName": "Work",
              "stopText": "Halt",
              "onlyStatisticsProxy": true,
              "vpnOptions": {
                "enable": true,
                "port": 7890,
                "ipv6": false,
                "dnsHijacking": true,
                "accessControlProps": {
                  "enable": true,
                  "mode": "rejectSelected",
                  "acceptList": ["a.b"],
                  "rejectList": ["c.d"]
                },
                "allowBypass": false,
                "systemProxy": true,
                "bypassDomain": ["example.test"],
                "stack": "gvisor",
                "routeAddress": ["0.0.0.0/0"]
              },
              "setupParams": {
                "test-url": "https://example.test/204",
                "selected-map": {"GLOBAL": "auto"}
              }
            }
        """.trimIndent()

        val state = gson.fromJson(json, SharedState::class.java)

        assertEquals("Starting", state.startTip)
        assertEquals("Work", state.currentProfileName)
        assertEquals(false, state.crashlytics)
        assertEquals(true, state.onlyStatisticsProxy)
        assertEquals(7890, state.vpnOptions?.port)
        assertEquals("gvisor", state.vpnOptions?.stack)
        assertEquals(
            AccessControlMode.REJECT_SELECTED,
            state.vpnOptions?.accessControlProps?.mode,
        )
        assertEquals(listOf("0.0.0.0/0"), state.vpnOptions?.routeAddress)
        assertEquals("https://example.test/204", state.setupParams?.testUrl)
    }

    @Test
    fun `the constructed default keeps every fallback Flutter relies on`() {
        val defaults = SharedState()

        assertEquals("FlClash", defaults.currentProfileName)
        assertEquals("Stop", defaults.stopText)
        assertEquals(true, defaults.crashlytics)
        assertEquals(false, defaults.onlyStatisticsProxy)
        assertNull(defaults.vpnOptions)
        assertNull(defaults.setupParams)
    }

    @Test
    fun `an empty document still yields the declared defaults`() {
        // Every SharedState parameter has a default, so Kotlin emits a no-arg constructor
        // that Gson uses instead of its Unsafe fallback. Losing a default on any one
        // parameter would silently turn the absent fields below into nulls.
        val state = gson.fromJson("{}", SharedState::class.java)

        assertNotNull(state)
        assertEquals("Starting VPN...", state.startTip)
        assertEquals("FlClash", state.currentProfileName)
        assertEquals(true, state.crashlytics)
        assertNull(state.vpnOptions)
        assertNull(state.setupParams)
    }

    @Test
    fun `a partial document keeps defaults for the fields it omits`() {
        val state = gson.fromJson("""{"currentProfileName":"Work"}""", SharedState::class.java)

        assertEquals("Work", state.currentProfileName)
        assertEquals("Stop", state.stopText)
        assertEquals("Stopping VPN...", state.stopTip)
    }

    @Test
    fun `setup params have no defaults so absent fields decode as null`() {
        // SetupParams declares no default values, so Gson builds it through Unsafe and
        // leaves missing fields null despite the non-nullable Kotlin types.
        val params = gson.fromJson("{}", SetupParams::class.java)

        @Suppress("SENSELESS_COMPARISON")
        assertTrue(params.testUrl == null)

        @Suppress("SENSELESS_COMPARISON")
        assertTrue(params.selectedMap == null)
    }

    @Test
    fun `a null json document decodes to null so the caller can fall back`() {
        assertNull(gson.fromJson("null", SharedState::class.java))
        assertNull(gson.fromJson(null as String?, SharedState::class.java))
    }

    @Test
    fun `an access control payload without a matching mode decodes to null`() {
        val json = """
            {"vpnOptions":{"accessControlProps":{"mode":"unknownMode"}}}
        """.trimIndent()

        val state = gson.fromJson(json, SharedState::class.java)

        assertNull(state.vpnOptions?.accessControlProps?.mode)
    }
}
