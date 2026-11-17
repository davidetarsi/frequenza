// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_consent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$analyticsConsentHash() => r'ad419a264459d3c68f583f5e2a666a414782cdf0';

/// Whether the anonymous statistics are on: on unless turned off in the
/// settings, off when the preferences cannot be read.
///
/// Copied from [AnalyticsConsent].
@ProviderFor(AnalyticsConsent)
final analyticsConsentProvider =
    AsyncNotifierProvider<AnalyticsConsent, bool>.internal(
      AnalyticsConsent.new,
      name: r'analyticsConsentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$analyticsConsentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AnalyticsConsent = AsyncNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
