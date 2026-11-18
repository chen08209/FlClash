package com.follow.clash.core

import com.google.gson.JsonParser
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test

class MitmTrustTest {
    private val setup = JsonParser.parseString("""{"selection":{"g":"p"},"options":{"testUrl":"t"}}""")
    private val answer = JsonParser.parseString("""{"certificate":{"pem":"PEM","fingerprint":"AA:BB"}}""")

    private fun trustedCa(trusts: (String) -> Boolean) =
        withTrustedCa(setup, answer, trusts).asJsonObject.getAsJsonObject("options").get("mitmTrustedCa").asString

    @Test
    fun `a CA the device trusts is named by its fingerprint and the rest of the params stay`() {
        val seen = mutableListOf<String>()
        val next = withTrustedCa(setup, answer) { pem -> seen.add(pem); true }.asJsonObject

        assertEquals(listOf("PEM"), seen)
        assertEquals("AA:BB", next.getAsJsonObject("options").get("mitmTrustedCa").asString)
        assertEquals("t", next.getAsJsonObject("options").get("testUrl").asString)
        assertEquals("p", next.getAsJsonObject("selection").get("g").asString)
        assertFalse(setup.asJsonObject.getAsJsonObject("options").has("mitmTrustedCa"))
    }

    @Test
    fun `a CA the device no longer trusts, or a check that fails, names none`() {
        assertEquals("", trustedCa { false })
        assertEquals("", trustedCa { error("no key store") })
    }

    @Test
    fun `a Core without a CA or without MITM keeps the params as they are`() {
        val none = JsonParser.parseString("""{"certificate":null}""")

        assertEquals(setup, withTrustedCa(setup, none) { true })
        assertEquals(setup, withTrustedCa(setup, null) { true })
    }

    @Test
    fun `params without options gain them`() {
        val bare = JsonParser.parseString("""{"selection":{}}""")

        val next = withTrustedCa(bare, answer) { true }.asJsonObject

        assertEquals("AA:BB", next.getAsJsonObject("options").get("mitmTrustedCa").asString)
    }
}
