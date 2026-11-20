import 'package:flutter/services.dart';

/// The app's own Android channel, served by the engine-owned FrequenzaPlatformPlugin: tuning sound,
/// Android and app versions, cache folder and the radio service's
/// foreground.
const nativeChannel = MethodChannel('frequenza/tuning_sound');
