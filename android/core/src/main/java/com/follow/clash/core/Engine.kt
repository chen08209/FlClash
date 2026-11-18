package com.follow.clash.core

internal fun CoreClient.engineRunning(): Boolean {
    val opened = snapshot("engine.state", emptyMap())
    return opened?.getAsJsonObject("snapshot")?.get("state")?.asString == "running"
}

internal fun CoreClient.startEngine(): Result<Unit> =
    runCatching {
        if (!engineRunning()) call("engine.start")
    }
