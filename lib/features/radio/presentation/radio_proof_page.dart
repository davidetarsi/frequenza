import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/widgets/app_button.dart';
import '../../../ui/widgets/app_icon_button.dart';
import '../application/radio_controller.dart';
import '../domain/radio_player_state.dart';

class RadioProofPage extends ConsumerStatefulWidget {
  const RadioProofPage({super.key, required this.appName});

  final String appName;

  @override
  ConsumerState<RadioProofPage> createState() => _RadioProofPageState();
}

class _RadioProofPageState extends ConsumerState<RadioProofPage> {
  String? _selectedCountry;
  final List<String> _historyLogs = [];

  static const List<Map<String, String?>> _countryOptions = [
    {'label': LocaleKeys.countryWorld, 'code': null},
    {'label': LocaleKeys.countryIT, 'code': 'IT'},
    {'label': LocaleKeys.countryFR, 'code': 'FR'},
    {'label': LocaleKeys.countryJP, 'code': 'JP'},
    {'label': LocaleKeys.countryBR, 'code': 'BR'},
    {'label': LocaleKeys.countryIS, 'code': 'IS'},
    {'label': LocaleKeys.countryUS, 'code': 'US'},
    {'label': LocaleKeys.countryDE, 'code': 'DE'},
  ];

  void _tune() {
    final controller = ref.read(radioControllerProvider.notifier);
    final country = _selectedCountry;
    setState(() {
      _historyLogs.insert(
        0,
        '${DateTime.now().toIso8601String().substring(11, 19)} [REQ] ${LocaleKeys.proofRequest.tr(
          context: context,
          args: [country ?? LocaleKeys.countryWorld.tr(context: context)],
        )}',
      );
    });
    controller.tuneRandom(countryCode: country);
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(radioControllerProvider);
    final theme = Theme.of(context);

    ref.listen<RadioPlayerState>(radioControllerProvider, (prev, next) {
      if (prev?.station != next.station && next.station != null) {
        setState(() {
          _historyLogs.insert(
            0,
            '${DateTime.now().toIso8601String().substring(11, 19)} [OK] ${next.station!.name} (${next.station!.countryCode}) - ${next.station!.codec ?? "AUDIO"} - ${next.station!.streamUrl}',
          );
        });
      }
      if (next.status == PlaybackStatus.error && next.errorMessage != null) {
        setState(() {
          _historyLogs.insert(
            0,
            '${DateTime.now().toIso8601String().substring(11, 19)} [ERR] ${LocaleKeys.stationError.tr(context: context)}',
          );
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.appName), centerTitle: true),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.contentMaxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.medium),
              children: [
                // Country Filter selector
                Text(
                  LocaleKeys.countrySelect.tr(context: context),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.small),
                Wrap(
                  spacing: AppSpacing.small,
                  runSpacing: RadioDiagnosticsDesign.inlineGap,
                  children: [
                    for (final item in _countryOptions)
                      ChoiceChip(
                        label: Text(item['label']!.tr(context: context)),
                        selected: _selectedCountry == item['code'],
                        onSelected: playerState.isLoading
                            ? null
                            : (_) {
                                setState(() {
                                  _selectedCountry = item['code'];
                                });
                              },
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),

                // Station Card
                Card(
                  elevation: RadioDiagnosticsDesign.cardElevation,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.large),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.small,
                          runSpacing: AppSpacing.small,
                          children: [
                            _StatusBadge(status: playerState.status),
                            if (playerState.station?.codec != null)
                              Chip(
                                label: Text(
                                  '${playerState.station!.codec} ${playerState.station!.bitrate != null ? LocaleKeys.proofBitrate.tr(context: context, args: ['${playerState.station!.bitrate}']) : ""}'
                                      .trim(),
                                  style: theme.textTheme.labelSmall,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.medium),
                        AnimatedSwitcher(
                          duration: AppMotion.standard(context),
                          child: Text(
                            playerState.station?.name ??
                                LocaleKeys.proofNoStation.tr(context: context),
                            key: ValueKey(playerState.station?.name ?? 'empty'),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.small),
                        Text(
                          playerState.station != null
                              ? LocaleKeys.proofStationLocation.tr(
                                  context: context,
                                  args: [
                                    playerState.station!.country,
                                    playerState.station!.countryCode,
                                  ],
                                )
                              : LocaleKeys.proofHint.tr(context: context),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (playerState.station != null) ...[
                          const SizedBox(height: AppSpacing.small),
                          Text(
                            playerState.station!.streamUrl,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: theme.colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (playerState.errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.medium),
                          Text(
                            LocaleKeys.stationError.tr(context: context),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.large),

                // Main Action Button
                AppButton(
                  label: playerState.isLoading
                      ? LocaleKeys.proofSearch.tr(context: context)
                      : LocaleKeys.tune.tr(context: context),
                  isLoading: playerState.isLoading,
                  onPressed: _tune,
                ),
                const SizedBox(height: AppSpacing.medium),

                // Controls Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppIconButton(
                      variant: AppIconButtonVariant.tonal,
                      key: const ValueKey('play-pause-button'),
                      icon: Icon(
                        playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: RadioDiagnosticsDesign.iconSize,
                      ),
                      tooltip: playerState.isPlaying
                          ? LocaleKeys.pause.tr(context: context)
                          : LocaleKeys.proofPlay.tr(context: context),
                      onPressed:
                          playerState.station == null || playerState.isLoading
                          ? null
                          : () {
                              final controller = ref.read(
                                radioControllerProvider.notifier,
                              );
                              if (playerState.isPlaying) {
                                controller.pause();
                              } else {
                                controller.play();
                              }
                            },
                    ),
                    const SizedBox(width: AppSpacing.large),
                    AppIconButton(
                      variant: AppIconButtonVariant.outlined,
                      key: const ValueKey('stop-button'),
                      icon: const Icon(
                        Icons.stop,
                        size: RadioDiagnosticsDesign.iconSize,
                      ),
                      tooltip: LocaleKeys.proofStop.tr(context: context),
                      onPressed: playerState.station == null
                          ? null
                          : () => ref
                                .read(radioControllerProvider.notifier)
                                .stop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.large),

                // Log Box
                Text(
                  LocaleKeys.proofLogTitle.tr(
                    context: context,
                    args: ['${_historyLogs.length}'],
                  ),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.small),
                Container(
                  height: RadioDiagnosticsDesign.logHeight,
                  padding: const EdgeInsets.all(AppSpacing.small),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: RadioDiagnosticsDesign.logRadius,
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: _historyLogs.isEmpty
                      ? Center(
                          child: Text(
                            LocaleKeys.proofLogEmpty.tr(context: context),
                            style: theme.textTheme.bodySmall,
                          ),
                        )
                      : ListView.separated(
                          itemCount: _historyLogs.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: AppSpacing.small),
                          itemBuilder: (context, index) => SelectableText(
                            _historyLogs[index],
                            style: theme.textTheme.bodySmall?.merge(
                              RadioDiagnosticsDesign.logFont,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PlaybackStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, color, icon) = switch (status) {
      PlaybackStatus.idle => (
        LocaleKeys.proofIdle.tr(context: context),
        theme.colorScheme.outline,
        Icons.radio,
      ),
      PlaybackStatus.tuning => (
        LocaleKeys.proofTuning.tr(context: context),
        theme.colorScheme.primary,
        Icons.search,
      ),
      PlaybackStatus.buffering => (
        LocaleKeys.proofBuffering.tr(context: context),
        theme.colorScheme.secondary,
        Icons.hourglass_top,
      ),
      PlaybackStatus.playing => (
        LocaleKeys.proofPlaying.tr(context: context),
        theme.colorScheme.primary,
        Icons.volume_up,
      ),
      PlaybackStatus.paused => (
        LocaleKeys.paused.tr(context: context),
        theme.colorScheme.secondary,
        Icons.pause_circle,
      ),
      PlaybackStatus.error => (
        LocaleKeys.proofError.tr(context: context),
        theme.colorScheme.error,
        Icons.error_outline,
      ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: RadioDiagnosticsDesign.badgeIconSize, color: color),
        const SizedBox(width: RadioDiagnosticsDesign.inlineGap),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
