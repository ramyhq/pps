import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

class GeneralServiceDraft extends Equatable {
  const GeneralServiceDraft({
    required this.dateOfService,
    required this.endDate,
    required this.serviceName,
    required this.description,
    required this.quantity,
    required this.supplierId,
    required this.salePerItem,
    required this.costPerItem,
    required this.totalSale,
    required this.totalCost,
    required this.termsAndConditions,
    required this.providerRemarks,
    required this.notes,
  });

  final DateTime dateOfService;
  final DateTime endDate;
  final String serviceName;
  final String description;
  final int quantity;
  final int? supplierId;
  final Decimal salePerItem;
  final Decimal costPerItem;
  final Decimal totalSale;
  final Decimal totalCost;
  final String? termsAndConditions;
  final String? providerRemarks;
  final String? notes;

  @override
  List<Object?> get props => <Object?>[
    dateOfService,
    endDate,
    serviceName,
    description,
    quantity,
    supplierId,
    salePerItem,
    costPerItem,
    totalSale,
    totalCost,
    termsAndConditions,
    providerRemarks,
    notes,
  ];
}
