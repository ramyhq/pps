import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pps/core/constants/app_colors.dart';
import 'package:pps/core/constants/app_strings.dart';
import 'package:pps/core/widgets/custom_form_fields.dart';
import 'package:pps/core/widgets/segmented_time_picker.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/reservations/data/models/transportation_service_draft.dart';
import 'package:pps/features/reservations/provider/reservations_data_providers.dart';

class CreateTransportationServiceScreen extends ConsumerStatefulWidget {
  const CreateTransportationServiceScreen({
    super.key,
    this.reservationId,
    this.serviceId,
  });

  final String? reservationId;
  final String? serviceId;

  static const double _pagePadding = AppSpacing.s16;
  static const double _sectionGap = AppSpacing.s16;
  static const double _fieldGap = AppSpacing.s12;

  @override
  ConsumerState<CreateTransportationServiceScreen> createState() =>
      _CreateTransportationServiceScreenState();
}

class _CreateTransportationServiceScreenState
    extends ConsumerState<CreateTransportationServiceScreen> {
  _RouteType _routeType = _RouteType.custom;
  bool _pricingPerTrip = false;

  int? _selectedClientId;
  DateTime _clientOptionDate = DateTime.now();
  String? _reservationId;
  bool _isSaving = false;

  int? _selectedSupplierId;
  String? _selectedSupplierLabel;
  String? _selectedTermsAndConditions = AppStrings.termsAndConditionsDefaultKey;

  String? _serviceRoute;
  String? _applyVehicle;
  DateTime? _providerOptionDate;
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _transactionNotesController =
      TextEditingController();
  final TextEditingController _providerRemarksController =
      TextEditingController();
  final TextEditingController _applyQuantityController =
      TextEditingController();
  final TextEditingController _applyPaxController = TextEditingController();

  final TextEditingController _salePerItemController = TextEditingController(
    text: '0',
  );
  final TextEditingController _costPerItemController = TextEditingController(
    text: '0',
  );

  final List<_TripFormData> _trips = <_TripFormData>[];

  static const List<String> _destinationItems = <String>[
    'MED TRAIN',
    'MED APT',
    'MED HTL',
    'MED MAZARAT',
    'MAK HTL',
    'MAK TRAIN',
    'MAK MAZARAT',
    'JED APT',
    'JED HTL',
    'JED TOUR',
  ];

  static const List<String> _vehicleItems = <String>[
    'Bus - BUS',
    'Bus - 49',
    'GMC - GMC',
    'Coaster - COASTAR',
    'Train - SAR',
    'Hiase - PRIVETE',
    'STARIA - 4 Seats',
    'STARIA - 7 Seats',
    'TAXI - Camry - 4 Seats',
    'PICK UP LUGGAGE - TRUCK',
    'TAXI - Lexus car - 4 Seats',
    'Bus - Bus VIP - 28 Seats',
  ];

  static const List<String> _tripTypeItems = <String>[
    'Arrival',
    'Internal',
    'Departure',
  ];

  @override
  void initState() {
    super.initState();
    _trips.add(_TripFormData(index: 1));
    _reservationId = widget.reservationId;
    final serviceId = widget.serviceId;
    if (serviceId != null && serviceId.trim().isNotEmpty) {
      Future<void>.microtask(() async {
        try {
          final repository = ref.read(reservationsRepositoryProvider);
          final draft = await ref
              .read(reservationsRepositoryProvider)
              .fetchTransportationServiceDraft(serviceId);
          if (!mounted) {
            return;
          }
          String? supplierLabel;
          final supplierId = draft.supplierId;
          if (supplierId != null) {
            final cached =
                ref.read(reservationSuppliersProvider).value ?? const [];
            supplierLabel = cached
                .where((s) => s.id == supplierId)
                .map((s) => s.label)
                .cast<String?>()
                .firstWhere((label) => label != null, orElse: () => null);
            supplierLabel ??= (await repository.listSuppliers())
                .where((s) => s.id == supplierId)
                .map((s) => s.label)
                .cast<String?>()
                .firstWhere((label) => label != null, orElse: () => null);
          }
          setState(() {
            _routeType = _RouteType.values.firstWhere(
              (t) => t.name == draft.routeType,
              orElse: () => _RouteType.custom,
            );
            _pricingPerTrip = draft.pricingPerTrip;
            _serviceRoute = draft.serviceRoute;
            _selectedSupplierId = draft.supplierId;
            _selectedSupplierLabel = draft.supplierName ?? supplierLabel;
            _selectedTermsAndConditions =
                draft.termsAndConditions ?? 'Standard';
            _providerOptionDate = draft.providerOptionDate;
            _transactionNotesController.text = draft.transactionNotes ?? '';
            _providerRemarksController.text = draft.providerRemarks ?? '';
            if (draft.trips.isNotEmpty) {
              _salePerItemController.text = draft.trips.first.salePerItem
                  .toString();
              _costPerItemController.text = draft.trips.first.costPerItem
                  .toString();
            }
            for (final trip in _trips) {
              trip.dispose();
            }
            _trips.clear();
            for (var i = 0; i < draft.trips.length; i++) {
              final source = draft.trips[i];
              final form = _TripFormData(index: i + 1)
                ..type = source.type
                ..fromDestination = source.fromDestination
                ..toDestination = source.toDestination
                ..vehicle = source.vehicle
                ..date = source.date;
              form.timeController.text = source.time;
              form.quantityController.text = source.quantity.toString();
              form.paxController.text = source.pax.toString();
              form.notesController.text = source.notes ?? '';
              form.salePerItemController.text = source.salePerItem.toString();
              form.costPerItemController.text = source.costPerItem.toString();
              _trips.add(form);
            }
            if (_trips.isEmpty) {
              _trips.add(_TripFormData(index: 1));
            }
          });
        } catch (_) {}
      });
    }
    final reservationId = widget.reservationId;
    if (reservationId != null) {
      Future<void>.microtask(() async {
        try {
          final details = await ref
              .read(reservationsRepositoryProvider)
              .fetchReservationDetails(reservationId);
          if (!mounted) {
            return;
          }
          setState(() {
            _selectedClientId = details.order.client.id;
            _clientOptionDate =
                details.order.clientOptionDate ?? DateTime.now();
            _guestNameController.text = details.order.guestName ?? '';
          });
        } catch (_) {}
      });
    }
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    setState(() {
      _isSaving = true;
    });
    try {
      final repository = ref.read(reservationsRepositoryProvider);
      final editingServiceId = widget.serviceId?.trim();
      if (editingServiceId != null &&
          editingServiceId.isNotEmpty &&
          _reservationId == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Missing reservation id for edit.'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
      var reservationId = _reservationId;
      if (reservationId == null) {
        final clientId = _selectedClientId;
        if (clientId == null) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Please select client before save.'),
              backgroundColor: AppColors.danger,
            ),
          );
          setState(() {
            _isSaving = false;
          });
          return;
        }
        final createdOrder = await repository.createReservationOrder(
          CreateReservationOrderDraft(
            clientId: clientId,
            guestName: _guestNameController.text.trim().isEmpty
                ? null
                : _guestNameController.text.trim(),
            guestNationality: null,
            clientOptionDate: _clientOptionDate,
          ),
        );
        reservationId = createdOrder.id;
        setState(() {
          _reservationId = reservationId;
          _selectedClientId = createdOrder.client.id;
        });
      } else {
        await repository.updateReservationMainInfo(
          reservationId: reservationId,
          clientId: _selectedClientId!,
          guestName: _guestNameController.text.trim().isEmpty
              ? null
              : _guestNameController.text.trim(),
          guestNationality: null,
          clientOptionDate: _clientOptionDate,
        );
      }

      if (_selectedSupplierId == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Please select service provider before save.'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      var totalSale = Decimal.parse('0');
      var totalCost = Decimal.parse('0');

      final globalSalePerItem = _parseDecimal(_salePerItemController.text);
      final globalCostPerItem = _parseDecimal(_costPerItemController.text);
      final pricingPerTrip = _pricingPerTrip;

      final trips = _trips
          .map((trip) {
            final quantity =
                int.tryParse(trip.quantityController.text.trim()) ?? 0;
            final salePerItem = pricingPerTrip
                ? _parseDecimal(trip.salePerItemController.text)
                : globalSalePerItem;
            final costPerItem = pricingPerTrip
                ? _parseDecimal(trip.costPerItemController.text)
                : globalCostPerItem;

            totalSale = totalSale + (salePerItem * Decimal.fromInt(quantity));
            totalCost = totalCost + (costPerItem * Decimal.fromInt(quantity));
            return TransportationTripDraft(
              type: (trip.type ?? '').trim(),
              fromDestination: (trip.fromDestination ?? '').trim(),
              toDestination: (trip.toDestination ?? '').trim(),
              vehicle: (trip.vehicle ?? '').trim(),
              date: trip.date,
              time: trip.timeController.text.trim(),
              quantity: quantity,
              pax: int.tryParse(trip.paxController.text.trim()) ?? 0,
              notes: trip.notesController.text.trim().isEmpty
                  ? null
                  : trip.notesController.text.trim(),
              salePerItem: salePerItem,
              costPerItem: costPerItem,
            );
          })
          .toList(growable: false);

      final draft = TransportationServiceDraft(
        pricingPerTrip: pricingPerTrip,
        routeType: _routeType.name,
        serviceRoute: _serviceRoute,
        supplierId: _selectedSupplierId,
        supplierName: _selectedSupplierLabel,
        termsAndConditions: _selectedTermsAndConditions,
        transactionNotes: _transactionNotesController.text.trim().isEmpty
            ? null
            : _transactionNotesController.text.trim(),
        providerRemarks: _providerRemarksController.text.trim().isEmpty
            ? null
            : _providerRemarksController.text.trim(),
        providerOptionDate: _providerOptionDate,
        trips: trips,
        totalSale: totalSale,
        totalCost: totalCost,
      );

      if (editingServiceId != null && editingServiceId.isNotEmpty) {
        await repository.updateTransportationService(
          serviceId: editingServiceId,
          draft: draft,
        );
      } else {
        await repository.addTransportationService(
          reservationId: reservationId,
          draft: draft,
        );
      }

      if (!mounted) {
        return;
      }
      ref.invalidate(reservationDetailsProvider(reservationId));
      ref.invalidate(reservationOrdersProvider);
      context.go('/reservations/details?reservationId=$reservationId');
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final trip in _trips) {
      trip.dispose();
    }
    _guestNameController.dispose();
    _transactionNotesController.dispose();
    _providerRemarksController.dispose();
    _applyQuantityController.dispose();
    _applyPaxController.dispose();
    _salePerItemController.dispose();
    _costPerItemController.dispose();
    super.dispose();
  }

  void _addTrip() {
    setState(() {
      final next = _TripFormData(index: _trips.length + 1);
      if (_pricingPerTrip) {
        next.salePerItemController.text = _salePerItemController.text;
        next.costPerItemController.text = _costPerItemController.text;
      }
      _trips.add(next);
    });
  }

  void _removeTrip(_TripFormData trip) {
    setState(() {
      _trips.remove(trip);
      trip.dispose();
      for (var i = 0; i < _trips.length; i++) {
        _trips[i] = _trips[i].copyWith(index: i + 1);
      }
    });
  }

  void _applyToAllTrips() {
    final qty = _applyQuantityController.text.trim();
    final pax = _applyPaxController.text.trim();

    for (final trip in _trips) {
      trip.vehicle = _applyVehicle;
      if (qty.isNotEmpty) {
        trip.quantityController.text = qty;
      }
      if (pax.isNotEmpty) {
        trip.paxController.text = pax;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          CreateTransportationServiceScreen._pagePadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(),
            const SizedBox(
              height: CreateTransportationServiceScreen._sectionGap,
            ),
            const Text(
              'Reservation number : - S',
              style: TextStyle(
                fontSize: AppFontSizes.title13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            _buildReservationDetailsCard(),
            const SizedBox(
              height: CreateTransportationServiceScreen._sectionGap,
            ),
            _buildServiceDetailsCard(),
            const SizedBox(
              height: CreateTransportationServiceScreen._sectionGap,
            ),
            _buildBottomActions(),
            const SizedBox(height: AppSpacing.s40),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Transportation Service',
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: AppSpacing.s4),
            Row(
              children: [
                const Text(
                  'Reservations',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppFontSizes.title13,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                  child: Text(
                    '•',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  'Create',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.arrow_back, size: AppIconSizes.s16),
          label: const Text('Back'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r4),
            ),
            backgroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildReservationDetailsCard() {
    final clientsAsync = ref.watch(reservationClientsProvider);
    final clients = clientsAsync.value ?? const [];
    String? selectedClientLabel;
    if (_selectedClientId != null) {
      for (final client in clients) {
        if (client.id == _selectedClientId) {
          selectedClientLabel = client.label;
          break;
        }
      }
    }

    final items = <String>{
      ...clients.map((client) => client.label),
      if (selectedClientLabel != null) selectedClientLabel,
    }.toList(growable: false);

    final isClientLocked = _reservationId != null;

    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: const BoxDecoration(
              color: AppColors.light,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadii.r8),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'Reservation details',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop =
                    constraints.maxWidth >= CreateScreensBreakpoints.desktop;
                final isLargeDesktop =
                    constraints.maxWidth >=
                    CreateScreensBreakpoints.largeDesktop;

                const col2Width = 195.0;
                const col4Width = 409.0;
                final clientWidth =
                    constraints.maxWidth >= CreateScreensBreakpoints.xlDesktop
                    ? CreateScreensLayout.clientWidthXl
                    : constraints.maxWidth >= CreateScreensBreakpoints.mdDesktop
                    ? CreateScreensLayout.clientWidthMd
                    : CreateScreensLayout.clientWidthSm;

                Widget row1() {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: clientWidth,
                        child: CustomDropdown(
                          label: 'Client',
                          isRequired: true,
                          value: selectedClientLabel,
                          items: items,
                          enabled: !isClientLocked,
                          onChanged: (value) {
                            final selected = value?.trim();
                            if (selected == null || selected.isEmpty) {
                              setState(() {
                                _selectedClientId = null;
                              });
                              return;
                            }
                            final match = clients
                                .where((c) => c.label == selected)
                                .toList(growable: false);
                            if (match.isEmpty) {
                              return;
                            }
                            setState(() {
                              _selectedClientId = match.first.id;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                        width: CreateTransportationServiceScreen._fieldGap,
                      ),
                      SizedBox(
                        width: col2Width,
                        child: CustomDatePickerField(
                          label: 'Client option date',
                          initialDate: _clientOptionDate,
                          onChanged: (value) {
                            setState(() {
                              _clientOptionDate = value;
                            });
                          },
                          popupWidth: AppWidths.datePickerPopup,
                        ),
                      ),
                      const Spacer(),
                    ],
                  );
                }

                Widget row2() {
                  if (isLargeDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: col4Width,
                          child: CustomTextField(
                            label: 'Guest name',
                            controller: _guestNameController,
                          ),
                        ),
                        const Spacer(),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: CustomTextField(
                          label: 'Guest name',
                          controller: _guestNameController,
                        ),
                      ),
                      const Spacer(),
                    ],
                  );
                }

                Widget row3() {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: clientWidth,
                        child: CustomDropdown(
                          label: 'Terms & conditions',
                          items: AppStrings.termsAndConditionsOptions,
                          value: _selectedTermsAndConditions,
                          onChanged: (value) {
                            setState(() {
                              _selectedTermsAndConditions =
                                  value?.trim().isEmpty == true
                                  ? null
                                  : value?.trim();
                            });
                          },
                        ),
                      ),
                      const Spacer(),
                    ],
                  );
                }

                if (!isDesktop) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomDropdown(
                        label: 'Client',
                        isRequired: true,
                        value: selectedClientLabel,
                        items: items,
                        enabled: !isClientLocked,
                        onChanged: (value) {
                          final selected = value?.trim();
                          if (selected == null || selected.isEmpty) {
                            setState(() {
                              _selectedClientId = null;
                            });
                            return;
                          }
                          final match = clients
                              .where((c) => c.label == selected)
                              .toList(growable: false);
                          if (match.isEmpty) {
                            return;
                          }
                          setState(() {
                            _selectedClientId = match.first.id;
                          });
                        },
                      ),
                      const SizedBox(
                        height: CreateTransportationServiceScreen._sectionGap,
                      ),
                      CustomDatePickerField(
                        label: 'Client option date',
                        initialDate: _clientOptionDate,
                        onChanged: (value) {
                          setState(() {
                            _clientOptionDate = value;
                          });
                        },
                        popupWidth: AppWidths.datePickerPopup,
                      ),
                      const SizedBox(
                        height: CreateTransportationServiceScreen._sectionGap,
                      ),
                      CustomTextField(
                        label: 'Guest name',
                        controller: _guestNameController,
                      ),
                      const SizedBox(
                        height: CreateTransportationServiceScreen._sectionGap,
                      ),
                      CustomDropdown(
                        label: 'Terms & conditions',
                        items: AppStrings.termsAndConditionsOptions,
                        value: _selectedTermsAndConditions,
                        onChanged: (value) {
                          setState(() {
                            _selectedTermsAndConditions =
                                value?.trim().isEmpty == true
                                ? null
                                : value?.trim();
                          });
                        },
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    row1(),
                    const SizedBox(
                      height: CreateTransportationServiceScreen._sectionGap,
                    ),
                    row2(),
                    const SizedBox(
                      height: CreateTransportationServiceScreen._sectionGap,
                    ),
                    row3(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsCard() {
    final suppliersAsync = ref.watch(reservationSuppliersProvider);
    return Card(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: const BoxDecoration(
              color: AppColors.light,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppRadii.r8),
              ),
            ),
            child: const Row(
              children: [
                Text(
                  'Service details',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop =
                    constraints.maxWidth >= CreateScreensBreakpoints.desktop;
                const col2Width = 195.0;
                final clientWidth =
                    constraints.maxWidth >= CreateScreensBreakpoints.xlDesktop
                    ? CreateScreensLayout.clientWidthXl
                    : constraints.maxWidth >= CreateScreensBreakpoints.mdDesktop
                    ? CreateScreensLayout.clientWidthMd
                    : CreateScreensLayout.clientWidthSm;

                Widget providerRow() {
                  Widget dropdownFor(List<String> items) {
                    return CustomDropdown(
                      label: 'Service provider',
                      isRequired: true,
                      items: items,
                      value: items.contains(_selectedSupplierLabel)
                          ? _selectedSupplierLabel
                          : null,
                      onChanged: (v) {
                        setState(() {
                          _selectedSupplierLabel = v;
                          _selectedSupplierId = null;
                        });
                      },
                    );
                  }

                  Widget providerDropdown() {
                    return suppliersAsync.when(
                      data: (suppliers) {
                        final items = suppliers
                            .map((s) => s.label)
                            .toList(growable: false);
                        return CustomDropdown(
                          label: 'Service provider',
                          isRequired: true,
                          items: items,
                          value: items.contains(_selectedSupplierLabel)
                              ? _selectedSupplierLabel
                              : null,
                          onChanged: (v) {
                            setState(() {
                              _selectedSupplierLabel = v;
                              _selectedSupplierId = suppliers
                                  .where((s) => s.label == v)
                                  .map((s) => s.id)
                                  .cast<int?>()
                                  .firstWhere(
                                    (id) => id != null,
                                    orElse: () => null,
                                  );
                            });
                          },
                        );
                      },
                      loading: () => dropdownFor(const <String>[]),
                      error: (_, __) => dropdownFor(const <String>[]),
                    );
                  }

                  if (!isDesktop) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [providerDropdown()],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: clientWidth, child: providerDropdown()),
                      const Spacer(),
                    ],
                  );
                }

                Widget notesRow() {
                  if (!isDesktop) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'Transactions notes',
                          hintText: 'Notes to appear in financial transaction',
                          controller: _transactionNotesController,
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Transactions notes',
                          hintText: 'Notes to appear in financial transaction',
                          controller: _transactionNotesController,
                        ),
                      ),
                    ],
                  );
                }

                Widget providerRemarksRow() {
                  if (!isDesktop) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'Provider remarks',
                          controller: _providerRemarksController,
                        ),
                        const SizedBox(
                          height: CreateTransportationServiceScreen._sectionGap,
                        ),
                        CustomDatePickerField(
                          label: 'Provider option date',
                          initialDate:
                              _providerOptionDate ?? DateTime(2026, 3, 12),
                          startEmpty: _providerOptionDate == null,
                          onChanged: (value) {
                            setState(() {
                              _providerOptionDate = value;
                            });
                          },
                          popupWidth: AppWidths.datePickerPopup,
                        ),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'Provider remarks',
                          controller: _providerRemarksController,
                        ),
                      ),
                      const SizedBox(
                        width: CreateTransportationServiceScreen._fieldGap,
                      ),
                      SizedBox(
                        width: col2Width,
                        child: CustomDatePickerField(
                          label: 'Provider option date',
                          initialDate:
                              _providerOptionDate ?? DateTime(2026, 3, 12),
                          startEmpty: _providerOptionDate == null,
                          onChanged: (value) {
                            setState(() {
                              _providerOptionDate = value;
                            });
                          },
                          popupWidth: AppWidths.datePickerPopup,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    providerRow(),
                    const SizedBox(
                      height: CreateTransportationServiceScreen._sectionGap,
                    ),
                    notesRow(),
                    const SizedBox(
                      height: CreateTransportationServiceScreen._sectionGap,
                    ),
                    providerRemarksRow(),
                    const SizedBox(
                      height: CreateTransportationServiceScreen._sectionGap,
                    ),
                    _buildPricingModeToggle(),
                    const SizedBox(height: AppSpacing.s8),
                    _buildPricingAllService(),
                    const SizedBox(
                      height: CreateTransportationServiceScreen._sectionGap,
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(
                      height: CreateTransportationServiceScreen._sectionGap,
                    ),
                    const Text(
                      'Trips details',
                      style: TextStyle(
                        fontSize: AppFontSizes.title13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    _buildTripsDetailsSection(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingAllService() {
    if (_pricingPerTrip) {
      var totalSale = Decimal.parse('0');
      var totalCost = Decimal.parse('0');
      for (final trip in _trips) {
        final quantity = int.tryParse(trip.quantityController.text.trim()) ?? 0;
        final salePerItem = _parseDecimal(trip.salePerItemController.text);
        final costPerItem = _parseDecimal(trip.costPerItemController.text);
        totalSale = totalSale + (salePerItem * Decimal.fromInt(quantity));
        totalCost = totalCost + (costPerItem * Decimal.fromInt(quantity));
      }
      return _buildPricingSummaryTable(
        totalSale: totalSale,
        totalCost: totalCost,
      );
    }
    return _buildPerItemPricingTable(
      itemsCount: _totalItemsCount(),
      salePerItemController: _salePerItemController,
      costPerItemController: _costPerItemController,
      enabled: !_pricingPerTrip,
      onChanged: () => setState(() {}),
    );
  }

  int _totalItemsCount() {
    var total = 0;
    for (final trip in _trips) {
      final parsed = int.tryParse(trip.quantityController.text.trim()) ?? 0;
      if (parsed > 0) {
        total += parsed;
      }
    }
    return total;
  }

  Decimal _parseDecimal(String raw) {
    final normalized = raw.trim().replaceAll(',', '');
    if (normalized.isEmpty) {
      return Decimal.parse('0');
    }
    return Decimal.tryParse(normalized) ?? Decimal.parse('0');
  }

  String _formatDecimal6(Decimal value) {
    final raw = value.toString();
    if (!raw.contains('.')) {
      return '$raw.000000';
    }
    final parts = raw.split('.');
    final integer = parts[0].isEmpty ? '0' : parts[0];
    final frac = parts.length > 1 ? parts[1] : '';
    final padded = '${frac}000000';
    return '$integer.${padded.substring(0, 6)}';
  }

  Widget _buildPricingModeToggle() {
    return Row(
      children: [
        Checkbox(
          value: _pricingPerTrip,
          onChanged: (v) {
            if (v == null) {
              return;
            }
            setState(() {
              _pricingPerTrip = v;
              if (_pricingPerTrip) {
                final globalSale = _salePerItemController.text.trim();
                final globalCost = _costPerItemController.text.trim();
                for (final trip in _trips) {
                  if (trip.salePerItemController.text.trim().isEmpty ||
                      trip.salePerItemController.text.trim() == '0') {
                    trip.salePerItemController.text = globalSale.isEmpty
                        ? '0'
                        : globalSale;
                  }
                  if (trip.costPerItemController.text.trim().isEmpty ||
                      trip.costPerItemController.text.trim() == '0') {
                    trip.costPerItemController.text = globalCost.isEmpty
                        ? '0'
                        : globalCost;
                  }
                }
              } else {
                if (_trips.isNotEmpty) {
                  _salePerItemController.text =
                      _trips.first.salePerItemController.text;
                  _costPerItemController.text =
                      _trips.first.costPerItemController.text;
                }
              }
            });
          },
          side: const BorderSide(color: AppColors.inputBorder),
          activeColor: AppColors.primary,
        ),
        const Text(
          'Set Sale and Cost per each Trip',
          style: TextStyle(
            fontSize: AppFontSizes.body12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: AppSpacing.s6),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primarySurfaceAlt,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: AppColors.inputBorder),
          ),
          alignment: Alignment.center,
          child: const Text(
            '?',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerItemPricingTable({
    required int itemsCount,
    required TextEditingController salePerItemController,
    required TextEditingController costPerItemController,
    required bool enabled,
    required VoidCallback onChanged,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTableWidth =
            constraints.maxWidth >= CreateScreensBreakpoints.largeDesktop
            ? CreateScreensLayout.pricingTableMaxWidth900
            : constraints.maxWidth;

        //CALCULATIONS تحويل عدد العناصر إلى Decimal لاستخدامه في حساب المجاميع المالية المعروضة.
        final itemsDecimal = Decimal.fromInt(itemsCount);

        final salePerItem = _parseDecimal(salePerItemController.text);
        final salePrice = salePerItem * itemsDecimal;
        final saleTotal = salePrice;

        final costPerItem = _parseDecimal(costPerItemController.text);
        final costPrice = costPerItem * itemsDecimal;
        final costTotal = costPrice;

        const borderColor = AppColors.inputBorder;
        const headerBg = AppColors.primarySurfaceAlt;
        const headerTextStyle = TextStyle(
          fontSize: AppFontSizes.label11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
        const rowLabelStyle = TextStyle(
          fontSize: AppFontSizes.body12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
        const valueTextStyle = TextStyle(
          fontSize: AppFontSizes.body12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        );

        Widget gridCell({
          required Widget child,
          BorderSide? right,
          Alignment alignment = Alignment.centerLeft,
          EdgeInsets padding = const EdgeInsets.symmetric(
            horizontal: AppSpacing.s10,
            vertical: AppSpacing.s6,
          ),
          Color? backgroundColor,
        }) {
          return Container(
            alignment: alignment,
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(right: right ?? BorderSide.none),
            ),
            child: child,
          );
        }

        Widget perItemInput(TextEditingController controller) {
          return Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 120,
              height: AppHeights.dropdownSearch30,
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                onChanged: (_) => onChanged(),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  ArabicDigitsToEnglishInputFormatter(),
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,6}$')),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s10,
                    vertical: AppSpacing.s8,
                  ),
                  isDense: true,
                ),
                style: valueTextStyle,
              ),
            ),
          );
        }

        Widget headerRow() {
          return Container(
            height: AppHeights.field34,
            decoration: const BoxDecoration(
              color: headerBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: CreateScreensLayout.pricingLabelColWidth90,
                  child: gridCell(
                    child: const SizedBox.shrink(),
                    right: const BorderSide(color: borderColor),
                    backgroundColor: headerBg,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: gridCell(
                    child: const Center(
                      child: Text('Per Item', style: headerTextStyle),
                    ),
                    right: const BorderSide(color: borderColor),
                    alignment: Alignment.center,
                    backgroundColor: headerBg,
                  ),
                ),
                Expanded(
                  child: gridCell(
                    child: const Text('Price', style: headerTextStyle),
                    right: const BorderSide(color: borderColor),
                    backgroundColor: headerBg,
                  ),
                ),
                Expanded(
                  child: gridCell(
                    child: const Text('Total', style: headerTextStyle),
                    backgroundColor: headerBg,
                  ),
                ),
              ],
            ),
          );
        }

        Widget dataRow({
          required String label,
          required TextEditingController perItemController,
          required Decimal price,
          required Decimal total,
          bool addBottomBorder = true,
        }) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: addBottomBorder
                    ? const BorderSide(color: borderColor)
                    : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: CreateScreensLayout.pricingLabelColWidth90,
                  child: gridCell(
                    child: Text(label, style: rowLabelStyle),
                    right: const BorderSide(color: borderColor),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: gridCell(
                    child: perItemInput(perItemController),
                    right: const BorderSide(color: borderColor),
                  ),
                ),
                Expanded(
                  child: gridCell(
                    child: Text(_formatDecimal6(price), style: valueTextStyle),
                    right: const BorderSide(color: borderColor),
                  ),
                ),
                Expanded(
                  child: gridCell(
                    child: Text(_formatDecimal6(total), style: valueTextStyle),
                  ),
                ),
              ],
            ),
          );
        }

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxTableWidth),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(AppRadii.r4),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                headerRow(),
                dataRow(
                  label: 'Sale',
                  perItemController: salePerItemController,
                  price: salePrice,
                  total: saleTotal,
                ),
                dataRow(
                  label: 'Cost',
                  perItemController: costPerItemController,
                  price: costPrice,
                  total: costTotal,
                  addBottomBorder: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPricingSummaryTable({
    required Decimal totalSale,
    required Decimal totalCost,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxTableWidth =
            constraints.maxWidth >= CreateScreensBreakpoints.largeDesktop
            ? CreateScreensLayout.pricingTableMaxWidth900
            : constraints.maxWidth;

        const borderColor = AppColors.inputBorder;
        const headerBg = AppColors.primarySurfaceAlt;
        const headerTextStyle = TextStyle(
          fontSize: AppFontSizes.label11,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
        const rowLabelStyle = TextStyle(
          fontSize: AppFontSizes.body12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        );
        const valueTextStyle = TextStyle(
          fontSize: AppFontSizes.body12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        );

        Widget gridCell({
          required Widget child,
          BorderSide? right,
          Alignment alignment = Alignment.centerLeft,
          EdgeInsets padding = const EdgeInsets.symmetric(
            horizontal: AppSpacing.s10,
            vertical: AppSpacing.s6,
          ),
          Color? backgroundColor,
        }) {
          return Container(
            alignment: alignment,
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(right: right ?? BorderSide.none),
            ),
            child: child,
          );
        }

        Widget headerRow() {
          return Container(
            height: AppHeights.field34,
            decoration: const BoxDecoration(
              color: headerBg,
              border: Border(bottom: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: CreateScreensLayout.pricingLabelColWidth90,
                  child: gridCell(
                    child: const SizedBox.shrink(),
                    right: const BorderSide(color: borderColor),
                    backgroundColor: headerBg,
                  ),
                ),
                Expanded(
                  child: gridCell(
                    child: const Text('Price', style: headerTextStyle),
                    right: const BorderSide(color: borderColor),
                    backgroundColor: headerBg,
                  ),
                ),
                Expanded(
                  child: gridCell(
                    child: const Text('Total', style: headerTextStyle),
                    backgroundColor: headerBg,
                  ),
                ),
              ],
            ),
          );
        }

        Widget dataRow({
          required String label,
          required Decimal price,
          required Decimal total,
          bool addBottomBorder = true,
        }) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: addBottomBorder
                    ? const BorderSide(color: borderColor)
                    : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: CreateScreensLayout.pricingLabelColWidth90,
                  child: gridCell(
                    child: Text(label, style: rowLabelStyle),
                    right: const BorderSide(color: borderColor),
                  ),
                ),
                Expanded(
                  child: gridCell(
                    child: Text(_formatDecimal6(price), style: valueTextStyle),
                    right: const BorderSide(color: borderColor),
                  ),
                ),
                Expanded(
                  child: gridCell(
                    child: Text(_formatDecimal6(total), style: valueTextStyle),
                  ),
                ),
              ],
            ),
          );
        }

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxTableWidth),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(AppRadii.r4),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                headerRow(),
                dataRow(label: 'Sale', price: totalSale, total: totalSale),
                dataRow(
                  label: 'Cost',
                  price: totalCost,
                  total: totalCost,
                  addBottomBorder: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTripsDetailsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop =
            constraints.maxWidth >= CreateScreensBreakpoints.desktop;
        const col2Width = 195.0;
        const vehicleWidth = 409.0;

        final quantityWidth =
            constraints.maxWidth >= CreateScreensBreakpoints.mdDesktop
            ? CreateScreensLayout.tripQuantityWidthMd120
            : CreateScreensLayout.tripQuantityWidthSm110;
        final paxWidth = quantityWidth;

        Widget routeSelection() {
          if (!isDesktop) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Route Selection',
                  style: TextStyle(
                    fontSize: AppFontSizes.body12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),
                RadioListTile<_RouteType>(
                  value: _RouteType.custom,
                  groupValue: _routeType,
                  title: const Text(
                    'Custom Route',
                    style: TextStyle(fontSize: AppFontSizes.title13),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onChanged: (v) =>
                      setState(() => _routeType = v ?? _RouteType.custom),
                ),
                RadioListTile<_RouteType>(
                  value: _RouteType.service,
                  groupValue: _routeType,
                  title: const Text(
                    'Service Route',
                    style: TextStyle(fontSize: AppFontSizes.title13),
                  ),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  onChanged: (v) =>
                      setState(() => _routeType = v ?? _RouteType.custom),
                ),
                if (_routeType == _RouteType.service) ...[
                  const SizedBox(
                    height: CreateTransportationServiceScreen._sectionGap,
                  ),
                  CustomDropdown(
                    label: 'Service route',
                    items: const ['Route A', 'Route B'],
                    value: _serviceRoute,
                    onChanged: (v) => setState(() => _serviceRoute = v),
                  ),
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: col2Width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route Selection',
                      style: TextStyle(
                        fontSize: AppFontSizes.body12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    RadioListTile<_RouteType>(
                      value: _RouteType.custom,
                      groupValue: _routeType,
                      title: const Text(
                        'Custom Route',
                        style: TextStyle(fontSize: AppFontSizes.title13),
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      onChanged: (v) =>
                          setState(() => _routeType = v ?? _RouteType.custom),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: CreateTransportationServiceScreen._fieldGap,
              ),
              SizedBox(
                width: col2Width,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: CreateScreensLayout.radioTopPadding22,
                  ),
                  child: RadioListTile<_RouteType>(
                    value: _RouteType.service,
                    groupValue: _routeType,
                    title: const Text(
                      'Service Route',
                      style: TextStyle(fontSize: AppFontSizes.title13),
                    ),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (v) =>
                        setState(() => _routeType = v ?? _RouteType.custom),
                  ),
                ),
              ),
              const SizedBox(
                width: CreateTransportationServiceScreen._fieldGap,
              ),
              if (_routeType == _RouteType.service)
                SizedBox(
                  width: clientWidthFromConstraints(constraints),
                  child: CustomDropdown(
                    label: 'Service route',
                    items: const ['Route A', 'Route B'],
                    value: _serviceRoute,
                    onChanged: (v) => setState(() => _serviceRoute = v),
                  ),
                ),
              const Spacer(),
            ],
          );
        }

        Widget applyRow() {
          if (!isDesktop) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDropdown(
                  label: 'Vehicle',
                  isRequired: true,
                  items: _vehicleItems,
                  value: _applyVehicle,
                  onChanged: (v) => setState(() => _applyVehicle = v),
                ),
                const SizedBox(
                  height: CreateTransportationServiceScreen._sectionGap,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Quantity',
                        isRequired: true,
                        controller: _applyQuantityController,
                        keyboardType: TextInputType.number,
                        showStepper: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: CreateTransportationServiceScreen._fieldGap,
                    ),
                    Expanded(
                      child: CustomTextField(
                        label: 'PAX',
                        controller: _applyPaxController,
                        keyboardType: TextInputType.number,
                        showStepper: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: _applyToAllTrips,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.r4),
                      ),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s10,
                      ),
                    ),
                    child: const Text('Apply to all'),
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: vehicleWidth,
                child: CustomDropdown(
                  label: 'Vehicle',
                  isRequired: true,
                  items: _vehicleItems,
                  value: _applyVehicle,
                  onChanged: (v) => setState(() => _applyVehicle = v),
                ),
              ),
              const SizedBox(
                width: CreateTransportationServiceScreen._fieldGap,
              ),
              SizedBox(
                width: quantityWidth,
                child: CustomTextField(
                  label: 'Quantity',
                  isRequired: true,
                  controller: _applyQuantityController,
                  keyboardType: TextInputType.number,
                  showStepper: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(
                width: CreateTransportationServiceScreen._fieldGap,
              ),
              SizedBox(
                width: paxWidth,
                child: CustomTextField(
                  label: 'PAX',
                  controller: _applyPaxController,
                  keyboardType: TextInputType.number,
                  showStepper: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(
                width: CreateTransportationServiceScreen._fieldGap,
              ),
              OutlinedButton(
                onPressed: _applyToAllTrips,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                  ),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s10,
                  ),
                ),
                child: const Text('Apply to all'),
              ),
              const Spacer(),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            routeSelection(),
            const SizedBox(
              height: CreateTransportationServiceScreen._sectionGap,
            ),
            applyRow(),
            const SizedBox(
              height: CreateTransportationServiceScreen._sectionGap,
            ),
            ..._trips.map(_buildTripCard),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _addTrip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: AppSpacing.s4,
                  ),
                  textStyle: const TextStyle(
                    fontSize: AppFontSizes.title13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('+ Add'),
              ),
            ),
          ],
        );
      },
    );
  }

  double clientWidthFromConstraints(BoxConstraints constraints) {
    return constraints.maxWidth >= CreateScreensBreakpoints.xlDesktop
        ? CreateScreensLayout.clientWidthXl
        : constraints.maxWidth >= CreateScreensBreakpoints.mdDesktop
        ? CreateScreensLayout.clientWidthMd
        : CreateScreensLayout.clientWidthSm;
  }

  Widget _buildTripCard(_TripFormData trip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.r8),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.s12,
              0,
              AppSpacing.s12,
              AppSpacing.s16,
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.directions_bus,
                  color: AppColors.primary,
                  size: AppIconSizes.s16,
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(
                  'Trip (#T-${trip.index})',
                  style: const TextStyle(
                    fontSize: AppFontSizes.title13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            trailing: _trips.length > 1
                ? IconButton(
                    onPressed: () => _removeTrip(trip),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: AppIconSizes.s18,
                      color: AppColors.danger,
                    ),
                    tooltip: 'Delete',
                    splashRadius: AppRadii.r20,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  )
                : const Icon(
                    Icons.keyboard_arrow_up,
                    size: AppIconSizes.s20,
                    color: AppColors.primary,
                  ),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop =
                      constraints.maxWidth >= CreateScreensBreakpoints.desktop;
                  const fieldGap = CreateTransportationServiceScreen._fieldGap;
                  const rowGap = CreateTransportationServiceScreen._sectionGap;

                  if (!isDesktop) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDropdown(
                          label: 'Type',
                          items: _tripTypeItems,
                          value: trip.type,
                          onChanged: (v) => setState(() => trip.type = v),
                        ),
                        const SizedBox(height: rowGap),
                        CustomDropdown(
                          label: 'From',
                          isRequired: true,
                          items: _destinationItems,
                          value: trip.fromDestination,
                          onChanged: (v) =>
                              setState(() => trip.fromDestination = v),
                        ),
                        const SizedBox(height: rowGap),
                        CustomTextField(
                          label: 'From place',
                          controller: trip.fromPlaceController,
                        ),
                        const SizedBox(height: rowGap),
                        CustomDropdown(
                          label: 'To',
                          isRequired: true,
                          items: _destinationItems,
                          value: trip.toDestination,
                          onChanged: (v) =>
                              setState(() => trip.toDestination = v),
                        ),
                        const SizedBox(height: rowGap),
                        CustomTextField(
                          label: 'To place',
                          controller: trip.toPlaceController,
                        ),
                        const SizedBox(height: rowGap),
                        CustomDatePickerField(
                          label: 'Date',
                          isRequired: true,
                          initialDate: trip.date,
                          onChanged: (d) => setState(() => trip.date = d),
                          popupWidth: AppWidths.datePickerPopup,
                        ),
                        const SizedBox(height: rowGap),
                        SegmentedTimePicker(
                          label: 'Time',
                          isRequired: true,
                          controller: trip.timeController,
                        ),
                        const SizedBox(height: rowGap),
                        CustomDropdown(
                          label: 'Vehicle',
                          isRequired: true,
                          items: _vehicleItems,
                          value: trip.vehicle,
                          onChanged: (v) => setState(() => trip.vehicle = v),
                        ),
                        const SizedBox(height: rowGap),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                label: 'Quantity',
                                isRequired: true,
                                controller: trip.quantityController,
                                onChanged: (_) => setState(() {}),
                                keyboardType: TextInputType.number,
                                showStepper: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            const SizedBox(width: fieldGap),
                            Expanded(
                              child: CustomTextField(
                                label: 'PAX',
                                controller: trip.paxController,
                                keyboardType: TextInputType.number,
                                showStepper: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: rowGap),
                        CustomTextField(
                          label: 'Trip notes',
                          hintText: 'Drive name, Driver phone, Flight no. ...',
                          controller: trip.notesController,
                        ),
                        if (_pricingPerTrip) ...[
                          const SizedBox(height: rowGap),
                          _buildPerItemPricingTable(
                            itemsCount:
                                int.tryParse(
                                  trip.quantityController.text.trim(),
                                ) ??
                                0,
                            salePerItemController: trip.salePerItemController,
                            costPerItemController: trip.costPerItemController,
                            enabled: true,
                            onChanged: () => setState(() {}),
                          ),
                        ],
                      ],
                    );
                  }

                  // Desktop Layout (Grid aligned with image)
                  // Col Flex: Type(2), From(3), Place(3), To(3), Place(4)
                  // Row 2: Date(2), Time(3), Vehicle(3), Qty/Pax(3), Notes(4)
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomDropdown(
                              label: 'Type',
                              items: _tripTypeItems,
                              value: trip.type,
                              onChanged: (v) => setState(() => trip.type = v),
                            ),
                          ),
                          const SizedBox(width: fieldGap),
                          Expanded(
                            flex: 3,
                            child: CustomDropdown(
                              label: 'From',
                              isRequired: true,
                              items: _destinationItems,
                              value: trip.fromDestination,
                              onChanged: (v) =>
                                  setState(() => trip.fromDestination = v),
                            ),
                          ),
                          const SizedBox(width: fieldGap),
                          Expanded(
                            flex: 3,
                            child: CustomTextField(
                              label: 'Place',
                              controller: trip.fromPlaceController,
                            ),
                          ),
                          const SizedBox(width: fieldGap),
                          Expanded(
                            flex: 3,
                            child: CustomDropdown(
                              label: 'To',
                              isRequired: true,
                              items: _destinationItems,
                              value: trip.toDestination,
                              onChanged: (v) =>
                                  setState(() => trip.toDestination = v),
                            ),
                          ),
                          const SizedBox(width: fieldGap),
                          Expanded(
                            flex: 4,
                            child: CustomTextField(
                              label: 'Place',
                              controller: trip.toPlaceController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: rowGap),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomDatePickerField(
                              label: 'Date',
                              isRequired: true,
                              initialDate: trip.date,
                              onChanged: (d) => setState(() => trip.date = d),
                              popupWidth: AppWidths.datePickerPopup,
                              hintText: 'dd/MM/yyyy',
                            ),
                          ),
                          const SizedBox(width: fieldGap),
                          Expanded(
                            flex: 3,
                            child: SegmentedTimePicker(
                              label: 'Time',
                              isRequired: true,
                              controller: trip.timeController,
                            ),
                          ),
                          const SizedBox(width: fieldGap),
                          Expanded(
                            flex: 3,
                            child: CustomDropdown(
                              label: 'Vehicle',
                              isRequired: true,
                              items: _vehicleItems,
                              value: trip.vehicle,
                              onChanged: (v) =>
                                  setState(() => trip.vehicle = v),
                            ),
                          ),
                          const SizedBox(width: fieldGap),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    label: 'Quantity',
                                    isRequired: true,
                                    controller: trip.quantityController,
                                    onChanged: (_) => setState(() {}),
                                    keyboardType: TextInputType.number,
                                    showStepper: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: fieldGap),
                                Expanded(
                                  child: CustomTextField(
                                    label: 'PAX',
                                    controller: trip.paxController,
                                    keyboardType: TextInputType.number,
                                    showStepper: true,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: fieldGap),
                          Expanded(
                            flex: 4,
                            child: CustomTextField(
                              label: 'Trip notes',
                              hintText:
                                  'Drive name, Driver phone, Flight no. ...',
                              controller: trip.notesController,
                            ),
                          ),
                        ],
                      ),
                      if (_pricingPerTrip) ...[
                        const SizedBox(height: rowGap),
                        _buildPerItemPricingTable(
                          itemsCount:
                              int.tryParse(
                                trip.quantityController.text.trim(),
                              ) ??
                              0,
                          salePerItemController: trip.salePerItemController,
                          costPerItemController: trip.costPerItemController,
                          enabled: true,
                          onChanged: () => setState(() {}),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: AppColors.actionGreen,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.r4),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s20,
        vertical: AppSpacing.s12,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: const Icon(Icons.save, size: AppIconSizes.s16),
          label: const Text('Save'),
          style: buttonStyle,
        ),
        const SizedBox(width: AppSpacing.s8),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: const Icon(Icons.save, size: AppIconSizes.s16),
          label: const Text('Save & New Service'),
          style: buttonStyle,
        ),
        const SizedBox(width: AppSpacing.s8),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: const Icon(Icons.save, size: AppIconSizes.s16),
          label: const Text('Save And New'),
          style: buttonStyle,
        ),
      ],
    );
  }
}

enum _RouteType { custom, service }

class _TripFormData {
  final int index;
  String? type;
  String? fromDestination;
  String? toDestination;
  String? vehicle;
  DateTime date;

  final TextEditingController fromPlaceController;
  final TextEditingController toPlaceController;
  final TextEditingController timeController;
  final TextEditingController quantityController;
  final TextEditingController paxController;
  final TextEditingController notesController;
  final TextEditingController salePerItemController;
  final TextEditingController costPerItemController;

  _TripFormData({required this.index})
    : date = DateTime.now(),
      fromPlaceController = TextEditingController(),
      toPlaceController = TextEditingController(),
      timeController = TextEditingController(),
      quantityController = TextEditingController(),
      paxController = TextEditingController(),
      notesController = TextEditingController(),
      salePerItemController = TextEditingController(text: '0'),
      costPerItemController = TextEditingController(text: '0');

  _TripFormData copyWith({required int index}) {
    final next = _TripFormData(index: index)
      ..type = type
      ..fromDestination = fromDestination
      ..toDestination = toDestination
      ..vehicle = vehicle
      ..date = date;
    next.fromPlaceController.text = fromPlaceController.text;
    next.toPlaceController.text = toPlaceController.text;
    next.timeController.text = timeController.text;
    next.quantityController.text = quantityController.text;
    next.paxController.text = paxController.text;
    next.notesController.text = notesController.text;
    next.salePerItemController.text = salePerItemController.text;
    next.costPerItemController.text = costPerItemController.text;
    return next;
  }

  void dispose() {
    fromPlaceController.dispose();
    toPlaceController.dispose();
    timeController.dispose();
    quantityController.dispose();
    paxController.dispose();
    notesController.dispose();
    salePerItemController.dispose();
    costPerItemController.dispose();
  }
}
