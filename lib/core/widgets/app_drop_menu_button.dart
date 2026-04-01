import 'package:flutter/material.dart';
import 'package:rms_clone/core/constants/app_colors.dart';

enum AppDropMenuEntryType { action, divider }

class AppDropMenuEntry<T> {
  const AppDropMenuEntry.action({
    required this.value,
    required this.label,
    this.icon,
    this.isDanger = false,
  }) : type = AppDropMenuEntryType.action;

  const AppDropMenuEntry.divider()
    : type = AppDropMenuEntryType.divider,
      value = null,
      label = null,
      icon = null,
      isDanger = false;

  final AppDropMenuEntryType type;
  final T? value;
  final String? label;
  final IconData? icon;
  final bool isDanger;
}

class AppDropMenuButton<T> extends StatefulWidget {
  const AppDropMenuButton({
    super.key,
    required this.child,
    required this.entries,
    required this.onSelected,
    this.menuExtraWidth = 160,
    this.menuMinWidth = 190,
    this.menuMaxWidth = 280,
    this.menuOffsetY = 6,
    this.menuBorderRadius = AppRadii.r12,
    this.triggerBorderRadius,
    this.triggerHoverColor,
  });

  final Widget child;
  final List<AppDropMenuEntry<T>> entries;
  final ValueChanged<T> onSelected;
  final double menuExtraWidth;
  final double menuMinWidth;
  final double menuMaxWidth;
  final double menuOffsetY;
  final double menuBorderRadius;
  final BorderRadius? triggerBorderRadius;
  final Color? triggerHoverColor;

  @override
  State<AppDropMenuButton<T>> createState() => _AppDropMenuButtonState<T>();
}

class _AppDropMenuButtonState<T> extends State<AppDropMenuButton<T>> {
  final GlobalKey _anchorKey = GlobalKey();

  Future<void> _openMenu() async {
    final anchorContext = _anchorKey.currentContext;
    if (anchorContext == null) {
      return;
    }
    final overlayObject = Overlay.of(context).context.findRenderObject();
    if (overlayObject is! RenderBox) {
      return;
    }
    final anchorObject = anchorContext.findRenderObject();
    if (anchorObject is! RenderBox) {
      return;
    }

    final anchorOffset = anchorObject.localToGlobal(
      Offset.zero,
      ancestor: overlayObject,
    );
    final position = RelativeRect.fromLTRB(
      anchorOffset.dx,
      anchorOffset.dy + anchorObject.size.height + widget.menuOffsetY,
      overlayObject.size.width - anchorOffset.dx - anchorObject.size.width,
      overlayObject.size.height - anchorOffset.dy,
    );

    final double menuWidth = (anchorObject.size.width + widget.menuExtraWidth)
        .clamp(widget.menuMinWidth, widget.menuMaxWidth)
        .toDouble();

    final double dividerWidth = (menuWidth - 44)
        .clamp(80, menuWidth)
        .toDouble();

    final selected = await showMenu<T>(
      context: context,
      position: position,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: AppElevations.menu,
      shadowColor: Colors.black.withValues(alpha: AppAlphas.shadow28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(widget.menuBorderRadius),
      ),
      constraints: BoxConstraints(minWidth: menuWidth, maxWidth: menuWidth),
      items: [
        for (final entry in widget.entries)
          if (entry.type == AppDropMenuEntryType.divider)
            PopupMenuItem<T>(
              enabled: false,
              padding: EdgeInsets.zero,
              height: AppHeights.chip16,
              child: Center(
                child: Container(
                  width: dividerWidth,
                  height: 1,
                  color: AppColors.secondary.withValues(
                    alpha: AppAlphas.separator35,
                  ),
                ),
              ),
            )
          else
            PopupMenuItem<T>(
              enabled: false,
              padding: EdgeInsets.zero,
              child: _AppDropMenuItem(
                icon: entry.icon,
                label: entry.label ?? '',
                isDanger: entry.isDanger,
                onTap: () {
                  final value = entry.value;
                  if (value == null) {
                    Navigator.of(context).pop();
                    return;
                  }
                  Navigator.of(context).pop(value);
                },
              ),
            ),
      ],
    );

    if (!mounted) {
      return;
    }
    if (selected == null) {
      return;
    }
    widget.onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openMenu,
        borderRadius: widget.triggerBorderRadius,
        hoverColor: widget.triggerHoverColor,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: KeyedSubtree(key: _anchorKey, child: widget.child),
      ),
    );
  }
}

class _AppDropMenuItem extends StatefulWidget {
  const _AppDropMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDanger = false,
  });

  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  State<_AppDropMenuItem> createState() => _AppDropMenuItemState();
}

class _AppDropMenuItemState extends State<_AppDropMenuItem> {
  @override
  Widget build(BuildContext context) {
    final fg = widget.isDanger ? AppColors.danger : AppColors.textPrimary;
    final hoverBg = AppColors.border.withValues(alpha: AppAlphas.hover26);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s4,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.r8),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(AppRadii.r8),
          hoverColor: hoverBg,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            height: AppHeights.menuItem40,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: AppIconSizes.s18, color: fg),
                  const SizedBox(width: AppSpacing.s10),
                ],
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFontSizes.label11,
                      fontWeight: FontWeight.w700,
                      color: fg,
                      height: 1.0,
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
