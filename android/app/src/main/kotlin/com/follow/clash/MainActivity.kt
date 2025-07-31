package com.follow.clash

import android.os.Bundle
import androidx.lifecycle.lifecycleScope
import com.follow.clash.common.GlobalState
import com.follow.clash.plugins.AppPlugin
import com.follow.clash.plugins.ServicePlugin
import com.follow.clash.plugins.TilePlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity(),
    CoroutineScope by CoroutineScope(SupervisorJob() + Dispatchers.Default) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        lifecycleScope.launch {
            State.destroyServiceEngine()
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(AppPlugin())
        flutterEngine.plugins.add(ServicePlugin())
        flutterEngine.plugins.add(TilePlugin())
        State.flutterEngine = flutterEngine
    }

    override fun onDestroy() {
        GlobalState.launch {
            Service.setEventListener(null)
        }
        State.flutterEngine = null
        super.onDestroy()
    }
}