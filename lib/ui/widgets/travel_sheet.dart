import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../l10n/locale_keys.g.dart';
import '../theme/app_spacing.dart';
import '../theme/travel_sheet_design.dart';
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
  ).ink.withValues(alpha: TravelSheetDesign.barrierOpacity),
  constraints: const BoxConstraints(maxWidth: TravelSheetDesign.maxWidth),
  builder: builder,
);

/// Presentation inside a modal route or inside an existing page.
enum TravelSheetPresentation { draggable, embedded }

/// The app's bottom sheet: surface, heading, close action and scrolling body.
/// Embedded sheets fit their contents up to the parent's height constraint.
class TravelSheet extends StatefulWidget {
  const TravelSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onClose,
    this.backgroundColor,
    this.foregroundColor,
    this.presentation = TravelSheetPresentation.draggable,
    required this.children,
  }) : assert(
         presentation != TravelSheetPresentation.embedded || onClose != null,
       );

  final String title;
  final String? subtitle;
  final Widget? leading, trailing;
  final VoidCallback? onClose;
  final Color? backgroundColor, foregroundColor;
  final TravelSheetPresentation presentation;
  final List<Widget> children;

  @override
  State<TravelSheet> createState() => _TravelSheetState();
}

class _TravelSheetState extends State<TravelSheet> {
  var _pulled = 0.0;

  void _close() => (widget.onClose ?? () => Navigator.of(context).pop())();

  bool _onScroll(ScrollNotification event) {
    if (widget.presentation != TravelSheetPresentation.embedded) return false;
    switch (event) {
      case OverscrollNotification(:final overscroll, dragDetails: _?)
          when overscroll < 0:
        _pulled -= overscroll;
        if (_pulled >= TravelSheetDesign.pullToClose) {
          _pulled = 0;
          _close();
        }
      case ScrollEndNotification() || ScrollStartNotification():
        _pulled = 0;
      default:
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.presentation == TravelSheetPresentation.embedded) {
      return _surface(context);
    }
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: TravelSheetDesign.initialHeight,
      minChildSize: TravelSheetDesign.minHeight,
      maxChildSize: TravelSheetDesign.maxHeight,
      // A route sheet has a messenger so undo notices appear above it.
      builder: (context, scroll) => ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: _surface(context, controller: scroll),
        ),
      ),
    );
  }

  Widget _surface(BuildContext context, {ScrollController? controller}) {
    final palette = TravelRadioPalette.of(context);
    final background = widget.backgroundColor ?? palette.paper;
    final ink = widget.foregroundColor ?? palette.ink;
    final muted = widget.foregroundColor == null
        ? palette.muted
        : ink.withValues(alpha: TravelSheetDesign.mutedOpacity);
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: TravelSheetDesign.radius,
        border: Border(top: BorderSide(color: palette.metalLight)),
        boxShadow: [
          BoxShadow(
            color: palette.ink.withValues(
              alpha: TravelSheetDesign.shadowOpacity,
            ),
            blurRadius: TravelSheetDesign.shadowBlur,
            offset: TravelSheetDesign.shadowOffset,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: TravelSheetDesign.radius,
        child: Material(
          color: background,
          child: SafeArea(
            top: false,
            bottom: widget.presentation == TravelSheetPresentation.draggable,
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: widget.title,
              child: DefaultTextStyle(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: ink),
                child: GestureDetector(
                  onVerticalDragEnd:
                      widget.presentation == TravelSheetPresentation.embedded
                      ? (details) {
                          if ((details.primaryVelocity ?? 0) > 0) _close();
                        }
                      : null,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: ListView(
                      primary: false,
                      controller: controller,
                      shrinkWrap:
                          widget.presentation ==
                          TravelSheetPresentation.embedded,
                      padding: TravelSheetDesign.padding,
                      children: [
                        _TravelSheetHeader(
                          onClose: _close,
                          foregroundColor: ink,
                          closeBackgroundColor: widget.foregroundColor == null
                              ? palette.paperRaised
                              : ink.withValues(
                                  alpha:
                                      TravelSheetDesign.closeBackgroundOpacity,
                                ),
                          title: Row(
                            children: [
                              if (widget.leading case final leading?) ...[
                                leading,
                                const SizedBox(width: AppSpacing.standard),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.merge(TravelSheetDesign.titleText)
                                          .copyWith(color: ink),
                                    ),
                                    if (widget.subtitle
                                        case final subtitle?) ...[
                                      const SizedBox(
                                        height: TravelSheetDesign.titleGap,
                                      ),
                                      Text(
                                        subtitle,
                                        style: TextStyle(color: muted),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (widget.trailing case final trailing?) ...[
                                const SizedBox(width: AppSpacing.standard),
                                Flexible(child: trailing),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: TravelSheetDesign.contentGap),
                        ...widget.children,
                      ],
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

/// Shared handle, heading and accessible close action for the app's sheets.
class _TravelSheetHeader extends StatelessWidget {
  const _TravelSheetHeader({
    required this.title,
    required this.onClose,
    required this.foregroundColor,
    required this.closeBackgroundColor,
  });

  final Widget title;
  final VoidCallback onClose;
  final Color foregroundColor, closeBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final ink = foregroundColor;
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
                    width: TravelSheetDesign.handleSize.width,
                    height: TravelSheetDesign.handleSize.height,
                    decoration: BoxDecoration(
                      color: ink.withValues(
                        alpha: TravelSheetDesign.handleOpacity,
                      ),
                      borderRadius: TravelSheetDesign.handleRadius,
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
                backgroundColor: closeBackgroundColor,
                foregroundColor: ink,
                tooltip: LocaleKeys.close.tr(context: context),
                onPressed: onClose,
                icon: const Icon(
                  Icons.close,
                  size: TravelSheetDesign.closeIconSize,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
