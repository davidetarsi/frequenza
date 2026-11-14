import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/locale_keys.g.dart';

const _platform = MethodChannel('frequenza/tuning_sound');

/// From Android 13 the system shows its own confirmation for every copy.
Future<bool> systemConfirmsCopy() async {
  if (defaultTargetPlatform != TargetPlatform.android) return false;
  try {
    final sdk = await _platform
        .invokeMethod<int>('sdkInt')
        .timeout(const Duration(seconds: 1));
    return (sdk ?? 0) >= 33;
  } on Exception {
    return false;
  }
}

/// Copies the song on air, with a light buzz; says so only where the
/// phone would not.
Future<void> copyTrackTitle(BuildContext context, String title) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = LocaleKeys.titleCopied.tr(context: context);
  await Clipboard.setData(ClipboardData(text: title));
  await HapticFeedback.lightImpact();
  if (await systemConfirmsCopy()) return;
  messenger.showSnackBar(SnackBar(content: Text(message)));
}
