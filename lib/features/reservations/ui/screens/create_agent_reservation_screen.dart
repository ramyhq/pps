import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:decimal/decimal.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rms_clone/core/constants/app_colors.dart';
import 'package:rms_clone/core/widgets/custom_form_fields.dart';
import 'package:rms_clone/features/reservations/provider/create_agent_reservation_provider.dart';
import 'package:rms_clone/features/reservations/provider/reservations_data_providers.dart';

class CreateAgentReservationScreen extends ConsumerStatefulWidget {
  const CreateAgentReservationScreen({
    super.key,
    this.reservationId,
    this.serviceId,
  });

  final String? reservationId;
  final String? serviceId;

  @override
  ConsumerState<CreateAgentReservationScreen> createState() =>
      _CreateAgentReservationScreenState();
}

class _CreateAgentReservationScreenState
    extends ConsumerState<CreateAgentReservationScreen> {
  final TextEditingController _nightsController = TextEditingController();
  final TextEditingController _guestNameController = TextEditingController();
  final TextEditingController _numberOfRoomsController =
      TextEditingController();
  final FocusNode _nightsFocusNode = FocusNode();
  late final ProviderSubscription<CreateAgentReservationState>
  _nightsSyncSubscription;
  bool _isUpdatingNightsField = false;
  int? _selectedHotelId;
  int? _selectedSupplierId;
  final TextEditingController _saleRoomApplyController =
      TextEditingController();
  final TextEditingController _saleMealPerPaxApplyController =
      TextEditingController();
  final TextEditingController _costRoomApplyController =
      TextEditingController();
  final TextEditingController _costMealPerPaxApplyController =
      TextEditingController();
  bool _isRoomActionLocked = false;
  bool _hasAppliedRates = false;
  bool _isRatesLoading = false;

  @override
  void initState() {
    super.initState();
    _numberOfRoomsController.addListener(() {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    void resetApplyFlag() {
      if (_hasAppliedRates) {
        _hasAppliedRates = false;
      }
    }

    _saleRoomApplyController.addListener(resetApplyFlag);
    _saleMealPerPaxApplyController.addListener(resetApplyFlag);
    _costRoomApplyController.addListener(resetApplyFlag);
    _costMealPerPaxApplyController.addListener(resetApplyFlag);
    if (widget.reservationId == null) {
      _selectedHotelId = null;
      _selectedSupplierId = null;
    }
    Future<void>(() {
      if (!mounted) {
        return;
      }
      final notifier = ref.read(createAgentReservationProvider.notifier);
      if (widget.reservationId == null) {
        notifier.startNewReservation();
      }
      final currentState = ref.read(createAgentReservationProvider);
      _setNightsText(currentState.nightsCount);
      notifier.setReservationContext(
        reservationId: widget.reservationId,
        clientId: currentState.selectedClientId,
        clientOptionDate: currentState.clientOptionDate,
        guestName: currentState.guestName,
      );
    });
    _nightsSyncSubscription = ref.listenManual<CreateAgentReservationState>(
      createAgentReservationProvider,
      (previous, next) {
        if (!mounted) {
          return;
        }
        if (_nightsFocusNode.hasFocus) {
          return;
        }
        final previousNights = previous?.nightsCount ?? 0;
        if (next.nightsCount != previousNights && next.nightsCount > 0) {
          _setNightsText(next.nightsCount);
        }
      },
    );
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
          ref
              .read(createAgentReservationProvider.notifier)
              .setReservationContext(
                reservationId: reservationId,
                clientId: details.order.client.id,
                clientOptionDate: details.order.clientOptionDate,
                guestName: details.order.guestName,
              );
          _guestNameController.text = details.order.guestName ?? '';
        } catch (_) {}
      });
    }
    final serviceId = widget.serviceId;
    if (serviceId != null && serviceId.trim().isNotEmpty) {
      Future<void>.microtask(() async {
        try {
          final draft = await ref
              .read(reservationsRepositoryProvider)
              .fetchAgentServiceDraft(serviceId);
          if (!mounted) {
            return;
          }
          ref
              .read(createAgentReservationProvider.notifier)
              .startEditingService(serviceId: serviceId, draft: draft);
          _guestNameController.text =
              ref.read(createAgentReservationProvider).guestName ?? '';
          _selectedHotelId = draft.hotelId;
          _selectedSupplierId = draft.supplierId;
          _setNightsText(ref.read(createAgentReservationProvider).nightsCount);
          setState(() {});
        } catch (_) {}
      });
    }
  }

  @override
  void dispose() {
    _nightsController.dispose();
    _guestNameController.dispose();
    _nightsFocusNode.dispose();
    _nightsSyncSubscription.close();
    _numberOfRoomsController.dispose();
    _saleRoomApplyController.dispose();
    _saleMealPerPaxApplyController.dispose();
    _costRoomApplyController.dispose();
    _costMealPerPaxApplyController.dispose();
    super.dispose();
  }

  void _onArrivalDateChanged(DateTime date) {
    _hasAppliedRates = false;
    final notifier = ref.read(createAgentReservationProvider.notifier);
    notifier.onArrivalDateChanged(
      date: date,
      desiredNights: _parseNightsInput(),
    );
    _setNightsText(ref.read(createAgentReservationProvider).nightsCount);
  }

  void _onDepartureDateChanged(DateTime date) {
    _hasAppliedRates = false;
    ref
        .read(createAgentReservationProvider.notifier)
        .onDepartureDateChanged(date);
    _setNightsText(ref.read(createAgentReservationProvider).nightsCount);
  }

  int _parseNightsInput() {
    final parsed = int.tryParse(_nightsController.text.trim());
    if (parsed == null || parsed < 1) {
      return 1;
    }
    return parsed;
  }

  void _setNightsText(int nights) {
    final value = '$nights';
    _isUpdatingNightsField = true;
    _nightsController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _isUpdatingNightsField = false;
  }

  void _onNightsChanged(String value) {
    if (_isUpdatingNightsField) {
      return;
    }
    final nights = int.tryParse(value.trim());
    if (nights == null || nights < 1) {
      return;
    }
    _hasAppliedRates = false;
    ref.read(createAgentReservationProvider.notifier).onNightsChanged(nights);
  }

  void _applyRatesToAllDays() {
    final saleRoom = _saleRoomApplyController.text.trim();
    final saleMealPerPax = _saleMealPerPaxApplyController.text.trim();
    final costRoom = _costRoomApplyController.text.trim();
    final costMealPerPax = _costMealPerPaxApplyController.text.trim();
    if (saleRoom.isEmpty &&
        saleMealPerPax.isEmpty &&
        costRoom.isEmpty &&
        costMealPerPax.isEmpty) {
      setState(() => _hasAppliedRates = true);
      return;
    }
    ref
        .read(createAgentReservationProvider.notifier)
        .applyRatesToAllDays(
          saleRoom: saleRoom,
          saleMealPerPax: saleMealPerPax,
          costRoom: costRoom,
          costMealPerPax: costMealPerPax,
        );
    setState(() => _hasAppliedRates = true);
  }

  String _formatMoney(Decimal value) {
    final text = value.toString();
    if (!text.contains('.')) {
      return '$text.00';
    }
    final parts = text.split('.');
    if (parts.length != 2) {
      return text;
    }
    if (parts[1].isEmpty) {
      return '${parts[0]}.00';
    }
    if (parts[1].length == 1) {
      return '${parts[0]}.${parts[1]}0';
    }
    return '${parts[0]}.${parts[1].substring(0, 2)}';
  }

  Decimal _parseMoney(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return Decimal.parse('0');
    }
    return Decimal.tryParse(normalized) ?? Decimal.parse('0');
  }

  String _formatFixed(Decimal value, int fractionDigits) {
    final text = value.toString();
    if (fractionDigits < 1) {
      return text.split('.').first;
    }
    final zeros = List<String>.filled(fractionDigits, '0').join();
    if (!text.contains('.')) {
      return '$text.$zeros';
    }
    final parts = text.split('.');
    if (parts.length != 2) {
      return text;
    }
    final fraction = parts[1];
    if (fraction.isEmpty) {
      return '${parts[0]}.$zeros';
    }
    if (fraction.length < fractionDigits) {
      return '${parts[0]}.${fraction.padRight(fractionDigits, '0')}';
    }
    if (fraction.length > fractionDigits) {
      return '${parts[0]}.${fraction.substring(0, fractionDigits)}';
    }
    return '${parts[0]}.$fraction';
  }

  void _showRoomFormMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  void _clearRoomDetailsForm() {
    _hasAppliedRates = true;
    _numberOfRoomsController.clear();
    if (mounted) {
      setState(() {});
    }
    ref
        .read(createAgentReservationProvider.notifier)
        .clearRoomDetailsForNextEntry();
  }

  void _onAddOrEditRoomPressed() {
    if (_isRoomActionLocked) {
      return;
    }
    setState(() => _isRoomActionLocked = true);
    try {
      final roomsCount =
          int.tryParse(_numberOfRoomsController.text.trim()) ?? 0;
      final currentState = ref.read(createAgentReservationProvider);
      final editingIndex = currentState.editingRoomIndex;
      if (editingIndex == null && !_hasAppliedRates) {
        _showRoomFormMessage('Please press Apply before adding a room.');
        return;
      }
      if (roomsCount < 1) {
        _showRoomFormMessage('Please enter number of rooms.');
        return;
      }
      if (currentState.selectedRoomType == null) {
        _showRoomFormMessage('Please select room type.');
        return;
      }
      if (currentState.selectedMealPlan == null) {
        _showRoomFormMessage('Please select meal plan.');
        return;
      }
      if (currentState.nightsCount < 1) {
        _showRoomFormMessage('Please select nights before adding rooms.');
        return;
      }

      final notifier = ref.read(createAgentReservationProvider.notifier);
      final success = editingIndex == null
          ? notifier.addRoomToSummary(roomsCount: roomsCount)
          : notifier.updateRoomInSummary(
              index: editingIndex,
              roomsCount: roomsCount,
            );
      if (success) {
        _clearRoomDetailsForm();
      }
    } finally {
      if (mounted) {
        setState(() => _isRoomActionLocked = false);
      }
    }
  }

  void _clearRoomForm() {
    _hasAppliedRates = false;
    _isRatesLoading = false;
    _numberOfRoomsController.clear();
    _saleRoomApplyController.clear();
    _saleMealPerPaxApplyController.clear();
    _costRoomApplyController.clear();
    _costMealPerPaxApplyController.clear();
    _selectedHotelId = null;
    _selectedSupplierId = null;
    if (mounted) {
      setState(() {});
    }
    ref.read(createAgentReservationProvider.notifier).clearRoomFormState();
  }

  void _removeRoomFromSummary(int index) {
    ref
        .read(createAgentReservationProvider.notifier)
        .removeRoomFromSummary(index);
  }

  Future<bool> _confirmRemoveRoom() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.r12),
          ),
          child: SizedBox(
            width: 520,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s24,
                vertical: AppSpacing.s24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.warning, width: 4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '!',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  const Text(
                    'Are you sure?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.info,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.r4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s24,
                            vertical: AppSpacing.s10,
                          ),
                        ),
                        child: const Text('Yes'),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textSecondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.r4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s24,
                            vertical: AppSpacing.s10,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<String?> _saveReservationAndGetId({
    required bool clearForNewEntry,
  }) async {
    final notifier = ref.read(createAgentReservationProvider.notifier);
    notifier.setGuestName(_guestNameController.text);
    notifier.setHotelSelection(
      hotelId: _selectedHotelId,
      hotelName: _selectedHotelLabel(
        ref.read(reservationHotelsProvider).value ?? const [],
      ),
      hotelCity: _selectedHotelCity(
        ref.read(reservationHotelsProvider).value ?? const [],
      ),
    );
    notifier.setSupplierSelection(
      supplierId: _selectedSupplierId,
      supplierName: _selectedSupplierLabel(
        ref.read(reservationSuppliersProvider).value ?? const [],
      ),
    );
    final success = await notifier.saveReservation(
      clearForNewEntry: clearForNewEntry,
    );
    if (!mounted) {
      return null;
    }

    final currentState = ref.read(createAgentReservationProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    if (success) {
      final reservationId = currentState.lastSavedReservationId ?? '-';
      messenger.showSnackBar(
        SnackBar(
          content: Text('Reservation saved successfully (#$reservationId)'),
          backgroundColor: AppColors.success,
        ),
      );
      if (clearForNewEntry) {
        _clearRoomForm();
      }
      return reservationId == '-' ? null : reservationId;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          currentState.lastSaveError ?? 'Failed to save reservation',
        ),
        backgroundColor: AppColors.danger,
      ),
    );
    return null;
  }

  String? _selectedHotelLabel(List<dynamic> hotels) {
    for (final hotel in hotels) {
      if (hotel.id == _selectedHotelId) {
        return hotel.label;
      }
    }
    return null;
  }

  String? _selectedHotelCity(List<dynamic> hotels) {
    for (final hotel in hotels) {
      if (hotel.id == _selectedHotelId) {
        final city = hotel.city;
        if (city is String && city.trim().isNotEmpty) {
          return city.trim();
        }
        return null;
      }
    }
    return null;
  }

  String? _selectedSupplierLabel(List<dynamic> suppliers) {
    for (final supplier in suppliers) {
      if (supplier.id == _selectedSupplierId) {
        return supplier.label;
      }
    }
    return null;
  }

  Future<void> _onSavePressed() async {
    final reservationId = await _saveReservationAndGetId(
      clearForNewEntry: false,
    );
    if (!mounted) {
      return;
    }
    if (reservationId == null) {
      return;
    }
    ref.invalidate(reservationDetailsProvider(reservationId));
    ref.invalidate(reservationOrdersProvider);
    context.go('/reservations/details?reservationId=$reservationId');
  }

  Future<void> _onSaveAndNewHotelPressed() async {
    await _saveReservationAndGetId(clearForNewEntry: true);
  }

  Future<void> _onSaveAndNewPressed() async {
    final reservationId = await _saveReservationAndGetId(
      clearForNewEntry: true,
    );
    if (!mounted) {
      return;
    }
    if (reservationId == null) {
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add service'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.miscellaneous_services),
                  title: const Text('General service'),
                  onTap: () => Navigator.of(dialogContext).pop('general'),
                ),
                ListTile(
                  leading: const Icon(Icons.directions_car),
                  title: const Text('Transportation'),
                  onTap: () =>
                      Navigator.of(dialogContext).pop('transportation'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    switch (selected) {
      case 'general':
        context.go('/reservations/create-general?reservationId=$reservationId');
        return;
      case 'transportation':
        context.go(
          '/reservations/create-transportation?reservationId=$reservationId',
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createAgentReservationProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            _buildTitleSection(),
            const SizedBox(height: AppSpacing.s16),

            // Reservation ID
            Text(
              'Res. ID : ${state.lastSavedServiceDisplayNo ?? '-'}',
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.s12),

            // Reservation Details Card
            _buildReservationDetailsCard(state),
            const SizedBox(height: AppSpacing.s16),

            // Room Details Card
            _buildRoomDetailsCard(state),
            const SizedBox(height: AppSpacing.s16),

            // Bottom Actions
            _buildBottomActions(state),
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
              'Agent Direct Reservation',
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

  Widget _buildReservationDetailsCard(CreateAgentReservationState state) {
    final clientsAsync = ref.watch(reservationClientsProvider);
    final clients = clientsAsync.value ?? const [];
    String? selectedClientLabel;
    if (state.selectedClientId != null) {
      for (final client in clients) {
        if (client.id == state.selectedClientId) {
          selectedClientLabel = client.label;
          break;
        }
      }
    }

    final items = <String>{
      ...clients.map((client) => client.label),
      if (selectedClientLabel != null) selectedClientLabel,
    }.toList(growable: false);

    final isClientLocked = state.reservationId != null;

    final hotelsAsync = ref.watch(reservationHotelsProvider);
    final hotels = hotelsAsync.value ?? const [];
    String? selectedHotelLabel;
    if (_selectedHotelId != null) {
      for (final hotel in hotels) {
        if (hotel.id == _selectedHotelId) {
          selectedHotelLabel = hotel.label;
          break;
        }
      }
    }
    final hotelItems = <String>{
      ...hotels.map((hotel) => hotel.label),
      if (selectedHotelLabel != null) selectedHotelLabel,
    }.toList(growable: false);

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
    final supplierItems = <String>{
      ...suppliers.map((supplier) => supplier.label),
      if (selectedSupplierLabel != null) selectedSupplierLabel,
    }.toList(growable: false);

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
                final arrivalWidth =
                    constraints.maxWidth >= CreateScreensBreakpoints.xlDesktop
                    ? CreateScreensLayout.arrivalWidthXl
                    : constraints.maxWidth >= CreateScreensBreakpoints.mdDesktop
                    ? CreateScreensLayout.arrivalWidthMd
                    : CreateScreensLayout.arrivalWidthSm;
                final nightsWidth =
                    constraints.maxWidth >= CreateScreensBreakpoints.mdDesktop
                    ? CreateScreensLayout.nightsWidthMd
                    : CreateScreensLayout.nightsWidthSm;
                final departureWidth = arrivalWidth;
                final clientWidth =
                    constraints.maxWidth >= CreateScreensBreakpoints.xlDesktop
                    ? CreateScreensLayout.clientWidthXl
                    : constraints.maxWidth >= CreateScreensBreakpoints.mdDesktop
                    ? CreateScreensLayout.clientWidthMd
                    : CreateScreensLayout.clientWidthSm;
                final hotelWidth = clientWidth;

                return Column(
                  children: [
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: arrivalWidth,
                            child: CustomDatePickerField(
                              label: 'Arrival date',
                              isRequired: true,
                              initialDate: state.arrivalDate,
                              onChanged: _onArrivalDateChanged,
                              popupWidth: AppWidths.datePickerPopup,
                              startEmpty: false,
                              autoOpen:
                                  widget.reservationId == null &&
                                  widget.serviceId == null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          SizedBox(
                            width: nightsWidth,
                            child: _buildNightsInput(),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          SizedBox(
                            width: departureWidth,
                            child: CustomDatePickerField(
                              label: 'Departure date',
                              isRequired: true,
                              initialDate: state.departureDate,
                              onChanged: _onDepartureDateChanged,
                              popupWidth: AppWidths.datePickerPopup,
                              startEmpty: false,
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
                            child: CustomDatePickerField(
                              label: 'Arrival date',
                              isRequired: true,
                              initialDate: state.arrivalDate,
                              onChanged: _onArrivalDateChanged,
                              popupWidth: AppWidths.datePickerPopup,
                              startEmpty: false,
                              autoOpen:
                                  widget.reservationId == null &&
                                  widget.serviceId == null,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          SizedBox(
                            width: CreateScreensLayout.nightsWidthSm,
                            child: _buildNightsInput(),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: CustomDatePickerField(
                              label: 'Departure date',
                              isRequired: true,
                              initialDate: state.departureDate,
                              onChanged: _onDepartureDateChanged,
                              popupWidth: AppWidths.datePickerPopup,
                              startEmpty: false,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.s16),
                    if (isDesktop)
                      Row(
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
                                  ref
                                      .read(
                                        createAgentReservationProvider.notifier,
                                      )
                                      .setSelectedClientId(null);
                                  return;
                                }
                                final match = clients
                                    .where((c) => c.label == selected)
                                    .toList(growable: false);
                                if (match.isEmpty) {
                                  return;
                                }
                                ref
                                    .read(
                                      createAgentReservationProvider.notifier,
                                    )
                                    .setSelectedClientId(match.first.id);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          SizedBox(
                            width: hotelWidth,
                            child: CustomDatePickerField(
                              label: 'Client option date',
                              initialDate: state.clientOptionDate,
                              onChanged: (value) {
                                ref
                                    .read(
                                      createAgentReservationProvider.notifier,
                                    )
                                    .setClientOptionDate(value);
                              },
                              popupWidth: AppWidths.datePickerPopup,
                              startEmpty: true,
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
                            child: CustomDropdown(
                              label: 'Client',
                              isRequired: true,
                              value: selectedClientLabel,
                              items: items,
                              enabled: !isClientLocked,
                              onChanged: (value) {
                                final selected = value?.trim();
                                if (selected == null || selected.isEmpty) {
                                  ref
                                      .read(
                                        createAgentReservationProvider.notifier,
                                      )
                                      .setSelectedClientId(null);
                                  return;
                                }
                                final match = clients
                                    .where((c) => c.label == selected)
                                    .toList(growable: false);
                                if (match.isEmpty) {
                                  return;
                                }
                                ref
                                    .read(
                                      createAgentReservationProvider.notifier,
                                    )
                                    .setSelectedClientId(match.first.id);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: CustomDatePickerField(
                              label: 'Client option date',
                              initialDate: state.clientOptionDate,
                              onChanged: (value) {
                                ref
                                    .read(
                                      createAgentReservationProvider.notifier,
                                    )
                                    .setClientOptionDate(value);
                              },
                              popupWidth: AppWidths.datePickerPopup,
                              startEmpty: true,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.s16),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Guest name',
                            controller: _guestNameController,
                            onChanged: (value) {
                              ref
                                  .read(createAgentReservationProvider.notifier)
                                  .setGuestName(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    if (isDesktop)
                      Row(
                        children: [
                          SizedBox(
                            width: hotelWidth,
                            child: CustomDropdown(
                              label: 'Hotel',
                              value: selectedHotelLabel,
                              items: hotelItems,
                              onChanged: (value) {
                                final selected = value?.trim();
                                if (selected == null || selected.isEmpty) {
                                  setState(() {
                                    _selectedHotelId = null;
                                  });
                                  return;
                                }
                                final match = hotels
                                    .where((h) => h.label == selected)
                                    .toList(growable: false);
                                if (match.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  _selectedHotelId = match.first.id;
                                });
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: CustomDropdown(
                              label: 'Hotel',
                              value: selectedHotelLabel,
                              items: hotelItems,
                              onChanged: (value) {
                                final selected = value?.trim();
                                if (selected == null || selected.isEmpty) {
                                  setState(() {
                                    _selectedHotelId = null;
                                  });
                                  return;
                                }
                                final match = hotels
                                    .where((h) => h.label == selected)
                                    .toList(growable: false);
                                if (match.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  _selectedHotelId = match.first.id;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: AppSpacing.s16),
                    if (isDesktop)
                      Row(
                        children: [
                          SizedBox(
                            width: hotelWidth,
                            child: CustomDropdown(
                              label: 'Supplier',
                              value: selectedSupplierLabel,
                              items: supplierItems,
                              onChanged: (value) {
                                final selected = value?.trim();
                                if (selected == null || selected.isEmpty) {
                                  setState(() {
                                    _selectedSupplierId = null;
                                  });
                                  return;
                                }
                                final match = suppliers
                                    .where((s) => s.label == selected)
                                    .toList(growable: false);
                                if (match.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  _selectedSupplierId = match.first.id;
                                });
                              },
                            ),
                          ),
                          const Spacer(),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: CustomDropdown(
                              label: 'Supplier',
                              value: selectedSupplierLabel,
                              items: supplierItems,
                              onChanged: (value) {
                                final selected = value?.trim();
                                if (selected == null || selected.isEmpty) {
                                  setState(() {
                                    _selectedSupplierId = null;
                                  });
                                  return;
                                }
                                final match = suppliers
                                    .where((s) => s.label == selected)
                                    .toList(growable: false);
                                if (match.isEmpty) {
                                  return;
                                }
                                setState(() {
                                  _selectedSupplierId = match.first.id;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomDetailsCard(CreateAgentReservationState state) {
    const dateColumnWidth = CreateScreensLayout.dateColumnWidth;
    const cellHeight = CreateScreensLayout.cellHeight28;
    const rowTextStyle = TextStyle(
      fontSize: AppFontSizes.label11,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
    );

    final roomsCount = int.tryParse(_numberOfRoomsController.text.trim()) ?? 0;
    final paxPerRoom = CreateAgentReservationNotifier.paxPerRoomFor(
      state.selectedRoomType,
    );
    //CALCULATIONS إجمالي الركاب للمعاينة = عدد الغرف × عدد الأفراد لكل غرفة.
    final pax = roomsCount * paxPerRoom;
    //CALCULATIONS تحويل إجمالي الركاب إلى Decimal لحساب الوجبات المعروضة.
    final paxDecimal = Decimal.fromInt(pax);

    var totalSaleRoom = Decimal.parse('0');
    var totalSaleMealPerPax = Decimal.parse('0');
    var totalSaleMealPrice = Decimal.parse('0');
    var totalSalePrice = Decimal.parse('0');
    var totalSaleTotal = Decimal.parse('0');

    var totalCostRoom = Decimal.parse('0');
    var totalCostMealPerPax = Decimal.parse('0');
    var totalCostMealPrice = Decimal.parse('0');
    var totalCostPrice = Decimal.parse('0');
    var totalCostTotal = Decimal.parse('0');

    for (final rate in state.roomRates) {
      final saleRoom = _parseMoney(rate.saleRoom);
      final saleMealPerPax = _parseMoney(rate.saleMealPerPax);
      //CALCULATIONS سعر وجبات البيع لليوم = سعر الوجبة لكل راكب × إجمالي الركاب.
      final saleMealPrice = saleMealPerPax * paxDecimal;
      //CALCULATIONS سعر البيع لليوم = سعر الغرفة + سعر الوجبات لذلك اليوم.
      final salePrice = saleRoom + saleMealPrice;

      //CALCULATIONS مجموع بيع الغرف = جمع قيمة الغرفة لكل يوم.
      totalSaleRoom = totalSaleRoom + saleRoom;
      //CALCULATIONS مجموع بيع الوجبة لكل راكب = جمع سعر الوجبة اليومية لكل راكب.
      totalSaleMealPerPax = totalSaleMealPerPax + saleMealPerPax;
      //CALCULATIONS مجموع بيع الوجبات = جمع ناتج (وجبة لكل راكب × إجمالي الركاب) لكل يوم.
      totalSaleMealPrice = totalSaleMealPrice + saleMealPrice;
      //CALCULATIONS مجموع أسعار البيع = جمع سعر اليوم الكامل قبل عمود Total.
      totalSalePrice = totalSalePrice + salePrice;
      //CALCULATIONS إجمالي البيع النهائي = جمع سعر البيع اليومي لكل الليالي.
      totalSaleTotal = totalSaleTotal + salePrice;

      final costRoom = _parseMoney(rate.costRoom);
      final costMealPerPax = _parseMoney(rate.costMealPerPax);
      //CALCULATIONS سعر وجبات التكلفة لليوم = تكلفة الوجبة لكل راكب × إجمالي الركاب.
      final costMealPrice = costMealPerPax * paxDecimal;
      //CALCULATIONS سعر التكلفة لليوم = تكلفة الغرفة + تكلفة الوجبات لذلك اليوم.
      final costPrice = costRoom + costMealPrice;

      //CALCULATIONS مجموع تكلفة الغرف = جمع تكلفة الغرفة لكل يوم.
      totalCostRoom = totalCostRoom + costRoom;
      //CALCULATIONS مجموع تكلفة الوجبة لكل راكب = جمع تكلفة الوجبة اليومية لكل راكب.
      totalCostMealPerPax = totalCostMealPerPax + costMealPerPax;
      //CALCULATIONS مجموع تكلفة الوجبات = جمع ناتج (تكلفة الوجبة لكل راكب × إجمالي الركاب) لكل يوم.
      totalCostMealPrice = totalCostMealPrice + costMealPrice;
      //CALCULATIONS مجموع أسعار التكلفة = جمع تكلفة اليوم الكامل قبل عمود Total.
      totalCostPrice = totalCostPrice + costPrice;
      //CALCULATIONS إجمالي التكلفة النهائي = جمع سعر التكلفة اليومي لكل الليالي.
      totalCostTotal = totalCostTotal + costPrice;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.r8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
            decoration: BoxDecoration(
              color: AppColors.light,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.r8),
              ),
              border: Border.all(color: Colors.transparent),
            ),
            child: const Row(
              children: [
                Text(
                  'Room details',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSizes.title13,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildRoomTopTextInput(
                        'No. of rooms',
                        controller: _numberOfRoomsController,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      flex: 5,
                      child: _buildRoomTopDropdown(
                        'Room type',
                        value: state.selectedRoomType,
                        items: CreateAgentReservationNotifier.roomTypeOptions,
                        onChanged: (value) {
                          ref
                              .read(createAgentReservationProvider.notifier)
                              .setSelectedRoomType(value);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      flex: 4,
                      child: _buildRoomTopDropdown(
                        'Meal plan',
                        value: state.selectedMealPlan,
                        items: CreateAgentReservationNotifier.mealPlanOptions,
                        onChanged: (value) {
                          ref
                              .read(createAgentReservationProvider.notifier)
                              .setSelectedMealPlan(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.secondary),
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: dateColumnWidth,
                                height: CreateScreensLayout.headerHeight32,
                                color: AppColors.primarySurface.withValues(
                                  alpha: 0.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s12,
                                ),
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  'Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppFontSizes.label11,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: CreateScreensLayout.headerHeight32,
                                  color: AppColors.primarySurface,
                                  alignment: Alignment.center,
                                  child: const Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Sale',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppFontSizes.label11,
                                          ),
                                        ),
                                      ),
                                      VerticalDivider(
                                        width: 1,
                                        color: AppColors.secondary,
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Cost',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppFontSizes.label11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1, color: AppColors.secondary),
                          Container(
                            color: AppColors.light,
                            height: CreateScreensLayout.headerHeight32,
                            child: Row(
                              children: [
                                const SizedBox(width: dateColumnWidth),
                                _buildGridHeaderCell(
                                  'Room',
                                  drawLeftBorder: true,
                                ),
                                _buildGridHeaderCell('Meal Per PAX'),
                                _buildGridHeaderCell('Meal Price'),
                                _buildGridHeaderCell('Price'),
                                _buildGridHeaderCell('Total'),
                                _buildGridHeaderCell(
                                  'Room',
                                  drawLeftBorder: true,
                                ),
                                _buildGridHeaderCell('Meal Per PAX'),
                                _buildGridHeaderCell('Meal Price'),
                                _buildGridHeaderCell('Price'),
                                _buildGridHeaderCell('Total'),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.secondary),
                          Container(
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.s4,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: dateColumnWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s8,
                                    ),
                                    child: Column(
                                      children: [
                                        _WeekdayMultiSelectField(
                                          width: dateColumnWidth,
                                          selectedWeekdays:
                                              state.selectedWeekdays,
                                          onChanged: (value) {
                                            ref
                                                .read(
                                                  createAgentReservationProvider
                                                      .notifier,
                                                )
                                                .setSelectedWeekdays(value);
                                          },
                                        ),
                                        const SizedBox(height: AppSpacing.s4),
                                        SizedBox(
                                          width: double.infinity,
                                          height: cellHeight,
                                          child: ElevatedButton(
                                            onPressed: state.roomRates.isEmpty
                                                ? null
                                                : _applyRatesToAllDays,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryAction,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadii.r4,
                                                    ),
                                              ),
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: const Text(
                                              'Apply',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: AppFontSizes.label11,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _buildGridInputCell(
                                  controller: _saleRoomApplyController,
                                  enabled: true,
                                  drawLeftBorder: true,
                                ),
                                _buildGridInputCell(
                                  controller: _saleMealPerPaxApplyController,
                                  enabled: true,
                                ),
                                _buildGridEmptyCell(),
                                _buildGridEmptyCell(),
                                _buildGridEmptyCell(),
                                _buildGridInputCell(
                                  controller: _costRoomApplyController,
                                  enabled: true,
                                  drawLeftBorder: true,
                                ),
                                _buildGridInputCell(
                                  controller: _costMealPerPaxApplyController,
                                  enabled: true,
                                ),
                                _buildGridEmptyCell(),
                                _buildGridEmptyCell(),
                                _buildGridEmptyCell(),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.secondary),
                          ...state.roomRates.map((rate) {
                            final saleRoomValue = _parseMoney(rate.saleRoom);
                            final saleMealPerPaxValue = _parseMoney(
                              rate.saleMealPerPax,
                            );
                            //CALCULATIONS سعر وجبة البيع في الصف = سعر الوجبة لكل راكب × إجمالي الركاب.
                            final saleMealPriceValue =
                                saleMealPerPaxValue * paxDecimal;
                            //CALCULATIONS سعر البيع في الصف = سعر الغرفة + سعر الوجبات في هذا اليوم.
                            final salePriceValue =
                                saleRoomValue + saleMealPriceValue;

                            final costRoomValue = _parseMoney(rate.costRoom);
                            final costMealPerPaxValue = _parseMoney(
                              rate.costMealPerPax,
                            );
                            //CALCULATIONS سعر وجبة التكلفة في الصف = تكلفة الوجبة لكل راكب × إجمالي الركاب.
                            final costMealPriceValue =
                                costMealPerPaxValue * paxDecimal;
                            //CALCULATIONS سعر التكلفة في الصف = تكلفة الغرفة + تكلفة الوجبات في هذا اليوم.
                            final costPriceValue =
                                costRoomValue + costMealPriceValue;

                            return Column(
                              children: [
                                Container(
                                  color: Colors.white,
                                  height: AppHeights.dropdownSearch30,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: dateColumnWidth,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.s8,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          DateFormat(
                                            'EEEE d/MM/yyyy',
                                          ).format(rate.date),
                                          style: rowTextStyle,
                                        ),
                                      ),
                                      _buildGridDataCell(
                                        rate.saleRoom,
                                        isInput: true,
                                        drawLeftBorder: true,
                                        cellHeight: cellHeight,
                                        enabled: false,
                                        fieldKey:
                                            '${state.roomRatesRevision}_${rate.date.millisecondsSinceEpoch}_sale_room',
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                createAgentReservationProvider
                                                    .notifier,
                                              )
                                              .updateSaleRoom(
                                                date: rate.date,
                                                value: value,
                                              );
                                        },
                                      ),
                                      _buildGridDataCell(
                                        rate.saleMealPerPax,
                                        isInput: true,
                                        cellHeight: cellHeight,
                                        enabled: false,
                                        fieldKey:
                                            '${state.roomRatesRevision}_${rate.date.millisecondsSinceEpoch}_sale_meal',
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                createAgentReservationProvider
                                                    .notifier,
                                              )
                                              .updateSaleMealPerPax(
                                                date: rate.date,
                                                value: value,
                                              );
                                        },
                                      ),
                                      _buildGridDataCell(
                                        _formatFixed(saleMealPriceValue, 6),
                                      ),
                                      _buildGridDataCell(
                                        _formatFixed(salePriceValue, 6),
                                      ),
                                      _buildGridDataCell(
                                        _formatFixed(salePriceValue, 6),
                                      ),
                                      _buildGridDataCell(
                                        rate.costRoom,
                                        isInput: true,
                                        drawLeftBorder: true,
                                        cellHeight: cellHeight,
                                        enabled: false,
                                        fieldKey:
                                            '${state.roomRatesRevision}_${rate.date.millisecondsSinceEpoch}_cost_room',
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                createAgentReservationProvider
                                                    .notifier,
                                              )
                                              .updateCostRoom(
                                                date: rate.date,
                                                value: value,
                                              );
                                        },
                                      ),
                                      _buildGridDataCell(
                                        rate.costMealPerPax,
                                        isInput: true,
                                        cellHeight: cellHeight,
                                        enabled: false,
                                        fieldKey:
                                            '${state.roomRatesRevision}_${rate.date.millisecondsSinceEpoch}_cost_meal',
                                        onChanged: (value) {
                                          ref
                                              .read(
                                                createAgentReservationProvider
                                                    .notifier,
                                              )
                                              .updateCostMealPerPax(
                                                date: rate.date,
                                                value: value,
                                              );
                                        },
                                      ),
                                      _buildGridDataCell(
                                        _formatFixed(costMealPriceValue, 6),
                                      ),
                                      _buildGridDataCell(
                                        _formatFixed(costPriceValue, 6),
                                      ),
                                      _buildGridDataCell(
                                        _formatFixed(costPriceValue, 6),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                  color: AppColors.secondary,
                                ),
                              ],
                            );
                          }),
                          Container(
                            color: AppColors.primarySurface.withValues(
                              alpha: 0.3,
                            ),
                            height: CreateScreensLayout.headerHeight32,
                            child: Row(
                              children: [
                                Container(
                                  width: dateColumnWidth,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s8,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    'All Nights Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppFontSizes.label11,
                                    ),
                                  ),
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalSaleRoom, 6),
                                  drawLeftBorder: true,
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalSaleMealPerPax, 6),
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalSaleMealPrice, 6),
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalSalePrice, 6),
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalSaleTotal, 6),
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalCostRoom, 6),
                                  drawLeftBorder: true,
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalCostMealPerPax, 6),
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalCostMealPrice, 6),
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalCostPrice, 6),
                                ),
                                _buildGridDataCell(
                                  _formatFixed(totalCostTotal, 6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_isRatesLoading)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 160),
                              builder: (context, value, child) {
                                return Opacity(opacity: value, child: child);
                              },
                              child: Container(
                                color: Colors.white.withValues(alpha: 0.65),
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRoomActionLocked
                          ? null
                          : _onAddOrEditRoomPressed,
                      icon: const Icon(Icons.add, size: AppIconSizes.s12),
                      label: Text(
                        state.editingRoomIndex == null ? 'Add' : 'Edit',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAction,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.r4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                          vertical: AppSpacing.s8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: AppFontSizes.body12,
                        ),
                        minimumSize: const Size(0, AppHeights.button32),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s8),
                    OutlinedButton.icon(
                      onPressed: _clearRoomDetailsForm,
                      icon: const Icon(Icons.close, size: AppIconSizes.s12),
                      label: const Text('Clear'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryAction,
                        side: const BorderSide(color: AppColors.primaryAction),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.r4),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                          vertical: AppSpacing.s8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: AppFontSizes.body12,
                        ),
                        minimumSize: const Size(0, AppHeights.button32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s24),

                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                          border: Border.all(color: AppColors.border),
                          color: Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                          child: Column(
                            children: [
                              Container(
                                height: AppHeights.field34,
                                color: AppColors.primarySurfaceAlt,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s12,
                                ),
                                child: Row(
                                  children: [
                                    _buildSummaryHeader(
                                      'No. Of Rooms',
                                      flex: 2,
                                    ),
                                    _buildSummaryHeader('Total RN', flex: 2),
                                    _buildSummaryHeader('Room Type', flex: 3),
                                    _buildSummaryHeader('Meal Plan', flex: 2),
                                    _buildSummaryHeader('Total Sale', flex: 2),
                                    _buildSummaryHeader('Total Cost', flex: 2),
                                    _buildSummaryHeader('Actions', flex: 2),
                                  ],
                                ),
                              ),
                              const Divider(height: 1, color: AppColors.border),
                              if (state.addedRooms.isEmpty)
                                const SizedBox(
                                  height: AppHeights.field34,
                                  child: Center(
                                    child: Text(
                                      '-',
                                      style: TextStyle(
                                        fontSize: AppFontSizes.body12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...state.addedRooms.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final room = entry.value;
                                  final rowColor = index.isEven
                                      ? Colors.white
                                      : AppColors.light.withValues(alpha: 0.75);
                                  return Container(
                                    height: AppHeights.field34,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: rowColor,
                                      border: const Border(
                                        bottom: BorderSide(
                                          color: AppColors.border,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildSummaryCell(
                                          '${room.numberOfRooms}',
                                          flex: 2,
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Text(
                                                '${room.totalRn}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.s8,
                                              ),
                                              const Icon(
                                                Icons.check_circle,
                                                size: AppIconSizes.s14,
                                                color: AppColors.success,
                                              ),
                                              const SizedBox(
                                                width: AppSpacing.s4,
                                              ),
                                              Text(
                                                '${room.totalRn}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.success,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _buildSummaryCell(
                                          room.roomType,
                                          flex: 3,
                                        ),
                                        _buildSummaryCell(
                                          room.mealPlan,
                                          flex: 2,
                                        ),
                                        _buildSummaryCell(
                                          _formatMoney(room.totalSale),
                                          flex: 2,
                                        ),
                                        _buildSummaryCell(
                                          _formatMoney(room.totalCost),
                                          flex: 2,
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _isRatesLoading = true;
                                                  });
                                                  final roomToEdit =
                                                      state.addedRooms[index];
                                                  _numberOfRoomsController
                                                          .text =
                                                      '${roomToEdit.numberOfRooms}';
                                                  final notifier = ref.read(
                                                    createAgentReservationProvider
                                                        .notifier,
                                                  );
                                                  notifier.startEditingRoom(
                                                    index: index,
                                                  );
                                                  final ratesToRestore =
                                                      roomToEdit
                                                          .roomRates
                                                          .isEmpty
                                                      ? state.roomRates
                                                      : roomToEdit.roomRates;
                                                  notifier
                                                      .restoreRoomRatesFromSummary(
                                                        roomRates:
                                                            ratesToRestore,
                                                      );
                                                  notifier.setSelectedRoomType(
                                                    roomToEdit.roomType,
                                                  );
                                                  notifier.setSelectedMealPlan(
                                                    roomToEdit.mealPlan,
                                                  );
                                                  final byDateKey =
                                                      <int, RoomDayRate>{
                                                        for (final rate
                                                            in ratesToRestore)
                                                          DateTime(
                                                                rate.date.year,
                                                                rate.date.month,
                                                                rate.date.day,
                                                              ).millisecondsSinceEpoch:
                                                              rate,
                                                      };
                                                  final refreshedState = ref.read(
                                                    createAgentReservationProvider,
                                                  );
                                                  final firstDate =
                                                      refreshedState
                                                          .roomRates
                                                          .isEmpty
                                                      ? null
                                                      : refreshedState
                                                            .roomRates
                                                            .first
                                                            .date;
                                                  final firstDateKey =
                                                      firstDate == null
                                                      ? null
                                                      : DateTime(
                                                          firstDate.year,
                                                          firstDate.month,
                                                          firstDate.day,
                                                        ).millisecondsSinceEpoch;
                                                  final rateForApply =
                                                      firstDateKey == null
                                                      ? null
                                                      : byDateKey[firstDateKey] ??
                                                            (ratesToRestore
                                                                    .isEmpty
                                                                ? null
                                                                : ratesToRestore
                                                                      .first);
                                                  _saleRoomApplyController
                                                          .text =
                                                      rateForApply?.saleRoom ??
                                                      '';
                                                  _saleMealPerPaxApplyController
                                                          .text =
                                                      rateForApply
                                                          ?.saleMealPerPax ??
                                                      '';
                                                  _costRoomApplyController
                                                          .text =
                                                      rateForApply?.costRoom ??
                                                      '';
                                                  _costMealPerPaxApplyController
                                                          .text =
                                                      rateForApply
                                                          ?.costMealPerPax ??
                                                      '';
                                                  setState(() {
                                                    _hasAppliedRates = true;
                                                  });
                                                  Future<void>.delayed(
                                                    const Duration(
                                                      milliseconds: 220,
                                                    ),
                                                    () {
                                                      if (!mounted) {
                                                        return;
                                                      }
                                                      setState(() {
                                                        _isRatesLoading = false;
                                                      });
                                                    },
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: AppIconSizes.s16,
                                                  color: AppColors.primary,
                                                ),
                                                splashRadius: AppIconSizes.s18,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 28,
                                                      minHeight: 28,
                                                    ),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.receipt_long_outlined,
                                                  size: AppIconSizes.s16,
                                                  color: AppColors.primary,
                                                ),
                                                splashRadius: AppIconSizes.s18,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 28,
                                                      minHeight: 28,
                                                    ),
                                              ),
                                              IconButton(
                                                onPressed: () async {
                                                  if (_isRoomActionLocked) {
                                                    return;
                                                  }
                                                  final confirmed =
                                                      await _confirmRemoveRoom();
                                                  if (!confirmed || !mounted) {
                                                    return;
                                                  }
                                                  _removeRoomFromSummary(index);
                                                },
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: AppIconSizes.s16,
                                                  color: AppColors.danger,
                                                ),
                                                splashRadius: AppIconSizes.s18,
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 28,
                                                      minHeight: 28,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              Container(
                                height: AppHeights.field34,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.s12,
                                ),
                                color: AppColors.secondary,
                                child: Row(
                                  children: [
                                    _buildSummaryCell('Total', flex: 9),
                                    _buildSummaryCell(
                                      _formatMoney(state.totalSale),
                                      flex: 2,
                                    ),
                                    _buildSummaryCell(
                                      _formatMoney(state.totalCost),
                                      flex: 2,
                                    ),
                                    const Expanded(flex: 2, child: SizedBox()),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.s30),

                // Bottom Fields
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildBottomField(
                        'PAX',
                        '${state.totalPax}',
                        isReadOnly: true,
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
  }

  Widget _buildNightsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nights',
          style: AppTextStyles.label.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.s4),
        SizedBox(
          height: AppHeights.field34,
          child: TextField(
            controller: _nightsController,
            focusNode: _nightsFocusNode,
            keyboardType: TextInputType.number,
            onChanged: _onNightsChanged,
            inputFormatters: [ArabicDigitsToEnglishInputFormatter()],
            style: const TextStyle(
              fontSize: AppFontSizes.label11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s10,
                vertical: AppSpacing.s10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.r4),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.r4),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.r4),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTopTextInput(
    String label, {
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRoomTopLabel(label),
        const SizedBox(height: AppSpacing.s6),
        SizedBox(
          height: AppHeights.button32,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [ArabicDigitsToEnglishInputFormatter()],
            style: const TextStyle(
              fontSize: AppFontSizes.label11,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppFontSizes.label11,
                fontWeight: FontWeight.w500,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s10,
                vertical: AppSpacing.s10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.r4),
                borderSide: const BorderSide(color: AppColors.secondary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.r4),
                borderSide: const BorderSide(color: AppColors.secondary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.r4),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomTopDropdown(
    String label, {
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return CustomDropdown(
      label: label,
      value: value,
      items: items,
      hint: 'Select $label',
      onChanged: onChanged,
      fieldHeight: AppHeights.button32,
      popupMaxHeight: AppHeights.dropdownPopupMax180,
      searchable: true,
    );
  }

  Widget _buildRoomTopLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppFontSizes.body12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildGridHeaderCell(String text, {bool drawLeftBorder = false}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: drawLeftBorder
              ? const Border(left: BorderSide(color: AppColors.secondary))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: AppFontSizes.label11,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGridEmptyCell() {
    return Expanded(child: Container(alignment: Alignment.center));
  }

  Widget _buildGridInputCell({
    required TextEditingController controller,
    bool enabled = true,
    bool drawLeftBorder = false,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: drawLeftBorder
                ? const Border(left: BorderSide(color: AppColors.secondary))
                : null,
          ),
          child: Container(
            height: AppHeights.cell24,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.secondary),
              borderRadius: BorderRadius.circular(AppRadii.r4),
              color: enabled ? Colors.white : AppColors.disabledFill,
            ),
            alignment: Alignment.center,
            child: TextField(
              controller: controller,
              enabled: enabled,
              textAlignVertical: TextAlignVertical.center,
              inputFormatters: [ArabicDigitsToEnglishInputFormatter()],
              style: const TextStyle(
                fontSize: AppFontSizes.label11,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: AppSpacing.s8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridDataCell(
    String text, {
    bool isInput = false,
    bool drawLeftBorder = false,
    double cellHeight = AppHeights.cell24,
    bool enabled = true,
    String fieldKey = '',
    ValueChanged<String>? onChanged,
  }) {
    final effectiveFieldKey = enabled ? fieldKey : '$fieldKey|$text';
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: drawLeftBorder
              ? const Border(left: BorderSide(color: AppColors.secondary))
              : null,
        ),
        child: Container(
          alignment: Alignment.center,
          child: isInput
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
                  height: cellHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.secondary),
                    borderRadius: BorderRadius.circular(AppRadii.r4),
                    color: enabled ? Colors.white : AppColors.disabledFill,
                  ),
                  alignment: Alignment.centerLeft,
                  child: enabled
                      ? TextFormField(
                          key: ValueKey<String>(effectiveFieldKey),
                          initialValue: text,
                          enabled: enabled,
                          onChanged: onChanged,
                          textAlignVertical: TextAlignVertical.center,
                          inputFormatters: [
                            ArabicDigitsToEnglishInputFormatter(),
                          ],
                          style: const TextStyle(
                            fontSize: AppFontSizes.label11,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.s8,
                              vertical: AppSpacing.s8,
                            ),
                          ),
                        )
                      : Padding(
                          key: ValueKey<String>(effectiveFieldKey),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s8,
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: AppFontSizes.label11,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: AppFontSizes.label11,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSummaryCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBottomField(
    String label,
    String value, {
    bool isReadOnly = false,
  }) {
    if (isReadOnly) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppFontSizes.body12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppFontSizes.title13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: AppFontSizes.body12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Container(
          height: AppHeights.menuItem40,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondary),
            borderRadius: BorderRadius.circular(AppRadii.r4),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(CreateAgentReservationState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton.icon(
          onPressed: state.isSaving ? null : _onSavePressed,
          icon: state.isSaving
              ? const SizedBox(
                  width: AppIconSizes.s14,
                  height: AppIconSizes.s14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save, size: AppIconSizes.s16),
          label: const Text('Save'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.actionGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r4),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s12,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        ElevatedButton.icon(
          onPressed: state.isSaving ? null : _onSaveAndNewHotelPressed,
          icon: const Icon(Icons.save, size: AppIconSizes.s16),
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Save & New Hotel'),
              SizedBox(width: AppSpacing.s4),
              Icon(Icons.arrow_drop_down, size: AppIconSizes.s18),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.actionGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r4),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s12,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        ElevatedButton.icon(
          onPressed: state.isSaving ? null : _onSaveAndNewPressed,
          icon: const Icon(Icons.save, size: AppIconSizes.s16),
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Save And New'),
              SizedBox(width: AppSpacing.s4),
              Icon(Icons.arrow_drop_down, size: AppIconSizes.s18),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.actionGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r4),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s12,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekdayMultiSelectField extends StatefulWidget {
  const _WeekdayMultiSelectField({
    required this.width,
    required this.selectedWeekdays,
    required this.onChanged,
  });

  final double width;
  final Set<int> selectedWeekdays;
  final ValueChanged<Set<int>> onChanged;

  @override
  State<_WeekdayMultiSelectField> createState() =>
      _WeekdayMultiSelectFieldState();
}

class _WeekdayMultiSelectFieldState extends State<_WeekdayMultiSelectField> {
  static const _items = <({int weekday, String label})>[
    (weekday: DateTime.sunday, label: 'SUN'),
    (weekday: DateTime.monday, label: 'MON'),
    (weekday: DateTime.tuesday, label: 'TUE'),
    (weekday: DateTime.wednesday, label: 'WED'),
    (weekday: DateTime.thursday, label: 'THU'),
    (weekday: DateTime.friday, label: 'FRI'),
    (weekday: DateTime.saturday, label: 'SAT'),
  ];

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late Set<int> _selected;

  String _labelForWeekday(int weekday) {
    for (final item in _items) {
      if (item.weekday == weekday) {
        return item.label;
      }
    }
    return '';
  }

  void _removeWeekday(int weekday) {
    if (!_selected.contains(weekday)) {
      return;
    }
    setState(() {
      _selected.remove(weekday);
    });
    widget.onChanged({..._selected});
  }

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selectedWeekdays};
  }

  @override
  void didUpdateWidget(covariant _WeekdayMultiSelectField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWeekdays != widget.selectedWeekdays) {
      _selected = {...widget.selectedWeekdays};
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleOverlay() {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (overlayContext) {
        final screenWidth = MediaQuery.sizeOf(overlayContext).width;
        var popupWidth = widget.width;
        if (popupWidth > screenWidth - AppSpacing.s16) {
          popupWidth = screenWidth - AppSpacing.s16;
        }
        return Positioned.fill(
          child: Stack(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const SizedBox.expand(),
              ),
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                followerAnchor: Alignment.topLeft,
                targetAnchor: Alignment.bottomLeft,
                offset: const Offset(0, AppSpacing.s2),
                child: Material(
                  color: Colors.transparent,
                  child: StatefulBuilder(
                    builder: (context, setOverlayState) {
                      return Container(
                        width: popupWidth,
                        constraints: const BoxConstraints(
                          maxHeight: AppHeights.dropdownPopupMax180,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadii.r4),
                          border: Border.all(color: AppColors.secondary),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              final isSelected = _selected.contains(
                                item.weekday,
                              );
                              return Material(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                child: InkWell(
                                  hoverColor: const Color(0xFFF3F8FF),
                                  onTap: () {
                                    if (isSelected) {
                                      _selected.remove(item.weekday);
                                    } else {
                                      _selected.add(item.weekday);
                                    }
                                    widget.onChanged({..._selected});
                                    setOverlayState(() {});
                                  },
                                  child: SizedBox(
                                    height: AppHeights.menuItem40,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: AppSpacing.s8),
                                        Theme(
                                          data: Theme.of(context).copyWith(
                                            checkboxTheme: CheckboxThemeData(
                                              side: const BorderSide(
                                                color: AppColors.checkboxBorder,
                                                width: 1.2,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadii.r2,
                                                    ),
                                              ),
                                              visualDensity:
                                                  VisualDensity.compact,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          child: Checkbox(
                                            value: isSelected,
                                            onChanged: (value) {
                                              final next = value ?? false;
                                              if (next) {
                                                _selected.add(item.weekday);
                                              } else {
                                                _selected.remove(item.weekday);
                                              }
                                              widget.onChanged({..._selected});
                                              setOverlayState(() {});
                                            },
                                            checkColor: isSelected
                                                ? AppColors.primary
                                                : Colors.white,
                                            activeColor: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.s8),
                                        Text(
                                          item.label,
                                          style: TextStyle(
                                            fontSize: AppFontSizes.title13,
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedInOrder = _items
        .where((item) => _selected.contains(item.weekday))
        .map((item) => item.weekday)
        .toList(growable: false);

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleOverlay,
        borderRadius: BorderRadius.circular(AppRadii.r4),
        child: Container(
          height: CreateScreensLayout.cellHeight28,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondary),
            borderRadius: BorderRadius.circular(AppRadii.r4),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: selectedInOrder.isEmpty
                    ? const Text(
                        'Select days',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFontSizes.label11,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final weekday in selectedInOrder)
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: AppSpacing.s6,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.s6,
                                    vertical: AppSpacing.s2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.light,
                                    border: Border.all(
                                      color: AppColors.secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.r4,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _removeWeekday(weekday),
                                        child: const Icon(
                                          Icons.close,
                                          size: AppIconSizes.s12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.s4),
                                      Text(
                                        _labelForWeekday(weekday),
                                        style: const TextStyle(
                                          fontSize: AppFontSizes.label11,
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: AppIconSizes.s14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
