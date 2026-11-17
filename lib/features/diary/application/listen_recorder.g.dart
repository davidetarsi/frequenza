// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listen_recorder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$diaryClockHash() => r'29ffe4a816807b436447d9b732597fa1757d04ac';

/// See also [diaryClock].
@ProviderFor(diaryClock)
final diaryClockProvider = Provider<DiaryClock>.internal(
  diaryClock,
  name: r'diaryClockProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$diaryClockHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DiaryClockRef = ProviderRef<DiaryClock>;
String _$listenRecorderHash() => r'c33e8da41c1eb9aef27b692ef9ee92c68b23de35';

/// Watches the radio from outside and writes the log: every 30 seconds,
/// when the app goes to the background, and when a listen ends. The
/// writes go one at a time, in order; a failed write never reaches the
/// radio.
///
/// Copied from [listenRecorder].
@ProviderFor(listenRecorder)
final listenRecorderProvider = Provider<void>.internal(
  listenRecorder,
  name: r'listenRecorderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$listenRecorderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ListenRecorderRef = ProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
