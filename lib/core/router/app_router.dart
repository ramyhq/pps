import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/scaffold_with_sidebar.dart';
import '../../features/reservations/ui/screens/reservation_list_screen.dart';
import '../../features/reservations/ui/screens/reservation_details_screen.dart';
import '../../features/reservations/ui/screens/create_general_service_screen.dart';
import '../../features/reservations/ui/screens/create_agent_reservation_screen.dart';
import '../../features/reservations/ui/screens/create_transportation_service_screen.dart';
import '../../features/rms_auth/ui/screens/rms_login_screen.dart';
import '../../features/rms_bridge/ui/screens/rms_bridge_home_screen.dart';
import '../../features/rms_bridge/ui/screens/rms_bridge_import_reservation_screen.dart';
import '../../features/rms_bridge/ui/screens/rms_bridge_reservation_details_screen.dart';
import '../../features/dashboard/ui/screens/dashboard_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

Page<void> _noTransitionPage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(key: state.pageKey, child: child);
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      GoRoute(path: '/login', redirect: (context, state) => '/dashboard'),
      GoRoute(
        path: '/rms-login',
        pageBuilder: (context, state) =>
            _noTransitionPage(state, const RmsLoginScreen()),
      ),
      GoRoute(
        path: '/create-agent',
        redirect: (context, state) => '/reservations/create-agent',
      ),
      GoRoute(
        path: '/create-general',
        redirect: (context, state) => '/reservations/create-general',
      ),
      GoRoute(
        path: '/create-transportation',
        redirect: (context, state) => '/reservations/create-transportation',
      ),
      GoRoute(
        path: '/details',
        redirect: (context, state) => '/reservations/details',
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithSidebar(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            redirect: (context, state) {
              // TODO(permissions): Enforce RBAC for dashboard access (roles/permissions).
              return null;
            },
            pageBuilder: (context, state) =>
                _noTransitionPage(state, const DashboardScreen()),
          ),
          GoRoute(
            path: '/reservations',
            redirect: (context, state) {
              // TODO(permissions): Enforce RBAC for reservations access (view/list/details/create/edit).
              return null;
            },
            pageBuilder: (context, state) =>
                _noTransitionPage(state, const ReservationListScreen()),
            routes: [
              GoRoute(
                path: 'details',
                pageBuilder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  return _noTransitionPage(
                    state,
                    ReservationDetailsScreen(reservationId: reservationId),
                  );
                },
              ),
              GoRoute(
                path: 'pdf-preview',
                pageBuilder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  return _noTransitionPage(
                    state,
                    ReservationDetailsPdfPreviewScreen(
                      reservationId: reservationId,
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'create-general',
                pageBuilder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  final serviceId = state.uri.queryParameters['serviceId'];
                  return _noTransitionPage(
                    state,
                    CreateGeneralServiceScreen(
                      reservationId: reservationId,
                      serviceId: serviceId,
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'create-agent',
                pageBuilder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  final serviceId = state.uri.queryParameters['serviceId'];
                  return _noTransitionPage(
                    state,
                    CreateAgentReservationScreen(
                      reservationId: reservationId,
                      serviceId: serviceId,
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'create-transportation',
                pageBuilder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  final serviceId = state.uri.queryParameters['serviceId'];
                  return _noTransitionPage(
                    state,
                    CreateTransportationServiceScreen(
                      reservationId: reservationId,
                      serviceId: serviceId,
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/clients',
            redirect: (context, state) {
              // TODO(permissions): Enforce RBAC for clients access (list/details/bulk import).
              return null;
            },
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const SimplePlaceholderScreen(
                title: AppStrings.clientsTitle,
                description: AppStrings.clientsPlaceholderDescription,
                bullets: [
                  'List clients with search, filters, and quick actions.',
                  'Client details: contact info, history, and attachments.',
                  'Bulk import will be added later.',
                ],
              ),
            ),
          ),
          GoRoute(
            path: '/suppliers',
            redirect: (context, state) {
              // TODO(permissions): Enforce RBAC for suppliers access (list/details/bulk import).
              return null;
            },
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const SimplePlaceholderScreen(
                title: AppStrings.suppliersTitle,
                description: AppStrings.suppliersPlaceholderDescription,
                bullets: [
                  'List suppliers with filters by type and availability.',
                  'Supplier details: contracts, rates, and notes.',
                  'Bulk import will be added later.',
                ],
              ),
            ),
          ),
          GoRoute(
            path: '/hotels',
            redirect: (context, state) {
              // TODO(permissions): Enforce RBAC for hotels access (list/details/bulk import).
              return null;
            },
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const SimplePlaceholderScreen(
                title: AppStrings.hotelsTitle,
                description: AppStrings.hotelsPlaceholderDescription,
                bullets: [
                  'Hotels list with city/category filters.',
                  'Hotel details: room types, meal plans, and rates.',
                  'Bulk import will be added later.',
                ],
              ),
            ),
          ),
          GoRoute(
            path: '/services',
            redirect: (context, state) {
              // TODO(permissions): Enforce RBAC for services catalog access.
              return null;
            },
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const SimplePlaceholderScreen(
                title: AppStrings.servicesCatalogTitle,
                description: AppStrings.servicesCatalogPlaceholderDescription,
                bullets: [
                  'Browse service types and pricing rules.',
                  'Backed by Supabase tables (e.g., reservation_service_types).',
                  'CRUD and permissions will be added later.',
                ],
              ),
            ),
          ),
          GoRoute(
            path: '/templates',
            redirect: (context, state) {
              // TODO(permissions): Enforce RBAC for templates access (view/edit).
              return null;
            },
            pageBuilder: (context, state) =>
                _noTransitionPage(state, const TemplatesPlaceholderScreen()),
          ),
          GoRoute(
            path: '/reports',
            redirect: (context, state) {
              // TODO(permissions): Enforce RBAC for reports access (view/export/print).
              return null;
            },
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const SimplePlaceholderScreen(
                title: AppStrings.reportsTitle,
                description: AppStrings.reportsPlaceholderDescription,
                bullets: [
                  'Sales, cost, and margin summaries.',
                  'Filters by date range, client, supplier, and service type.',
                  'Export (PDF/Excel) and print will be added later.',
                ],
              ),
            ),
          ),
          GoRoute(
            path: '/settings',
            redirect: (context, state) {
              // TODO(permissions): Enforce RBAC for settings access (users/roles/app settings/integrations).
              return null;
            },
            pageBuilder: (context, state) => _noTransitionPage(
              state,
              const SimplePlaceholderScreen(
                title: AppStrings.settingsTitle,
                description: AppStrings.settingsPlaceholderDescription,
                bullets: [
                  'User management and roles/permissions (RBAC).',
                  'Application settings: themes, localization, defaults.',
                  'Integrations: Supabase, notifications, and audit logs.',
                ],
              ),
            ),
          ),
          GoRoute(
            path: '/rms-bridge',
            pageBuilder: (context, state) =>
                _noTransitionPage(state, const RmsBridgeHomeScreen()),
            routes: [
              GoRoute(
                path: 'import',
                pageBuilder: (context, state) => _noTransitionPage(
                  state,
                  const RmsBridgeImportReservationScreen(),
                ),
              ),
              GoRoute(
                path: 'reservation-details',
                pageBuilder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'] ?? '';
                  return _noTransitionPage(
                    state,
                    RmsBridgeReservationDetailsScreen(
                      reservationId: reservationId,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class SimplePlaceholderScreen extends StatelessWidget {
  final String title;
  final String description;
  final List<String> bullets;

  const SimplePlaceholderScreen({
    required this.title,
    required this.description,
    required this.bullets,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppInsets.pageDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: AppFontSizes.pageTitle24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            description,
            style: const TextStyle(
              fontSize: AppFontSizes.body12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Container(
            width: double.infinity,
            padding: AppInsets.cardBody10,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.r6),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.placeholderHeading,
                  style: TextStyle(
                    fontSize: AppFontSizes.title14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                const Text(
                  AppStrings.placeholderHint,
                  style: TextStyle(
                    fontSize: AppFontSizes.label11,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
                for (final bullet in bullets) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.circle,
                          size: 6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          bullet,
                          style: const TextStyle(
                            fontSize: AppFontSizes.body12,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TemplatesPlaceholderScreen extends StatelessWidget {
  const TemplatesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = AppStrings.termsAndConditionsTemplates.entries.toList();
    return SingleChildScrollView(
      padding: AppInsets.pageDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.templatesTitle,
            style: TextStyle(
              fontSize: AppFontSizes.pageTitle24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          const Text(
            AppStrings.templatesPlaceholderDescription,
            style: TextStyle(
              fontSize: AppFontSizes.body12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          for (final entry in entries) ...[
            Container(
              width: double.infinity,
              padding: AppInsets.cardBody10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadii.r6),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: AppFontSizes.title14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    entry.value.trim().isEmpty ? '—' : entry.value,
                    style: const TextStyle(
                      fontSize: AppFontSizes.label11,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
          ],
        ],
      ),
    );
  }
}
