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
        )?.apply {
            isLooping = true
            // Un player in errore lancia eccezioni a ogni chiamata: meglio
            // un volo senza fruscio che l'app chiusa.
            setOnErrorListener { player, _, _ ->
                fades.removeCallbacksAndMessages(null)
                player.release()
                if (tuningPlayer === player) tuningPlayer = null
                true
            }
        }

        tuningChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "frequenza/tuning_sound")
        tuningChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    if (inForeground) startTuningSound()
                    result.success(null)
                }
                // All'atterraggio sfuma; pausa, stop e volo fallito tagliano subito.
                "fadeOut" -> {
                    fadeOutTuningSound()
                    result.success(null)
                }
                "stop" -> {
                    stopTuningSound()
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
        safely {
            player.setVolume(TUNING_VOLUME, TUNING_VOLUME)
            if (!player.isPlaying) {
                player.seekTo(Random.nextInt(maxOf(player.duration, 1)))
                player.start()
            }
        }
    }

    // All'atterraggio il fruscio sfuma mentre la stazione sale.
    private fun fadeOutTuningSound() {
        val player = tuningPlayer ?: return
        if (safely { player.isPlaying } != true) return
        fades.removeCallbacksAndMessages(null)
        val steps = FADE_MS / FADE_STEP_MS
        for (step in 1..steps) {
            fades.postDelayed({
                val volume = TUNING_VOLUME * (steps - step) / steps
                if (step < steps) {
                    safely { player.setVolume(volume, volume) }
                } else {
                    stopTuningSound()
                }
            }, step * FADE_STEP_MS)
        }
    }

    private fun stopTuningSound() {
        fades.removeCallbacksAndMessages(null)
        tuningPlayer?.let { player -> safely { if (player.isPlaying) player.pause() } }
    }

    // Il fruscio è un contorno: un errore del player non deve chiudere l'app.
    private inline fun <T> safely(block: () -> T): T? =
        try {
            block()
        } catch (_: IllegalStateException) {
            null
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
