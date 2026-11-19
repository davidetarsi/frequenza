package it.davidetarsi.frequenza

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.AudioManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.ryanheise.audioservice.RadioForeground
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel
import kotlin.random.Random

// Lives with the shared Flutter engine used by audio_service, not the Activity.
// Notification commands must keep working with the screen off or Activity detached.
class FrequenzaPlatformPlugin : FlutterPlugin {
    private var tuningChannel: MethodChannel? = null
    private var tuningPlayer: MediaPlayer? = null
    private val fades = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        tuningPlayer = MediaPlayer.create(
            context,
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

        tuningChannel = MethodChannel(binding.binaryMessenger, "frequenza/tuning_sound")
        tuningChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    startTuningSound()
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
                // Update the channel label without changing its ID or user settings.
                "notificationChannel" -> {
                    val args = call.arguments as? Map<*, *>
                    val id = args?.get("id") as? String
                    val name = args?.get("name") as? String
                    if (id.isNullOrBlank() || name.isNullOrBlank() || id.length > 128 || name.length > 512) {
                        result.error("invalid_channel", null, null)
                    } else {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val manager = context.getSystemService(NotificationManager::class.java)
                            if (manager != null) {
                                val channel = manager.getNotificationChannel(id)
                                    ?: NotificationChannel(id, name, NotificationManager.IMPORTANCE_LOW).apply {
                                        setShowBadge(false)
                                    }
                                channel.name = name
                                manager.createNotificationChannel(channel)
                            }
                        }
                        result.success(null)
                    }
                }
                // Le app di musica in cui cercare una canzone salvata.
                "installedApps" -> {
                    val packages = (call.arguments as? List<*>).orEmpty().filterIsInstance<String>()
                    result.success(packages.filter { context.packageManager.getLaunchIntentForPackage(it) != null })
                }
                // Dove copiare il logo di ripiego della notifica.
                "cacheDir" -> result.success(context.cacheDir.absolutePath)
                // Per il modulo delle segnalazioni: «Google Pixel 8 · Android 16».
                "deviceInfo" -> {
                    val maker = Build.MANUFACTURER.replaceFirstChar { it.uppercase() }
                    val model = if (Build.MODEL.startsWith(Build.MANUFACTURER, ignoreCase = true)) {
                        Build.MODEL
                    } else {
                        "$maker ${Build.MODEL}"
                    }
                    result.success("$model · Android ${Build.VERSION.RELEASE}")
                }
                // Per il modulo delle segnalazioni: 0.2.1+2.
                "appVersion" -> {
                    val info = context.packageManager.getPackageInfo(context.packageName, 0)
                    val code = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        info.longVersionCode
                    } else {
                        @Suppress("DEPRECATION") info.versionCode.toLong()
                    }
                    result.success("${info.versionName}+$code")
                }
                // La radio si è fermata davvero: il servizio esce dal primo piano.
                "leaveForeground" -> {
                    RadioForeground.leave()
                    result.success(null)
                }
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

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopTuningSound()
        tuningChannel?.setMethodCallHandler(null)
        tuningChannel = null
        tuningPlayer?.release()
        tuningPlayer = null
    }

    private companion object {
        const val TUNING_VOLUME = 0.42f
        const val FADE_MS = 400L
        const val FADE_STEP_MS = 40L
    }
}
