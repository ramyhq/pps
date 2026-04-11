import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/module_dashboard_layout.dart';
import '../../../../core/widgets/kpi_card.dart';

class SuppliersDashboardScreen extends StatelessWidget {
  const SuppliersDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleDashboardLayout(
      title: 'Suppliers Dashboard',
      description:
          'Manage your suppliers, view statistics, and active contracts.',
      onViewList: () {
        context.go('/suppliers/list');
      },
      onAddSingle: () {
        context.go('/suppliers/add');
      },
      onAddBulk: () {
        context.go('/suppliers/bulk-import');
      },
      kpiCards: const [
        KpiCard(
          title: 'Total Suppliers',
          value: '84',
          icon: Icons.storefront_rounded,
          color: Color(0xFF3B82F6), // Blue
          tooltip: 'Total number of registered suppliers',
          trendPercentage: 3.5,
          isTrendPositive: true,
        ),
        KpiCard(
          title: 'Active Contracts',
          value: '62',
          icon: Icons.assignment_rounded,
          color: Color(0xFF10B981), // Green
          tooltip: 'Suppliers with active contracts currently',
          trendPercentage: 8.2,
          isTrendPositive: true,
        ),
        KpiCard(
          title: 'Pending Renewals',
          value: '12',
          icon: Icons.warning_rounded,
          color: Color(0xFFF59E0B), // Orange
          tooltip: 'Contracts expiring in the next 30 days',
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
            'Supplier Analytics & Charts Will Appear Here',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
