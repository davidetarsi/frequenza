package it.davidetarsi.frequenza

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.random.Random

class MainActivity : AudioServiceActivity() {
    private var tuningChannel: MethodChannel? = null
    private var tuningPlayer: MediaPlayer? = null
    private val fades = Handler(Looper.getMainLooper())
    private var inForeground = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tuningPlayer = MediaPlayer.create(
            this,
            R.raw.tuning_static,
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build(),
            AudioManager.AUDIO_SESSION_ID_GENERATE,
        )?.apply { isLooping = true }

        tuningChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "frequenza/tuning_sound")
        tuningChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    if (inForeground) startTuningSound()
                    result.success(null)
                }
                "stop" -> {
                    fadeOutTuningSound()
                    result.success(null)
                }
                // Dal 13 Android conferma da sé ogni copia negli appunti.
                "sdkInt" -> result.success(Build.VERSION.SDK_INT)
                // Dove copiare il logo di ripiego della notifica.
                "cacheDir" -> result.success(cacheDir.absolutePath)
                else -> result.notImplemented()
            }
        }
    }

    // Ogni volo parte da un punto diverso del fruscio, così non suona mai uguale.
    private fun startTuningSound() {
        val player = tuningPlayer ?: return
        fades.removeCallbacksAndMessages(null)
        player.setVolume(TUNING_VOLUME, TUNING_VOLUME)
        if (!player.isPlaying) {
            player.seekTo(Random.nextInt(maxOf(player.duration, 1)))
            player.start()
        }
    }

    // All'atterraggio il fruscio sfuma mentre la stazione sale.
    private fun fadeOutTuningSound() {
        val player = tuningPlayer ?: return
        if (!player.isPlaying) return
        fades.removeCallbacksAndMessages(null)
        val steps = FADE_MS / FADE_STEP_MS
        for (step in 1..steps) {
            fades.postDelayed({
                val volume = TUNING_VOLUME * (steps - step) / steps
                if (step < steps) {
                    player.setVolume(volume, volume)
                } else {
                    stopTuningSound()
                }
            }, step * FADE_STEP_MS)
        }
    }

    private fun stopTuningSound() {
        fades.removeCallbacksAndMessages(null)
        tuningPlayer?.let { if (it.isPlaying) it.pause() }
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
        tuningPlayer?.release()
        tuningPlayer = null
        super.cleanUpFlutterEngine(flutterEngine)
    }

    private companion object {
        const val TUNING_VOLUME = 0.42f
        const val FADE_MS = 400L
        const val FADE_STEP_MS = 40L
    }
}
