import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_localization.dart';
import '../../../app/routing/app_router.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/widgets/code_badge.dart';
import '../../radio/application/radio_controller.dart';
import '../../radio/presentation/radio_page.dart';
import '../application/welcome_seen.dart';

class WelcomeTour extends ConsumerStatefulWidget {
  const WelcomeTour({super.key, required this.builder});
  final Widget Function(RadioPageAnchors targets) builder;

  @override
  ConsumerState<WelcomeTour> createState() => _WelcomeTourState();
}

class _WelcomeTourState extends ConsumerState<WelcomeTour> {
  final _targets = RadioPageAnchors();
  final _surface = GlobalKey();
  int _step = 0;
  bool _closing = false;
  Rect? _screen, _target;

  void _measure() {
    if (!mounted) return;
    final surface = _surface.currentContext?.findRenderObject();
    final screen = _targets.screen.currentContext?.findRenderObject();
    final key = [_targets.dial, _targets.favorites, _targets.diary][_step];
    final target = key.currentContext?.findRenderObject();
    if (surface is! RenderBox || screen is! RenderBox || target is! RenderBox) {
      return;
    }
    Rect rect(RenderBox box) =>
        surface.globalToLocal(box.localToGlobal(Offset.zero)) & box.size;
    final face = rect(
      screen,
    ).deflate(RadioCabinetDesign.screenFrameInset + 1.5);
    // The dial anchor includes its caption; only the round control is lit.
    final anchor = rect(target);
    final focus = _step == 0
        ? Rect.fromLTWH(anchor.left, anchor.top, anchor.width, anchor.width)
        : anchor;
    if (_screen != face || _target != focus) {
      setState(() {
        _screen = face;
        _target = focus;
      });
    }
  }

  void _advance() {
    if (_closing) return;
    if (_step == 2) {
      unawaited(_finish());
    } else {
      if (_step == 0) {
        unawaited(ref.read(radioControllerProvider.notifier).tuneRandom());
      }
      setState(() {
        _step++;
        _target = null;
      });
    }
  }

  Future<void> _finish() async {
    if (_closing) return;
    setState(() => _closing = true);
    final duration = AppMotion.standard(context);
    // Preserve the existing welcome-to-home route and cabinet Hero transition.
    await ref.read(welcomeSeenProvider.notifier).markSeen();
    if (!mounted) return;
    await Future<void>.delayed(duration);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = TravelRadioPalette.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_finish());
      },
      child: Material(
        color: palette.paper,
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: _closing ? 0 : 1,
              duration: AppMotion.standard(context),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 52,
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.medium),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (final (locale, label) in const [
                          (AppLocalization.english, LocaleKeys.english),
                          (AppLocalization.italian, LocaleKeys.italian),
                        ])
                          IconButton(
                            tooltip: label.tr(context: context),
                            isSelected: context.locale == locale,
                            color: context.locale == locale
                                ? theme.colorScheme.primary
                                : palette.muted,
                            icon: CodeBadge(locale.languageCode.toUpperCase()),
                            onPressed: _closing
                                ? null
                                : () => context.setLocale(locale),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _measure(),
                  );
                  return Stack(
                    key: _surface,
                    fit: StackFit.expand,
                    children: [
                      ExcludeSemantics(
                        child: IgnorePointer(
                          child: MediaQuery.removePadding(
                            context: context,
                            removeTop: true,
                            child: widget.builder(_targets),
                          ),
                        ),
                      ),
                      if (_screen != null && _target != null)
                        AnimatedOpacity(
                          opacity: _closing ? 0 : 1,
                          duration: AppMotion.standard(context),
                          child: _Guide(
                            screen: _screen!,
                            target: _target!,
                            step: _step,
                            onAdvance: _advance,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Guide extends StatelessWidget {
  const _Guide({
    required this.screen,
    required this.target,
    required this.step,
    required this.onAdvance,
  });
  final Rect screen, target;
  final int step;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final title = [
      LocaleKeys.tourStartTitle,
      LocaleKeys.tourFavoritesTitle,
      LocaleKeys.tourDiaryTitle,
    ][step].tr(context: context);
    final body = [
      LocaleKeys.welcomeBody,
      LocaleKeys.tourFavoritesBody,
      LocaleKeys.tourDiaryBody,
    ][step].tr(context: context);
    final hint = [
      LocaleKeys.welcomeHint,
      LocaleKeys.tourContinue,
      LocaleKeys.tourClose,
    ][step].tr(context: context);
    const ink = TravelRadioPalette.screenInk;
    return GestureDetector(
      key: const ValueKey('welcome-guide'),
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTapUp: (event) {
        if (step > 0 || target.contains(event.localPosition)) onAdvance();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GuidePainter(screen, target, step == 0),
            ),
          ),
          Positioned.fromRect(
            rect: screen,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TravelRadioPalette.screenHighlight,
                    TravelRadioPalette.screen,
                  ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  key: ValueKey('tour-copy-$step'),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Semantics(
                      container: true,
                      liveRegion: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.tourProgress.tr(
                                  context: context,
                                  args: ['${step + 1}'],
                                ),
                                style: TextStyle(
                                  color: ink.withValues(alpha: .7),
                                  fontSize: 13,
                                  fontFamily: 'monospace',
                                  letterSpacing: 1.4,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.large),
                              Semantics(
                                header: true,
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              Text(
                                body,
                                style: TextStyle(
                                  color: ink.withValues(alpha: .9),
                                  fontSize: 16,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.medium,
                            ),
                            child: Semantics(
                              button: true,
                              onTap: onAdvance,
                              child: Text(
                                hint,
                                style: TextStyle(
                                  color: ink.withValues(alpha: .7),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _Arrow(screen, target, step == 0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  const _GuidePainter(this.screen, this.target, this.knob);
  final Rect screen, target;
  final bool knob;
  @override
  void paint(Canvas canvas, Size size) {
    final focus = target.inflate(7);
    final shape = RRect.fromRectAndRadius(
      focus,
      Radius.circular(knob ? focus.width / 2 : 32),
    );
    final holes = Path()
      ..addRRect(RRect.fromRectAndRadius(screen, const Radius.circular(12)))
      ..addRRect(shape);
    final shade = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      holes,
    );
    canvas.drawPath(
      shade,
      Paint()..color = const Color(0xFF081810).withValues(alpha: .64),
    );
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = TravelRadioPalette.screenInk,
    );
  }

  @override
  bool shouldRepaint(covariant _GuidePainter old) =>
      old.screen != screen || old.target != target || old.knob != knob;
}

class _Arrow extends CustomPainter {
  const _Arrow(this.screen, this.target, this.knob);
  final Rect screen, target;
  final bool knob;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    if (knob) {
      final start = Offset(screen.right - 30, screen.bottom - 32);
      final end = Offset(target.center.dx, target.top - 8);
      path.moveTo(start.dx, start.dy);
      path.cubicTo(
        start.dx + 12,
        start.dy + 30,
        end.dx + 10,
        end.dy - 22,
        end.dx,
        end.dy,
      );
    } else {
      final start = Offset(screen.right - 24, screen.top + 26);
      final end = Offset(target.center.dx, target.bottom + 9);
      path.moveTo(start.dx, start.dy);
      path.cubicTo(
        math.min(size.width - 18, start.dx + 52),
        screen.top - 75,
        end.dx + 40,
        end.dy + 58,
        end.dx,
        end.dy,
      );
    }
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length)!;
    final point = tangent.position;
    final angle = tangent.angle;
    for (final delta in [-.5, .5]) {
      path.moveTo(point.dx, point.dy);
      path.lineTo(
        point.dx - 10 * math.cos(angle + delta),
        point.dy - 10 * math.sin(angle + delta),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF081810).withValues(alpha: .6),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = TravelRadioPalette.screenInk,
    );
  }

  @override
  bool shouldRepaint(covariant _Arrow old) =>
      old.screen != screen || old.target != target || old.knob != knob;
}
