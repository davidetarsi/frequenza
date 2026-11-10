import 'package:flutter/material.dart';

/// Static cabinet: motion will be designed after the layout is validated.
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final casing = dark ? const Color(0xFF525950) : const Color(0xFFDED8C5);
    final ink = dark ? const Color(0xFFF1F0DE) : const Color(0xFF203E38);
    const screenInk = Color(0xFFE2E8C3);
    return Column(
      children: [
        Container(
          width: 150,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF354C41), width: 9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: casing,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF969C89)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                offset: Offset(0, 7),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'F / RADIO',
                style: TextStyle(color: ink, letterSpacing: 2, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF213D35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF354C41), width: 4),
                ),
                child: DefaultTextStyle(
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: screenInk),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        country.toUpperCase(),
                        style: const TextStyle(fontSize: 12, letterSpacing: 1),
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          station,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (detail.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(detail),
                      ],
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Icon(
                            isBusy ? Icons.more_horiz : Icons.circle,
                            size: 10,
                            color: screenInk,
                          ),
                          Text(status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final showSpeaker =
                      constraints.maxWidth >= 240 &&
                      MediaQuery.textScalerOf(context).scale(1) < 1.5;
                  final knob = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Semantics(
                        label: tuneLabel,
                        button: true,
                        enabled: onTune != null,
                        onTap: onTune,
                        child: ExcludeSemantics(
                          child: Material(
                            color: const Color(0xFFB6BCA2),
                            shape: CircleBorder(
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 4,
                              ),
                            ),
                            child: InkWell(
                              key: const ValueKey('tune-knob'),
                              onTap: onTune,
                              customBorder: const CircleBorder(),
                              child: SizedBox.square(
                                dimension: 100,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 4,
                                    height: 20,
                                    margin: const EdgeInsets.only(top: 9),
                                    color: const Color(0xFF354C41),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        knobLabel,
                        style: TextStyle(
                          color: ink,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  );
                  return Row(
                    mainAxisAlignment: showSpeaker
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      if (showSpeaker)
                        const SizedBox.square(
                          dimension: 108,
                          child: CustomPaint(painter: _SpeakerPainter()),
                        ),
                      Flexible(child: knob),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpeakerPainter extends CustomPainter {
  const _SpeakerPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero), r = size.shortestSide / 2;
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFF354C41));
    final paint = Paint()..color = const Color(0xFF172B23);
    for (var y = -8; y <= 8; y++) {
      for (var x = -8; x <= 8; x++) {
        final p = Offset(x * 6.0, y * 6.0);
        if (p.distance < r - 8) canvas.drawCircle(center + p, 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpeakerPainter oldDelegate) => false;
}
