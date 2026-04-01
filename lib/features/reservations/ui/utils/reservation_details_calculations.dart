import 'package:decimal/decimal.dart';
import 'package:rms_clone/features/reservations/data/models/reservation_service.dart';

class ReservationDetailsTotals {
  const ReservationDetailsTotals({
    required this.totalSale,
    required this.totalCost,
  });

  final Decimal totalSale;
  final Decimal totalCost;
}

class ReservationDetailsCalculations {
  static ReservationDetailsTotals totals(
    Iterable<ReservationServiceSummary> services,
  ) {
    //CALCULATIONS إجمالي البيع في صفحة التفاصيل = مجموع totalSale لكل الخدمات المحملة.
    final totalSale = services.fold<Decimal>(
      Decimal.parse('0'),
      (sum, service) => sum + service.totalSale,
    );
    //CALCULATIONS إجمالي التكلفة في صفحة التفاصيل = مجموع totalCost لكل الخدمات المحملة.
    final totalCost = services.fold<Decimal>(
      Decimal.parse('0'),
      (sum, service) => sum + service.totalCost,
    );
    return ReservationDetailsTotals(totalSale: totalSale, totalCost: totalCost);
  }
}
