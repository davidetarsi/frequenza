import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_translations.g.dart';
import '../localization/application/app_language_provider.dart';
import '../localization/domain/app_language.dart';
import '../localization/application/language_effects.dart';
import '../platform/application/app_platform_provider.dart';

class AppLocalization extends ConsumerWidget {
  const AppLocalization({super.key, required this.child, this.startLocale});

  static const english = Locale('en');
  static const italian = Locale('it');
  static const locales = [english, italian];
  final Widget child;
  final Locale? startLocale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(languagePreferenceProvider);
    if (startLocale == null && preference.isLoading && !preference.hasValue) {
      return const SizedBox.shrink();
    }
    final language =
        preference.valueOrNull ??
        AppLanguage.device(ref.watch(appPlatformProvider).deviceLanguageCode);
    return EasyLocalization(
      supportedLocales: locales,
      fallbackLocale: english,
      startLocale: startLocale ?? Locale(language.name),
      saveLocale: false,
      path: 'assets/translations',
      assetLoader: const CodegenLoader(),
      child: _LocaleBridge(
        initialLocale: startLocale ?? Locale(language.name),
        child: child,
      ),
    );
  }
}

class _LocaleBridge extends ConsumerStatefulWidget {
  const _LocaleBridge({required this.initialLocale, required this.child});
  final Locale initialLocale;
  final Widget child;
  @override
  ConsumerState<_LocaleBridge> createState() => _LocaleBridgeState();
}

class _LocaleBridgeState extends ConsumerState<_LocaleBridge> {
  Future<void> _changes = Future.value();
  bool _initialized = false;
  bool _initializing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    if (context.locale == widget.initialLocale) return;
    // Use the public locale API to override the library's cached start locale.
    // Keep the native splash until the first correctly translated app frame.
    _initializing = true;
    WidgetsBinding.instance.deferFirstFrame();
    _changes = _changes.then((_) async {
      try {
        if (mounted) await context.setLocale(widget.initialLocale);
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stack),
        );
      } finally {
        WidgetsBinding.instance.allowFirstFrame();
        if (mounted) setState(() => _initializing = false);
      }
    });
  }

  void _applyLatest() {
    _changes = _changes.then((_) async {
      if (!mounted) return;
      final preference = ref.read(languagePreferenceProvider);
      final language = preference.valueOrNull;
      if (preference.hasError || preference.isLoading || language == null) {
        return;
      }
      try {
        final locale = Locale(language.name);
        if (context.locale != locale) await context.setLocale(locale);
        if (mounted) {
          ref.read(activeAppLanguageProvider.notifier).activate(language);
        }
      } catch (error, stack) {
        FlutterError.reportError(
          FlutterErrorDetails(exception: error, stack: stack),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) return const SizedBox.shrink();
    ref.watch(appLanguageEffectsProvider);
    ref.listen(languagePreferenceProvider, (before, after) {
      if (before?.hasValue == true && !after.isLoading && !after.hasError) {
        _applyLatest();
      }
    });
    final language = AppLanguage.device(context.locale.languageCode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.locale.languageCode == language.name) {
        ref.read(activeAppLanguageProvider.notifier).activate(language);
      }
    });
    return widget.child;
  }
}
