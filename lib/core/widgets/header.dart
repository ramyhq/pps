import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../../features/reservations/provider/reservations_data_providers.dart';
import 'custom_form_fields.dart';

class Header extends ConsumerStatefulWidget {
  const Header({super.key});

  @override
  ConsumerState<Header> createState() => _HeaderState();
}

class _HeaderState extends ConsumerState<Header> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _createMenuAnchorKey = GlobalKey();
  bool _isSearching = false;
  bool _isCreateMenuOpen = false;

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

  Future<void> _openCreateMenu(String? reservationId) async {
    if (_isCreateMenuOpen) {
      return;
    }

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
              label: AppStrings.addAgentDirect,
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
              label: AppStrings.addGeneral,
              onTap: () =>
                  Navigator.of(context).pop(_HeaderCreateAction.addGeneral),
            ),
          ),
          PopupMenuItem<_HeaderCreateAction>(
            enabled: false,
            padding: EdgeInsets.zero,
            child: _HeaderDropMenuItem(
              icon: Icons.directions_bus,
              label: AppStrings.addTransport,
              onTap: () =>
                  Navigator.of(context).pop(_HeaderCreateAction.addTransport),
            ),
          ),
        ],
      );

      if (!mounted || selected == null) {
        return;
      }

      final query = reservationId == null || reservationId.trim().isEmpty
          ? ''
          : '?reservationId=$reservationId';
      switch (selected) {
        case _HeaderCreateAction.addAgentDirect:
          context.go('/reservations/create-agent$query');
          return;
        case _HeaderCreateAction.addGeneral:
          context.go('/reservations/create-general$query');
          return;
        case _HeaderCreateAction.addTransport:
          context.go('/reservations/create-transportation$query');
          return;
      }
    } finally {
      if (mounted) {
        setState(() => _isCreateMenuOpen = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = GoRouterState.of(context).uri;
    final reservationId = uri.queryParameters['reservationId'];

    return Container(
      height: AppHeights.header60,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu, color: AppColors.textSecondary),
          ),
          const SizedBox(width: AppSpacing.s8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  AppStrings.appTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  AppStrings.appTitleArabic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Favorites
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.star,
              color: AppColors.warning,
              size: AppIconSizes.s16,
            ),
            label: const Text(
              'Favorites',
              style: TextStyle(color: AppColors.textPrimary),
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
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
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
                    decoration: const InputDecoration(
                      hintText: 'Res. ID',
                      hintStyle: TextStyle(
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
            child: SizedBox(
              width: AppHeights.field34,
              height: AppHeights.field34,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _isCreateMenuOpen
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.r12),
                ),
                child: IconButton(
                  onPressed: () => _openCreateMenu(reservationId),
                  icon: Icon(
                    FontAwesomeIcons.calendarPlus,
                    size: AppIconSizes.s18,
                    color: _isCreateMenuOpen ? Colors.white : AppColors.primary,
                  ),
                  padding: EdgeInsets.zero,
                  splashRadius: AppIconSizes.s18,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              FontAwesomeIcons.building,
              size: AppIconSizes.s18,
              color: AppColors.primary,
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  FontAwesomeIcons.bell,
                  size: AppIconSizes.s18,
                  color: AppColors.primary,
                ),
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
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.chat_bubble_outline,
              size: AppIconSizes.s18,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.wb_sunny_outlined,
              size: AppIconSizes.s18,
              color: AppColors.textSecondary,
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
        ],
      ),
    );
  }
}

enum _HeaderCreateAction { addAgentDirect, addGeneral, addTransport }

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
