import 'package:equatable/equatable.dart';

class RmsBridgeHotelSegment extends Equatable {
  const RmsBridgeHotelSegment({
    required this.referenceId,
    required this.hotelId,
    required this.arrivalDate,
    required this.departureDate,
    required this.label,
    required this.type,
    required this.totalSale,
    required this.totalCost,
  });

  final String referenceId;
  final String? hotelId;
  final String? arrivalDate;
  final String? departureDate;
  final String? label;
  final String? type;
  final String? totalSale;
  final String? totalCost;

  @override
  List<Object?> get props => [
        referenceId,
        hotelId,
        arrivalDate,
        departureDate,
        label,
        type,
        totalSale,
        totalCost,
      ];
}

