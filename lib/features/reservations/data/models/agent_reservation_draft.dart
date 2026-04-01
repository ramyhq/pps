import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class AgentReservationDraft extends Equatable {
  const AgentReservationDraft({
    required this.arrivalDate,
    required this.departureDate,
    required this.isManualRate,
    required this.isPricesWithoutVat,
    required this.hotelId,
    required this.hotelName,
    required this.hotelCity,
    required this.supplierId,
    required this.supplierName,
    required this.selectedRoomType,
    required this.selectedMealPlan,
    required this.roomRates,
    required this.roomsSummary,
    required this.totalPax,
    required this.totalSale,
    required this.totalCost,
  });

  final DateTime arrivalDate;
  final DateTime departureDate;
  final bool isManualRate;
  final bool isPricesWithoutVat;
  final int? hotelId;
  final String? hotelName;
  final String? hotelCity;
  final int? supplierId;
  final String? supplierName;
  final String? selectedRoomType;
  final String? selectedMealPlan;
  final List<AgentReservationRoomRate> roomRates;
  final List<AgentReservationRoomSummary> roomsSummary;
  final int totalPax;
  final Decimal totalSale;
  final Decimal totalCost;

  @override
  List<Object?> get props => <Object?>[
    arrivalDate,
    departureDate,
    isManualRate,
    isPricesWithoutVat,
    hotelId,
    hotelName,
    hotelCity,
    supplierId,
    supplierName,
    selectedRoomType,
    selectedMealPlan,
    roomRates,
    roomsSummary,
    totalPax,
    totalSale,
    totalCost,
  ];
}

class AgentReservationRoomRate extends Equatable {
  const AgentReservationRoomRate({
    required this.date,
    required this.saleRoom,
    required this.saleMealPerPax,
    required this.costRoom,
    required this.costMealPerPax,
  });

  final DateTime date;
  final String saleRoom;
  final String saleMealPerPax;
  final String costRoom;
  final String costMealPerPax;

  @override
  List<Object?> get props => <Object?>[
    date,
    saleRoom,
    saleMealPerPax,
    costRoom,
    costMealPerPax,
  ];
}

class AgentReservationRoomSummary extends Equatable {
  const AgentReservationRoomSummary({
    required this.numberOfRooms,
    required this.totalRn,
    required this.roomType,
    required this.mealPlan,
    required this.pax,
    required this.totalSale,
    required this.totalCost,
  });

  final int numberOfRooms;
  final int totalRn;
  final String roomType;
  final String mealPlan;
  final int pax;
  final Decimal totalSale;
  final Decimal totalCost;

  @override
  List<Object?> get props => <Object?>[
    numberOfRooms,
    totalRn,
    roomType,
    mealPlan,
    pax,
    totalSale,
    totalCost,
  ];
}
