import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:pps/core/constants/app_colors.dart';
import 'package:pps/core/widgets/app_drop_menu_button.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/dashboard/provider/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final selectedPeriod = ref.watch(dashboardPeriodProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Overview of your reservations and performance.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Tooltip(
                message: "Select the time period for dashboard statistics.",
                child: _buildPeriodSelector(context, ref, selectedPeriod),
              ),
            ],
          ),
          const SizedBox(height: 32),

          statsAsync.when(
            data: (stats) =>
                _buildDashboardContent(context, ref, stats, selectedPeriod),
            loading: () => const SizedBox(
              height: 400,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, stack) => SizedBox(
              height: 400,
              child: Center(
                child: Text(
                  'Error loading dashboard: $err',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    int selectedPeriod,
  ) {
    return AppDropMenuButton<int>(
      onSelected: (value) {
        ref.read(dashboardPeriodProvider.notifier).setPeriod(value);
      },
      menuMinWidth: 140,
      menuMaxWidth: 160,
      menuExtraWidth: 0,
      menuOffsetY: 8,
      triggerBorderRadius: BorderRadius.circular(8),
      triggerHoverColor: AppColors.border.withValues(alpha: 0.20),
      entries: const [
        AppDropMenuEntry.action(value: 7, label: 'Last 7 days'),
        AppDropMenuEntry.action(value: 30, label: 'Last 30 days'),
        AppDropMenuEntry.action(value: 90, label: 'Last 90 days'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Last $selectedPeriod days',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    DashboardStats stats,
    int period,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Row
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildPremiumKpiCard(
              title: "Today's Reservations",
              value: '${stats.todayCount}',
              icon: Icons.today_rounded,
              color: AppColors.primary,
              tooltip: "Number of reservations created today.",
            ),
            _buildPremiumKpiCard(
              title: "This Week",
              value: '${stats.thisWeekCount}',
              icon: Icons.calendar_view_week_rounded,
              color: const Color(0xFFF59E0B), // Amber
              tooltip: "Number of reservations created this week.",
            ),
            _buildPremiumKpiCard(
              title: "Period Total ($period Days)",
              value: '${stats.currentPeriodCount}',
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF10B981), // Yellow/Green
              tooltip: "Total reservations created within the selected period.",
              trendPercentage: stats.performancePercentage,
              isTrendPositive: stats.isPerformancePositive,
            ),
            _buildPremiumKpiCard(
              title: "Today's Schedule",
              value: '${stats.needsFollowUp.length}',
              icon: Icons.schedule_rounded,
              color: AppColors.danger,
              tooltip:
                  "Reservations needing RMS Invoice within the follow-up period.",
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Middle Row: Chart + Follow Ups
        LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;
            if (isDesktop) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildChartSection(stats)),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 4,
                    child: _buildFollowUpSection(context, stats),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildChartSection(stats),
                  const SizedBox(height: 24),
                  _buildFollowUpSection(context, stats),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 24),

        // Bottom Row: Top Clients
        _buildTopClientsSection(stats),
      ],
    );
  }

  Widget _buildPremiumKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String tooltip,
    double? trendPercentage,
    bool? isTrendPositive,
  }) {
    return Tooltip(
      message: tooltip,
      textStyle: const TextStyle(fontSize: 12, color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                if (trendPercentage != null && isTrendPositive != null) ...[
                  const SizedBox(width: 12),
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isTrendPositive
                                  ? const Color(0xFF10B981)
                                  : AppColors.danger)
                              .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isTrendPositive
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: isTrendPositive
                              ? const Color(0xFF10B981)
                              : AppColors.danger,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${trendPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isTrendPositive
                                ? const Color(0xFF10B981)
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(DashboardStats stats) {
    if (stats.dailyStats.isEmpty) {
      return _buildEmptySection("Reservations Overview");
    }

    final maxY = stats.dailyStats
        .map((e) => e.count)
        .fold<int>(0, (max, e) => e > max ? e : max)
        .toDouble();
    final chartMaxY = maxY < 5 ? 5.0 : maxY + (maxY * 0.2);

    List<FlSpot> spots = [];
    for (int i = 0; i < stats.dailyStats.length; i++) {
      spots.add(FlSpot(i.toDouble(), stats.dailyStats[i].count.toDouble()));
    }

    return Container(
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Tooltip(
            message:
                "Shows a visual trend of daily reservations over the selected period.",
            child: Text(
              "Reservations Overview",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Daily volume of reservations created.",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMaxY > 10
                      ? (chartMaxY / 5).ceilToDouble()
                      : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppColors.border.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: stats.dailyStats.length > 15 ? 5 : 2,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < 0 ||
                            value.toInt() >= stats.dailyStats.length) {
                          return const SizedBox();
                        }
                        final date = stats.dailyStats[value.toInt()].date;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat('MMM d').format(date),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: chartMaxY > 10
                          ? (chartMaxY / 5).ceilToDouble()
                          : 1,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: stats.dailyStats.length.toDouble() - 1,
                minY: 0,
                maxY: chartMaxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: stats.dailyStats.length <= 30,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: AppColors.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final date =
                            stats.dailyStats[touchedSpot.x.toInt()].date;
                        return LineTooltipItem(
                          '${DateFormat('MMM d, yyyy').format(date)}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: '${touchedSpot.y.toInt()} Reservations',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.normal,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpSection(BuildContext context, DashboardStats stats) {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Tooltip(
                message:
                    "List of recent reservations that still need an RMS invoice number.",
                child: Text(
                  "Today's Schedule",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Tooltip(
                message:
                    "Select how many days back to check for missing RMS invoices.",
                child: Consumer(
                  builder: (context, ref, child) {
                    final followUpPeriod = ref.watch(
                      dashboardFollowUpPeriodProvider,
                    );
                    return AppDropMenuButton<int>(
                      onSelected: (value) {
                        ref
                            .read(dashboardFollowUpPeriodProvider.notifier)
                            .setPeriod(value);
                      },
                      menuMinWidth: 120,
                      menuMaxWidth: 140,
                      menuExtraWidth: 0,
                      menuOffsetY: 8,
                      triggerBorderRadius: BorderRadius.circular(12),
                      triggerHoverColor: AppColors.danger.withValues(
                        alpha: 0.1,
                      ),
                      entries: const [
                        AppDropMenuEntry.action(
                          value: 3,
                          label: 'Last 3 Days',
                          isDanger: true,
                        ),
                        AppDropMenuEntry.action(
                          value: 7,
                          label: 'Last 7 Days',
                          isDanger: true,
                        ),
                        AppDropMenuEntry.action(
                          value: 14,
                          label: 'Last 14 Days',
                          isDanger: true,
                        ),
                        AppDropMenuEntry.action(
                          value: 30,
                          label: 'Last 30 Days',
                          isDanger: true,
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Last $followUpPeriod Days',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.danger,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 14,
                              color: AppColors.danger,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Recent reservations missing RMS Invoice.",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          if (stats.needsFollowUp.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 48,
                      color: const Color(0xFF10B981).withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "All caught up!",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: stats.needsFollowUp.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.border, height: 1),
                itemBuilder: (context, index) {
                  final order = stats.needsFollowUp[index];
                  final hasRms =
                      order.rmsInvoiceNo != null &&
                      order.rmsInvoiceNo!.isNotEmpty;
                  return InkWell(
                    onTap: () => context.go(
                      '/reservations/details?reservationId=${order.id}',
                    ),
                    hoverColor: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 8,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasRms
                                  ? const Color(0xFF10B981)
                                  : AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.client.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM d, yyyy - hh:mm a',
                                  ).format(order.createdAt),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'PPS: #${order.reservationNo}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'RMS: ${hasRms ? order.rmsInvoiceNo : "-"}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: hasRms
                                      ? AppColors.textSecondary
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopClientsSection(DashboardStats stats) {
    if (stats.topClients.isEmpty) {
      return _buildEmptySection("Top Clients");
    }

    final maxCount = stats.topClients
        .map((e) => e.count)
        .fold<int>(0, (max, e) => e > max ? e : max);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Tooltip(
            message:
                "Shows the top 5 clients based on the number of reservations created in the selected period.",
            child: Text(
              "Top Clients",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Clients with the highest volume of reservations in the selected period.",
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: stats.topClients.asMap().entries.map((entry) {
                  final index = entry.key;
                  final client = entry.value;
                  final percentage = maxCount > 0
                      ? client.count / maxCount
                      : 0.0;

                  Widget rankIcon;
                  switch (index) {
                    case 0:
                      rankIcon = const Tooltip(
                        message: "1st Place - Gold Cup",
                        child: Text('🏆', style: TextStyle(fontSize: 20)),
                      );
                      break;
                    case 1:
                      rankIcon = const Tooltip(
                        message: "2nd Place - Silver Cup",
                        child: Icon(
                          Icons.emoji_events,
                          color: Color(0xFFC0C0C0),
                          size: 24,
                        ),
                      );
                      break;
                    case 2:
                      rankIcon = const Tooltip(
                        message: "3rd Place - Gold Medal",
                        child: Text('🥇', style: TextStyle(fontSize: 20)),
                      );
                      break;
                    case 3:
                      rankIcon = const Tooltip(
                        message: "4th Place - Silver Medal",
                        child: Text('🥈', style: TextStyle(fontSize: 20)),
                      );
                      break;
                    default:
                      rankIcon = Center(
                        child: Text(
                          '#${index + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      children: [
                        // Avatar / Rank Icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: rankIcon),
                        ),
                        const SizedBox(width: 16),
                        // Name and Bar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      client.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${client.count} Res.',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Stack(
                                children: [
                                  Container(
                                    height: 6,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.border.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: percentage,
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String title) {
    return Container(
      height: 420,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Not enough data.",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
