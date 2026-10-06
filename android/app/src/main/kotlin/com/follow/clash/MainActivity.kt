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
    }

    // Android 14+ moves a root task to back on system back only when Home launched it with a
    // MAIN/LAUNCHER intent; any other launch (notification, QS tile, link) is finished through
    // here, which would destroy the engine instead of minimizing.
    override fun finishAfterTransition() {
        if (isTaskRoot) moveTaskToBack(true) else super.finishAfterTransition()
    }

    override fun onDestroy() {
        flutterEngine?.let(ServiceState::detachFlutterEngine)
        super.onDestroy()
    }
}
