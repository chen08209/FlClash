package com.follow.clash.core

import android.util.Log
import com.google.gson.JsonElement
import com.google.gson.JsonParser
import java.net.InetAddress
import java.net.InetSocketAddress
import java.net.URI
import java.util.concurrent.CompletableFuture
import java.util.concurrent.atomic.AtomicBoolean

data class TunOptions(
    val mtu: Int,
    val address: List<String>,
    val dns: List<String>,
    val congestionController: String?,
) {
    fun params(handle: Long): Map<String, Any?> =
        buildMap {
            put("source", mapOf("kind" to "inherited", "handle" to handle))
            put("mtu", mtu)
            put("address", address)
            put("dns", dns)
            congestionController?.takeIf { it.isNotEmpty() }?.let { put("congestionController", it) }
        }
}

object Core {
    private val client by lazy {
        CoreClient(NativeCore, log = { message -> Log.w(TAG, message) })
    }

    private val releasing = AtomicBoolean()
    private val bridgeLock = Any()
    private var bridgeSession = 0L

    fun load() = NativeCore.load()

    fun forceGC() {
        if (!releasing.compareAndSet(false, true)) return
        client.callAsync("core.releaseMemory").whenComplete { _, _ -> releasing.set(false) }
    }

    fun setMitmPressure(level: Int) = client.send("core.setPressure", mapOf("level" to level))

    fun updateDns(servers: List<String>) = client.send("network.update", mapOf("dnsServers" to servers))

    fun resetNetwork() = client.send("network.update", mapOf("interfaceChanged" to true))

    // The descriptor is the Core's from the adoption on, whatever the start does.
    fun startTun(
        fd: Int,
        protect: (Int) -> Boolean,
        resolveUid: (protocol: Int, source: InetSocketAddress, target: InetSocketAddress) -> Int,
        resolvePackage: (uid: Int) -> String,
        options: TunOptions,
    ) {
        NativeCore.setPlatformHost(Host(protect, resolveUid, resolvePackage))
        try {
            val handle = NativeCore.adoptFd(fd)
            check(handle != 0L) { "the core is not running" }
            client.call("tun.start", options.params(handle))
        } catch (error: Exception) {
            NativeCore.setPlatformHost(null)
            throw error
        }
    }

    fun stopTun() {
        try {
            client.call("tun.stop")
        } catch (error: CoreCallException) {
            Log.w(TAG, "tun.stop failed: ${error.message}")
        } finally {
            NativeCore.setPlatformHost(null)
        }
    }

    fun startListener(): Result<Unit> = client.startEngine()

    fun stopListener() {
        try {
            if (client.engineRunning()) client.call("engine.stop")
        } catch (error: CoreCallException) {
            Log.w(TAG, "engine.stop failed: ${error.message}")
        }
    }

    fun watchTraffic(
        onlyProxy: Boolean,
        onLost: () -> Unit,
        onTraffic: (up: Long, down: Long) -> Unit,
    ): AutoCloseable = client.watchTraffic(onlyProxy, onLost, onTraffic)

    fun quickSetup(
        initParams: String,
        setupParams: String,
        trustsCa: (String) -> Boolean,
        callback: (String) -> Unit,
    ) {
        val steps: CompletableFuture<JsonElement?> =
            try {
                client.quickSetup(JsonParser.parseString(initParams), JsonParser.parseString(setupParams), trustsCa)
            } catch (error: Exception) {
                CompletableFuture.failedFuture(error)
            }
        steps.whenComplete { _, error ->
            callback(error?.let { (it.cause ?: it).message.orEmpty().ifEmpty { "unknown error" } }.orEmpty())
        }
    }

    fun updateEventListener(callback: ((ByteArray) -> Unit)?) {
        synchronized(bridgeLock) {
            val previous = bridgeSession
            bridgeSession = 0L
            if (previous != 0L) NativeCore.close(previous)
            if (callback != null) {
                bridgeSession = NativeCore.open { frame ->
                    callback(frame)
                    true
                }
            }
        }
    }

    fun sendFrame(data: ByteArray) {
        val session = synchronized(bridgeLock) { bridgeSession }
        check(session != 0L && NativeCore.send(session, data)) { "no session to take the frame" }
    }

    private class Host(
        private val protect: (Int) -> Boolean,
        private val resolveUid: (Int, InetSocketAddress, InetSocketAddress) -> Int,
        private val resolvePackage: (Int) -> String,
    ) : PlatformHost {
        override fun protect(fd: Int): Boolean = runCatching { protect.invoke(fd) }.getOrDefault(false)

        override fun resolveUid(
            protocol: Int,
            source: String,
            target: String,
        ): Int =
            runCatching {
                resolveUid.invoke(protocol, socketAddress(source), socketAddress(target))
            }.getOrDefault(-1)

        override fun resolvePackage(uid: Int): String = runCatching { resolvePackage.invoke(uid) }.getOrDefault("")
    }

    private fun socketAddress(address: String): InetSocketAddress {
        val uri = URI("tcp://$address")
        val host = requireNotNull(uri.host) { "Missing host in address: $address" }
        require(uri.port >= 0) { "Missing port in address: $address" }
        return InetSocketAddress(InetAddress.getByName(host), uri.port)
    }

    private const val TAG = "FlClash"
}

// The certificate's answer completes on the Core's frame thread, and the trust check reads the device's key store.
internal fun CoreClient.quickSetup(
    init: JsonElement,
    setup: JsonElement,
    trustsCa: (String) -> Boolean,
): CompletableFuture<JsonElement?> =
    callAsync("core.init", init)
        .thenCompose { callAsync("mitm.certificate").exceptionally { null } }
        .thenApplyAsync { answer -> withTrustedCa(setup, answer, trustsCa) }
        .thenCompose { params -> callAsync("config.apply", params) }
        .thenCompose { callAsync("engine.start") }
