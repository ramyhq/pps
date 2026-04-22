import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pps/l10n/app_localizations.dart';
import '../constants/app_colors.dart';
import '../localization/locale_provider.dart';
import '../../features/reservations/provider/create_agent_reservation_provider.dart';
import '../../features/reservations/provider/reservations_data_providers.dart';
import 'custom_form_fields.dart';

class Header extends ConsumerStatefulWidget {
  const Header({
    super.key,
    this.onMenuPressed,
    this.showMenuButton = true,
    this.menuIcon = Icons.menu,
    this.showLogo = false,
    this.logoAssetPath,
    this.sidebarExpanded = false,
    this.onSidebarToggle,
  });

  final VoidCallback? onMenuPressed;
  final bool showMenuButton;
  final IconData menuIcon;
  final bool showLogo;
  final String? logoAssetPath;
  final bool sidebarExpanded;
  final VoidCallback? onSidebarToggle;

  @override
  ConsumerState<Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<Header> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _createMenuAnchorKey = GlobalKey();
  final GlobalKey _languageMenuAnchorKey = GlobalKey();
  bool _isSearching = false;
  bool _isCreateMenuOpen = false;
  bool _isLanguageMenuOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submitSearch() async {
    if (_isSearching) {
      return;
    }
    final raw = _searchController.text.trim();
    if (raw.isEmpty) {
      return;
    }
    final reservationNo = int.tryParse(raw);
    if (reservationNo == null) {
      return;
    }
    setState(() {
      _isSearching = true;
    });
    try {
      final repository = ref.read(reservationsRepositoryProvider);
      final reservationId = await repository.findReservationOrderIdByNo(
        reservationNo,
      );
      if (!mounted || reservationId == null) {
        return;
      }
      context.go('/reservations/details?reservationId=$reservationId');
      _searchController.clear();
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _openCreateMenu() async {
    if (_isCreateMenuOpen) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;

    final anchorContext = _createMenuAnchorKey.currentContext;
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
      anchorOffset.dy + anchorObject.size.height + 6,
      overlayObject.size.width - anchorOffset.dx - anchorObject.size.width,
      overlayObject.size.height - anchorOffset.dy,
    );

    final double menuWidth = (anchorObject.size.width + 160)
        .clamp(190, 280)
        .toDouble();
    final double dividerWidth = (menuWidth - 44)
        .clamp(80, menuWidth)
        .toDouble();

    setState(() => _isCreateMenuOpen = true);
    try {
      final selected = await showMenu<_HeaderCreateAction>(
        context: context,
        position: position,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: AppElevations.menu,
        shadowColor: Colors.black.withValues(alpha: AppAlphas.shadow28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.r12),
        ),
        constraints: BoxConstraints(minWidth: menuWidth, maxWidth: menuWidth),
        items: [
          PopupMenuItem<_HeaderCreateAction>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: _HeaderDropMenuItem(
              icon: Icons.hotel,
              label: l10n.addAgentDirect,
              onTap: () =>
                  Navigator.of(context).pop(_HeaderCreateAction.addAgentDirect),
            ),
          ),
          PopupMenuItem<_HeaderCreateAction>(
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
          ),
          PopupMenuItem<_HeaderCreateAction>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: _HeaderDropMenuItem(
              icon: Icons.shopping_cart_outlined,
              label: l10n.addGeneral,
              onTap: () =>
                  Navigator.of(context).pop(_HeaderCreateAction.addGeneral),
            ),
          ),
          PopupMenuItem<_HeaderCreateAction>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: _HeaderDropMenuItem(
              icon: Icons.directions_bus,
              label: l10n.addTransport,
              onTap: () =>
                  Navigator.of(context).pop(_HeaderCreateAction.addTransport),
            ),
          ),
        ],
      );

      if (!mounted || selected == null) {
        return;
      }

      final flowKey = DateTime.now().microsecondsSinceEpoch.toString();
      switch (selected) {
        case _HeaderCreateAction.addAgentDirect:
          ref.invalidate(createAgentReservationProvider);
          context.go('/reservations/create-agent?flow=$flowKey');
          return;
        case _HeaderCreateAction.addGeneral:
          context.go('/reservations/create-general?flow=$flowKey');
          return;
        case _HeaderCreateAction.addTransport:
          context.go('/reservations/create-transportation?flow=$flowKey');
          return;
      }
    } finally {
      if (mounted) {
        setState(() => _isCreateMenuOpen = false);
      }
    }
  }

  Future<void> _openLanguageMenu() async {
    if (_isLanguageMenuOpen) {
      return;
    }
    final l10n = AppLocalizations.of(context)!;

    final anchorContext = _languageMenuAnchorKey.currentContext;
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
      anchorOffset.dy + anchorObject.size.height + 6,
      overlayObject.size.width - anchorOffset.dx - anchorObject.size.width,
      overlayObject.size.height - anchorOffset.dy,
    );

    setState(() => _isLanguageMenuOpen = true);
    try {
      final selected = await showMenu<_HeaderLanguageAction>(
        context: context,
        position: position,
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: AppElevations.menu,
        shadowColor: Colors.black.withValues(alpha: AppAlphas.shadow28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.r12),
        ),
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 280),
        items: [
          PopupMenuItem<_HeaderLanguageAction>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: _HeaderLanguageMenuItem(
              flag: const Text('🇺🇸', style: TextStyle(fontSize: 16)),
              label: l10n.languageEnglish,
              onTap: () => Navigator.of(context).pop(_HeaderLanguageAction.en),
            ),
          ),
          PopupMenuItem<_HeaderLanguageAction>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: _HeaderLanguageMenuItem(
              flag: const Text('🇪🇬', style: TextStyle(fontSize: 16)),
              label: l10n.languageArabic,
              onTap: () => Navigator.of(context).pop(_HeaderLanguageAction.ar),
            ),
          ),
        ],
      );

      if (!mounted || selected == null) {
        return;
      }

      final localeNotifier = ref.read(localeProvider.notifier);
      switch (selected) {
        case _HeaderLanguageAction.en:
          localeNotifier.setLocale(const Locale('en'));
          return;
        case _HeaderLanguageAction.ar:
          localeNotifier.setLocale(const Locale('ar'));
          return;
      }
    } finally {
      if (mounted) {
        setState(() => _isLanguageMenuOpen = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final logoAssetPath = widget.logoAssetPath;
    final showDesktopLogo = widget.showLogo && logoAssetPath != null;
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final languageFlag = switch (locale.languageCode) {
      'ar' => '🇪🇬',
      _ => '🇺🇸',
    };

    return Container(
      height: 80.0, // Increased height for bigger logo
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDesktopLogo)
            Container(
              width: widget.sidebarExpanded ? AppWidths.sidebar : null,
              padding: EdgeInsets.symmetric(
                horizontal: widget.sidebarExpanded
                    ? AppSpacing.s24
                    : AppSpacing.s12,
              ),
              child: Row(
                mainAxisAlignment: widget.sidebarExpanded
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: [
                  if (!widget.sidebarExpanded) ...[
                    SizedBox(
                      width: AppHeights.field34,
                      height: AppHeights.field34,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.light,
                          borderRadius: BorderRadius.circular(AppRadii.r6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          onPressed: widget.onSidebarToggle,
                          icon: const Icon(
                            Icons.chevron_right_rounded,
                            size: AppIconSizes.s18,
                            color: AppColors.textSecondary,
                          ),
                          padding: EdgeInsets.zero,
                          splashRadius: AppIconSizes.s18,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s16),
                  ],
                  SizedBox(
                    height: 50.0, // Much bigger logo
                    child: Image.asset(logoAssetPath, fit: BoxFit.contain),
                  ),
                  if (widget.sidebarExpanded) ...[
                    SizedBox(
                      width: AppHeights.field34,
                      height: AppHeights.field34,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.light,
                          borderRadius: BorderRadius.circular(AppRadii.r6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          onPressed: widget.onSidebarToggle,
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            size: AppIconSizes.s18,
                            color: AppColors.textSecondary,
                          ),
                          padding: EdgeInsets.zero,
                          splashRadius: AppIconSizes.s18,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            )
          else if (widget.showMenuButton)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.s24),
              child: IconButton(
                onPressed: widget.onMenuPressed,
                icon: Icon(widget.menuIcon, color: AppColors.textSecondary),
              ),
            ),

          Expanded(
            child: Row(
              children: [
                if (!showDesktopLogo && !widget.showMenuButton)
                  const SizedBox(width: AppSpacing.s24),
                const Spacer(),
                // Favorites
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.star,
                    color: AppColors.warning,
                    size: AppIconSizes.s16,
                  ),
                  label: Text(
                    l10n.favorites,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                // Search
                Container(
                  width: AppWidths.headerSearch,
                  height: AppHeights.field34,
                  decoration: BoxDecoration(
                    color: AppColors.light,
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            ArabicDigitsToEnglishInputFormatter(),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onSubmitted: (_) => _submitSearch(),
                          decoration: InputDecoration(
                            hintText: l10n.ppsResNumber,
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: AppFontSizes.body12,
                              fontWeight: FontWeight.w500,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: AppFontSizes.body12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Search button
                      IconButton(
                        onPressed: _submitSearch,
                        icon: const Icon(
                          Icons.search,
                          size: AppIconSizes.s16,
                          color: AppColors.textSecondary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: AppHeights.field34,
                          minHeight: AppHeights.field34,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),
                // Actions
                KeyedSubtree(
                  key: _createMenuAnchorKey,
                  child: _HeaderIconButton(
                    onPressed: _openCreateMenu,
                    icon: FontAwesomeIcons.calendarPlus,
                    iconSize: AppIconSizes.s18,
                    active: _isCreateMenuOpen,
                  ),
                ),
                _HeaderIconButton(
                  onPressed: () {},
                  icon: FontAwesomeIcons.building,
                  iconSize: AppIconSizes.s18,
                ),
                Stack(
                  children: [
                    _HeaderIconButton(
                      onPressed: () {},
                      icon: FontAwesomeIcons.bell,
                      iconSize: AppIconSizes.s18,
                    ),
                    Positioned(
                      right: AppSpacing.s8,
                      top: AppSpacing.s8,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.s2),
                        decoration: const BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: AppSpacing.s12,
                          minHeight: AppSpacing.s12,
                        ),
                        child: const Text(
                          '33',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppFontSizes.tiny8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                _HeaderIconButton(
                  onPressed: () {},
                  icon: Icons.chat_bubble_outline,
                  iconSize: AppIconSizes.s18,
                ),
                _HeaderIconButton(
                  onPressed: () {},
                  icon: Icons.wb_sunny_outlined,
                  iconSize: AppIconSizes.s18,
                ),
                KeyedSubtree(
                  key: _languageMenuAnchorKey,
                  child: _HeaderIconButton(
                    onPressed: _openLanguageMenu,
                    active: _isLanguageMenuOpen,
                    child: Text(
                      languageFlag,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                const CircleAvatar(
                  radius: AppIconSizes.s16,
                  backgroundColor: AppColors.secondary,
                  child: Icon(
                    Icons.person,
                    color: AppColors.textSecondary,
                    size: AppIconSizes.s20,
                  ),
                ),
                const SizedBox(width: AppSpacing.s24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _HeaderCreateAction { addAgentDirect, addGeneral, addTransport }

enum _HeaderLanguageAction { en, ar }

class _HeaderIconButton extends StatefulWidget {
  const _HeaderIconButton({
    required this.onPressed,
    this.icon,
    this.iconSize = AppIconSizes.s18,
    this.child,
    this.active = false,
  }) : assert(icon != null || child != null);

  final VoidCallback? onPressed;
  final IconData? icon;
  final double iconSize;
  final Widget? child;
  final bool active;

  @override
  State<_HeaderIconButton> createState() => _HeaderIconButtonState();
}

class _HeaderIconButtonState extends State<_HeaderIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = widget.active || _hovered;
    final bgColor = highlighted
        ? AppColors.primarySurfaceAlt
        : Colors.transparent;
    final iconColor = highlighted ? AppColors.primary : AppColors.textSecondary;

    return SizedBox(
      width: AppHeights.field34,
      height: AppHeights.field34,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        child: InkWell(
          onTap: widget.onPressed,
          onHover: (value) => setState(() => _hovered = value),
          borderRadius: BorderRadius.circular(AppRadii.r12),
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Center(
            child: widget.icon != null
                ? Icon(widget.icon, size: widget.iconSize, color: iconColor)
                : widget.child!,
          ),
        ),
      ),
    );
  }
}

class _HeaderDropMenuItem extends StatefulWidget {
  const _HeaderDropMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_HeaderDropMenuItem> createState() => _HeaderDropMenuItemState();
}

class _HeaderDropMenuItemState extends State<_HeaderDropMenuItem> {
  @override
  Widget build(BuildContext context) {
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
                  Icon(
                    widget.icon,
                    size: AppIconSizes.s18,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.s10),
                ],
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppFontSizes.label11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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

class _HeaderLanguageMenuItem extends StatefulWidget {
  const _HeaderLanguageMenuItem({
    required this.flag,
    required this.label,
    required this.onTap,
  });

  final Widget flag;
  final String label;
  final VoidCallback onTap;

  @override
  State<_HeaderLanguageMenuItem> createState() =>
      _HeaderLanguageMenuItemState();
}

class _HeaderLanguageMenuItemState extends State<_HeaderLanguageMenuItem> {
  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  width: AppIconSizes.s20,
                  child: Center(child: widget.flag),
                ),
                const SizedBox(width: AppSpacing.s10),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppFontSizes.label11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
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
