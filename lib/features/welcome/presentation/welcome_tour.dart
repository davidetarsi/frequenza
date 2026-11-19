import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_localization.dart';
import '../../../app/localization/presentation/change_language.dart';
import '../../../app/routing/app_router.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_motion.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/theme/welcome_tour_design.dart';
import '../../../ui/widgets/code_badge.dart';
import '../../radio/presentation/radio_page.dart';
import '../application/welcome_controller.dart';
import '../domain/welcome_session.dart';

class WelcomeTour extends ConsumerStatefulWidget {
  const WelcomeTour({super.key, required this.builder});
  final Widget Function(RadioPageAnchors targets) builder;

  @override
  ConsumerState<WelcomeTour> createState() => _WelcomeTourState();
}

class _WelcomeTourState extends ConsumerState<WelcomeTour> {
  final _targets = RadioPageAnchors();
  final _surface = GlobalKey();
  Rect? _screen, _target;

  void _measure() {
    if (!mounted) return;
    final surface = _surface.currentContext?.findRenderObject();
    final screen = _targets.screen.currentContext?.findRenderObject();
    final step = ref.read(welcomeControllerProvider).step;
    final key = switch (step) {
      WelcomeStep.radio => _targets.dial,
      WelcomeStep.favorites => _targets.favorites,
      WelcomeStep.diary => _targets.diary,
    };
    final target = key.currentContext?.findRenderObject();
    if (surface is! RenderBox || screen is! RenderBox || target is! RenderBox) {
      return;
    }
    Rect rect(RenderBox box) =>
        surface.globalToLocal(box.localToGlobal(Offset.zero)) & box.size;
    final face = rect(screen).deflate(
      RadioCabinetDesign.screenFrameInset + WelcomeTourDesign.screenInset,
    );
    // The dial anchor includes its caption; only the round control is lit.
    final anchor = rect(target);
    final focus = step == WelcomeStep.radio
        ? Rect.fromLTWH(anchor.left, anchor.top, anchor.width, anchor.width)
        : anchor;
    if (_screen != face || _target != focus) {
      setState(() {
        _screen = face;
        _target = focus;
      });
    }
  }

  void _advance() => ref.read(welcomeControllerProvider.notifier).advance();

  Future<void> _leave() async {
    // Timing and navigation belong to presentation; the controller has already
    // recorded completion. Preserve the existing route and cabinet Hero.
    final duration = AppMotion.standard(context);
    await Future<void>.delayed(duration);
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(welcomeControllerProvider);
    ref.listen(welcomeControllerProvider, (before, after) {
      if (before?.step != after.step) {
        setState(() => _target = null);
      }
      if (after is WelcomeCompleted) unawaited(_leave());
    });
    final theme = Theme.of(context);
    final palette = TravelRadioPalette.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(welcomeControllerProvider.notifier).dismiss();
      },
      child: Material(
        color: palette.paper,
        child: Column(
          children: [
            AnimatedOpacity(
              opacity: session.isClosing ? 0 : 1,
              duration: AppMotion.standard(context),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: WelcomeTourDesign.languageBarHeight,
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
                            onPressed: session.isClosing
                                ? null
                                : () => changeLanguage(context, ref, locale),
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
                          opacity: session.isClosing ? 0 : 1,
                          duration: AppMotion.standard(context),
                          child: _Guide(
                            screen: _screen!,
                            target: _target!,
                            step: session.step,
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
  final WelcomeStep step;
  final VoidCallback onAdvance;

  @override
  Widget build(BuildContext context) {
    final title = switch (step) {
      WelcomeStep.radio => LocaleKeys.tourStartTitle,
      WelcomeStep.favorites => LocaleKeys.tourFavoritesTitle,
      WelcomeStep.diary => LocaleKeys.tourDiaryTitle,
    }.tr(context: context);
    final body = switch (step) {
      WelcomeStep.radio => LocaleKeys.welcomeBody,
      WelcomeStep.favorites => LocaleKeys.tourFavoritesBody,
      WelcomeStep.diary => LocaleKeys.tourDiaryBody,
    }.tr(context: context);
    final hint = switch (step) {
      WelcomeStep.radio => LocaleKeys.welcomeHint,
      WelcomeStep.favorites => LocaleKeys.tourContinue,
      WelcomeStep.diary => LocaleKeys.tourClose,
    }.tr(context: context);
    return GestureDetector(
      key: const ValueKey('welcome-guide'),
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTapUp: (event) {
        if (step != WelcomeStep.radio || target.contains(event.localPosition)) {
          onAdvance();
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GuidePainter(screen, target, step == WelcomeStep.radio),
            ),
          ),
          Positioned.fromRect(
            rect: screen,
            child: Container(
              padding: WelcomeTourDesign.copyPadding,
              decoration: WelcomeTourDesign.copyDecoration,
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  key: ValueKey('tour-copy-${step.index}'),
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
                                  args: ['${step.index + 1}'],
                                ),
                                style: WelcomeTourDesign.progressText,
                              ),
                              const SizedBox(height: AppSpacing.large),
                              Semantics(
                                header: true,
                                child: Text(
                                  title,
                                  style: WelcomeTourDesign.titleText,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.medium),
                              Text(body, style: WelcomeTourDesign.bodyText),
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
                                style: WelcomeTourDesign.hintText,
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
              child: CustomPaint(
                painter: _Arrow(screen, target, step == WelcomeStep.radio),
              ),
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
    final focus = target.inflate(WelcomeTourDesign.focusOutset);
    final shape = RRect.fromRectAndRadius(
      focus,
      knob ? Radius.circular(focus.width / 2) : WelcomeTourDesign.actionRadius,
    );
    final holes = Path()
      ..addRRect(RRect.fromRectAndRadius(screen, WelcomeTourDesign.copyRadius))
      ..addRRect(shape);
    final shade = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      holes,
    );
    canvas.drawPath(shade, Paint()..color = WelcomeTourDesign.shade);
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = WelcomeTourDesign.focusStroke
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
      final start = screen.bottomRight + WelcomeTourDesign.dialArrowStart;
      final end = Offset(
        target.center.dx,
        target.top - WelcomeTourDesign.dialArrowGap,
      );
      path.moveTo(start.dx, start.dy);
      path.cubicTo(
        start.dx + WelcomeTourDesign.dialArrowFirstControl.dx,
        start.dy + WelcomeTourDesign.dialArrowFirstControl.dy,
        end.dx + WelcomeTourDesign.dialArrowLastControl.dx,
        end.dy + WelcomeTourDesign.dialArrowLastControl.dy,
        end.dx,
        end.dy,
      );
    } else {
      final start = screen.topRight + WelcomeTourDesign.actionArrowStart;
      final end = Offset(
        target.center.dx,
        target.bottom + WelcomeTourDesign.actionArrowGap,
      );
      path.moveTo(start.dx, start.dy);
      path.cubicTo(
        math.min(
          size.width - WelcomeTourDesign.actionArrowSideInset,
          start.dx + WelcomeTourDesign.actionArrowBend,
        ),
        screen.top - WelcomeTourDesign.actionArrowRise,
        end.dx + WelcomeTourDesign.actionArrowLastControl.dx,
        end.dy + WelcomeTourDesign.actionArrowLastControl.dy,
        end.dx,
        end.dy,
      );
    }
    final metric = path.computeMetrics().first;
    final tangent = metric.getTangentForOffset(metric.length)!;
    final point = tangent.position;
    final angle = tangent.angle;
    for (final delta in [
      -WelcomeTourDesign.arrowHeadSpread,
      WelcomeTourDesign.arrowHeadSpread,
    ]) {
      path.moveTo(point.dx, point.dy);
      path.lineTo(
        point.dx - WelcomeTourDesign.arrowHeadLength * math.cos(angle + delta),
        point.dy - WelcomeTourDesign.arrowHeadLength * math.sin(angle + delta),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = WelcomeTourDesign.arrowShadowStroke
        ..strokeCap = StrokeCap.round
        ..color = WelcomeTourDesign.arrowShadow,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = WelcomeTourDesign.arrowStroke
        ..strokeCap = StrokeCap.round
        ..color = TravelRadioPalette.screenInk,
    );
  }

  @override
  bool shouldRepaint(covariant _Arrow old) =>
      old.screen != screen || old.target != target || old.knob != knob;
}
