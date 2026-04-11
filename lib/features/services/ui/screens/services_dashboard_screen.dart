import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/module_dashboard_layout.dart';
import '../../../../core/widgets/kpi_card.dart';

class ServicesDashboardScreen extends StatelessWidget {
  const ServicesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleDashboardLayout(
      title: 'Services Dashboard',
      description: 'Manage your services, view statistics, and monitor usage.',
      onViewList: () {
        context.go('/services/list');
      },
      onAddSingle: () {
        context.go('/services/add');
      },
      onAddBulk: () {
        context.go('/services/bulk-import');
      },
      kpiCards: const [
        KpiCard(
          title: 'Total Services',
          value: '42',
          icon: Icons.category_rounded,
          color: Color(0xFF3B82F6), // Blue
          tooltip: 'Total number of registered services',
          trendPercentage: 2.5,
          isTrendPositive: true,
        ),
        KpiCard(
          title: 'Most Used',
          value: 'Airport Transfer',
          icon: Icons.directions_car_rounded,
          color: Color(0xFF10B981), // Green
          tooltip: 'Most frequently booked service this month',
        ),
        KpiCard(
          title: 'Total Bookings',
          value: '845',
          icon: Icons.receipt_long_rounded,
          color: Color(0xFF8B5CF6), // Purple
          tooltip: 'Total service bookings',
          trendPercentage: 15.2,
          isTrendPositive: true,
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
            'Service Analytics & Charts Will Appear Here',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
