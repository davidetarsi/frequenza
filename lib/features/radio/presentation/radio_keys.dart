import 'package:flutter/material.dart';
import '../../../ui/theme/travel_radio_design.dart';
import '../../../ui/theme/travel_radio_palette.dart';

/// A piano key on the radio: an icon only, its name for tooltips and
/// TalkBack. [down] keeps it pressed in, the way a latched key shows that
/// the radio is paused or the station is saved.
class RadioKey extends StatelessWidget {
  const RadioKey({
    super.key,
    required this.icon,
    required this.label,
    required this.down,
    required this.onPressed,
    this.iconColor,
  });
  final IconData icon;
  final String label;
  final bool down;
  final VoidCallback? onPressed;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    final p = TravelRadioPalette.of(context);
    final enabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      toggled: down,
      label: label,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: Tooltip(
          message: label,
          excludeFromSemantics: true,
          child: Opacity(
            opacity: enabled ? 1 : RadioKeyDesign.disabledOpacity,
            child: AnimatedSlide(
              offset: down ? RadioKeyDesign.downSlide : Offset.zero,
              duration: RadioKeyDesign.travel,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: RadioKeyDesign.radius,
                  boxShadow: down
                      ? null
                      : [
                          const BoxShadow(
                            color: TravelRadioPalette.hardware,
                            offset: RadioKeyDesign.edgeOffset,
                          ),
                          BoxShadow(
                            color: p.ink.withValues(
                              alpha: RadioKeyDesign.shadowOpacity,
                            ),
                            offset: RadioKeyDesign.shadowOffset,
                            blurRadius: RadioKeyDesign.shadowBlur,
                          ),
                        ],
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: RadioKeyDesign.radius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: down
                            ? [p.metalDark, p.metalLight]
                            : [p.metalLight, p.metalDark],
                      ),
                    ),
                    child: InkWell(
                      onTap: onPressed,
                      borderRadius: RadioKeyDesign.radius,
                      child: Center(
                        child: Icon(
                          icon,
                          size: RadioKeyDesign.iconSize,
                          color: iconColor ?? TravelRadioPalette.screen,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The recessed slot holding the radio's two keys side by side.
class RadioKeys extends StatelessWidget {
  const RadioKeys({
    super.key,
    required this.play,
    required this.save,
    required this.height,
  });
  final RadioKey play, save;
  final double height;
  @override
  Widget build(BuildContext context) {
    final p = TravelRadioPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(RadioKeyDesign.slotPadding),
      decoration: BoxDecoration(
        color: TravelRadioPalette.hardware,
        borderRadius: RadioKeyDesign.slotRadius,
        boxShadow: [
          BoxShadow(
            color: p.metalLight.withValues(
              alpha: RadioKeyDesign.slotHighlightOpacity,
            ),
            offset: RadioKeyDesign.slotHighlightOffset,
          ),
        ],
      ),
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: play),
            const SizedBox(width: RadioKeyDesign.slotPadding),
            Expanded(child: save),
          ],
        ),
      ),
    );
  }
}
