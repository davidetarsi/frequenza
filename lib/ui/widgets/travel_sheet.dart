import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../l10n/locale_keys.g.dart';
import '../theme/app_spacing.dart';
import '../theme/travel_radio_design.dart';
import '../theme/travel_radio_palette.dart';
import 'app_icon_button.dart';

/// Opens a [TravelSheet] from the bottom, over the dimmed radio.
Future<void> showTravelSheet(
  BuildContext context, {
  required WidgetBuilder builder,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: Colors.transparent,
  elevation: 0,
  barrierColor: TravelRadioPalette.of(
    context,
  ).ink.withValues(alpha: RadioFavoritesDesign.barrierOpacity),
  constraints: const BoxConstraints(maxWidth: RadioFavoritesDesign.maxWidth),
  builder: builder,
);

/// The paper drawer shared by favorites and settings: handle, title,
/// optional subtitle and close button, then [children] in a draggable list.
class TravelSheet extends StatelessWidget {
  const TravelSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });
  final String title;
  final String? subtitle;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final p = TravelRadioPalette.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: RadioFavoritesDesign.initialHeight,
      minChildSize: RadioFavoritesDesign.minHeight,
      maxChildSize: RadioFavoritesDesign.maxHeight,
      builder: (context, scroll) => Container(
        decoration: BoxDecoration(
          color: p.paper,
          borderRadius: RadioFavoritesDesign.sheetRadius,
          border: Border(top: BorderSide(color: p.metalLight)),
          boxShadow: [
            BoxShadow(
              color: p.ink.withValues(
                alpha: RadioFavoritesDesign.shadowOpacity,
              ),
              blurRadius: RadioFavoritesDesign.shadowBlur,
              offset: RadioFavoritesDesign.shadowOffset,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: RadioFavoritesDesign.sheetRadius,
          child: Material(
            color: p.paper,
            child: SafeArea(
              top: false,
              child: ListView(
                controller: scroll,
                padding: RadioFavoritesDesign.sheetPadding,
                children: [
                  Center(
                    child: Container(
                      width: RadioFavoritesDesign.handleSize.width,
                      height: RadioFavoritesDesign.handleSize.height,
                      decoration: BoxDecoration(
                        color: p.trim,
                        borderRadius: RadioFavoritesDesign.handleRadius,
                      ),
                    ),
                  ),
                  const SizedBox(height: RadioFavoritesDesign.headerGap),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: p.ink,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing:
                                        RadioFavoritesDesign.titleTracking,
                                  ),
                            ),
                            if (subtitle case final subtitle?) ...[
                              const SizedBox(
                                height: RadioFavoritesDesign.titleGap,
                              ),
                              Text(subtitle, style: TextStyle(color: p.muted)),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.standard),
                      AppIconButton(
                        variant: AppIconButtonVariant.tonal,
                        backgroundColor: p.paperRaised,
                        foregroundColor: p.ink,
                        tooltip: LocaleKeys.close.tr(context: context),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          size: RadioFavoritesDesign.closeIconSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RadioFavoritesDesign.contentGap),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
