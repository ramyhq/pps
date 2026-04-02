import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  static const double _collapsedWidth = 64;
  static const double _expandedWidth = AppWidths.sidebar;
  static const double _navItemHeight = 44;

  static const String _logoAssetPath = 'assets/images/sahl_logo.jpg';

  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    final reservationItems =
        <({IconData icon, String title, String routePath})>[
          (
            icon: FontAwesomeIcons.calendarDays,
            title: 'Reservations',
            routePath: '/reservations',
          ),
          (
            icon: FontAwesomeIcons.plus,
            title: 'Create General Service',
            routePath: '/reservations/create-general',
          ),
          (
            icon: FontAwesomeIcons.plus,
            title: 'Agent Direct Reservation',
            routePath: '/reservations/create-agent',
          ),
          (
            icon: FontAwesomeIcons.plus,
            title: 'Create Transportation Service',
            routePath: '/reservations/create-transportation',
          ),
        ];

    return AnimatedContainer(
      duration: AppDurations.accordion,
      curve: Curves.easeOut,
      width: _isExpanded ? _expandedWidth : _collapsedWidth,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _SidebarHeader(
              isExpanded: _isExpanded,
              logoAssetPath: _logoAssetPath,
              onToggle: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppDurations.accordion,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeOut,
                child: !_isExpanded
                    ? const SizedBox.shrink()
                    : ListView(
                        key: const ValueKey('sidebar-items-expanded'),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s0,
                          AppSpacing.s12,
                          AppSpacing.s0,
                          AppSpacing.s12,
                        ),
                        children: [
                          for (final item in reservationItems)
                            _buildNavItem(
                              context: context,
                              icon: item.icon,
                              label: item.title,
                              routePath: item.routePath,
                              isActive:
                                  location == item.routePath ||
                                  (item.routePath == '/reservations' &&
                                      location.startsWith('/reservations')),
                            ),
                        ],
                      ),
              ),
            ),
          ],
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
    const activeBg = AppColors.primarySurfaceAlt;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s4,
        AppSpacing.s12,
        AppSpacing.s4,
      ),
      child: Material(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.r12),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.r12),
          hoverColor: AppColors.light,
          onTap: () => context.go(routePath),
          child: SizedBox(
            height: _navItemHeight,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.accordion,
                  curve: Curves.easeOut,
                  width: 3,
                  height: isActive ? 18 : 0,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: AppSpacing.s10),
                Icon(
                  icon,
                  size: AppIconSizes.s16,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.s10),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final bool isExpanded;
  final String logoAssetPath;
  final VoidCallback onToggle;

  const _SidebarHeader({
    required this.isExpanded,
    required this.logoAssetPath,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
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
                      child: Image.asset(
                        logoAssetPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: 22,
                      child: Image.asset(
                        logoAssetPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: AppHeights.field34,
                height: AppHeights.field34,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.light,
                    borderRadius: BorderRadius.circular(AppRadii.r12),
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
