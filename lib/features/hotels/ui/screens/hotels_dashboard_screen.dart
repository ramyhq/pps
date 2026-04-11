import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/module_dashboard_layout.dart';
import '../../../../core/widgets/kpi_card.dart';

class HotelsDashboardScreen extends StatelessWidget {
  const HotelsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleDashboardLayout(
      title: 'Hotels Dashboard',
      description:
          'Manage your hotels, view statistics, and monitor occupancy.',
      onViewList: () {
        context.go('/hotels/list');
      },
      onAddSingle: () {
        context.go('/hotels/add');
      },
      onAddBulk: () {
        context.go('/hotels/bulk-import');
      },
      kpiCards: const [
        KpiCard(
          title: 'Total Hotels',
          value: '128',
          icon: Icons.domain_rounded,
          color: Color(0xFF3B82F6), // Blue
          tooltip: 'Total number of registered hotels',
          trendPercentage: 5.4,
          isTrendPositive: true,
        ),
        KpiCard(
          title: 'Average Occupancy',
          value: '78%',
          icon: Icons.hotel_rounded,
          color: Color(0xFF10B981), // Green
          tooltip: 'Current average occupancy rate',
          trendPercentage: 12.5,
          isTrendPositive: true,
        ),
        KpiCard(
          title: 'Under Maintenance',
          value: '5',
          icon: Icons.build_circle_rounded,
          color: Color(0xFFEF4444), // Red
          tooltip: 'Hotels or rooms currently under maintenance',
          trendPercentage: 1.2,
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
            'Hotel Analytics & Charts Will Appear Here',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
