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
String _$analyticsHash() => r'6f7808a198a9e9d7502b08f5ab9aa58b6b4db305';

/// Where the events go: nowhere without the keys, or with the statistics
/// off or not yet read. Every time they start, a new launch code.
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
String _$analyticsSessionDetailsHash() =>
    r'5a2fbd2c8474f628599766a8fb2a957865f276bd';

/// The launch details (version, language, theme, Android), sent with
/// every event; empty until the launch has been described.
///
/// Copied from [AnalyticsSessionDetails].
@ProviderFor(AnalyticsSessionDetails)
final analyticsSessionDetailsProvider =
    NotifierProvider<AnalyticsSessionDetails, Map<String, Object>>.internal(
      AnalyticsSessionDetails.new,
      name: r'analyticsSessionDetailsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$analyticsSessionDetailsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnalyticsSessionDetails = Notifier<Map<String, Object>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
