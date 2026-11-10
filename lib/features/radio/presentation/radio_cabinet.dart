import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../ui/theme/travel_radio_palette.dart';

/// Static receiver. Interactive motion is deliberately deferred.
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
  });
  final String country, station, detail, status, knobLabel, tuneLabel;
  final VoidCallback? onTune;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final p = TravelRadioPalette.of(context);
    return Column(
      children: [
        const SizedBox(
          width: 156,
          height: 34,
          child: CustomPaint(painter: _HandlePainter()),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: p.ink.withValues(alpha: .18),
                offset: const Offset(0, 12),
                blurRadius: 22,
              ),
              BoxShadow(color: p.trim, offset: const Offset(0, 6)),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [p.metalLight, p.trim],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(23),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.shellTop, p.shellBottom],
                ),
                border: Border.all(color: p.metalLight.withValues(alpha: .65)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'F / RADIO',
                          style: TextStyle(
                            color: p.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _Screw(color: p.trim),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: TravelRadioPalette.hardware,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: p.metalLight.withValues(alpha: .7),
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF162F28),
                            TravelRadioPalette.screen,
                          ],
                        ),
                        border: Border.all(color: const Color(0xFF52634C)),
                      ),
                      child: DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: TravelRadioPalette.screenInk,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              country.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                letterSpacing: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                station,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600,
                                  height: 1.15,
                                ),
                              ),
                            ),
                            if (detail.isNotEmpty) ...[
                              const SizedBox(height: 9),
                              Text(detail),
                            ],
                            const SizedBox(height: 18),
                            Container(
                              height: 1,
                              color: TravelRadioPalette.screenInk.withValues(
                                alpha: .18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: TravelRadioPalette.screenInk,
                                    boxShadow: !isBusy
                                        ? [
                                            BoxShadow(
                                              color: TravelRadioPalette
                                                  .screenInk
                                                  .withValues(alpha: .35),
                                              blurRadius: 7,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    status,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final speaker =
                          constraints.maxWidth >= 240 &&
                          MediaQuery.textScalerOf(context).scale(1) < 1.5;
                      return Row(
                        mainAxisAlignment: speaker
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.center,
                        children: [
                          if (speaker)
                            const RepaintBoundary(
                              child: SizedBox.square(
                                dimension: 112,
                                child: CustomPaint(painter: _SpeakerPainter()),
                              ),
                            ),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _TuningDial(
                                  palette: p,
                                  label: tuneLabel,
                                  onTap: onTune,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  knobLabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: p.ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _Screw(color: p.trim),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          color: p.trim.withValues(alpha: .6),
                        ),
                      ),
                      _Screw(color: p.trim),
                    ],
                  ),
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
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(
        child: Container(
          width: 4,
          height: 1,
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
    final path = Path()
      ..moveTo(8, size.height)
      ..lineTo(8, 17)
      ..quadraticBezierTo(8, 6, 21, 6)
      ..lineTo(size.width - 21, 6)
      ..quadraticBezierTo(size.width - 8, 6, size.width - 8, 17)
      ..lineTo(size.width - 8, size.height);
    canvas.drawPath(
      path,
      Paint()
        ..color = TravelRadioPalette.hardware
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path.shift(const Offset(0, -2)),
      Paint()
        ..color = const Color(0xFF73816A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
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
      ..strokeWidth = 1.5;
    for (var i = 0; i < 21; i++) {
      final a = (135 + i * 13.5) * math.pi / 180;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * (r - 1),
        c + Offset(math.cos(a), math.sin(a)) * (r - (i % 5 == 0 ? 6 : 4)),
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
    canvas.drawCircle(c, r - 3, Paint()..color = const Color(0xFF8B947C));
    canvas.drawCircle(
      c,
      r - 6,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF68735D), Color(0xFF283C30)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final paint = Paint()..color = const Color(0xFF172B23);
    for (var y = -9; y <= 9; y++) {
      for (var x = -9; x <= 9; x++) {
        final offset = Offset(x * 5.5 + (y.isOdd ? 2.75 : 0), y * 5.5);
        if (offset.distance < r - 9) canvas.drawCircle(c + offset, 1.25, paint);
      }
    }
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - 1),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFFA9B199)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
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
  });
  final TravelRadioPalette palette;
  final String label;
  final VoidCallback? onTap;
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
        border: Border.all(color: TravelRadioPalette.hardware, width: 4),
      ),
      child: InkWell(
        key: const ValueKey('tune-knob'),
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.metalDark),
                ),
              ),
              Positioned(
                top: 8,
                child: Container(
                  width: 4,
                  height: 17,
                  decoration: BoxDecoration(
                    color: TravelRadioPalette.accent,
                    borderRadius: BorderRadius.circular(3),
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
        child: CustomPaint(
          painter: _DialTicks(palette.trim),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: palette.ink.withValues(alpha: .25),
                    blurRadius: 8,
                    offset: const Offset(0, 5),
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
    );
  }
}
