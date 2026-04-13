import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:decimal/decimal.dart';
import 'package:pps/core/constants/app_colors.dart';
import 'package:pps/core/constants/app_strings.dart';
import 'package:pps/core/widgets/custom_form_fields.dart';
import 'package:pps/features/reservations/data/models/general_service_draft.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/reservations/data/models/supplier.dart';
import 'package:pps/features/reservations/provider/reservations_data_providers.dart';

class CreateGeneralServiceScreen extends ConsumerStatefulWidget {
  const CreateGeneralServiceScreen({
    super.key,
    this.reservationId,
    this.serviceId,
  });

  final String? reservationId;
  final String? serviceId;

  static const double _pagePadding = 16;
  static const double _sectionGap = 16;
  static const double _fieldGap = 12;

  @override
  ConsumerState<CreateGeneralServiceScreen> createState() =>
      _CreateGeneralServiceScreenState();
}

class _CreateGeneralServiceScreenState
    extends ConsumerState<CreateGeneralServiceScreen> {
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  int? _selectedClientId;
  DateTime _clientOptionDate = DateTime.now();
  bool _isSaving = false;
  String? _reservationId;
  int? _reservationNo;
  int? _selectedSupplierId;
  String? _selectedSupplierLabel;
  String? _selectedServiceName;
  String _selectedTermsAndConditions = AppStrings.termsAndConditionsDefaultKey;

  late final TextEditingController _saleController;
  late final TextEditingController _costController;
  late final TextEditingController _quantityController;
  late final TextEditingController _serviceDescriptionController;
  late final TextEditingController _providerRemarksController;
  late final TextEditingController _guestNameController;
  late final TextEditingController _daysController;

  DateTime _dateOfService = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _daysManuallyEdited = false;

  @override
  void initState() {
    super.initState();
    _reservationId = widget.reservationId;
    _saleController = TextEditingController(text: '0');
    _costController = TextEditingController(text: '0');
    _quantityController = TextEditingController(text: '1');
    _serviceDescriptionController = TextEditingController();
    _providerRemarksController = TextEditingController();
    _guestNameController = TextEditingController();
    _dateOfService = _dateOnly(DateTime.now());
    _endDate = _dateOfService.add(const Duration(days: 1));
    _daysController = TextEditingController(text: '1');
    final serviceId = widget.serviceId;
    if (serviceId != null && serviceId.trim().isNotEmpty) {
      Future<void>.microtask(() async {
        try {
          final repository = ref.read(reservationsRepositoryProvider);
          final draft = await repository.fetchGeneralServiceDraft(serviceId);
          if (!mounted) {
            return;
          }
          String? supplierLabel;
          final supplierId = draft.supplierId;
          if (supplierId != null) {
            final cached =
                ref.read(reservationSuppliersProvider).value ??
                const <Supplier>[];
            final cachedMatch = cached
                .where((s) => s.id == supplierId)
                .toList(growable: false);
            if (cachedMatch.isNotEmpty) {
              supplierLabel = cachedMatch.first.label;
            } else {
              final list = await repository.listSuppliers();
              final match = list
                  .where((s) => s.id == supplierId)
                  .toList(growable: false);
              if (match.isNotEmpty) {
                supplierLabel = match.first.label;
              }
            }
          }
          setState(() {
            _selectedSupplierId = draft.supplierId;
            _selectedSupplierLabel = supplierLabel;
            _selectedServiceName = draft.serviceName;
            _saleController.text = draft.salePerItem.toString();
            _costController.text = draft.costPerItem.toString();
            _quantityController.text = draft.quantity.toString();
            _serviceDescriptionController.text = draft.description;
            _providerRemarksController.text = draft.providerRemarks ?? '';
            _selectedTermsAndConditions =
                draft.termsAndConditions?.trim().isNotEmpty == true
                ? draft.termsAndConditions!.trim()
                : _selectedTermsAndConditions;
            _dateOfService = _dateOnly(draft.dateOfService);
            _endDate = _dateOnly(draft.endDate);
            _daysManuallyEdited = false;
            //CALCULATIONS عدد الأيام المحفوظ يعاد احتسابه من فرق تاريخ النهاية وبداية الخدمة.
            _daysController.text = _endDate
                .difference(_dateOfService)
                .inDays
                .clamp(0, 9999)
                .toString();
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
            _reservationNo = details.order.reservationNo;
          });
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _saleController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _serviceDescriptionController.dispose();
    _providerRemarksController.dispose();
    _guestNameController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  int _parseQuantityOrDefault(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 1;
    if (parsed <= 0) return 1;
    return parsed;
  }

  int _parseDays(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null) return 0;
    if (parsed < 0) return 0;
    return parsed;
  }

  void _setDays(int days) {
    _daysController.text = days.toString();
  }

  void _onDateOfServiceChanged(DateTime value) {
    final newStart = _dateOnly(value);
    setState(() {
      _dateOfService = newStart;

      if (_daysManuallyEdited) {
        final days = _parseDays(_daysController.text);
        //CALCULATIONS تاريخ النهاية = تاريخ بداية الخدمة + عدد الأيام الذي أدخله المستخدم.
        _endDate = _dateOfService.add(Duration(days: days));
        return;
      }

      //CALCULATIONS عدد الأيام الحالي = تاريخ النهاية - تاريخ بداية الخدمة.
      final diff = _endDate.difference(_dateOfService).inDays;
      if (diff <= 0) {
        _endDate = _dateOfService;
        _setDays(0);
      } else {
        _setDays(diff);
      }
    });
  }

  void _onDaysChanged(String value) {
    final days = _parseDays(value);
    setState(() {
      _daysManuallyEdited = true;
      //CALCULATIONS تغيير عدد الأيام يدفع تاريخ النهاية ليصبح بداية الخدمة + عدد الأيام.
      _endDate = _dateOfService.add(Duration(days: days));
    });
  }

  void _onEndDateChanged(DateTime value) {
    final newEnd = _dateOnly(value);
    setState(() {
      _daysManuallyEdited = false;

      if (newEnd.isBefore(_dateOfService)) {
        _endDate = _dateOfService;
        _setDays(0);
        return;
      }

      _endDate = newEnd;
      //CALCULATIONS عدد الأيام = تاريخ النهاية الجديد - تاريخ بداية الخدمة.
      _setDays(_endDate.difference(_dateOfService).inDays);
    });
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
          _reservationNo = createdOrder.reservationNo;
        });
      } else {
        final clientId = _selectedClientId;
        if (clientId != null) {
          await repository.updateReservationMainInfo(
            reservationId: reservationId,
            clientId: clientId,
            guestName: _guestNameController.text.trim().isEmpty
                ? null
                : _guestNameController.text.trim(),
            guestNationality: null,
            clientOptionDate: _clientOptionDate,
          );
        }
      }

      if (_selectedSupplierId == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Please select supplier before save.'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final selectedServiceName = _selectedServiceName?.trim();
      if (selectedServiceName == null || selectedServiceName.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Please select service before save.'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final salePerItem = _parseDecimalInput(_saleController.text);
      if (salePerItem == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Invalid sale value.'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final costPerItem = _parseDecimalInput(_costController.text);
      if (costPerItem == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Invalid cost value.'),
            backgroundColor: AppColors.danger,
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }
      final quantity = _parseQuantityOrDefault(_quantityController.text);
      //CALCULATIONS إجمالي البيع للخدمة العامة = سعر البيع للوحدة × الكمية.
      final totalSale = salePerItem * Decimal.fromInt(quantity);
      //CALCULATIONS إجمالي التكلفة للخدمة العامة = سعر التكلفة للوحدة × الكمية.
      final totalCost = costPerItem * Decimal.fromInt(quantity);
      if (editingServiceId != null && editingServiceId.isNotEmpty) {
        await repository.updateGeneralService(
          serviceId: editingServiceId,
          draft: GeneralServiceDraft(
            dateOfService: _dateOfService,
            endDate: _endDate,
            serviceName: selectedServiceName,
            description: _serviceDescriptionController.text.trim(),
            quantity: quantity,
            supplierId: _selectedSupplierId,
            salePerItem: salePerItem,
            costPerItem: costPerItem,
            totalSale: totalSale,
            totalCost: totalCost,
            termsAndConditions: _selectedTermsAndConditions,
            providerRemarks: _providerRemarksController.text.trim().isEmpty
                ? null
                : _providerRemarksController.text.trim(),
            notes: null,
          ),
        );
      } else {
        await repository.addGeneralService(
          reservationId: reservationId,
          draft: GeneralServiceDraft(
            dateOfService: _dateOfService,
            endDate: _endDate,
            serviceName: selectedServiceName,
            description: _serviceDescriptionController.text.trim(),
            quantity: quantity,
            supplierId: _selectedSupplierId,
            salePerItem: salePerItem,
            costPerItem: costPerItem,
            totalSale: totalSale,
            totalCost: totalCost,
            termsAndConditions: _selectedTermsAndConditions,
            providerRemarks: _providerRemarksController.text.trim().isEmpty
                ? null
                : _providerRemarksController.text.trim(),
            notes: null,
          ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(CreateGeneralServiceScreen._pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            _buildTitleSection(),
            const SizedBox(height: CreateGeneralServiceScreen._sectionGap),

            // Reservation Number
            Text(
              'Reservation number : ${_reservationNo ?? '-'}',
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),

            // Reservation Details Card
            _buildReservationDetailsCard(),
            const SizedBox(height: CreateGeneralServiceScreen._sectionGap),

            // Service Details Card
            _buildServiceDetailsCard(),
            const SizedBox(height: CreateGeneralServiceScreen._sectionGap),

            // Bottom Actions
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
            const Text('Create General Service', style: AppTextStyles.heading),
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
                  if (isLargeDesktop) {
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
                          width: CreateGeneralServiceScreen._fieldGap,
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
                        width: CreateGeneralServiceScreen._fieldGap,
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
                  if (isLargeDesktop) {
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
                              final next = value?.trim();
                              if (next == null || next.isEmpty) {
                                return;
                              }
                              setState(() {
                                _selectedTermsAndConditions = next;
                              });
                            },
                          ),
                        ),
                        const Spacer(),
                      ],
                    );
                  }

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
                            final next = value?.trim();
                            if (next == null || next.isEmpty) {
                              return;
                            }
                            setState(() {
                              _selectedTermsAndConditions = next;
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
                        height: CreateGeneralServiceScreen._sectionGap,
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
                        height: CreateGeneralServiceScreen._sectionGap,
                      ),
                      CustomTextField(
                        label: 'Guest name',
                        controller: _guestNameController,
                      ),
                      const SizedBox(
                        height: CreateGeneralServiceScreen._sectionGap,
                      ),
                      CustomDropdown(
                        label: 'Terms & conditions',
                        items: AppStrings.termsAndConditionsOptions,
                        value: _selectedTermsAndConditions,
                        onChanged: (value) {
                          final next = value?.trim();
                          if (next == null || next.isEmpty) {
                            return;
                          }
                          setState(() {
                            _selectedTermsAndConditions = next;
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
                      height: CreateGeneralServiceScreen._sectionGap,
                    ),
                    row2(),
                    const SizedBox(
                      height: CreateGeneralServiceScreen._sectionGap,
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
    final suppliers = suppliersAsync.value ?? const [];
    String? selectedSupplierLabel;
    if (_selectedSupplierId != null) {
      for (final supplier in suppliers) {
        if (supplier.id == _selectedSupplierId) {
          selectedSupplierLabel = supplier.label;
          break;
        }
      }
    }
    selectedSupplierLabel ??= _selectedSupplierLabel;

    final supplierItems = <String>{
      ...suppliers.map((supplier) => supplier.label),
      if (selectedSupplierLabel != null) selectedSupplierLabel,
    }.toList(growable: false);

    final servicesAsync = ref.watch(generalServicesProvider);
    final services = servicesAsync.value ?? const <String>[];
    final serviceItems = <String>{
      ...services,
      if (_selectedServiceName != null) _selectedServiceName!,
    }.toList(growable: false);

    return _ServiceDetailsCard(
      sectionGap: CreateGeneralServiceScreen._sectionGap,
      fieldGap: CreateGeneralServiceScreen._fieldGap,
      financialGrid: _buildFinancialGrid(),
      serviceItems: serviceItems,
      selectedServiceName: _selectedServiceName,
      onServiceChanged: (value) {
        setState(() {
          _selectedServiceName = value;
        });
      },
      supplierItems: supplierItems,
      selectedSupplierLabel: selectedSupplierLabel,
      onSupplierChanged: (value) {
        final selected = value?.trim();
        if (selected == null || selected.isEmpty) {
          setState(() {
            _selectedSupplierId = null;
            _selectedSupplierLabel = null;
          });
          return;
        }
        final match = suppliers
            .where((supplier) => supplier.label == selected)
            .toList();
        setState(() {
          _selectedSupplierLabel = selected;
          _selectedSupplierId = match.isEmpty ? null : match.first.id;
        });
      },
      serviceDescriptionController: _serviceDescriptionController,
      providerRemarksController: _providerRemarksController,
      quantityController: _quantityController,
      dateOfService: _dateOfService,
      endDate: _endDate,
      daysController: _daysController,
      onDateOfServiceChanged: _onDateOfServiceChanged,
      onEndDateChanged: _onEndDateChanged,
      onDaysChanged: _onDaysChanged,
      onQuantityChanged: (_) => setState(() {}),
    );
  }

  Widget _buildFinancialGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final quantity = _parseQuantityOrDefault(_quantityController.text);
        final salePerItem =
            _parseDecimalInput(_saleController.text) ?? Decimal.parse('0');
        final costPerItem =
            _parseDecimalInput(_costController.text) ?? Decimal.parse('0');
        //CALCULATIONS إجمالي البيع المعروض لحظيًا = سعر البيع للوحدة × الكمية.
        final totalSale = salePerItem * Decimal.fromInt(quantity);
        //CALCULATIONS إجمالي التكلفة المعروضة لحظيًا = سعر التكلفة للوحدة × الكمية.
        final totalCost = costPerItem * Decimal.fromInt(quantity);

        final isWide = constraints.maxWidth >= CreateScreensBreakpoints.wide;
        const col2Width = 195.0;
        final colWidth =
            constraints.maxWidth >= CreateScreensBreakpoints.largeDesktop
            ? col2Width
            : ((constraints.maxWidth -
                          (CreateGeneralServiceScreen._fieldGap * 3)) /
                      4)
                  .clamp(160.0, col2Width);

        if (!isWide) {
          const minFieldWidth = 160.0;
          const maxFieldWidth = 240.0;
          final fieldWidth = constraints.maxWidth <= minFieldWidth
              ? constraints.maxWidth
              : ((constraints.maxWidth - CreateGeneralServiceScreen._fieldGap) /
                        2)
                    .clamp(minFieldWidth, maxFieldWidth);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: CreateGeneralServiceScreen._fieldGap,
                  runSpacing: CreateGeneralServiceScreen._sectionGap,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: CustomTextField(
                        label: 'Sale',
                        isRequired: true,
                        controller: _saleController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _buildReadOnlyField(
                        'Sale per item',
                        salePerItem.toString(),
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _buildReadOnlyField(
                        'Sale price',
                        totalSale.toString(),
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _buildReadOnlyField(
                        'Total sale',
                        totalSale.toString(),
                        isBold: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CreateGeneralServiceScreen._sectionGap),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: CreateGeneralServiceScreen._fieldGap,
                  runSpacing: CreateGeneralServiceScreen._sectionGap,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: CustomTextField(
                        label: 'Cost',
                        isRequired: true,
                        controller: _costController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _buildReadOnlyField(
                        'Cost per item',
                        costPerItem.toString(),
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _buildReadOnlyField(
                        'Cost price',
                        totalCost.toString(),
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: _buildReadOnlyField(
                        'Total cost',
                        totalCost.toString(),
                        isBold: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: colWidth,
                  child: CustomTextField(
                    label: 'Sale',
                    isRequired: true,
                    controller: _saleController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: CreateGeneralServiceScreen._fieldGap),
                SizedBox(
                  width: colWidth,
                  child: _buildReadOnlyField(
                    'Sale per item',
                    salePerItem.toString(),
                  ),
                ),
                const SizedBox(width: CreateGeneralServiceScreen._fieldGap),
                SizedBox(
                  width: colWidth,
                  child: _buildReadOnlyField(
                    'Sale price',
                    totalSale.toString(),
                  ),
                ),
                const SizedBox(width: CreateGeneralServiceScreen._fieldGap),
                SizedBox(
                  width: colWidth,
                  child: _buildReadOnlyField(
                    'Total sale',
                    totalSale.toString(),
                    isBold: true,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: CreateGeneralServiceScreen._sectionGap),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: colWidth,
                  child: CustomTextField(
                    label: 'Cost',
                    isRequired: true,
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: CreateGeneralServiceScreen._fieldGap),
                SizedBox(
                  width: colWidth,
                  child: _buildReadOnlyField(
                    'Cost per item',
                    costPerItem.toString(),
                  ),
                ),
                const SizedBox(width: CreateGeneralServiceScreen._fieldGap),
                SizedBox(
                  width: colWidth,
                  child: _buildReadOnlyField(
                    'Cost price',
                    totalCost.toString(),
                  ),
                ),
                const SizedBox(width: CreateGeneralServiceScreen._fieldGap),
                SizedBox(
                  width: colWidth,
                  child: _buildReadOnlyField(
                    'Total cost',
                    totalCost.toString(),
                    isBold: true,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ],
        );
      },
    );
  }

  Decimal? _parseDecimalInput(String input) {
    final normalized = input.trim().replaceAll(',', '');
    if (normalized.isEmpty) {
      return Decimal.parse('0');
    }
    return Decimal.tryParse(normalized);
  }

  Widget _buildReadOnlyField(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: AppSpacing.s8),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.title13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
      ],
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

class _ServiceDetailsCard extends StatelessWidget {
  final double sectionGap;
  final double fieldGap;
  final Widget financialGrid;
  final List<String> serviceItems;
  final String? selectedServiceName;
  final ValueChanged<String?> onServiceChanged;
  final List<String> supplierItems;
  final String? selectedSupplierLabel;
  final ValueChanged<String?> onSupplierChanged;
  final TextEditingController serviceDescriptionController;
  final TextEditingController providerRemarksController;
  final TextEditingController quantityController;
  final DateTime dateOfService;
  final DateTime endDate;
  final TextEditingController daysController;
  final ValueChanged<DateTime> onDateOfServiceChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<String> onDaysChanged;
  final ValueChanged<String> onQuantityChanged;

  const _ServiceDetailsCard({
    required this.sectionGap,
    required this.fieldGap,
    required this.financialGrid,
    required this.serviceItems,
    required this.selectedServiceName,
    required this.onServiceChanged,
    required this.supplierItems,
    required this.selectedSupplierLabel,
    required this.onSupplierChanged,
    required this.serviceDescriptionController,
    required this.providerRemarksController,
    required this.quantityController,
    required this.dateOfService,
    required this.endDate,
    required this.daysController,
    required this.onDateOfServiceChanged,
    required this.onEndDateChanged,
    required this.onDaysChanged,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                final isLargeDesktop =
                    constraints.maxWidth >=
                    CreateScreensBreakpoints.largeDesktop;

                const col1Width = 98.0;
                const col2Width = 195.0;
                const col4Width = 409.0;
                const col10Width = 1025.0;

                final desktop = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLargeDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: col2Width,
                            child: CustomDropdown(
                              label: 'Service',
                              items: serviceItems,
                              value: selectedServiceName,
                              enabled: serviceItems.isNotEmpty,
                              onChanged: onServiceChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          SizedBox(
                            width: col4Width,
                            child: CustomTextField(
                              label: 'Service description',
                              controller: serviceDescriptionController,
                            ),
                          ),
                          const Spacer(),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: CustomDropdown(
                              label: 'Service',
                              items: serviceItems,
                              value: selectedServiceName,
                              enabled: serviceItems.isNotEmpty,
                              onChanged: onServiceChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          Expanded(
                            flex: 4,
                            child: CustomTextField(
                              label: 'Service description',
                              controller: serviceDescriptionController,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: sectionGap),
                    if (isLargeDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: col2Width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Service provider',
                                  style: AppTextStyles.label,
                                ),
                                const SizedBox(height: AppSpacing.s8),
                                Row(
                                  children: [
                                    Radio(
                                      value: true,
                                      groupValue: true,
                                      onChanged: (v) {},
                                      activeColor: AppColors.primary,
                                    ),
                                    const Text(
                                      'Supplier',
                                      style: TextStyle(
                                        fontSize: AppFontSizes.title13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          SizedBox(
                            width: col4Width,
                            child: CustomDropdown(
                              label: 'Supplier',
                              items: supplierItems,
                              value: selectedSupplierLabel,
                              onChanged: onSupplierChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          SizedBox(
                            width: col1Width,
                            child: CustomTextField(
                              label: 'Quantity',
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              showStepper: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: onQuantityChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          SizedBox(
                            width: col2Width,
                            child: CustomDatePickerField(
                              label: 'Date of service',
                              initialDate: dateOfService,
                              popupWidth: AppWidths.datePickerPopup,
                              onChanged: onDateOfServiceChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          SizedBox(
                            width: col1Width,
                            child: CustomTextField(
                              label: 'Days',
                              controller: daysController,
                              keyboardType: TextInputType.number,
                              showStepper: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: onDaysChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          SizedBox(
                            width: col2Width,
                            child: CustomDatePickerField(
                              label: 'End date',
                              initialDate: endDate,
                              popupWidth: AppWidths.datePickerPopup,
                              onChanged: onEndDateChanged,
                            ),
                          ),
                          const Spacer(),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Service provider',
                                  style: AppTextStyles.label,
                                ),
                                const SizedBox(height: AppSpacing.s8),
                                Row(
                                  children: [
                                    Radio(
                                      value: true,
                                      groupValue: true,
                                      onChanged: (v) {},
                                      activeColor: AppColors.primary,
                                    ),
                                    const Text(
                                      'Supplier',
                                      style: TextStyle(
                                        fontSize: AppFontSizes.title13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          Expanded(
                            flex: 4,
                            child: CustomDropdown(
                              label: 'Supplier',
                              items: supplierItems,
                              value: selectedSupplierLabel,
                              onChanged: onSupplierChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          Expanded(
                            flex: 1,
                            child: CustomTextField(
                              label: 'Quantity',
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              showStepper: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: onQuantityChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          Expanded(
                            flex: 2,
                            child: CustomDatePickerField(
                              label: 'Date of service',
                              initialDate: dateOfService,
                              popupWidth: AppWidths.datePickerPopup,
                              onChanged: onDateOfServiceChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          Expanded(
                            flex: 1,
                            child: CustomTextField(
                              label: 'Days',
                              controller: daysController,
                              keyboardType: TextInputType.number,
                              showStepper: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: onDaysChanged,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          Expanded(
                            flex: 2,
                            child: CustomDatePickerField(
                              label: 'End date',
                              initialDate: endDate,
                              popupWidth: AppWidths.datePickerPopup,
                              onChanged: onEndDateChanged,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: sectionGap),
                    if (isLargeDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: col10Width,
                            child: CustomTextField(
                              label: 'Provider remarks',
                              controller: providerRemarksController,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          const SizedBox(width: col2Width),
                          const Spacer(),
                        ],
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 10,
                            child: CustomTextField(
                              label: 'Provider remarks',
                              controller: providerRemarksController,
                            ),
                          ),
                          SizedBox(width: fieldGap),
                          const Spacer(flex: 2),
                        ],
                      ),
                    SizedBox(height: sectionGap),
                    financialGrid,
                  ],
                );

                if (isDesktop) {
                  return desktop;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropdown(
                      label: 'Service',
                      items: serviceItems,
                      value: selectedServiceName,
                      enabled: serviceItems.isNotEmpty,
                      onChanged: onServiceChanged,
                    ),
                    SizedBox(height: sectionGap),
                    CustomTextField(
                      label: 'Service description',
                      controller: serviceDescriptionController,
                    ),
                    SizedBox(height: sectionGap),
                    const Text('Service provider', style: AppTextStyles.label),
                    Row(
                      children: [
                        Radio(
                          value: true,
                          groupValue: true,
                          onChanged: (v) {},
                          activeColor: AppColors.primary,
                        ),
                        const Text(
                          'Supplier',
                          style: TextStyle(fontSize: AppFontSizes.title13),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionGap),
                    CustomDropdown(
                      label: 'Supplier',
                      items: supplierItems,
                      value: selectedSupplierLabel,
                      onChanged: onSupplierChanged,
                    ),
                    SizedBox(height: sectionGap),
                    CustomTextField(
                      label: 'Quantity',
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      showStepper: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: onQuantityChanged,
                    ),
                    SizedBox(height: sectionGap),
                    CustomDatePickerField(
                      label: 'Date of service',
                      initialDate: dateOfService,
                      popupWidth: AppWidths.datePickerPopup,
                      onChanged: onDateOfServiceChanged,
                    ),
                    SizedBox(height: sectionGap),
                    CustomTextField(
                      label: 'Days',
                      controller: daysController,
                      keyboardType: TextInputType.number,
                      showStepper: true,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: onDaysChanged,
                    ),
                    SizedBox(height: sectionGap),
                    CustomDatePickerField(
                      label: 'End date',
                      initialDate: endDate,
                      popupWidth: AppWidths.datePickerPopup,
                      onChanged: onEndDateChanged,
                    ),
                    SizedBox(height: sectionGap),
                    CustomTextField(
                      label: 'Provider remarks',
                      controller: providerRemarksController,
                    ),
                    SizedBox(height: sectionGap),
                    financialGrid,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
