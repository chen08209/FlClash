package com.follow.clash

import androidx.lifecycle.MutableLiveData
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.TilePlugin
import io.flutter.embedding.engine.FlutterEngine
import java.util.Date

enum class RunState {
    START,
    PENDING,
    STOP
}

class GlobalState {
    companion object {
        val runState: MutableLiveData<RunState> = MutableLiveData<RunState>(RunState.STOP)
        var runTime: Date? = null
        var flutterEngine: FlutterEngine? = null
        fun getCurrentTilePlugin(): TilePlugin? =
            flutterEngine?.plugins?.get(TilePlugin::class.java) as TilePlugin?

        fun getCurrentAppPlugin(): AppPlugin? =
            flutterEngine?.plugins?.get(AppPlugin::class.java) as AppPlugin?
    }
}


