import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:pps/l10n/app_localizations.dart';
import 'package:pps/features/reservations/provider/reservations_data_providers.dart';
import '../constants/app_colors.dart';
import 'custom_form_fields.dart';

class Sidebar extends ConsumerStatefulWidget {
  const Sidebar({
    super.key,
    required this.isExpanded,
    this.onToggleExpanded,
    this.onItemSelected,
    this.showToggleButton = true,
    this.showHeader = true,
  });

  final bool isExpanded;
  final VoidCallback? onToggleExpanded;
  final VoidCallback? onItemSelected;
  final bool showToggleButton;
  final bool showHeader;

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  static const double _collapsedWidth = 64;
  static const double _expandedWidth = AppWidths.sidebar;
  static const double _navItemHeight = 40;

  static const String _logoAssetPath = 'assets/images/sahl_logo.jpg';

  final TextEditingController _searchController = TextEditingController();
  String _menuQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String location = GoRouterState.of(context).uri.path;
    final query = _menuQuery.trim().toLowerCase();

    final sections =
        <
          ({
            String title,
            List<({IconData icon, String title, String routePath})> items,
          })
        >[
          // TODO(permissions): Filter sections/items based on user roles/permissions once RBAC is implemented.
          (
            title: l10n.sidebarSectionOperations,
            items: [
              (
                icon: FontAwesomeIcons.chartLine,
                title: l10n.dashboardTitle,
                routePath: '/dashboard',
              ),
              (
                icon: FontAwesomeIcons.calendarDays,
                title: l10n.reservationsTitle,
                routePath: '/reservations',
              ),
            ],
          ),
          (
            title: l10n.sidebarSectionMasterData,
            items: [
              (
                icon: FontAwesomeIcons.users,
                title: l10n.clientsTitle,
                routePath: '/clients',
              ),
              (
                icon: FontAwesomeIcons.handshake,
                title: l10n.suppliersTitle,
                routePath: '/suppliers',
              ),
              (
                icon: FontAwesomeIcons.hotel,
                title: l10n.hotelsTitle,
                routePath: '/hotels',
              ),
              (
                icon: FontAwesomeIcons.listCheck,
                title: l10n.servicesCatalogTitle,
                routePath: '/services',
              ),
              (
                icon: FontAwesomeIcons.fileLines,
                title: l10n.templatesTitle,
                routePath: '/templates',
              ),
            ],
          ),
          (
            title: l10n.sidebarSectionReports,
            items: [
              (
                icon: FontAwesomeIcons.chartPie,
                title: l10n.reportsTitle,
                routePath: '/reports',
              ),
            ],
          ),
          (
            title: l10n.sidebarSectionIntegrations,
            items: [
              (
                icon: FontAwesomeIcons.bridge,
                title: l10n.rmsBridgeTitle,
                routePath: '/rms-bridge',
              ),
            ],
          ),
          (
            title: l10n.sidebarSectionSettings,
            items: [
              (
                icon: FontAwesomeIcons.gear,
                title: l10n.settingsTitle,
                routePath: '/settings',
              ),
            ],
          ),
        ];

    final allItems = <({IconData icon, String title, String routePath})>[
      for (final section in sections) ...section.items,
    ];

    final filteredItems = query.isEmpty
        ? allItems
        : allItems
              .where((item) => item.title.toLowerCase().contains(query))
              .toList(growable: false);

    final outerInsets = EdgeInsets.only(
      top: AppSpacing.s0,
      bottom: AppSpacing.s8,
      right: widget.isExpanded ? AppSpacing.s8 : AppSpacing.s0,
    );

    return AnimatedContainer(
      duration: AppDurations.accordion,
      curve: Curves.easeOut,
      width: widget.isExpanded ? _expandedWidth : _collapsedWidth,
      decoration: const BoxDecoration(color: AppColors.light),
      child: Padding(
        padding: outerInsets,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: widget.showHeader
                  ? const Radius.circular(AppRadii.r12)
                  : Radius.zero,
              bottomRight: const Radius.circular(AppRadii.r12),
            ),
            border: Border(
              right: const BorderSide(color: AppColors.border),
              bottom: const BorderSide(color: AppColors.border),
              top: widget.showHeader
                  ? const BorderSide(color: AppColors.border)
                  : BorderSide.none,
              left: widget.showHeader
                  ? const BorderSide(color: AppColors.border)
                  : BorderSide.none,
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                if (widget.showHeader)
                  _SidebarHeader(
                    isExpanded: widget.isExpanded,
                    logoAssetPath: _logoAssetPath,
                    onToggle: widget.onToggleExpanded,
                    showToggleButton: widget.showToggleButton,
                  ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppDurations.accordion,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    child: !widget.isExpanded
                        ? const SizedBox.shrink()
                        : Column(
                            key: const ValueKey('sidebar-expanded-content'),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.s12,
                                  AppSpacing.s12,
                                  AppSpacing.s12,
                                  AppSpacing.s10,
                                ),
                                child: _SidebarSearchField(
                                  controller: _searchController,
                                  value: _menuQuery,
                                  onChanged: (value) {
                                    setState(() {
                                      _menuQuery = value;
                                    });
                                  },
                                  onClear: () {
                                    setState(() {
                                      _menuQuery = '';
                                    });
                                    _searchController.clear();
                                  },
                                ),
                              ),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.s0,
                                    AppSpacing.s4,
                                    AppSpacing.s0,
                                    AppSpacing.s12,
                                  ),
                                  children: [
                                    if (filteredItems.isEmpty)
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                          AppSpacing.s12,
                                          AppSpacing.s10,
                                          AppSpacing.s12,
                                          AppSpacing.s0,
                                        ),
                                        child: Text(
                                          l10n.sidebarNoResults,
                                          style: const TextStyle(
                                            fontSize: AppFontSizes.label11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      )
                                    else if (query.isNotEmpty) ...[
                                      _buildSectionHeader(
                                        l10n.sidebarSectionResults,
                                      ),
                                      for (final item in filteredItems)
                                        _buildNavItem(
                                          context: context,
                                          icon: item.icon,
                                          label: item.title,
                                          routePath: item.routePath,
                                          isActive: _isRouteActive(
                                            location: location,
                                            routePath: item.routePath,
                                          ),
                                        ),
                                    ] else ...[
                                      for (final section in sections) ...[
                                        _buildSectionHeader(section.title),
                                        for (final item in section.items)
                                          _buildNavItem(
                                            context: context,
                                            icon: item.icon,
                                            label: item.title,
                                            routePath: item.routePath,
                                            isActive: _isRouteActive(
                                              location: location,
                                              routePath: item.routePath,
                                            ),
                                          ),
                                        const SizedBox(height: AppSpacing.s6),
                                      ],
                                    ],
                                  ],
                                ),
                              ),
                            ],
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

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String routePath,
    bool isActive = false,
  }) {
    final activeBg = AppColors.primary.withValues(alpha: 0.06);
    final hoverBg = AppColors.primary.withValues(alpha: 0.04);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s8,
        AppSpacing.s2,
        AppSpacing.s8,
        AppSpacing.s2,
      ),
      child: Material(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.r6),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.r6),
          hoverColor: hoverBg,
          onTap: () {
            if (routePath == '/reservations') {
              ref.invalidate(reservationOrdersProvider);
            }
            if (widget.onItemSelected != null) {
              final router = GoRouter.of(context);
              widget.onItemSelected!.call();
              router.go(routePath);
              return;
            }
            context.go(routePath);
          },
          child: SizedBox(
            height: _navItemHeight,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.accordion,
                  curve: Curves.easeOut,
                  width: 2,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                SizedBox(
                  width: 28,
                  child: Icon(
                    icon,
                    size: AppIconSizes.s16,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppFontSizes.body12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isRouteActive({required String location, required String routePath}) {
    if (routePath == '/reservations') {
      return location == routePath || location.startsWith('/reservations');
    }
    if (routePath == '/rms-bridge') {
      return location == routePath || location.startsWith('/rms-bridge');
    }
    return location == routePath;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s10,
        AppSpacing.s12,
        AppSpacing.s6,
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: AppFontSizes.badge10,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool isExpanded;
  final String logoAssetPath;
  final VoidCallback? onToggle;
  final bool showToggleButton;

  const _SidebarHeader({
    required this.isExpanded,
    required this.logoAssetPath,
    required this.onToggle,
    required this.showToggleButton,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isExpanded ? AppSpacing.s12 : AppSpacing.s0,
          AppSpacing.s12,
          AppSpacing.s12,
          AppSpacing.s12,
        ),
        child: SizedBox(
          height: 40,
          child: Row(
            children: [
              if (isExpanded)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 28,
                      child: Image.asset(logoAssetPath, fit: BoxFit.contain),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 22,
                      child: Image.asset(logoAssetPath, fit: BoxFit.contain),
                    ),
                  ),
                ),
              if (showToggleButton)
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
                      onPressed: onToggle,
                      icon: Icon(
                        isExpanded ? Icons.chevron_left : Icons.chevron_right,
                        size: AppIconSizes.s18,
                        color: AppColors.textSecondary,
                      ),
                      padding: EdgeInsets.zero,
                      splashRadius: AppIconSizes.s18,
                      tooltip: isExpanded ? 'Collapse' : 'Expand',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SidebarSearchField({
    required this.controller,
    required this.value,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppHeights.field34,
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(AppRadii.r6),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: AppIconSizes.s16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(
            child: TextField(
              controller: controller,
              inputFormatters: [ArabicDigitsToEnglishInputFormatter()],
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.sidebarSearchHint,
                hintStyle: const TextStyle(
                  fontSize: AppFontSizes.label11,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.s10,
                ),
              ),
              style: const TextStyle(
                fontSize: AppFontSizes.label11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (value.trim().isNotEmpty)
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                onPressed: onClear,
                padding: EdgeInsets.zero,
                splashRadius: 18,
                icon: const Icon(
                  Icons.close,
                  size: AppIconSizes.s16,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            const SizedBox(width: 28, height: 28),
        ],
      ),
    );
  }
}
