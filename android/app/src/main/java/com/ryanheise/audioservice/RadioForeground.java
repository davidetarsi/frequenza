package com.ryanheise.audioservice;

import android.app.Service;
import java.lang.reflect.Method;

/**
 * Frequenza: takes the radio's service out of the foreground once the radio
 * has really stopped. The service stays there while paused, so the plugin
 * never leaves it on its own; this class lives in the plugin's package to
 * reach the running service.
 */
public final class RadioForeground {
    private RadioForeground() {}

    /**
     * AudioService.onDestroy clears its listener even when an Activity keeps
     * the Flutter engine (and its AudioHandlerInterface) alive. Reattach the
     * existing interface before a new tune; no new engine or media session.
     */
    public static boolean reconnect() {
        try {
            AudioService.init(AudioServicePlugin.audioHandlerInterface());
            return true;
        } catch (Exception notReady) {
            return false;
        }
    }

    public static void leave() {
        // Keep the fallback in terms of the Android Service interface.
        Object service = AudioService.instance;
        if (service == null) return;
        try {
            // The plugin's own routine: out of the foreground, wake lock released.
            // Kept by name in proguard-rules.pro.
            Method exit = AudioService.class.getDeclaredMethod("exitForegroundState");
            exit.setAccessible(true);
            exit.invoke(service);
        } catch (ReflectiveOperationException | RuntimeException e) {
            if (service instanceof Service) {
                ((Service) service).stopForeground(Service.STOP_FOREGROUND_DETACH);
            }
        }
    }
}
