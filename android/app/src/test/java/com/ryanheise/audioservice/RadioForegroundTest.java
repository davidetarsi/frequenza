package com.ryanheise.audioservice;

import static org.junit.Assert.*;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import org.junit.Test;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMethodCodec;

/** Exercises the actual plugin's Java callbacks, not a copy of their logic. */
public class RadioForegroundTest {
    static class RecordingMessenger implements BinaryMessenger {
        final List<String> calls = new ArrayList<>();
        @Override public void send(String channel, ByteBuffer message) { send(channel, message, null); }
        @Override public void send(String channel, ByteBuffer message, BinaryReply reply) {
            message.flip();
            calls.add(StandardMethodCodec.INSTANCE.decodeMethodCall(message).method);
        }
        @Override public void setMessageHandler(String channel, BinaryMessageHandler handler) {}
    }

    @Test public void restoresAllControlsAfterTheServiceClearsItsListener() throws Exception {
        Field root = AudioServicePlugin.class.getDeclaredField("audioHandlerInterface");
        Field ready = AudioServicePlugin.class.getDeclaredField("flutterReady");
        Field listener = AudioService.class.getDeclaredField("listener");
        root.setAccessible(true); ready.setAccessible(true); listener.setAccessible(true);
        Object oldRoot = root.get(null); Object oldListener = listener.get(null);
        boolean oldReady = ready.getBoolean(null);
        try {
            RecordingMessenger messenger = new RecordingMessenger();
            Constructor<?> ctor = root.getType().getDeclaredConstructor(BinaryMessenger.class);
            ctor.setAccessible(true);
            Object dartBridge = ctor.newInstance(messenger);
            root.set(null, dartBridge); ready.setBoolean(null, true);
            AudioService.init((AudioService.ServiceListener) dartBridge);
            AudioService.MediaSessionCallback callback = new AudioService().new MediaSessionCallback();
            callback.onPause();
            assertEquals(List.of("pause"), messenger.calls);
            messenger.calls.clear();

            // AudioService.onDestroy clears this exact static listener while
            // disposeFlutterEngine preserves the engine when an Activity exists.
            AudioService.init(null);
            callback.onPause(); callback.onPlay(); callback.onSkipToNext();
            callback.onSkipToPrevious(); callback.onCustomAction("favorite", null);
            assertTrue(messenger.calls.isEmpty());

            assertTrue(RadioForeground.reconnect());
            callback.onPause(); callback.onPlay(); callback.onSkipToNext();
            callback.onSkipToPrevious(); callback.onCustomAction("favorite", null);
            assertEquals(List.of("pause", "play", "skipToNext", "skipToPrevious", "customAction"), messenger.calls);
            assertSame(dartBridge, listener.get(null));
        } finally {
            root.set(null, oldRoot); ready.setBoolean(null, oldReady); listener.set(null, oldListener);
        }
    }

    @Test public void notReadyIsSafeAndDoesNotInventAListener() throws Exception {
        Field root = AudioServicePlugin.class.getDeclaredField("audioHandlerInterface");
        Field listener = AudioService.class.getDeclaredField("listener");
        root.setAccessible(true); listener.setAccessible(true);
        Object oldRoot = root.get(null); Object oldListener = listener.get(null);
        try {
            root.set(null, null); listener.set(null, null);
            assertFalse(RadioForeground.reconnect());
            assertNull(listener.get(null));
        } finally { root.set(null, oldRoot); listener.set(null, oldListener); }
    }
}
