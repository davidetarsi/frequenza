// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appVersionHash() => r'7bcecb9938fb4563538cf33c51e2dde4d44dc4ac';

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
String _$deviceInfoHash() => r'ffe77d98baad513be6b6ffc1d40ea5ad9d2b9ca0';

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
