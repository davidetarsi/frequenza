package dev.davidetarsi.frequenza

import android.media.AudioAttributes
import android.media.SoundPool
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private var tuningChannel: MethodChannel? = null
    private var tuningPool: SoundPool? = null
    private var tuningSample = 0
    private var tuningStream = 0
    private var tuningRequested = false
    private var tuningLoaded = false
    private var inForeground = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val pool = SoundPool.Builder()
            .setMaxStreams(1)
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            )
            .build()
        tuningPool = pool
        pool.setOnLoadCompleteListener { loadedPool, sampleId, status ->
            if (loadedPool === tuningPool && sampleId == tuningSample && status == 0) {
                tuningLoaded = true
                playTuningSound()
            }
        }
        tuningSample = pool.load(this, R.raw.tuning_static, 1)

        tuningChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "frequenza/tuning_sound")
        tuningChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    tuningRequested = inForeground
                    playTuningSound()
                    result.success(null)
                }
                "stop" -> {
                    stopTuningSound()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun playTuningSound() {
        if (!tuningRequested || !tuningLoaded || tuningStream != 0) return
        tuningStream = tuningPool?.play(tuningSample, 0.42f, 0.42f, 1, -1, 1f) ?: 0
    }

    private fun stopTuningSound() {
        tuningRequested = false
        if (tuningStream != 0) tuningPool?.stop(tuningStream)
        tuningStream = 0
    }

    override fun onStart() {
        super.onStart()
        inForeground = true
    }

    override fun onStop() {
        inForeground = false
        stopTuningSound()
        super.onStop()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        stopTuningSound()
        tuningChannel?.setMethodCallHandler(null)
        tuningChannel = null
        tuningPool?.release()
        tuningPool = null
        tuningLoaded = false
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
