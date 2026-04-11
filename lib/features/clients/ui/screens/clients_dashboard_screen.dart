import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/module_dashboard_layout.dart';
import '../../../../core/widgets/kpi_card.dart';

class ClientsDashboardScreen extends StatelessWidget {
  const ClientsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleDashboardLayout(
      title: 'Clients Dashboard',
      description: 'Manage your clients, view statistics, and add new clients.',
      onViewList: () {
        context.go('/clients/list');
      },
      onAddSingle: () {
        context.go('/clients/add');
      },
      onAddBulk: () {
        context.go('/clients/bulk-import');
      },
      kpiCards: const [
        KpiCard(
          title: 'Total Clients',
          value: '1,245',
          icon: Icons.people_alt_rounded,
          color: Color(0xFF3B82F6), // Blue
          tooltip: 'Total number of registered clients',
          trendPercentage: 12.5,
          isTrendPositive: true,
        ),
        KpiCard(
          title: 'Active This Month',
          value: '342',
          icon: Icons.local_activity_rounded,
          color: Color(0xFF10B981), // Green
          tooltip: 'Clients with reservations in the current month',
          trendPercentage: 5.2,
          isTrendPositive: true,
        ),
        KpiCard(
          title: 'New Clients',
          value: '45',
          icon: Icons.person_add_rounded,
          color: Color(0xFF8B5CF6), // Purple
          tooltip: 'Clients added in the last 30 days',
          trendPercentage: 2.1,
          isTrendPositive: false,
        ),
      ],
      extraContent: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: const Center(
          child: Text(
            'Client Analytics & Charts Will Appear Here',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
