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
/// Snack bars shown from inside it appear at its bottom.
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
          // Its own messenger: an undo shows over the sheet, not under it.
          child: ScaffoldMessenger(
            child: Scaffold(
              backgroundColor: p.paper,
              body: SafeArea(
                top: false,
                child: ListView(
                  controller: scroll,
                  padding: RadioFavoritesDesign.sheetPadding,
                  children: [
                    TravelSheetHeader(
                      onClose: () => Navigator.pop(context),
                      title: Column(
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
                    const SizedBox(height: RadioFavoritesDesign.contentGap),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared handle, heading and accessible close action for the app's sheets.
class TravelSheetHeader extends StatelessWidget {
  const TravelSheetHeader({
    super.key,
    required this.title,
    required this.onClose,
    this.foregroundColor,
    this.closeBackgroundColor,
  });

  final Widget title;
  final VoidCallback onClose;
  final Color? foregroundColor, closeBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = TravelRadioPalette.of(context);
    final ink = foregroundColor ?? palette.ink;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: SizedBox.square(
                dimension: kMinInteractiveDimension,
                child: Center(
                  child: Container(
                    width: RadioFavoritesDesign.handleSize.width,
                    height: RadioFavoritesDesign.handleSize.height,
                    decoration: BoxDecoration(
                      color: ink.withValues(alpha: 0.6),
                      borderRadius: RadioFavoritesDesign.handleRadius,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: AppSpacing.standard),
            SizedBox.square(
              dimension: kMinInteractiveDimension,
              child: AppIconButton(
                variant: AppIconButtonVariant.tonal,
                backgroundColor: closeBackgroundColor ?? palette.paperRaised,
                foregroundColor: ink,
                tooltip: LocaleKeys.close.tr(context: context),
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  size: RadioFavoritesDesign.closeIconSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
