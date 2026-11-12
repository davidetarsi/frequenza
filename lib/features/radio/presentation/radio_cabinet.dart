import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../l10n/locale_keys.g.dart';
import '../../../ui/theme/app_spacing.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';
import '../../../ui/theme/app_motion.dart';
import '../../journey/presentation/journey_texts.dart';

class RadioCabinet extends StatelessWidget {
  const RadioCabinet({
    super.key,
    required this.country,
    required this.station,
    required this.detail,
    required this.status,
    required this.knobLabel,
    required this.tuneLabel,
    required this.onTune,
    required this.isBusy,
    required this.isPlaying,
    required this.compact,
    required this.horizontal,
    this.flying = false,
    this.landings = 0,
    this.map,
    this.localTime,
    this.tripLabel,
  });
  final String country, station, detail, status, knobLabel, tuneLabel;
  final VoidCallback? onTune;
  final bool isBusy, isPlaying, compact, horizontal;

  /// Shows [station] as a searching label instead of a name.
  final bool flying;

  /// Changes at each landing to bring the station name into focus.
  final int landings;

  /// Replaces the equalizer in the regular layout.
  final Widget? map;
  final Widget? localTime;
  final String? tripLabel;

  Widget _equalizer({required double height}) => SizedBox(
    height: height,
    width: double.infinity,
    child: ExcludeSemantics(child: _Equalizer(playing: isPlaying)),
  );

  @override
  Widget build(BuildContext context) {
    final p = TravelRadioPalette.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final metrics = compact
        ? RadioCabinetDesign.compact
        : RadioCabinetDesign.regular;
    final diameter = metrics.diameter;
    final stationFont = metrics.stationSize;
    final largeText =
        compact &&
        scaler.scale(TravelRadioLayout.referenceTextSize) >
            TravelRadioLayout.largeTextThreshold;
    final stationLines = largeText ? 1 : 2;
    final display = Container(
      padding: const EdgeInsets.all(RadioCabinetDesign.screenFrameInset),
      decoration: BoxDecoration(
        color: TravelRadioPalette.hardware,
        borderRadius: RadioCabinetDesign.screenFrameRadius,
        boxShadow: [
          BoxShadow(
            color: p.metalLight.withValues(
              alpha: RadioCabinetDesign.screenHighlightOpacity,
            ),
            offset: RadioCabinetDesign.screenHighlightOffset,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: metrics.screenInset,
          vertical: horizontal
              ? RadioCabinetDesign.screenLandscapeInset
              : metrics.screenInset,
        ),
        decoration: BoxDecoration(
          borderRadius: RadioCabinetDesign.screenRadius,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TravelRadioPalette.screenHighlight,
              TravelRadioPalette.screen,
            ],
          ),
          border: Border.all(color: TravelRadioPalette.screenBorder),
        ),
        child: DefaultTextStyle(
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: TravelRadioPalette.screenInk),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                country.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RadioCabinetDesign.countryText,
              ),
              SizedBox(height: metrics.countryGap),
              Semantics(
                liveRegion: true,
                child: SizedBox(
                  height:
                      scaler.scale(stationFont) *
                      stationLines *
                      RadioCabinetDesign.stationHeightFactor,
                  child: flying
                      ? FlightDots(
                          label: station,
                          maxLines: stationLines,
                          style: RadioCabinetDesign.stationText.copyWith(
                            fontSize: stationFont,
                          ),
                        )
                      : LandingFocus(
                          key: ValueKey(landings),
                          child: Text(
                            station,
                            maxLines: stationLines,
                            overflow: TextOverflow.ellipsis,
                            style: RadioCabinetDesign.stationText.copyWith(
                              fontSize: stationFont,
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: metrics.detailGap),
              SizedBox(
                height:
                    scaler.scale(RadioCabinetDesign.detailText.fontSize!) *
                    metrics.detailHeightFactor,
                child: Text(
                  detail,
                  maxLines: metrics.textLines,
                  overflow: TextOverflow.ellipsis,
                  style: RadioCabinetDesign.detailText,
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: RadioCabinetDesign.screenItemGap),
                if (map case final map?)
                  SizedBox(
                    height: RouteMapDesign.height,
                    width: double.infinity,
                    child: map,
                  )
                else
                  _equalizer(height: RadioEqualizerDesign.height),
              ],
              SizedBox(height: metrics.statusGap),
              Container(
                height: RadioCabinetDesign.hairline,
                color: TravelRadioPalette.screenInk.withValues(
                  alpha: RadioCabinetDesign.hairlineOpacity,
                ),
              ),
              SizedBox(height: metrics.statusGap),
              SizedBox(
                height:
                    scaler.scale(RadioCabinetDesign.statusText.fontSize!) *
                    metrics.statusHeightFactor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: RadioCabinetDesign.indicatorSize,
                      height: RadioCabinetDesign.indicatorSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TravelRadioPalette.screenInk,
                        boxShadow: !isBusy
                            ? [
                                BoxShadow(
                                  color: TravelRadioPalette.screenInk
                                      .withValues(
                                        alpha: RadioCabinetDesign
                                            .indicatorGlowOpacity,
                                      ),
                                  blurRadius: RadioCabinetDesign.indicatorSize,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.small),
                    Expanded(
                      flex: 3,
                      child: Text(
                        status,
                        maxLines: metrics.textLines,
                        overflow: TextOverflow.ellipsis,
                        style: RadioCabinetDesign.statusText,
                      ),
                    ),
                    if (localTime case final localTime?) ...[
                      const SizedBox(width: AppSpacing.small),
                      Flexible(flex: 2, child: localTime),
                    ],
                    if (compact) ...[
                      const SizedBox(width: AppSpacing.small),
                      SizedBox(
                        width: RadioEqualizerDesign.compactWidth,
                        child: _equalizer(
                          height: RadioEqualizerDesign.compactHeight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final controls = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox.square(
          key: const ValueKey('radio-speaker'),
          dimension: diameter,
          child: const CustomPaint(painter: _SpeakerPainter()),
        ),
        SizedBox(
          width: diameter,
          child: Column(
            children: [
              _TuningDial(
                palette: p,
                label: tuneLabel,
                onTap: onTune,
                diameter: diameter,
              ),
              SizedBox(height: metrics.dialLabelGap),
              SizedBox(
                height:
                    scaler.scale(metrics.dialLabelSize) *
                    metrics.dialLabelHeightFactor,
                child: Text(
                  knobLabel,
                  maxLines: metrics.textLines,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: RadioCabinetDesign.dialLabelText.copyWith(
                    color: p.ink,
                    fontSize: metrics.dialLabelSize,
                    height: compact
                        ? RadioCabinetDesign.dialLabelCompactHeight
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!horizontal)
          SizedBox(
            width: RadioCabinetDesign.handleWidth,
            height: metrics.handleHeight,
            child: const CustomPaint(painter: _HandlePainter()),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: RadioCabinetDesign.frameRadius,
            boxShadow: [
              BoxShadow(
                color: p.ink.withValues(
                  alpha: RadioCabinetDesign.frameShadowOpacity,
                ),
                offset: RadioCabinetDesign.frameShadowOffset,
                blurRadius: RadioCabinetDesign.frameShadowBlur,
              ),
              BoxShadow(
                color: p.trim,
                offset: RadioCabinetDesign.frameTrimOffset,
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(metrics.frameInset),
            decoration: BoxDecoration(
              borderRadius: RadioCabinetDesign.frameRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [p.metalLight, p.trim],
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(metrics.shellInset),
              decoration: BoxDecoration(
                borderRadius: RadioCabinetDesign.shellRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.shellTop, p.shellBottom],
                ),
                border: Border.all(
                  color: p.metalLight.withValues(
                    alpha: RadioCabinetDesign.shellBorderOpacity,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!compact) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            LocaleKeys.cabinetBrand.tr(context: context),
                            style: RadioCabinetDesign.brandText.copyWith(
                              color: p.ink,
                            ),
                          ),
                        ),
                        if (tripLabel case final tripLabel?) ...[
                          const SizedBox(width: AppSpacing.small),
                          Flexible(
                            child: Text(
                              tripLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: RadioCabinetDesign.brandText.copyWith(
                                color: p.ink,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: AppSpacing.small),
                        _Screw(color: p.trim),
                      ],
                    ),
                    const SizedBox(height: RadioCabinetDesign.brandGap),
                  ],
                  if (horizontal)
                    Row(
                      children: [
                        Expanded(child: display),
                        const SizedBox(width: AppSpacing.standard),
                        SizedBox(
                          width: diameter * 2 + AppSpacing.small,
                          child: controls,
                        ),
                      ],
                    )
                  else ...[
                    display,
                    SizedBox(height: metrics.controlsGap),
                    controls,
                  ],
                  if (!compact) ...[
                    const SizedBox(height: RadioCabinetDesign.trimGap),
                    Row(
                      children: [
                        _Screw(color: p.trim),
                        Expanded(
                          child: Container(
                            height: RadioCabinetDesign.hairline,
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.standard,
                            ),
                            color: p.trim.withValues(
                              alpha: RadioCabinetDesign.trimLineOpacity,
                            ),
                          ),
                        ),
                        _Screw(color: p.trim),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Screw extends StatelessWidget {
  const _Screw({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: RadioCabinetDesign.screwSize,
      height: RadioCabinetDesign.screwSize,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(
        child: Container(
          width: RadioCabinetDesign.screwSlotWidth,
          height: RadioCabinetDesign.hairline,
          color: TravelRadioPalette.hardware,
        ),
      ),
    ),
  );
}

class _HandlePainter extends CustomPainter {
  const _HandlePainter();
  @override
  void paint(Canvas canvas, Size size) {
    const side = RadioCabinetDesign.handleSideInset;
    const shoulder = RadioCabinetDesign.handleShoulder;
    const top = RadioCabinetDesign.handleTop;
    const corner = RadioCabinetDesign.handleCornerEnd;
    final path = Path()
      ..moveTo(side, size.height)
      ..lineTo(side, shoulder)
      ..quadraticBezierTo(side, top, corner, top)
      ..lineTo(size.width - corner, top)
      ..quadraticBezierTo(size.width - side, top, size.width - side, shoulder)
      ..lineTo(size.width - side, size.height);
    canvas.drawPath(
      path,
      Paint()
        ..color = TravelRadioPalette.hardware
        ..style = PaintingStyle.stroke
        ..strokeWidth = RadioCabinetDesign.handleStroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path.shift(RadioCabinetDesign.handleHighlightOffset),
      Paint()
        ..color = TravelRadioPalette.handleHighlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = RadioCabinetDesign.hairline,
    );
  }

  @override
  bool shouldRepaint(covariant _HandlePainter oldDelegate) => false;
}

class _DialTicks extends CustomPainter {
  const _DialTicks(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = size.shortestSide / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = RadioCabinetDesign.dialTickStroke;
    for (var i = 0; i < RadioCabinetDesign.dialTickCount; i++) {
      final a =
          (RadioCabinetDesign.dialTickSweepStart +
              i * RadioCabinetDesign.dialTickStep) *
          math.pi /
          180;
      canvas.drawLine(
        c +
            Offset(math.cos(a), math.sin(a)) *
                (r - RadioCabinetDesign.hairline),
        c +
            Offset(math.cos(a), math.sin(a)) *
                (r -
                    (i % RadioCabinetDesign.dialLongTickEvery == 0
                        ? RadioCabinetDesign.dialLongTickInset
                        : RadioCabinetDesign.dialShortTickInset)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DialTicks oldDelegate) =>
      color != oldDelegate.color;
}

class _SpeakerPainter extends CustomPainter {
  const _SpeakerPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero), r = size.shortestSide / 2;
    canvas.drawCircle(c, r, Paint()..color = TravelRadioPalette.hardware);
    canvas.drawCircle(
      c,
      r - RadioCabinetDesign.speakerRimInset,
      Paint()..color = TravelRadioPalette.speakerRim,
    );
    canvas.drawCircle(
      c,
      r - RadioCabinetDesign.speakerMeshInset,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            TravelRadioPalette.speakerMeshLight,
            TravelRadioPalette.speakerMeshDark,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final paint = Paint()..color = TravelRadioPalette.speakerPerforation;
    const grid = RadioCabinetDesign.speakerPerforationGrid;
    const spacing = RadioCabinetDesign.speakerPerforationSpacing;
    for (var y = -grid; y <= grid; y++) {
      for (var x = -grid; x <= grid; x++) {
        final offset = Offset(
          x * spacing + (y.isOdd ? spacing / 2 : 0),
          y * spacing,
        );
        if (offset.distance < r - RadioCabinetDesign.speakerPerforationInset) {
          canvas.drawCircle(
            c + offset,
            RadioCabinetDesign.speakerPerforationRadius,
            paint,
          );
        }
      }
    }
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - RadioCabinetDesign.hairline),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = TravelRadioPalette.speakerRimHighlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = RadioCabinetDesign.hairline,
    );
  }

  @override
  bool shouldRepaint(covariant _SpeakerPainter oldDelegate) => false;
}

class _TuningDial extends StatelessWidget {
  const _TuningDial({
    required this.palette,
    required this.label,
    required this.onTap,
    required this.diameter,
  });
  final TravelRadioPalette palette;
  final String label;
  final VoidCallback? onTap;
  final double diameter;
  @override
  Widget build(BuildContext context) {
    final face = Ink(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.metalLight, palette.metalDark, palette.metalLight],
        ),
        border: Border.all(
          color: TravelRadioPalette.hardware,
          width: RadioCabinetDesign.dialBorderWidth,
        ),
      ),
      child: InkWell(
        key: const ValueKey('tune-knob'),
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: diameter * RadioCabinetDesign.dialRingRatio,
                height: diameter * RadioCabinetDesign.dialRingRatio,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.metalDark),
                ),
              ),
              Positioned(
                top: RadioCabinetDesign.dialMarkerTop,
                child: Container(
                  width: RadioCabinetDesign.dialMarkerWidth,
                  height: RadioCabinetDesign.dialMarkerHeight,
                  decoration: BoxDecoration(
                    color: TravelRadioPalette.accent,
                    borderRadius: RadioCabinetDesign.dialMarkerRadius,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Semantics(
      label: label,
      button: true,
      enabled: onTap != null,
      onTap: onTap,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: diameter,
          child: CustomPaint(
            key: const ValueKey('radio-dial-face'),
            painter: _DialTicks(palette.trim),
            child: Padding(
              padding: const EdgeInsets.all(RadioCabinetDesign.dialTickInset),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: palette.ink.withValues(
                        alpha: RadioCabinetDesign.dialShadowOpacity,
                      ),
                      blurRadius: RadioCabinetDesign.dialShadowBlur,
                      offset: RadioCabinetDesign.dialShadowOffset,
                    ),
                  ],
                ),
                child: Material(
                  color: TravelRadioPalette.hardware,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: face,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Equalizer extends StatefulWidget {
  const _Equalizer({required this.playing});

  final bool playing;

  @override
  State<_Equalizer> createState() => _EqualizerState();
}

class _EqualizerState extends State<_Equalizer>
    with SingleTickerProviderStateMixin {
  late final _phase = AnimationController(
    vsync: this,
    duration: RadioEqualizerDesign.cycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(_Equalizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playing != widget.playing) _updateMotion();
  }

  void _updateMotion() {
    if (widget.playing && AppMotion.enabled(context)) {
      if (!_phase.isAnimating) _phase.repeat();
    } else {
      _phase.stop();
    }
  }

  @override
  void dispose() {
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(
      key: const ValueKey('radio-equalizer'),
      painter: _EqualizerPainter(phase: _phase, playing: widget.playing),
    ),
  );
}

class _EqualizerPainter extends CustomPainter {
  _EqualizerPainter({required this.phase, required this.playing})
    : super(repaint: phase);

  final Animation<double> phase;
  final bool playing;

  @override
  void paint(Canvas canvas, Size size) {
    const levels = RadioEqualizerDesign.levels;
    final columnWidth = size.width / levels.length;
    final step = size.height / RadioEqualizerDesign.segments;
    final angle = phase.value * 2 * math.pi;
    final paint = Paint()
      ..color = TravelRadioPalette.screenInk.withValues(
        alpha: playing
            ? RadioEqualizerDesign.activeOpacity
            : RadioEqualizerDesign.idleOpacity,
      );
    for (var column = 0; column < levels.length; column++) {
      final variation =
          math.sin(
                angle * RadioEqualizerDesign.primaryHarmonic +
                    column * RadioEqualizerDesign.primaryColumnPhase,
              ) *
              RadioEqualizerDesign.primaryAmplitude +
          math.sin(
            angle * RadioEqualizerDesign.secondaryHarmonic -
                column * RadioEqualizerDesign.secondaryColumnPhase,
          );
      final level = (levels[column] + variation).round().clamp(
        1,
        RadioEqualizerDesign.segments,
      );
      for (var segment = 0; segment < level; segment++) {
        canvas.drawRect(
          Rect.fromLTWH(
            column * columnWidth + RadioEqualizerDesign.segmentSideInset,
            size.height - (segment + 1) * step,
            columnWidth - RadioEqualizerDesign.segmentSideInset * 2,
            step * RadioEqualizerDesign.segmentHeightRatio,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_EqualizerPainter oldDelegate) =>
      playing != oldDelegate.playing || phase != oldDelegate.phase;
}
