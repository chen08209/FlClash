package com.follow.clash.core

import com.google.gson.JsonElement
import com.google.gson.JsonObject

internal fun withTrustedCa(
    setup: JsonElement,
    answer: JsonElement?,
    trusts: (String) -> Boolean,
): JsonElement {
    val certificate = (answer as? JsonObject)?.get("certificate") as? JsonObject ?: return setup
    val pem = certificate.get("pem")?.asString ?: return setup
    val trusted = runCatching { trusts(pem) }.getOrDefault(false)
    val next = setup.deepCopy().asJsonObject
    val options = next.getAsJsonObject("options") ?: JsonObject().also { next.add("options", it) }
    options.addProperty("mitmTrustedCa", if (trusted) certificate.get("fingerprint")?.asString.orEmpty() else "")
    return next
}
