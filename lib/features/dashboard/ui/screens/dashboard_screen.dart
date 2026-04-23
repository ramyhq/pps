import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:pps/core/constants/app_colors.dart';
import 'package:pps/core/widgets/app_drop_menu_button.dart';
import 'package:pps/features/dashboard/provider/dashboard_provider.dart';
import 'package:pps/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
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
                children: [
                  Text(
                    l10n.dashboardTitle,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.dashboardSubtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Tooltip(
                message: l10n.dashboardSelectPeriodTooltip,
                waitDuration: const Duration(seconds: 2),
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
                  l10n.dashboardErrorLoading(err.toString()),
                  style: const TextStyle(color: AppColors.danger),
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
    final l10n = AppLocalizations.of(context)!;
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
      entries: [
        AppDropMenuEntry.action(value: 7, label: l10n.dashboardLastDays(7)),
        AppDropMenuEntry.action(value: 30, label: l10n.dashboardLastDays(30)),
        AppDropMenuEntry.action(value: 90, label: l10n.dashboardLastDays(90)),
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
              l10n.dashboardLastDays(selectedPeriod),
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
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Row
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildPremiumKpiCard(
              title: l10n.dashboardTodaysReservationsTitle,
              value: '${stats.todayCount}',
              icon: Icons.today_rounded,
              color: AppColors.primary,
              tooltip: l10n.dashboardTodaysReservationsTooltip,
            ),
            _buildPremiumKpiCard(
              title: l10n.dashboardThisWeekTitle,
              value: '${stats.thisWeekCount}',
              icon: Icons.calendar_view_week_rounded,
              color: const Color(0xFFF59E0B), // Amber
              tooltip: l10n.dashboardThisWeekTooltip,
            ),
            _buildPremiumKpiCard(
              title: l10n.dashboardPeriodTotalTitle(period),
              value: '${stats.currentPeriodCount}',
              icon: Icons.bar_chart_rounded,
              color: const Color(0xFF10B981), // Yellow/Green
              tooltip: l10n.dashboardPeriodTotalTooltip,
              trendPercentage: stats.performancePercentage,
              isTrendPositive: stats.isPerformancePositive,
            ),
            _buildPremiumKpiCard(
              title: l10n.dashboardNeedsAttentionTitle,
              value: '${stats.needsFollowUp.length}',
              icon: Icons.schedule_rounded,
              color: AppColors.danger,
              tooltip: l10n.dashboardNeedsAttentionTooltip,
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
                  Expanded(flex: 7, child: _buildChartSection(context, stats)),
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
                  _buildChartSection(context, stats),
                  const SizedBox(height: 24),
                  _buildFollowUpSection(context, stats),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 24),

        // Bottom Row: Top Clients
        _buildTopClientsSection(context, stats),
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
      waitDuration: const Duration(seconds: 2),
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
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                    color: color.withValues(alpha: 0.1),
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
                              .withValues(alpha: 0.1),
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

  Widget _buildChartSection(BuildContext context, DashboardStats stats) {
    final l10n = AppLocalizations.of(context)!;
    if (stats.dailyStats.isEmpty) {
      return _buildEmptySection(
        context,
        l10n.dashboardReservationsOverviewTitle,
      );
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: l10n.dashboardReservationsOverviewTooltip,
            waitDuration: const Duration(seconds: 2),
            child: Text(
              l10n.dashboardReservationsOverviewTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.dashboardDailyVolumeSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
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
                      color: AppColors.border.withValues(alpha: 0.5),
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
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.0),
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
                              text: l10n.dashboardReservationsCount(
                                touchedSpot.y.toInt(),
                              ),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Tooltip(
                message: l10n.dashboardNeedsAttentionListTooltip,
                waitDuration: const Duration(seconds: 2),
                child: Text(
                  l10n.dashboardNeedsAttentionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Tooltip(
                message: l10n.dashboardFollowUpPeriodTooltip,
                waitDuration: const Duration(seconds: 2),
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
                      entries: [
                        AppDropMenuEntry.action(
                          value: 3,
                          label: l10n.dashboardLastDaysShort(3),
                          isDanger: true,
                        ),
                        AppDropMenuEntry.action(
                          value: 7,
                          label: l10n.dashboardLastDaysShort(7),
                          isDanger: true,
                        ),
                        AppDropMenuEntry.action(
                          value: 14,
                          label: l10n.dashboardLastDaysShort(14),
                          isDanger: true,
                        ),
                        AppDropMenuEntry.action(
                          value: 30,
                          label: l10n.dashboardLastDaysShort(30),
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
                              l10n.dashboardLastDaysShort(followUpPeriod),
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
          Text(
            l10n.dashboardNeedsAttentionSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
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
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.dashboardAllCaughtUp,
                      style: const TextStyle(
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
                    hoverColor: AppColors.primary.withValues(alpha: 0.05),
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
                                l10n.dashboardPpsNumber(order.reservationNo),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.dashboardRmsInvoice(
                                  hasRms ? order.rmsInvoiceNo! : '-',
                                ),
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

  Widget _buildTopClientsSection(BuildContext context, DashboardStats stats) {
    final l10n = AppLocalizations.of(context)!;
    if (stats.topClients.isEmpty) {
      return _buildEmptySection(context, l10n.dashboardTopClientsTitle);
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
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Tooltip(
            message: l10n.dashboardTopClientsTooltip,
            waitDuration: const Duration(seconds: 2),
            child: Text(
              l10n.dashboardTopClientsTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.dashboardTopClientsSubtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
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
                      rankIcon = Tooltip(
                        message: l10n.dashboardRankFirstTooltip,
                        waitDuration: const Duration(seconds: 2),
                        child: const Text('🏆', style: TextStyle(fontSize: 20)),
                      );
                      break;
                    case 1:
                      rankIcon = Tooltip(
                        message: l10n.dashboardRankSecondTooltip,
                        waitDuration: const Duration(seconds: 2),
                        child: const Icon(
                          Icons.emoji_events,
                          color: Color(0xFFC0C0C0),
                          size: 24,
                        ),
                      );
                      break;
                    case 2:
                      rankIcon = Tooltip(
                        message: l10n.dashboardRankThirdTooltip,
                        waitDuration: const Duration(seconds: 2),
                        child: const Text('🥇', style: TextStyle(fontSize: 20)),
                      );
                      break;
                    case 3:
                      rankIcon = Tooltip(
                        message: l10n.dashboardRankFourthTooltip,
                        waitDuration: const Duration(seconds: 2),
                        child: const Text('🥈', style: TextStyle(fontSize: 20)),
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
                            color: AppColors.primary.withValues(alpha: 0.05),
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
                                    l10n.dashboardReservationsAbbrev(
                                      client.count,
                                    ),
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
                                      color: AppColors.border.withValues(
                                        alpha: 0.5,
                                      ),
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

  Widget _buildEmptySection(BuildContext context, String title) {
    return Container(
      height: 420,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
          const Expanded(child: Center(child: _DashboardEmptyText())),
        ],
      ),
    );
  }
}

class _DashboardEmptyText extends StatelessWidget {
  const _DashboardEmptyText();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(
      l10n.notEnoughData,
      style: const TextStyle(color: AppColors.textSecondary),
    );
  }
}
