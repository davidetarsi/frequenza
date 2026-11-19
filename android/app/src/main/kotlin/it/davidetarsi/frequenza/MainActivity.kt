package it.davidetarsi.frequenza

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!flutterEngine.plugins.has(FrequenzaPlatformPlugin::class.java)) {
            flutterEngine.plugins.add(FrequenzaPlatformPlugin())
        }
    }
}
