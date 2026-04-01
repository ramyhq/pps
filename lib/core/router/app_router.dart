import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/scaffold_with_sidebar.dart';
import '../../features/reservations/ui/screens/reservation_list_screen.dart';
import '../../features/reservations/ui/screens/reservation_details_screen.dart';
import '../../features/reservations/ui/screens/create_general_service_screen.dart';
import '../../features/reservations/ui/screens/create_agent_reservation_screen.dart';
import '../../features/reservations/ui/screens/create_transportation_service_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/reservations/create-general',
    routes: [
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
            path: '/reservations',
            builder: (context, state) => const ReservationListScreen(),
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  return ReservationDetailsScreen(reservationId: reservationId);
                },
              ),
              GoRoute(
                path: 'pdf-preview',
                builder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  return ReservationDetailsPdfPreviewScreen(
                    reservationId: reservationId,
                  );
                },
              ),
              GoRoute(
                path: 'create-general',
                builder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  final serviceId = state.uri.queryParameters['serviceId'];
                  return CreateGeneralServiceScreen(
                    reservationId: reservationId,
                    serviceId: serviceId,
                  );
                },
              ),
              GoRoute(
                path: 'create-agent',
                builder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  final serviceId = state.uri.queryParameters['serviceId'];
                  return CreateAgentReservationScreen(
                    reservationId: reservationId,
                    serviceId: serviceId,
                  );
                },
              ),
              GoRoute(
                path: 'create-transportation',
                builder: (context, state) {
                  final reservationId =
                      state.uri.queryParameters['reservationId'];
                  final serviceId = state.uri.queryParameters['serviceId'];
                  return CreateTransportationServiceScreen(
                    reservationId: reservationId,
                    serviceId: serviceId,
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
