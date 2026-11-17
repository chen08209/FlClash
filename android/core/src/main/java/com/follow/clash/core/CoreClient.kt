package com.follow.clash.core

import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ExecutionException
import java.util.concurrent.ScheduledThreadPoolExecutor
import java.util.concurrent.TimeUnit
import java.util.concurrent.TimeoutException
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicLong

/** An error answer of the Core; [kind] is the stable `error.data.kind`, [message] is for people only. */
class CoreCallException(
    val kind: String?,
    message: String,
    cause: Throwable? = null,
) : Exception(message, cause)

private const val INITIAL_CREDIT = 4
private const val PROTOCOL_VERSION = 1

private val timeouts =
    ScheduledThreadPoolExecutor(1) { task -> Thread(task, "core-client-timeout").apply { isDaemon = true } }
        .apply { removeOnCancelPolicy = true }

private class Pending(
    val result: CompletableFuture<JsonElement?>,
    val onResult: ((JsonObject) -> Unit)? = null,
)

private class Call(
    val id: Long,
    val result: CompletableFuture<JsonElement?>,
)

private class Watch(
    val callId: Long,
    val onBatch: (JsonElement) -> Unit,
)

/**
 * A JSON-RPC session of the service's own with the Core, opened on first use and kept for
 * the process: the VPN service reaches the Core through it with no Flutter engine alive.
 * Callbacks run on the Core's threads and must not block.
 */
class CoreClient(
    private val transport: FrameTransport,
    private val clientName: String = "flclash-service",
    private val clientVersion: String = "",
    private val timeoutMillis: Long = 30_000,
    private val asyncTimeoutMillis: Long = 180_000,
    private val log: (String) -> Unit = {},
) {
    private val gson = Gson()
    private val lock = Any()
    private val ids = AtomicLong()
    private val pending = ConcurrentHashMap<Long, Pending>()
    private val watches = ConcurrentHashMap<Long, Watch>()
    private val endings = ConcurrentHashMap<Long, () -> Unit>()

    @Volatile
    private var session = 0L

    /** A call whose answer arrives when the Core has done it; it fails with [CoreCallException]. */
    fun callAsync(
        method: String,
        params: Any? = null,
    ): CompletableFuture<JsonElement?> {
        val result = begin(method, params).result
        val timeout =
            timeouts.schedule(
                { result.completeExceptionally(CoreCallException("timeout", "$method did not answer in $asyncTimeoutMillis ms")) },
                asyncTimeoutMillis,
                TimeUnit.MILLISECONDS,
            )
        result.whenComplete { _, _ -> timeout.cancel(false) }
        return result
    }

    fun call(
        method: String,
        params: Any? = null,
        timeoutMillis: Long = this.timeoutMillis,
    ): JsonElement? = await(begin(method, params).result, method, timeoutMillis)

    /** Opens a stream method for its snapshot alone and unsubscribes at once. */
    fun snapshot(
        method: String,
        params: Map<String, Any?>,
        timeoutMillis: Long = this.timeoutMillis,
    ): JsonObject? {
        val call = begin(method, params + ("credit" to 0))
        try {
            return await(call.result, method, timeoutMillis) as? JsonObject
        } finally {
            notify("\$/cancel", mapOf("id" to call.id))
        }
    }

    private fun await(
        future: CompletableFuture<JsonElement?>,
        method: String,
        timeoutMillis: Long,
    ): JsonElement? {
        try {
            return future.get(timeoutMillis, TimeUnit.MILLISECONDS)
        } catch (error: ExecutionException) {
            throw error.cause as? CoreCallException ?: CoreCallException(null, error.message.orEmpty(), error)
        } catch (error: TimeoutException) {
            future.cancel(true)
            throw CoreCallException("timeout", "$method did not answer in $timeoutMillis ms", error)
        }
    }

    /** Calls for the effect alone; a failure is logged. */
    fun send(
        method: String,
        params: Any? = null,
    ) {
        callAsync(method, params).whenComplete { _, error -> reportFailure(method, error) }
    }

    /**
     * Subscribes to a stream method. [onEvent] gets each element of each batch, and credit goes
     * back as batches are handled. Closing the result unsubscribes. [onLost] runs once if the
     * stream cannot open or the session ends under it, and not after a close.
     */
    fun watch(
        method: String,
        params: Map<String, Any?>,
        onLost: () -> Unit = {},
        onEvent: (JsonElement) -> Unit,
    ): AutoCloseable {
        val sub = AtomicLong(-1)
        val closed = AtomicBoolean()
        val callId = ids.incrementAndGet()
        endings[callId] = onLost
        val call =
            begin(method, params + ("credit" to INITIAL_CREDIT), callId) { opened ->
                val id = opened.get("sub").asLong
                if (closed.get()) return@begin
                watches[id] =
                    Watch(callId) { batch ->
                        val elements = if (batch is JsonArray) batch.toList() else listOf(batch)
                        elements.forEach(onEvent)
                        notify("\$/credit", mapOf("sub" to id, "n" to 1))
                    }
                sub.set(id)
                if (closed.get()) watches.remove(id)
            }
        call.result.whenComplete { _, error ->
            reportFailure(method, error)
            if (error != null) endings.remove(call.id)?.invoke()
        }
        return AutoCloseable {
            if (closed.getAndSet(true)) return@AutoCloseable
            endings.remove(call.id)
            watches.remove(sub.get())
            notify("\$/cancel", mapOf("id" to call.id))
        }
    }

    fun close() {
        val ended: Long
        synchronized(lock) {
            ended = session
            session = 0L
        }
        if (ended != 0L) transport.close(ended)
        failPending(CoreCallException("unavailable", "the session was closed"))
    }

    private fun reportFailure(
        method: String,
        error: Throwable?,
    ) {
        if (error != null) log("$method failed: ${error.cause?.message ?: error.message}")
    }

    private fun begin(
        method: String,
        params: Any?,
        id: Long = ids.incrementAndGet(),
        onResult: ((JsonObject) -> Unit)? = null,
    ): Call {
        val future = CompletableFuture<JsonElement?>()
        val live =
            try {
                ensureReady()
            } catch (error: CoreCallException) {
                future.completeExceptionally(error)
                return Call(id, future)
            }
        pending[id] = Pending(future, onResult)
        future.whenComplete { _, _ -> pending.remove(id) }
        if (!transport.send(live, envelope(id, method, params))) lost(live)
        return Call(id, future)
    }

    private fun notify(
        method: String,
        params: Any?,
    ) {
        val live = session
        if (live == 0L) return
        val message = JsonObject()
        message.addProperty("jsonrpc", "2.0")
        message.addProperty("method", method)
        message.add("params", gson.toJsonTree(params))
        if (!transport.send(live, gson.toJson(message).toByteArray())) lost(live)
    }

    private fun envelope(
        id: Long,
        method: String,
        params: Any?,
    ): ByteArray {
        val message = JsonObject()
        message.addProperty("jsonrpc", "2.0")
        message.addProperty("id", id)
        message.addProperty("method", method)
        if (params != null) message.add("params", gson.toJsonTree(params))
        return gson.toJson(message).toByteArray()
    }

    private fun ensureReady(): Long {
        synchronized(lock) {
            if (session != 0L) return session
            val opened = transport.open(::onFrame)
            if (opened == 0L) throw CoreCallException("unavailable", "the core is not running")
            val id = ids.incrementAndGet()
            val hello = CompletableFuture<JsonElement?>()
            pending[id] = Pending(hello)
            val greeting =
                mapOf(
                    "protocol" to mapOf("min" to PROTOCOL_VERSION, "max" to PROTOCOL_VERSION),
                    "client" to mapOf("name" to clientName, "version" to clientVersion),
                )
            try {
                check(transport.send(opened, envelope(id, "core.hello", greeting))) { "the core refused the session" }
                hello.get(timeoutMillis, TimeUnit.MILLISECONDS)
            } catch (error: Exception) {
                pending.remove(id)
                transport.close(opened)
                throw CoreCallException("unavailable", "the core did not greet: ${error.message}", error)
            }
            session = opened
            return opened
        }
    }

    private fun lost(live: Long) {
        synchronized(lock) {
            if (session == live) session = 0L
        }
        transport.close(live)
        failPending(CoreCallException("unavailable", "the session was lost"))
    }

    private fun failPending(error: CoreCallException) {
        pending.values.toList().forEach { it.result.completeExceptionally(error) }
        watches.clear()
        endings.keys.toList().forEach { endings.remove(it)?.invoke() }
    }

    private fun onFrame(bytes: ByteArray): Boolean {
        val message =
            try {
                JsonParser.parseString(String(bytes, Charsets.UTF_8)).asJsonObject
            } catch (error: Exception) {
                log("an unreadable message from the core: ${error.message}")
                return true
            }
        val id = message.get("id")
        when {
            id != null && !id.isJsonNull -> answer(id.asLong, message)
            message.get("method")?.asString == "\$/event" -> event(message.getAsJsonObject("params"))
        }
        return true
    }

    private fun answer(
        id: Long,
        message: JsonObject,
    ) {
        val entry = pending[id] ?: return
        val error = message.getAsJsonObject("error")
        if (error != null) {
            entry.result.completeExceptionally(failure(error))
            return
        }
        val result = message.get("result")
        try {
            if (result != null && result.isJsonObject) entry.onResult?.invoke(result.asJsonObject)
            entry.result.complete(result)
        } catch (error: Exception) {
            entry.result.completeExceptionally(CoreCallException(null, error.message.orEmpty(), error))
        }
    }

    private fun event(params: JsonObject) {
        val sub = params.get("sub").asLong
        if (params.get("resync")?.asBoolean == true) {
            watches.remove(sub)?.let { endings.remove(it.callId)?.invoke() }
            return
        }
        val data = params.get("data") ?: return
        watches[sub]?.onBatch?.invoke(data)
    }

    private fun failure(error: JsonObject): CoreCallException {
        val data = error.getAsJsonObject("data")
        val kind = data?.get("kind")?.asString
        val issue =
            data
                ?.getAsJsonArray("issues")
                ?.firstOrNull()
                ?.asJsonObject
                ?.get("message")
                ?.asString
        return CoreCallException(kind, issue ?: error.get("message")?.asString.orEmpty())
    }
}
