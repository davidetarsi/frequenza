package it.davidetarsi.frequenza

import com.ryanheise.audioservice.AudioServiceActivity
import com.ryanheise.audioservice.RadioForeground
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {
    override fun onResume() {
        super.onResume()
        // A stopped service may have cleared its listener while this engine lived.
        RadioForeground.reconnect()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!flutterEngine.plugins.has(FrequenzaPlatformPlugin::class.java)) {
            flutterEngine.plugins.add(FrequenzaPlatformPlugin())
        }
    }
}
