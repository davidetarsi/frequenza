// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_language_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$initialAppLanguageHash() =>
    r'57b19819f0c2ef9b61805bcdc165fdf5ccd24105';

/// See also [initialAppLanguage].
@ProviderFor(initialAppLanguage)
final initialAppLanguageProvider = Provider<AppLanguage>.internal(
  initialAppLanguage,
  name: r'initialAppLanguageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialAppLanguageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitialAppLanguageRef = ProviderRef<AppLanguage>;
String _$activeAppLanguageHash() => r'8b5af77c593b03f36839b544ff03da4e1356b326';

/// The language actually displayed, also used by non-widget surfaces.
///
/// Copied from [ActiveAppLanguage].
@ProviderFor(ActiveAppLanguage)
final activeAppLanguageProvider =
    NotifierProvider<ActiveAppLanguage, AppLanguage>.internal(
      ActiveAppLanguage.new,
      name: r'activeAppLanguageProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeAppLanguageHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveAppLanguage = Notifier<AppLanguage>;
String _$languagePreferenceHash() =>
    r'51266a3e1fea4ea89cc63bcd28851b2e1fe67d07';

/// The explicit choice; null means the initial device language is used.
///
/// Copied from [LanguagePreference].
@ProviderFor(LanguagePreference)
final languagePreferenceProvider =
    AsyncNotifierProvider<LanguagePreference, AppLanguage?>.internal(
      LanguagePreference.new,
      name: r'languagePreferenceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$languagePreferenceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LanguagePreference = AsyncNotifier<AppLanguage?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
