// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appVersionHash() => r'd2b2f8d29394812ca5bfc54e56a2e8cdc74480d8';

/// The installed version, as `0.2.1+2`; empty when Android cannot tell.
///
/// Copied from [appVersion].
@ProviderFor(appVersion)
final appVersionProvider = FutureProvider<String>.internal(
  appVersion,
  name: r'appVersionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appVersionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppVersionRef = FutureProviderRef<String>;
String _$deviceInfoHash() => r'9b05c9855b9907b22430f573a6156e62c685c574';

/// The phone, as `Google Pixel 8 · Android 16`; empty when Android cannot
/// tell.
///
/// Copied from [deviceInfo].
@ProviderFor(deviceInfo)
final deviceInfoProvider = FutureProvider<String>.internal(
  deviceInfo,
  name: r'deviceInfoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceInfoRef = FutureProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
