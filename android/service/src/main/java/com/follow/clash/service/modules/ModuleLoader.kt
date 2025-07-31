package com.follow.clash.service.modules

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

interface ModuleLoaderScope {
    fun <T : Module> install(module: T): T
}

interface ModuleLoader {
    fun load()

    fun cancel()
}

private val mutex = Mutex()
fun CoroutineScope.moduleLoader(block: suspend ModuleLoaderScope.() -> Unit): ModuleLoader {
    val modules = mutableListOf<Module>()
    var job: Job? = null

    return object : ModuleLoader {
        override fun load() {
            job = launch(Dispatchers.IO) {
                mutex.withLock {
                    val scope = object : ModuleLoaderScope {
                        override fun <T : Module> install(module: T): T {
                            modules.add(module)
                            module.install()
                            return module
                        }
                    }
                    scope.block()
                }
            }
        }

        override fun cancel() {
            launch(Dispatchers.IO) {
                job?.cancel()
                mutex.withLock {
                    modules.asReversed().forEach { it.uninstall() }
                    modules.clear()
                }
            }
        }
    }
}