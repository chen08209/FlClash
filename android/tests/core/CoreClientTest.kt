package com.follow.clash.core

import com.google.gson.JsonObject
import com.google.gson.JsonParser
import java.util.concurrent.CopyOnWriteArrayList
import java.util.concurrent.ExecutionException
import java.util.concurrent.TimeUnit
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test

private const val RESULT = """"result":{}"""
private const val OPENED = """"result":{"sub":7,"snapshot":{}}"""

private class FakeCore(
    private val answer: (method: String, params: JsonObject?) -> String? = { _, _ -> RESULT },
) : FrameTransport {
    val sent = CopyOnWriteArrayList<JsonObject>()
    val closed = CopyOnWriteArrayList<Long>()
    var opened = 0
    var refuseOpen = false
    var refuseSend = false
    var loseAfterAnswering: String? = null
    val delivering: ThreadLocal<Boolean> = ThreadLocal.withInitial { false }
    private var receiver: FrameReceiver? = null

    override fun open(receiver: FrameReceiver): Long {
        if (refuseOpen) return 0
        this.receiver = receiver
        opened++
        return opened.toLong()
    }

    override fun send(
        session: Long,
        frame: ByteArray,
    ): Boolean {
        if (refuseSend) return false
        val message = JsonParser.parseString(String(frame)).asJsonObject
        sent.add(message)
        val id = message.get("id") ?: return true
        val method = message.get("method").asString
        val tail = if (method == "core.hello") RESULT else answer(method, message.getAsJsonObject("params"))
        if (tail != null) push("""{"jsonrpc":"2.0","id":${id.asLong},$tail}""")
        return method != loseAfterAnswering
    }

    override fun close(session: Long) {
        closed.add(session)
    }

    fun push(json: String) {
        delivering.set(true)
        try {
            receiver!!.onFrame(json.toByteArray())
        } finally {
            delivering.set(false)
        }
    }

    fun methods() = sent.map { it.get("method").asString }
}

class CoreClientTest {
    @Test
    fun `a session greets before the first request and keeps the answer`() {
        val core = FakeCore { _, _ -> """"result":{"x":1}""" }
        val client = CoreClient(core)

        val answer = client.call("core.releaseMemory")!!.asJsonObject

        assertEquals(listOf("core.hello", "core.releaseMemory"), core.methods())
        assertEquals(1, answer.get("x").asInt)
        val greeting = core.sent.first().getAsJsonObject("params")
        assertEquals(1, greeting.getAsJsonObject("protocol").get("max").asInt)
    }

    @Test
    fun `later calls reuse the session`() {
        val core = FakeCore()
        val client = CoreClient(core)

        client.call("a")
        client.call("b")

        assertEquals(1, core.opened)
        assertEquals(listOf("core.hello", "a", "b"), core.methods())
    }

    @Test
    fun `an error answer carries its kind and the first issue of a rejected config`() {
        val core =
            FakeCore { _, _ ->
                """"error":{"code":-32010,"message":"config rejected","data":{"kind":"rejected","issues":[{"message":"bad proxy"}]}}"""
            }
        val client = CoreClient(core)

        val error = assertThrows(CoreCallException::class.java) { client.call("config.apply") }

        assertEquals("rejected", error.kind)
        assertEquals("bad proxy", error.message)
    }

    @Test
    fun `a core that is not up fails the call without sending`() {
        val core = FakeCore().apply { refuseOpen = true }

        val error = assertThrows(CoreCallException::class.java) { CoreClient(core).call("a") }

        assertEquals("unavailable", error.kind)
        assertTrue(core.sent.isEmpty())
    }

    @Test
    fun `a call that is never answered times out`() {
        val core = FakeCore { _, _ -> null }

        val error =
            assertThrows(CoreCallException::class.java) {
                CoreClient(core).call("a", timeoutMillis = 50)
            }

        assertEquals("timeout", error.kind)
    }

    @Test
    fun `an async call that is never answered fails once its time is up`() {
        val core = FakeCore { _, _ -> null }
        val client = CoreClient(core, asyncTimeoutMillis = 50)

        val error =
            assertThrows(ExecutionException::class.java) {
                client.callAsync("a").get(5, TimeUnit.SECONDS)
            }

        assertEquals("timeout", (error.cause as CoreCallException).kind)
    }

    @Test
    fun `a quick setup checks the CA off the thread that delivers the Core's answers`() {
        val core = FakeCore { method, _ -> if (method == "mitm.certificate") null else RESULT }
        var checkedWhileDelivering: Boolean? = null

        val setup =
            CoreClient(core).quickSetup(JsonObject(), JsonParser.parseString("""{"options":{}}""")) { pem ->
                checkedWhileDelivering = core.delivering.get()
                pem == "P"
            }
        val certificate = core.sent.single { it.get("method").asString == "mitm.certificate" }.get("id").asLong
        core.push("""{"jsonrpc":"2.0","id":$certificate,"result":{"certificate":{"pem":"P","fingerprint":"F"}}}""")
        setup.get(5, TimeUnit.SECONDS)

        assertEquals(false, checkedWhileDelivering)
        val apply = core.sent.single { it.get("method").asString == "config.apply" }
        assertEquals("F", apply.getAsJsonObject("params").getAsJsonObject("options").get("mitmTrustedCa").asString)
        assertEquals("engine.start", core.methods().last())
    }

    @Test
    fun `a lost session fails what waits and the next call opens another`() {
        val core = FakeCore()
        val client = CoreClient(core)
        client.call("a")

        core.refuseSend = true
        assertThrows(CoreCallException::class.java) { client.call("b") }
        core.refuseSend = false
        client.call("c")

        assertEquals(2, core.opened)
        assertEquals(listOf(1L), core.closed)
        assertEquals("c", core.methods().last())
    }

    @Test
    fun `a watch hands out each event of a batch and gives credit back`() {
        val core = FakeCore { method, _ -> if (method == "traffic.watch") OPENED else RESULT }
        val client = CoreClient(core)
        val seen = mutableListOf<Int>()

        client.watch("traffic.watch", mapOf("intervalMs" to 1000)) { seen.add(it.asJsonObject.get("up").asInt) }
        core.push("""{"jsonrpc":"2.0","method":"${'$'}/event","params":{"sub":7,"seq":1,"data":[{"up":1},{"up":2}]}}""")

        assertEquals(listOf(1, 2), seen)
        val request = core.sent.first { it.get("method").asString == "traffic.watch" }
        assertEquals(4, request.getAsJsonObject("params").get("credit").asInt)
        val credit = core.sent.last()
        assertEquals("${'$'}/credit", credit.get("method").asString)
        assertEquals(7, credit.getAsJsonObject("params").get("sub").asInt)
    }

    @Test
    fun `a listener the Core refuses to start fails the start`() {
        val core =
            FakeCore { method, _ ->
                when (method) {
                    "engine.state" -> """"result":{"sub":7,"snapshot":{"state":"stopped"}}"""
                    "engine.start" -> """"error":{"code":-32000,"message":"address in use","data":{"kind":"internal"}}"""
                    else -> RESULT
                }
            }

        val started = CoreClient(core).startEngine()

        assertTrue(started.isFailure)
        assertEquals("address in use", started.exceptionOrNull()!!.message)
    }

    @Test
    fun `a traffic watch asks for changes only and starts from the snapshot`() {
        val core =
            FakeCore { method, _ ->
                if (method == "traffic.watch") """"result":{"sub":7,"snapshot":{"up":5,"down":6}}""" else RESULT
            }
        val seen = mutableListOf<Pair<Long, Long>>()

        CoreClient(core).watchTraffic(onlyProxy = true, onLost = {}) { up, down -> seen.add(up to down) }
        core.push("""{"jsonrpc":"2.0","method":"${'$'}/event","params":{"sub":7,"seq":1,"data":[{"up":0,"down":0}]}}""")

        assertEquals(listOf(5L to 6L, 0L to 0L), seen)
        val params = core.sent.first { it.get("method").asString == "traffic.watch" }.getAsJsonObject("params")
        assertTrue(params.get("changesOnly").asBoolean)
        assertTrue(params.get("onlyProxy").asBoolean)
        assertEquals(1000, params.get("intervalMs").asInt)
    }

    @Test
    fun `a snapshot cancels the subscription it opened`() {
        val core = FakeCore { _, _ -> OPENED }
        val client = CoreClient(core)

        val opened = client.snapshot("engine.state", emptyMap())

        assertTrue(opened!!.has("snapshot"))
        val request = core.sent.first { it.get("method").asString == "engine.state" }
        assertEquals(0, request.getAsJsonObject("params").get("credit").asInt)
        val cancel = core.sent.last()
        assertEquals("${'$'}/cancel", cancel.get("method").asString)
        assertEquals(request.get("id").asLong, cancel.getAsJsonObject("params").get("id").asLong)
    }

    @Test
    fun `a watch reports a session lost under it once and not after a close`() {
        val core = FakeCore { _, _ -> OPENED }
        val client = CoreClient(core)
        var lost = 0
        val kept = client.watch("traffic.watch", emptyMap(), { lost++ }) {}
        val closed = client.watch("traffic.watch", emptyMap(), { lost += 10 }) {}
        closed.close()

        core.refuseSend = true
        assertThrows(CoreCallException::class.java) { client.call("b") }

        assertEquals(1, lost)
        kept.close()
        assertEquals(1, lost)
    }

    @Test
    fun `a watch reports a session lost right after its answer`() {
        val core = FakeCore { _, _ -> OPENED }
        core.loseAfterAnswering = "traffic.watch"
        var lost = 0

        CoreClient(core).watch("traffic.watch", emptyMap(), { lost++ }) {}

        assertEquals(1, lost)
    }

    @Test
    fun `a resync ends a watch as lost and drops what follows`() {
        val core = FakeCore { _, _ -> OPENED }
        val client = CoreClient(core)
        var lost = 0
        val seen = mutableListOf<Int>()
        client.watch("traffic.watch", emptyMap(), { lost++ }) { seen.add(1) }

        core.push("""{"jsonrpc":"2.0","method":"${'$'}/event","params":{"sub":7,"seq":1,"resync":true}}""")
        core.push("""{"jsonrpc":"2.0","method":"${'$'}/event","params":{"sub":7,"seq":2,"data":[{}]}}""")

        assertEquals(1, lost)
        assertTrue(seen.isEmpty())
        assertEquals(1, core.opened)
    }

    @Test
    fun `closing a watch cancels its request and drops later events`() {
        val core = FakeCore { _, _ -> OPENED }
        val client = CoreClient(core)
        val seen = mutableListOf<Int>()
        val watch = client.watch("traffic.watch", emptyMap()) { seen.add(1) }
        val id = core.sent.last().get("id").asLong

        watch.close()
        watch.close()
        core.push("""{"jsonrpc":"2.0","method":"${'$'}/event","params":{"sub":7,"seq":1,"data":[{}]}}""")

        assertTrue(seen.isEmpty())
        val cancels = core.sent.filter { it.get("method")?.asString == "${'$'}/cancel" }
        assertEquals(1, cancels.size)
        assertEquals(id, cancels.single().getAsJsonObject("params").get("id").asLong)
    }

    @Test
    fun `an unreadable message is skipped and the session stays`() {
        val core = FakeCore()
        val client = CoreClient(core)
        client.call("a")

        core.push("not json")
        client.call("b")

        assertEquals(1, core.opened)
    }

    @Test
    fun `closing the client ends the session`() {
        val core = FakeCore()
        val client = CoreClient(core)
        client.call("a")

        client.close()

        assertEquals(listOf(1L), core.closed)
    }
}

class TunOptionsTest {
    private val options =
        TunOptions(
            mtu = 9000,
            address = listOf("198.18.0.1/30"),
            dns = listOf("198.18.0.2"),
            congestionController = "bbr",
        )

    @Test
    fun `names the adopted descriptor and carries the options`() {
        val params = options.params(handle = 5)

        assertEquals(mapOf("kind" to "inherited", "handle" to 5L), params["source"])
        assertEquals(9000, params["mtu"])
        assertEquals("bbr", params["congestionController"])
        assertEquals(listOf("198.18.0.1/30"), params["address"])
    }

    @Test
    fun `leaves the congestion controller out when none is chosen`() {
        assertFalse(options.copy(congestionController = null).params(1).containsKey("congestionController"))
        assertFalse(options.copy(congestionController = "").params(1).containsKey("congestionController"))
    }
}
