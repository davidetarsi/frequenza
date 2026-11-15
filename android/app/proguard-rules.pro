# RadioForeground calls the plugin's routine that takes the service out of
# the foreground and releases its wake lock.
-keepclassmembers class com.ryanheise.audioservice.AudioService {
    private void exitForegroundState();
}
