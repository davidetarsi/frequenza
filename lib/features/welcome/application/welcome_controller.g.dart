// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'welcome_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$welcomeControllerHash() => r'59abf5fd32bdcb1f9dfd4cd03b132cc30e1df8b8';

/// Owns the guide's effects; the domain transition decides every state change.
/// Auto-disposal ties this session to the guide, not to the lifetime of the app.
///
/// Copied from [WelcomeController].
@ProviderFor(WelcomeController)
final welcomeControllerProvider =
    AutoDisposeNotifierProvider<WelcomeController, WelcomeSession>.internal(
      WelcomeController.new,
      name: r'welcomeControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$welcomeControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WelcomeController = AutoDisposeNotifier<WelcomeSession>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
