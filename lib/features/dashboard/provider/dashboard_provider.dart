import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/reservations/provider/reservations_data_providers.dart';

class ClientStat {
  final String name;
  final int count;
  ClientStat(this.name, this.count);
}

class DailyStat {
  final DateTime date;
  final int count;
  DailyStat(this.date, this.count);
}

class DashboardStats {
  const DashboardStats({
    required this.todayCount,
    required this.thisWeekCount,
    required this.currentPeriodCount,
    required this.dailyStats,
    required this.topClients,
    required this.needsFollowUp,
    required this.performancePercentage,
    required this.isPerformancePositive,
  });

  final int todayCount;
  final int thisWeekCount;
  final int currentPeriodCount;
  final List<DailyStat> dailyStats;
  final List<ClientStat> topClients;
  final List<ReservationOrder> needsFollowUp;
  final double performancePercentage;
  final bool isPerformancePositive;
}

class DashboardPeriodNotifier extends Notifier<int> {
  @override
  int build() => 30;

  void setPeriod(int days) {
    state = days;
  }
}

final dashboardPeriodProvider = NotifierProvider<DashboardPeriodNotifier, int>(
  () => DashboardPeriodNotifier(),
);

class DashboardFollowUpPeriodNotifier extends Notifier<int> {
  @override
  int build() => 7;

  void setPeriod(int days) {
    state = days;
  }
}

final dashboardFollowUpPeriodProvider =
    NotifierProvider<DashboardFollowUpPeriodNotifier, int>(
      () => DashboardFollowUpPeriodNotifier(),
    );

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final orders = await ref.watch(reservationOrdersProvider.future);
  final periodDays = ref.watch(dashboardPeriodProvider);
  final followUpDays = ref.watch(dashboardFollowUpPeriodProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final periodStart = today.subtract(Duration(days: periodDays - 1));
  final previousPeriodStart = periodStart.subtract(Duration(days: periodDays));

  int todayCount = 0;
  int weekCount = 0;

  // 1. Performance Comparison
  int currentPeriodCount = 0;
  int previousPeriodCount = 0;

  // 2. Chart Data
  final Map<DateTime, int> dailyCounts = {};
  for (int i = 0; i < periodDays; i++) {
    dailyCounts[periodStart.add(Duration(days: i))] = 0;
  }

  // 3. Top Clients & Follow ups
  final Map<String, int> clientCounts = {};
  final List<ReservationOrder> recentOrders = [];
  final followUpLimit = today.subtract(Duration(days: followUpDays));

  for (final order in orders) {
    final orderDate = DateTime(
      order.createdAt.year,
      order.createdAt.month,
      order.createdAt.day,
    );

    if (orderDate.isAtSameMomentAs(today)) {
      todayCount++;
    }
    if (orderDate.isAfter(startOfWeek.subtract(const Duration(days: 1)))) {
      weekCount++;
    }

    // Performance
    if (!orderDate.isBefore(periodStart) && !orderDate.isAfter(today)) {
      currentPeriodCount++;
      // Daily Stats
      if (dailyCounts.containsKey(orderDate)) {
        dailyCounts[orderDate] = dailyCounts[orderDate]! + 1;
      }
      // Clients
      final clientName = order.client.name;
      clientCounts[clientName] = (clientCounts[clientName] ?? 0) + 1;
    } else if (!orderDate.isBefore(previousPeriodStart) &&
        orderDate.isBefore(periodStart)) {
      previousPeriodCount++;
    }

    // Needs Follow Up (missing RMS within selected period)
    if (!orderDate.isBefore(followUpLimit)) {
      if (order.rmsInvoiceNo == null || order.rmsInvoiceNo!.trim().isEmpty) {
        recentOrders.add(order);
      }
    }
  }

  // Calculate Performance %
  double perfPercentage = 0.0;
  bool isPositive = true;
  if (previousPeriodCount == 0) {
    if (currentPeriodCount > 0) perfPercentage = 100.0;
  } else {
    perfPercentage =
        ((currentPeriodCount - previousPeriodCount) / previousPeriodCount) *
        100;
    isPositive = perfPercentage >= 0;
    perfPercentage = perfPercentage.abs();
  }

  // Top Clients
  final topClients = clientCounts.entries
      .map((e) => ClientStat(e.key, e.value))
      .sorted((a, b) => b.count.compareTo(a.count))
      .take(5)
      .toList();

  // Daily Stats Sorted
  final dailyStats = dailyCounts.entries
      .map((e) => DailyStat(e.key, e.value))
      .sorted((a, b) => a.date.compareTo(b.date))
      .toList();

  // Needs follow up sorted by newest
  recentOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return DashboardStats(
    todayCount: todayCount,
    thisWeekCount: weekCount,
    currentPeriodCount: currentPeriodCount,
    dailyStats: dailyStats,
    topClients: topClients,
    needsFollowUp: recentOrders,
    performancePercentage: perfPercentage,
    isPerformancePositive: isPositive,
  );
});
