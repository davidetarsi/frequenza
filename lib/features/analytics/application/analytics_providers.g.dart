// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsKeysHash() => r'215a3a45cc9867fce9d8edb23733c1cbac575bbc';

/// See also [analyticsKeys].
@ProviderFor(analyticsKeys)
final analyticsKeysProvider = Provider<AnalyticsKeys>.internal(
  analyticsKeys,
  name: r'analyticsKeysProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsKeysHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsKeysRef = ProviderRef<AnalyticsKeys>;
String _$analyticsHttpClientHash() =>
    r'01f17c6be3f18ba44478e05f38d6865a1a7934c2';

/// The HTTP client for the events; the package's own when null.
///
/// Copied from [analyticsHttpClient].
@ProviderFor(analyticsHttpClient)
final analyticsHttpClientProvider = Provider<http.Client?>.internal(
  analyticsHttpClient,
  name: r'analyticsHttpClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsHttpClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsHttpClientRef = ProviderRef<http.Client?>;
String _$analyticsSessionIdHash() =>
    r'c789d01c785e0ee061b3af6626beac16926f55be';

/// This launch, as 32 random hex characters. Never stored.
///
/// Copied from [analyticsSessionId].
@ProviderFor(analyticsSessionId)
final analyticsSessionIdProvider = Provider<String>.internal(
  analyticsSessionId,
  name: r'analyticsSessionIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsSessionIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsSessionIdRef = ProviderRef<String>;
String _$analyticsHash() => r'87a2a9c268a2dad9cf5bd593485003b4c016faac';

/// Where the events go: nowhere without the keys, or with the statistics
/// off or not yet read.
///
/// Copied from [analytics].
@ProviderFor(analytics)
final analyticsProvider = Provider<Analytics>.internal(
  analytics,
  name: r'analyticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyticsRef = ProviderRef<Analytics>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
