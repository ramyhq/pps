import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import 'custom_form_fields.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  final TextEditingController _searchController = TextEditingController();
  String _menuQuery = '';

  static const String _logoAssetPath = 'assets/images/sahl_logo.jpg';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final query = _menuQuery.trim().toLowerCase();

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

    final filteredReservationItems = query.isEmpty
        ? reservationItems
        : reservationItems
              .where((item) => item.title.toLowerCase().contains(query))
              .toList(growable: false);

    final showReservationSection =
        query.isEmpty ||
        'reservation management'.contains(query) ||
        filteredReservationItems.isNotEmpty;

    final hasAnyResults = showReservationSection;

    return Container(
      width: AppWidths.sidebar,
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s16,
                  AppSpacing.s16,
                  AppSpacing.s12,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadii.r12),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s16,
                          AppSpacing.s16,
                          AppSpacing.s12,
                          AppSpacing.s12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Image.asset(
                                    _logoAssetPath,
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
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.r12,
                                  ),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    size: AppIconSizes.s18,
                                    color: AppColors.textSecondary,
                                  ),
                                  padding: EdgeInsets.zero,
                                  splashRadius: AppIconSizes.s18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: AppSpacing.s12),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s12,
                        ),
                        child: SizedBox(
                          height: AppHeights.field34,
                          child: TextField(
                            controller: _searchController,
                            inputFormatters: [
                              ArabicDigitsToEnglishInputFormatter(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _menuQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search in menu...',
                              hintStyle: const TextStyle(
                                fontSize: AppFontSizes.label11,
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: AppIconSizes.s18,
                                color: AppColors.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.r12,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadii.r12,
                                ),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.s0,
                                horizontal: AppSpacing.s12,
                              ),
                              filled: true,
                              fillColor: AppColors.light,
                            ),
                            style: const TextStyle(
                              fontSize: AppFontSizes.label11,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                          ),
                          children: [
                            if (!hasAnyResults)
                              const Padding(
                                padding: EdgeInsets.only(top: AppSpacing.s12),
                                child: Text(
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: AppFontSizes.label11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            else if (showReservationSection) ...[
                              _buildMenuItem(
                                icon: FontAwesomeIcons.calendarCheck,
                                title: 'Reservation Management',
                                isActive: location.startsWith('/reservations'),
                                hasSubmenu: true,
                                isExpanded: true,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.s12,
                                ),
                                child: Column(
                                  children: [
                                    for (final item in filteredReservationItems)
                                      _buildSubMenuItem(
                                        context: context,
                                        icon: item.icon,
                                        title: item.title,
                                        routePath: item.routePath,
                                        isActive: location == item.routePath,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isActive = false,
    bool hasSubmenu = false,
    bool isExpanded = false,
    VoidCallback? onTap,
  }) {
    const activeBg = Color(0xFFEAF2FF);
    const inactiveColor = AppColors.textPrimary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s2),
      decoration: BoxDecoration(
        color: (isActive && hasSubmenu) ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.r8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: AppIconSizes.s16,
          color: isActive ? AppColors.primary : inactiveColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.primary : inactiveColor,
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.body12,
          ),
        ),
        trailing: hasSubmenu
            ? Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: AppIconSizes.s16,
                color: AppColors.textSecondary,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s0,
        ),
        visualDensity: VisualDensity.compact,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSubMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String? routePath,
    bool isActive = false,
    bool enabled = true,
  }) {
    const activeBg = Color(0xFFF1F5F9);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s2),
      decoration: BoxDecoration(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.r8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: AppIconSizes.s14,
          color: isActive
              ? AppColors.primary
              : enabled
              ? AppColors.textSecondary
              : AppColors.border,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isActive
                ? AppColors.primary
                : enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: AppFontSizes.label11,
          ),
        ),
        contentPadding: const EdgeInsets.only(
          left: AppSpacing.s14,
          right: AppSpacing.s10,
        ),
        visualDensity: VisualDensity.compact,
        onTap: (!enabled || routePath == null)
            ? null
            : () => context.go(routePath),
      ),
    );
  }
}
