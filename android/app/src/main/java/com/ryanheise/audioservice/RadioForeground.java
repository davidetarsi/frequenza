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

    public static void leave() {
        // As a plain Object: the plugin's base classes are not on the app's
        // compile classpath.
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
