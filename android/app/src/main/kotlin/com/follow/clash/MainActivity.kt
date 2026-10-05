package com.follow.clash

import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.ServicePlugin
import com.follow.clash.plugins.TilePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(AppPlugin())
        flutterEngine.plugins.add(ServicePlugin())
        flutterEngine.plugins.add(TilePlugin())
        ServiceState.attachFlutterEngine(flutterEngine)
        // A mode/profile request may have arrived while no engine was alive
        // (cold start from a shortcut/broadcast); replay them now that Dart can.
        ModeRequest.pending?.let { mode ->
            ModeRequest.pending = null
            AppPlugin.changeMode(mode)
        }
        ModeRequest.pendingProfileId?.let { id ->
            ModeRequest.pendingProfileId = null
            AppPlugin.selectProfile(id)
        }
    }

    override fun onDestroy() {
        flutterEngine?.let(ServiceState::detachFlutterEngine)
        super.onDestroy()
    }
}
