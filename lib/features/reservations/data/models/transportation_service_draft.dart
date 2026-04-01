import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class TransportationTripDraft extends Equatable {
  const TransportationTripDraft({
    required this.type,
    required this.fromDestination,
    required this.toDestination,
    required this.vehicle,
    required this.date,
    required this.time,
    required this.quantity,
    required this.pax,
    required this.notes,
    required this.salePerItem,
    required this.costPerItem,
  });

  final String type;
  final String fromDestination;
  final String toDestination;
  final String vehicle;
  final DateTime date;
  final String time;
  final int quantity;
  final int pax;
  final String? notes;
  final Decimal salePerItem;
  final Decimal costPerItem;

  @override
  List<Object?> get props => <Object?>[
    type,
    fromDestination,
    toDestination,
    vehicle,
    date,
    time,
    quantity,
    pax,
    notes,
    salePerItem,
    costPerItem,
  ];
}

class TransportationServiceDraft extends Equatable {
  const TransportationServiceDraft({
    required this.pricingPerTrip,
    required this.routeType,
    required this.serviceRoute,
    required this.supplierId,
    required this.supplierName,
    required this.termsAndConditions,
    required this.transactionNotes,
    required this.providerRemarks,
    required this.providerOptionDate,
    required this.trips,
    required this.totalSale,
    required this.totalCost,
  });

  final bool pricingPerTrip;
  final String routeType;
  final String? serviceRoute;
  final int? supplierId;
  final String? supplierName;
  final String? termsAndConditions;
  final String? transactionNotes;
  final String? providerRemarks;
  final DateTime? providerOptionDate;
  final List<TransportationTripDraft> trips;
  final Decimal totalSale;
  final Decimal totalCost;

  @override
  List<Object?> get props => <Object?>[
    pricingPerTrip,
    routeType,
    serviceRoute,
    supplierId,
    supplierName,
    termsAndConditions,
    transactionNotes,
    providerRemarks,
    providerOptionDate,
    trips,
    totalSale,
    totalCost,
  ];
}
