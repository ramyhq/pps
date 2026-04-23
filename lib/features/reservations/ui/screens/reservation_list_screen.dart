import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

import 'package:pps/core/constants/app_colors.dart';
import 'package:pps/core/widgets/app_dialog.dart';
import 'package:pps/core/widgets/app_drop_menu_button.dart';
import 'package:pps/core/widgets/custom_form_fields.dart';
import 'package:pps/features/reservations/data/models/reservation_details.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/reservations/data/models/reservation_service.dart';
import 'package:pps/features/reservations/provider/reservations_data_providers.dart';
import 'package:pps/l10n/app_localizations.dart';

enum _FilterFieldType { dropdown, dateRange }

class _FilterFieldSpec {
  const _FilterFieldSpec.dropdown(this.label)
    : type = _FilterFieldType.dropdown;
  const _FilterFieldSpec.dateRange(this.label)
    : type = _FilterFieldType.dateRange;

  final String label;
  final _FilterFieldType type;
}

class ReservationListScreen extends ConsumerStatefulWidget {
  const ReservationListScreen({super.key});

  @override
  ConsumerState<ReservationListScreen> createState() =>
      _ReservationListScreenState();
}

class _ReservationListScreenState extends ConsumerState<ReservationListScreen> {
  final Set<String> _expandedReservationIds = <String>{};

  void _toggleReservation(String reservationId) {
    setState(() {
      if (_expandedReservationIds.contains(reservationId)) {
        _expandedReservationIds.remove(reservationId);
      } else {
        _expandedReservationIds.add(reservationId);
      }
    });
  }

  void _expandAll(List<ReservationOrder> orders) {
    setState(() {
      _expandedReservationIds
        ..clear()
        ..addAll(orders.map((order) => order.id));
    });
  }

  void _collapseAll() {
    setState(() {
      _expandedReservationIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            _buildTopBar(context, l10n),
            const SizedBox(height: AppSpacing.s16),

            // Filters Section
            _buildFiltersCard(context, l10n),
            const SizedBox(height: AppSpacing.s16),

            // Search Actions
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: AppIconSizes.s16),
                  label: Text(l10n.search),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s20,
                      vertical: AppSpacing.s12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.close, size: AppIconSizes.s16),
                  label: Text(l10n.reset),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s20,
                      vertical: AppSpacing.s12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),

            // Data Table
            _buildDataTable(context),
            const SizedBox(height: AppSpacing.s16),

            // Pagination
            _buildPagination(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Text(
          l10n.reservationsTitle,
          style: const TextStyle(
            fontSize: AppFontSizes.pageTitle24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _buildTopButton(
          Icons.print,
          l10n.print,
          Colors.white,
          AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.s8),
        _buildTopButton(
          FontAwesomeIcons.fileExcel,
          l10n.exportToExcel,
          Colors.white,
          AppColors.success,
        ),
        const SizedBox(width: AppSpacing.s8),
        _buildTopButton(
          FontAwesomeIcons.filePdf,
          l10n.exportToPdf,
          Colors.white,
          AppColors.danger,
        ),
        const SizedBox(width: AppSpacing.s8),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.more_vert, size: AppIconSizes.s16),
          label: Text(l10n.actions),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        ElevatedButton.icon(
          onPressed: () => _openCreateReservationDialog(context),
          icon: const Icon(Icons.add, size: AppIconSizes.s16),
          label: Text(l10n.createReservation),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Future<void> _openCreateReservationDialog(BuildContext context) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AppDialog(
          maxWidth: ReservationDetailsLayout.editClientWidthLg,
          title: Text(
            l10n.create,
            style: const TextStyle(
              fontSize: AppFontSizes.title14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.hotel),
                title: Text(l10n.agentDirectReservation),
                onTap: () => Navigator.of(dialogContext).pop('agent'),
              ),
              ListTile(
                leading: const Icon(Icons.miscellaneous_services),
                title: Text(l10n.generalService),
                onTap: () => Navigator.of(dialogContext).pop('general'),
              ),
              ListTile(
                leading: const Icon(Icons.directions_car),
                title: Text(l10n.transportationService),
                onTap: () => Navigator.of(dialogContext).pop('transportation'),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.tableHeader,
                minimumSize: const Size(110, AppHeights.button32),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                side: const BorderSide(color: AppColors.inputBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                ),
              ),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );

    if (!context.mounted) {
      return;
    }

    switch (selected) {
      case 'agent':
        context.go('/reservations/create-agent');
        return;
      case 'general':
        context.go('/reservations/create-general');
        return;
      case 'transportation':
        context.go('/reservations/create-transportation');
        return;
    }
  }

  Widget _buildTopButton(
    IconData icon,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: AppIconSizes.s14, color: textColor),
      label: Text(
        label,
        style: TextStyle(color: textColor, fontSize: AppFontSizes.body12),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: bgColor,
        side: BorderSide(color: textColor.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.r4),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
      ),
    );
  }

  Widget _buildFiltersCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Reservation Info & Dates
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildFilterGroup(l10n.reservationFiltersInfoGroup, [
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(l10n.client),
                      _FilterFieldSpec.dropdown(l10n.hotel),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(l10n.guestName),
                      _FilterFieldSpec.dropdown(l10n.supplier),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersGuestNationality,
                      ),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersClientNationality,
                      ),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersHotelCity,
                      ),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersHotelCategory,
                      ),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(l10n.ppsResNumber),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersSaleAllotment,
                      ),
                    ]),
                  ]),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: _buildFilterGroup(l10n.reservationFiltersDatesGroup, [
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dateRange(
                        l10n.reservationFiltersArrivalDateRange,
                      ),
                      _FilterFieldSpec.dateRange(
                        l10n.reservationFiltersDepartureDateRange,
                      ),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dateRange(
                        l10n.reservationFiltersCreationDateRange,
                      ),
                      _FilterFieldSpec.dateRange(
                        l10n.reservationFiltersClientOptionDateRange,
                      ),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dateRange(
                        l10n.reservationFiltersHotelOptionDateRange,
                      ),
                      _FilterFieldSpec.dateRange(
                        l10n.reservationFiltersAgentOptionDateRange,
                      ),
                    ]),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdown(
                            label: l10n.reservationFiltersServiceDateRange,
                            items: const [],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.s24),
                            child: Row(
                              children: [
                                Checkbox(value: true, onChanged: (v) {}),
                                Text(
                                  l10n.reservationFiltersIncludeServices,
                                  style: const TextStyle(
                                    fontSize: AppFontSizes.title13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ],
            ),
            const Divider(height: AppSpacing.s24),
            // Row 2: Types & Status, Extra details, Remarks
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildFilterGroup(l10n.reservationFiltersTypesGroup, [
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersReservationType,
                      ),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersServiceType,
                      ),
                    ]),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.s8),
                            child: Row(
                              children: [
                                Checkbox(value: false, onChanged: (v) {}),
                                Text(
                                  l10n.reservationFiltersMyReservations,
                                  style: const TextStyle(
                                    fontSize: AppFontSizes.title13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(
                          child: CustomDropdown(
                            label: l10n.reservationFiltersType,
                            items: const [],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(
                          child: CustomDropdown(
                            label: l10n.reservationFiltersIsSent,
                            items: const [],
                          ),
                        ),
                      ],
                    ),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(l10n.status),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersFinancialStatus,
                      ),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersPaymentStatus,
                      ),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersInvoiced,
                      ),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersSplitReservation,
                      ),
                    ]),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFilterGroup(l10n.reservationFiltersExtraGroup, [
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersConfirmation,
                      ),
                      _FilterFieldSpec.dropdown(l10n.reservationFiltersVoucher),
                      _FilterFieldSpec.dropdown(l10n.reservationFiltersFileNo),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersReferenceNo,
                      ),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersAgreementNo,
                      ),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersEnteredBy,
                      ),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersB2bStatus,
                      ),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(l10n.company),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersSubClient,
                      ),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersSalesperson,
                      ),
                      _FilterFieldSpec.dropdown(l10n.creator),
                    ]),
                    _buildFilterRow(l10n, [
                      _FilterFieldSpec.dropdown(l10n.tag),
                      _FilterFieldSpec.dropdown(l10n.reservationFiltersOrderBy),
                      _FilterFieldSpec.dropdown(
                        l10n.reservationFiltersDirection,
                      ),
                    ]),
                  ]),
                ),
              ],
            ),
            const Divider(height: AppSpacing.s24),
            _buildFilterGroup(l10n.reservationFiltersRemarksGroup, [
              _buildFilterRow(l10n, [
                _FilterFieldSpec.dropdown(
                  l10n.reservationFiltersReservationRemarks,
                ),
                _FilterFieldSpec.dropdown(l10n.reservationFiltersDetailRemarks),
                _FilterFieldSpec.dropdown(l10n.reservationFiltersClientRemarks),
                _FilterFieldSpec.dropdown(l10n.reservationFiltersHotelRemarks),
              ]),
              _buildFilterRow(l10n, [
                _FilterFieldSpec.dropdown(l10n.reservationFiltersAgentRemarks),
              ]),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterGroup(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.info.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(AppRadii.r4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.info,
              fontWeight: FontWeight.bold,
              fontSize: AppFontSizes.title14,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          ...children.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: c,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(AppLocalizations l10n, List<_FilterFieldSpec> fields) {
    return Row(
      children: fields.map((field) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.s8),
            child: field.type == _FilterFieldType.dateRange
                ? CustomTextField(label: field.label, hintText: l10n.fromToHint)
                : CustomDropdown(
                    label: field.label,
                    items: const [],
                    hint: l10n.all,
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDataTable(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ordersAsync = ref.watch(reservationOrdersProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.r4),
        border: Border.all(color: AppColors.secondary),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.r4),
        child: Column(
          children: [
            if (ordersAsync.hasValue &&
                (ordersAsync.value ?? const []).isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  AppSpacing.s10,
                  AppSpacing.s16,
                  AppSpacing.s8,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTableControlLink(
                        label: l10n.expandAll,
                        icon: Icons.keyboard_arrow_down,
                        onTap: () => _expandAll(ordersAsync.value ?? const []),
                      ),
                      const SizedBox(width: AppSpacing.s14),
                      _buildTableControlLink(
                        label: l10n.collapseAll,
                        icon: Icons.keyboard_arrow_up,
                        onTap: _collapseAll,
                      ),
                    ],
                  ),
                ),
              ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: _ReservationTableMetrics.mainTableWidth,
                ),
                child: Column(
                  children: [
                    _buildOrdersTableHeader(l10n),
                    if (ordersAsync.isLoading)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.loading,
                            style: const TextStyle(
                              fontSize: AppFontSizes.title13,
                            ),
                          ),
                        ),
                      )
                    else if (ordersAsync.hasError)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ordersAsync.error.toString(),
                            style: const TextStyle(
                              fontSize: AppFontSizes.title13,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._buildOrdersRows(
                        context: context,
                        l10n: l10n,
                        orders: ordersAsync.value ?? const <ReservationOrder>[],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableControlLink({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.r4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppIconSizes.s14, color: AppColors.primary),
            const SizedBox(width: AppSpacing.s2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: AppFontSizes.body12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTableHeader(AppLocalizations l10n) {
    return Container(
      width: _ReservationTableMetrics.mainTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primarySurfaceAlt,
        border: Border(bottom: BorderSide(color: AppColors.secondary)),
      ),
      child: Row(
        children: [
          _buildHeaderTableCell(width: _ReservationTableMetrics.expandWidth),
          _buildHeaderTableCell(width: _ReservationTableMetrics.checkboxWidth),
          _buildHeaderTableCell(
            text: l10n.actions,
            width: _ReservationTableMetrics.actionsWidth,
          ),
          _buildHeaderTableCell(
            text: l10n.ppsResNumber,
            width: _ReservationTableMetrics.idWidth,
            sortable: true,
          ),
          _buildHeaderTableCell(
            text: l10n.from,
            width: _ReservationTableMetrics.dateWidth,
          ),
          _buildHeaderTableCell(
            text: l10n.to,
            width: _ReservationTableMetrics.dateWidth,
          ),
          _buildHeaderTableCell(
            text: l10n.client,
            width: _ReservationTableMetrics.clientWidth,
            sortable: true,
          ),
          _buildHeaderTableCell(
            text: l10n.guestName,
            width: _ReservationTableMetrics.guestWidth,
            sortable: true,
          ),
          _buildHeaderTableCell(
            text: l10n.detailsTitle,
            width: _ReservationTableMetrics.detailsWidth,
          ),
          _buildHeaderTableCell(
            text: l10n.tags,
            width: _ReservationTableMetrics.tagsWidth,
          ),
          _buildHeaderTableCell(
            text: l10n.status,
            width: _ReservationTableMetrics.statusWidth,
            sortable: true,
          ),
          _buildHeaderTableCell(
            text: l10n.sale,
            width: _ReservationTableMetrics.moneyWidth,
          ),
          _buildHeaderTableCell(
            text: l10n.paid,
            width: _ReservationTableMetrics.moneyWidth,
          ),
          _buildHeaderTableCell(
            text: l10n.remaining,
            width: _ReservationTableMetrics.remainingWidth,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrdersRows({
    required BuildContext context,
    required AppLocalizations l10n,
    required List<ReservationOrder> orders,
  }) {
    if (orders.isEmpty) {
      return <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.noReservationsFound,
              style: const TextStyle(fontSize: AppFontSizes.title13),
            ),
          ),
        ),
      ];
    }

    final rows = <Widget>[];
    for (final order in orders) {
      rows.add(
        _ReservationOrderRow(
          key: ValueKey<String>(order.id),
          context: context,
          order: order,
          isExpanded: _expandedReservationIds.contains(order.id),
          onToggleExpanded: () => _toggleReservation(order.id),
        ),
      );
    }
    return rows;
  }

  Widget _buildHeaderTableCell({
    String? text,
    required double width,
    bool sortable = false,
  }) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (text != null)
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppFontSizes.title13,
                color: AppColors.textSecondary,
              ),
            ),
          if (sortable) ...[
            const SizedBox(width: AppSpacing.s4),
            const Icon(
              Icons.unfold_more,
              size: AppIconSizes.s14,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPagination(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Text(l10n.show, style: const TextStyle(fontSize: AppFontSizes.body12)),
        const SizedBox(width: AppSpacing.s8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s8,
            vertical: AppSpacing.s4,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadii.r4),
          ),
          child: const Text(
            '10',
            style: TextStyle(fontSize: AppFontSizes.body12),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Text(
          l10n.entries,
          style: const TextStyle(fontSize: AppFontSizes.body12),
        ),
        const SizedBox(width: AppSpacing.s16),
        Text(
          l10n.showingEntriesRange(1, 10, 2144),
          style: const TextStyle(
            fontSize: AppFontSizes.body12,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        _buildPageButton('<'),
        _buildPageButton('1', isActive: true),
        _buildPageButton('2'),
        _buildPageButton('3'),
        _buildPageButton('4'),
        _buildPageButton('5'),
        _buildPageButton('>'),
        _buildPageButton('>>'),
      ],
    );
  }

  Widget _buildPageButton(String text, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(AppRadii.r4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textPrimary,
          fontSize: AppFontSizes.body12,
        ),
      ),
    );
  }
}

enum _ReservationRowAction {
  view,
  unpost,
  cancel,
  sendEmail,
  transactionsDetails,
  auditLog,
}

class _ReservationTableMetrics {
  static const double expandWidth = 28;
  static const double checkboxWidth = 36;
  static const double actionsWidth = 82;
  static const double idWidth = 62;
  static const double dateWidth = 96;
  static const double clientWidth = 172;
  static const double guestWidth = 96;
  static const double detailsWidth = 72;
  static const double tagsWidth = 64;
  static const double statusWidth = 110;
  static const double moneyWidth = 92;
  static const double remainingWidth = 108;

  static const double nestedActionsWidth = 66;
  static const double nestedNumberWidth = 88;
  static const double nestedMoneyWidth = 92;

  static const double groupedTitleWidth = 188;
  static const double groupedProviderWidth = 178;
  static const double groupedDateWidth = 98;
  static const double groupedQtyWidth = 58;
  static const double groupedDescriptionWidth = 190;
  static const double groupedSupplierWidth = 118;

  static const double mainTableWidth = 1240;
  static const double groupedTableWidth =
      checkboxWidth +
      nestedActionsWidth +
      nestedNumberWidth +
      groupedTitleWidth +
      groupedProviderWidth +
      groupedDateWidth +
      groupedDateWidth +
      groupedQtyWidth +
      groupedQtyWidth +
      nestedMoneyWidth +
      nestedMoneyWidth +
      groupedSupplierWidth +
      (AppSpacing.s12 * 2);
}

class _ReservationOrderRow extends ConsumerWidget {
  const _ReservationOrderRow({
    super.key,
    required this.context,
    required this.order,
    required this.isExpanded,
    required this.onToggleExpanded,
  });

  final BuildContext context;
  final ReservationOrder order;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailsAsync = ref.watch(reservationDetailsProvider(order.id));
    final details = detailsAsync.hasValue ? detailsAsync.value : null;
    final services = details?.services ?? const <ReservationServiceSummary>[];
    //CALCULATIONS إجمالي البيع في صف الحجز الرئيسي = مجموع totalSale لكل خدمات الحجز.
    final totalSale = services.fold<Decimal>(
      Decimal.parse('0'),
      (sum, service) => sum + service.totalSale,
    );
    final detailsCount = services.length;
    final totalSaleText = services.isEmpty ? '-' : _formatMoney(totalSale);

    return Column(
      children: [
        Container(
          width: _ReservationTableMetrics.mainTableWidth,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isExpanded ? AppColors.secondary : AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              _TableBox(
                width: _ReservationTableMetrics.expandWidth,
                child: InkWell(
                  onTap: onToggleExpanded,
                  borderRadius: BorderRadius.circular(AppRadii.r20),
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      color: Colors.white,
                      size: AppIconSizes.s12,
                    ),
                  ),
                ),
              ),
              const _TableBox(
                width: _ReservationTableMetrics.checkboxWidth,
                child: _ListCheckbox(),
              ),
              _TableBox(
                width: _ReservationTableMetrics.actionsWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _ReservationActionsMenu(
                    reservationId: order.id,
                    buttonHeight: 30,
                  ),
                ),
              ),
              _TableBox(
                width: _ReservationTableMetrics.idWidth,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () => context.go(
                      '/reservations/details?reservationId=${order.id}',
                    ),
                    child: Text(
                      order.reservationNo > 0 ? '${order.reservationNo}' : '-',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: AppFontSizes.title13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              _TableBox(
                width: _ReservationTableMetrics.dateWidth,
                child: Text(
                  _formatDate(order.createdAt),
                  style: const TextStyle(fontSize: AppFontSizes.title13),
                ),
              ),
              _TableBox(
                width: _ReservationTableMetrics.dateWidth,
                child: Text(
                  _formatDate(order.clientOptionDate),
                  style: const TextStyle(fontSize: AppFontSizes.title13),
                ),
              ),
              _TableBox(
                width: _ReservationTableMetrics.clientWidth,
                child: Text(
                  order.client.name,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: AppFontSizes.title13,
                    height: 1.45,
                  ),
                ),
              ),
              const _TableBox(
                width: _ReservationTableMetrics.guestWidth,
                child: Text(
                  '-',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppFontSizes.title13,
                  ),
                ),
              ),
              _TableBox(
                width: _ReservationTableMetrics.detailsWidth,
                child: InkWell(
                  onTap: onToggleExpanded,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        detailsCount > 0 ? '$detailsCount' : '-',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: AppFontSizes.title13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s2),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: AppIconSizes.s14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const _TableBox(
                width: _ReservationTableMetrics.tagsWidth,
                child: SizedBox(),
              ),
              _TableBox(
                width: _ReservationTableMetrics.statusWidth,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s14,
                      vertical: AppSpacing.s4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.actionGreen,
                      borderRadius: BorderRadius.circular(AppRadii.r4),
                    ),
                    child: Text(
                      l10n.confirmed,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppFontSizes.label11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              _TableBox(
                width: _ReservationTableMetrics.moneyWidth,
                alignment: Alignment.centerRight,
                child: Text(
                  totalSaleText,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: AppFontSizes.title13),
                ),
              ),
              const _TableBox(
                width: _ReservationTableMetrics.moneyWidth,
                alignment: Alignment.centerRight,
                child: Text(
                  '-',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: AppFontSizes.title13),
                ),
              ),
              _TableBox(
                width: _ReservationTableMetrics.remainingWidth,
                alignment: Alignment.centerRight,
                child: Text(
                  totalSaleText,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: AppFontSizes.title13),
                ),
              ),
            ],
          ),
        ),
        if (isExpanded)
          _ExpandedReservationServicesTable(
            order: order,
            detailsAsync: detailsAsync,
          ),
      ],
    );
  }
}

class _ExpandedReservationServicesTable extends StatelessWidget {
  const _ExpandedReservationServicesTable({
    required this.order,
    required this.detailsAsync,
  });

  final ReservationOrder order;
  final AsyncValue<ReservationDetails> detailsAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: _ReservationTableMetrics.mainTableWidth,
      color: const Color(0xFFF8FBFF),
      padding: const EdgeInsets.fromLTRB(36, 10, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.secondary),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: _ReservationTableMetrics.groupedTableWidth,
            ),
            child: Column(
              children: [
                if (detailsAsync.isLoading)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.loadingServices,
                        style: const TextStyle(fontSize: AppFontSizes.body12),
                      ),
                    ),
                  )
                else if (detailsAsync.hasError)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        detailsAsync.error.toString(),
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: AppFontSizes.body12,
                        ),
                      ),
                    ),
                  )
                else
                  ..._buildGroupedServiceRows(
                    context,
                    l10n,
                    detailsAsync.hasValue
                        ? detailsAsync.value!.services
                        : const <ReservationServiceSummary>[],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroupedServiceRows(
    BuildContext context,
    AppLocalizations l10n,
    List<ReservationServiceSummary> services,
  ) {
    if (services.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.noServicesFoundForReservation,
              style: const TextStyle(fontSize: AppFontSizes.body12),
            ),
          ),
        ),
      ];
    }

    final sections = <Widget>[];
    final hotelServicesByName = <String, List<ReservationServiceSummary>>{};
    final generalServices = <ReservationServiceSummary>[];
    final transportationServices = <ReservationServiceSummary>[];

    for (final service in services) {
      switch (service.type) {
        case ReservationServiceType.agent:
          final hotelName = _serviceGroupTitle(l10n, service);
          hotelServicesByName.putIfAbsent(hotelName, () => []).add(service);
        case ReservationServiceType.general:
          generalServices.add(service);
        case ReservationServiceType.transportation:
          transportationServices.add(service);
      }
    }

    for (final hotelEntry in hotelServicesByName.entries) {
      if (sections.isNotEmpty) {
        sections.add(const Divider(height: 1, color: AppColors.secondary));
      }
      sections.add(
        _buildServiceGroupSection(
          context,
          title: hotelEntry.key,
          bannerType: ReservationServiceType.agent,
          services: hotelEntry.value,
        ),
      );
    }

    if (generalServices.isNotEmpty) {
      if (sections.isNotEmpty) {
        sections.add(const Divider(height: 1, color: AppColors.secondary));
      }
      sections.add(
        _buildCompactServicesGroupSection(
          context,
          title: l10n.generalService,
          bannerType: ReservationServiceType.general,
          services: generalServices,
        ),
      );
    }

    if (transportationServices.isNotEmpty) {
      if (sections.isNotEmpty) {
        sections.add(const Divider(height: 1, color: AppColors.secondary));
      }
      sections.add(
        _buildCompactServicesGroupSection(
          context,
          title: l10n.transportationService,
          bannerType: ReservationServiceType.transportation,
          services: transportationServices,
        ),
      );
    }

    sections.add(_buildGrandTotalRow(l10n, services));
    return sections;
  }

  Widget _buildServiceGroupSection(
    BuildContext context, {
    required String title,
    required ReservationServiceType bannerType,
    required List<ReservationServiceSummary> services,
  }) {
    return Column(
      children: [
        _buildGroupBanner(
          title: title,
          bannerType: bannerType,
          count: services.length,
        ),
        _buildAgentHeader(AppLocalizations.of(context)!),
        for (final service in services) _buildServiceRow(context, service),
        _buildAgentTotalRow(
          AppLocalizations.of(context)!,
          services.length,
          //CALCULATIONS إجمالي بيع مجموعة الفنادق = مجموع totalSale لكل خدمات Agent داخل المجموعة.
          services.fold<Decimal>(
            Decimal.parse('0'),
            (sum, service) => sum + service.totalSale,
          ),
          //CALCULATIONS إجمالي تكلفة مجموعة الفنادق = مجموع totalCost لكل خدمات Agent داخل المجموعة.
          services.fold<Decimal>(
            Decimal.parse('0'),
            (sum, service) => sum + service.totalCost,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactServicesGroupSection(
    BuildContext context, {
    required String title,
    required ReservationServiceType bannerType,
    required List<ReservationServiceSummary> services,
  }) {
    return Column(
      children: [
        _buildGroupBanner(
          title: title,
          bannerType: bannerType,
          count: services.length,
        ),
        _buildGeneralHeader(AppLocalizations.of(context)!),
        for (final service in services) _buildServiceRow(context, service),
        _buildCompactTotalRow(
          AppLocalizations.of(context)!,
          services.length,
          //CALCULATIONS إجمالي بيع المجموعة المدمجة = مجموع totalSale لكل الخدمات العامة/المواصلات داخل المجموعة.
          services.fold<Decimal>(
            Decimal.parse('0'),
            (sum, service) => sum + service.totalSale,
          ),
          //CALCULATIONS إجمالي تكلفة المجموعة المدمجة = مجموع totalCost لكل الخدمات العامة/المواصلات داخل المجموعة.
          services.fold<Decimal>(
            Decimal.parse('0'),
            (sum, service) => sum + service.totalCost,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupBanner({
    required String title,
    required ReservationServiceType bannerType,
    required int count,
  }) {
    return Container(
      width: _ReservationTableMetrics.groupedTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: _groupBannerColor(bannerType),
        border: const Border(bottom: BorderSide(color: AppColors.secondary)),
      ),
      child: Row(
        children: [
          Icon(
            _serviceIcon(bannerType),
            size: AppIconSizes.s16,
            color: _serviceIconColor(bannerType),
          ),
          const SizedBox(width: AppSpacing.s8),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppFontSizes.title13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s8,
              vertical: AppSpacing.s2,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.r20),
              border: Border.all(color: AppColors.secondary),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: AppFontSizes.label11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentHeader(AppLocalizations l10n) {
    return Container(
      width: _ReservationTableMetrics.groupedTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primarySurfaceAlt,
        border: Border(bottom: BorderSide(color: AppColors.secondary)),
      ),
      child: Row(
        children: [
          const _TableBox(
            width: _ReservationTableMetrics.checkboxWidth,
            child: SizedBox(),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.nestedActionsWidth,
            child: Text('', style: TextStyle(fontSize: AppFontSizes.label11)),
          ),
          const _NestedHeaderCell(
            '#',
            width: _ReservationTableMetrics.nestedNumberWidth,
          ),
          _NestedHeaderCell(
            l10n.hotel,
            width: _ReservationTableMetrics.groupedTitleWidth,
          ),
          _NestedHeaderCell(
            l10n.provider,
            width: _ReservationTableMetrics.groupedProviderWidth,
          ),
          _NestedHeaderCell(
            l10n.arrivalDate,
            width: _ReservationTableMetrics.groupedDateWidth,
          ),
          _NestedHeaderCell(
            l10n.departureDate,
            width: _ReservationTableMetrics.groupedDateWidth,
          ),
          _NestedHeaderCell(
            l10n.rooms,
            width: _ReservationTableMetrics.groupedQtyWidth,
          ),
          _NestedHeaderCell(
            l10n.rn,
            width: _ReservationTableMetrics.groupedQtyWidth,
          ),
          _NestedHeaderCell(
            l10n.sale,
            width: _ReservationTableMetrics.nestedMoneyWidth,
          ),
          _NestedHeaderCell(
            l10n.cost,
            width: _ReservationTableMetrics.nestedMoneyWidth,
          ),
          _NestedHeaderCell(
            l10n.supplier,
            width: _ReservationTableMetrics.groupedSupplierWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralHeader(AppLocalizations l10n) {
    return Container(
      width: _ReservationTableMetrics.groupedTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primarySurfaceAlt,
        border: Border(bottom: BorderSide(color: AppColors.secondary)),
      ),
      child: Row(
        children: [
          const _TableBox(
            width: _ReservationTableMetrics.checkboxWidth,
            child: SizedBox(),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.nestedActionsWidth,
            child: Text('', style: TextStyle(fontSize: AppFontSizes.label11)),
          ),
          const _NestedHeaderCell(
            '#',
            width: _ReservationTableMetrics.nestedNumberWidth,
          ),
          _NestedHeaderCell(
            l10n.service,
            width: _ReservationTableMetrics.groupedTitleWidth,
          ),
          _NestedHeaderCell(
            l10n.provider,
            width: _ReservationTableMetrics.groupedProviderWidth,
          ),
          _NestedHeaderCell(
            l10n.date,
            width: _ReservationTableMetrics.groupedDateWidth,
          ),
          _NestedHeaderCell(
            l10n.qtyShort,
            width: _ReservationTableMetrics.groupedQtyWidth,
          ),
          _NestedHeaderCell(
            l10n.desc,
            width: _ReservationTableMetrics.groupedDescriptionWidth,
          ),
          _NestedHeaderCell(
            l10n.sale,
            width: _ReservationTableMetrics.nestedMoneyWidth,
          ),
          _NestedHeaderCell(
            l10n.cost,
            width: _ReservationTableMetrics.nestedMoneyWidth,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(
    BuildContext context,
    ReservationServiceSummary service,
  ) {
    switch (service.type) {
      case ReservationServiceType.agent:
        return _buildAgentServiceRow(context, service);
      case ReservationServiceType.general:
        return _buildGeneralServiceRow(context, service);
      case ReservationServiceType.transportation:
        return _buildTransportationServiceRow(context, service);
    }
  }

  Widget _buildAgentServiceRow(
    BuildContext context,
    ReservationServiceSummary service,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final hasCostAlert = service.totalCost > service.totalSale;
    final borderColor = hasCostAlert
        ? AppColors.dangerAccent
        : AppColors.border;

    return Container(
      width: _ReservationTableMetrics.groupedTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          const _TableBox(
            width: _ReservationTableMetrics.checkboxWidth,
            child: _ListCheckbox(),
          ),
          _buildServiceActionsCell(context, service),
          _TableBox(
            width: _ReservationTableMetrics.nestedNumberWidth,
            child: Text(
              service.displayNo,
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedTitleWidth,
            child: Text(
              _servicePrimaryValue(l10n, service),
              style: const TextStyle(fontSize: AppFontSizes.title13),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedProviderWidth,
            child: Text(
              order.client.name,
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                height: 1.4,
              ),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedDateWidth,
            child: Text(
              _formatDate(service.createdAt),
              style: const TextStyle(fontSize: AppFontSizes.body12),
            ),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedDateWidth,
            child: Text('-', style: TextStyle(fontSize: AppFontSizes.body12)),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedQtyWidth,
            alignment: Alignment.center,
            child: Text(
              '-',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppFontSizes.body12),
            ),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedQtyWidth,
            alignment: Alignment.center,
            child: Text(
              '-',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: AppFontSizes.body12),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.nestedMoneyWidth,
            alignment: Alignment.centerRight,
            child: Text(
              _formatMoney(service.totalSale),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: AppFontSizes.body12),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.nestedMoneyWidth,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    _formatMoney(service.totalCost),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: AppFontSizes.body12,
                      color: hasCostAlert
                          ? AppColors.dangerAccent
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (hasCostAlert) ...[
                  const SizedBox(width: AppSpacing.s4),
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: AppIconSizes.s14,
                    color: AppColors.dangerAccent,
                  ),
                ],
              ],
            ),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedSupplierWidth,
            child: Text('-', style: TextStyle(fontSize: AppFontSizes.body12)),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralServiceRow(
    BuildContext context,
    ReservationServiceSummary service,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final general = service.generalDetails;
    final hasCostAlert = service.totalCost > service.totalSale;
    final borderColor = hasCostAlert
        ? AppColors.dangerAccent
        : AppColors.border;

    return Container(
      width: _ReservationTableMetrics.groupedTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          const _TableBox(
            width: _ReservationTableMetrics.checkboxWidth,
            child: _ListCheckbox(),
          ),
          _buildServiceActionsCell(context, service),
          _TableBox(
            width: _ReservationTableMetrics.nestedNumberWidth,
            child: Text(
              service.displayNo,
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedTitleWidth,
            child: Text(
              _servicePrimaryValue(l10n, service),
              style: const TextStyle(fontSize: AppFontSizes.title13),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedProviderWidth,
            child: Text(
              _serviceProviderValue(l10n, service),
              style: const TextStyle(
                fontSize: AppFontSizes.body12,
                height: 1.4,
              ),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedDateWidth,
            child: Text(
              _formatDate(general?.dateOfService ?? service.createdAt),
              style: const TextStyle(fontSize: AppFontSizes.body12),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedQtyWidth,
            alignment: Alignment.center,
            child: Text(
              (general?.quantity ?? 1).toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: AppFontSizes.body12),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedDescriptionWidth,
            child: Text(
              _serviceDescriptionValue(l10n, service),
              style: const TextStyle(
                fontSize: AppFontSizes.body12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _buildSaleCell(service.totalSale),
          _buildCostCell(service.totalCost, hasCostAlert),
        ],
      ),
    );
  }

  Widget _buildTransportationServiceRow(
    BuildContext context,
    ReservationServiceSummary service,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final transportation = service.transportationDetails;
    final firstTrip = transportation == null || transportation.trips.isEmpty
        ? null
        : transportation.trips.first;
    final hasCostAlert = service.totalCost > service.totalSale;
    final borderColor = hasCostAlert
        ? AppColors.dangerAccent
        : AppColors.border;

    return Container(
      width: _ReservationTableMetrics.groupedTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          const _TableBox(
            width: _ReservationTableMetrics.checkboxWidth,
            child: _ListCheckbox(),
          ),
          _buildServiceActionsCell(context, service),
          _TableBox(
            width: _ReservationTableMetrics.nestedNumberWidth,
            child: Text(
              service.displayNo,
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedTitleWidth,
            child: Text(
              _servicePrimaryValue(l10n, service),
              style: const TextStyle(fontSize: AppFontSizes.title13),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedProviderWidth,
            child: Text(
              _serviceProviderValue(l10n, service),
              style: const TextStyle(
                fontSize: AppFontSizes.body12,
                height: 1.4,
              ),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedDateWidth,
            child: Text(
              _formatDate(firstTrip?.date ?? service.createdAt),
              style: const TextStyle(fontSize: AppFontSizes.body12),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedQtyWidth,
            alignment: Alignment.center,
            child: Text(
              _transportationQuantityValue(service),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: AppFontSizes.body12),
            ),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedDescriptionWidth,
            child: Text(
              _serviceDescriptionValue(l10n, service),
              style: const TextStyle(
                fontSize: AppFontSizes.body12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _buildSaleCell(service.totalSale),
          _buildCostCell(service.totalCost, hasCostAlert),
        ],
      ),
    );
  }

  Widget _buildAgentTotalRow(
    AppLocalizations l10n,
    int count,
    Decimal totalSale,
    Decimal totalCost,
  ) {
    return Container(
      width: _ReservationTableMetrics.groupedTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.light,
        border: Border(top: BorderSide(color: AppColors.secondary)),
      ),
      child: Row(
        children: [
          const _TableBox(
            width: _ReservationTableMetrics.checkboxWidth,
            child: SizedBox(),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.nestedActionsWidth,
            child: SizedBox(),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.nestedNumberWidth,
            child: SizedBox(),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedTitleWidth,
            child: Text(
              l10n.total,
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedProviderWidth,
            child: SizedBox(),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedDateWidth,
            child: SizedBox(),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedDateWidth,
            child: SizedBox(),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedQtyWidth,
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: AppFontSizes.body12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedQtyWidth,
            alignment: Alignment.center,
            child: Text('-', style: TextStyle(fontSize: AppFontSizes.body12)),
          ),
          _buildTotalMoneyCell(totalSale),
          _buildTotalMoneyCell(totalCost),
          const _TableBox(
            width: _ReservationTableMetrics.groupedSupplierWidth,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactTotalRow(
    AppLocalizations l10n,
    int count,
    Decimal totalSale,
    Decimal totalCost,
  ) {
    return Container(
      width: _ReservationTableMetrics.groupedTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      decoration: const BoxDecoration(
        color: AppColors.light,
        border: Border(top: BorderSide(color: AppColors.secondary)),
      ),
      child: Row(
        children: [
          const _TableBox(
            width: _ReservationTableMetrics.checkboxWidth,
            child: SizedBox(),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.nestedActionsWidth,
            child: SizedBox(),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.nestedNumberWidth,
            child: SizedBox(),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedTitleWidth,
            child: Text(
              l10n.total,
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedProviderWidth,
            child: SizedBox(),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedDateWidth,
            child: SizedBox(),
          ),
          _TableBox(
            width: _ReservationTableMetrics.groupedQtyWidth,
            alignment: Alignment.center,
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: AppFontSizes.body12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const _TableBox(
            width: _ReservationTableMetrics.groupedDescriptionWidth,
            child: SizedBox(),
          ),
          _buildTotalMoneyCell(totalSale),
          _buildTotalMoneyCell(totalCost),
        ],
      ),
    );
  }

  Widget _buildGrandTotalRow(
    AppLocalizations l10n,
    List<ReservationServiceSummary> services,
  ) {
    //CALCULATIONS Grand Total Sale = مجموع totalSale لكل خدمات الحجز المعروضة بعد التجميع.
    final totalSale = services.fold<Decimal>(
      Decimal.parse('0'),
      (sum, service) => sum + service.totalSale,
    );
    //CALCULATIONS Grand Total Cost = مجموع totalCost لكل خدمات الحجز المعروضة بعد التجميع.
    final totalCost = services.fold<Decimal>(
      Decimal.parse('0'),
      (sum, service) => sum + service.totalCost,
    );

    return Container(
      width: _ReservationTableMetrics.groupedTableWidth,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primarySurfaceAlt,
        border: Border(top: BorderSide(color: AppColors.secondary)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.grandTotal,
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: _ReservationTableMetrics.nestedMoneyWidth,
            child: Text(
              _formatMoney(totalSale),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          SizedBox(
            width: _ReservationTableMetrics.nestedMoneyWidth,
            child: Text(
              _formatMoney(totalCost),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: AppFontSizes.title13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceActionsCell(
    BuildContext context,
    ReservationServiceSummary service,
  ) {
    return _TableBox(
      width: _ReservationTableMetrics.nestedActionsWidth,
      child: Row(
        children: [
          InkWell(
            onTap: () => _openServiceEdit(context, order.id, service),
            child: const Icon(
              Icons.edit_outlined,
              size: AppIconSizes.s16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Icon(
            _serviceIcon(service.type),
            size: AppIconSizes.s16,
            color: _serviceIconColor(service.type),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCell(Decimal amount) {
    return _TableBox(
      width: _ReservationTableMetrics.nestedMoneyWidth,
      alignment: Alignment.centerRight,
      child: Text(
        _formatMoney(amount),
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: AppFontSizes.body12),
      ),
    );
  }

  Widget _buildCostCell(Decimal amount, bool hasCostAlert) {
    return _TableBox(
      width: _ReservationTableMetrics.nestedMoneyWidth,
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Text(
              _formatMoney(amount),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: AppFontSizes.body12,
                color: hasCostAlert
                    ? AppColors.dangerAccent
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (hasCostAlert) ...[
            const SizedBox(width: AppSpacing.s4),
            const Icon(
              Icons.warning_amber_rounded,
              size: AppIconSizes.s14,
              color: AppColors.dangerAccent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalMoneyCell(Decimal amount) {
    return _TableBox(
      width: _ReservationTableMetrics.nestedMoneyWidth,
      alignment: Alignment.centerRight,
      child: Text(
        _formatMoney(amount),
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: AppFontSizes.body12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReservationActionsMenu extends StatelessWidget {
  const _ReservationActionsMenu({
    required this.reservationId,
    required this.buttonHeight,
  });

  final String reservationId;
  final double buttonHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppDropMenuButton<_ReservationRowAction>(
      onSelected: (action) {
        switch (action) {
          case _ReservationRowAction.view:
            context.go('/reservations/details?reservationId=$reservationId');
            return;
          case _ReservationRowAction.unpost:
          case _ReservationRowAction.cancel:
          case _ReservationRowAction.sendEmail:
          case _ReservationRowAction.transactionsDetails:
          case _ReservationRowAction.auditLog:
            return;
        }
      },
      entries: [
        AppDropMenuEntry.action(
          value: _ReservationRowAction.view,
          label: l10n.view,
          icon: Icons.visibility,
        ),
        AppDropMenuEntry.action(
          value: _ReservationRowAction.unpost,
          label: l10n.unpost,
          icon: Icons.undo,
        ),
        AppDropMenuEntry.action(
          value: _ReservationRowAction.cancel,
          label: l10n.cancel,
          icon: Icons.cancel,
          isDanger: true,
        ),
        AppDropMenuEntry.action(
          value: _ReservationRowAction.sendEmail,
          label: l10n.sendEmail,
          icon: Icons.email,
        ),
        AppDropMenuEntry.action(
          value: _ReservationRowAction.transactionsDetails,
          label: l10n.transactionsDetails,
          icon: Icons.receipt_long,
        ),
        AppDropMenuEntry.action(
          value: _ReservationRowAction.auditLog,
          label: l10n.auditLog,
          icon: Icons.history,
        ),
      ],
      menuExtraWidth: 140,
      menuMinWidth: 190,
      menuMaxWidth: 240,
      menuOffsetY: 6,
      triggerBorderRadius: BorderRadius.circular(AppRadii.r4),
      triggerHoverColor: Colors.white.withValues(alpha: AppAlphas.hover08),
      child: Container(
        height: buttonHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadii.r4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.settings, size: AppIconSizes.s14, color: Colors.white),
            SizedBox(width: AppSpacing.s6),
            Icon(
              Icons.keyboard_arrow_down,
              size: AppIconSizes.s14,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _NestedHeaderCell extends StatelessWidget {
  const _NestedHeaderCell(this.text, {required this.width});

  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return _TableBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: AppFontSizes.title13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ListCheckbox extends StatelessWidget {
  const _ListCheckbox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.r4),
        border: Border.all(color: AppColors.checkboxBorder),
      ),
    );
  }
}

class _TableBox extends StatelessWidget {
  const _TableBox({
    required this.width,
    required this.child,
    this.alignment = Alignment.centerLeft,
  });

  final double width;
  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Align(alignment: alignment, child: child),
    );
  }
}

String _formatDate(DateTime? date) {
  if (date == null || date.year <= 1) {
    return '-';
  }
  return DateFormat('dd/MM/yyyy').format(date);
}

String _formatMoney(Decimal amount) {
  final formatter = NumberFormat('#,##0.00');
  return formatter.format(double.tryParse(amount.toString()) ?? 0);
}

void _openServiceEdit(
  BuildContext context,
  String reservationId,
  ReservationServiceSummary service,
) {
  switch (service.type) {
    case ReservationServiceType.agent:
      context.go(
        '/reservations/create-agent?reservationId=$reservationId&serviceId=${service.id}',
      );
    case ReservationServiceType.general:
      context.go(
        '/reservations/create-general?reservationId=$reservationId&serviceId=${service.id}',
      );
    case ReservationServiceType.transportation:
      context.go(
        '/reservations/create-transportation?reservationId=$reservationId&serviceId=${service.id}',
      );
  }
}

Color _groupBannerColor(ReservationServiceType type) {
  switch (type) {
    case ReservationServiceType.agent:
      return const Color(0xFFF5FBF7);
    case ReservationServiceType.general:
      return const Color(0xFFF7F9FC);
    case ReservationServiceType.transportation:
      return const Color(0xFFF3F8FF);
  }
}

String _servicePrimaryValue(
  AppLocalizations l10n,
  ReservationServiceSummary service,
) {
  switch (service.type) {
    case ReservationServiceType.agent:
      final hotelName = service.agentDetails?.hotelName?.trim() ?? '';
      return hotelName.isEmpty ? l10n.agentDirect : hotelName;
    case ReservationServiceType.general:
      final name = service.generalDetails?.serviceName.trim() ?? '';
      return name.isEmpty
          ? l10n.generalService
          : l10n.generalServiceWithName(name);
    case ReservationServiceType.transportation:
      return l10n.transportationService;
  }
}

String _serviceGroupTitle(
  AppLocalizations l10n,
  ReservationServiceSummary service,
) {
  switch (service.type) {
    case ReservationServiceType.agent:
      final hotelName = service.agentDetails?.hotelName?.trim() ?? '';
      return hotelName.isEmpty ? l10n.hotelDirect : hotelName;
    case ReservationServiceType.general:
      return l10n.generalService;
    case ReservationServiceType.transportation:
      return l10n.transportationService;
  }
}

String _serviceProviderValue(
  AppLocalizations l10n,
  ReservationServiceSummary service,
) {
  switch (service.type) {
    case ReservationServiceType.agent:
      final supplierName = service.agentDetails?.supplierName?.trim() ?? '';
      return supplierName.isEmpty ? '-' : supplierName;
    case ReservationServiceType.general:
      return l10n.providerFallback;
    case ReservationServiceType.transportation:
      final supplierName =
          service.transportationDetails?.supplierName?.trim() ?? '';
      return supplierName.isEmpty ? l10n.providerFallback : supplierName;
  }
}

String _serviceDescriptionValue(
  AppLocalizations l10n,
  ReservationServiceSummary service,
) {
  switch (service.type) {
    case ReservationServiceType.agent:
      final agent = service.agentDetails;
      if (agent == null) {
        return '-';
      }
      final parts = <String>[
        if ((agent.selectedRoomType ?? '').trim().isNotEmpty)
          agent.selectedRoomType!.trim(),
        if ((agent.selectedMealPlan ?? '').trim().isNotEmpty)
          agent.selectedMealPlan!.trim(),
        if (agent.totalPax > 0) '${agent.totalPax} ${l10n.pax}',
      ];
      return parts.isEmpty ? '-' : parts.join(' • ');
    case ReservationServiceType.general:
      final description = service.generalDetails?.description.trim() ?? '';
      return description.isEmpty
          ? l10n.serviceWithNumber(service.displayNo)
          : description;
    case ReservationServiceType.transportation:
      final trips = service.transportationDetails?.trips;
      final firstTrip = trips == null || trips.isEmpty ? null : trips.first;
      if (firstTrip == null) {
        return l10n.tripWithNumber(service.displayNo);
      }
      final type = firstTrip.type.trim();
      final route = _routeLabel(
        firstTrip.fromDestination.trim(),
        firstTrip.toDestination.trim(),
      );
      if (type.isEmpty && route.isEmpty) {
        return l10n.tripWithNumber(service.displayNo);
      }
      if (type.isEmpty) {
        return route;
      }
      if (route.isEmpty) {
        return type;
      }
      return '$type • $route';
  }
}

String _transportationQuantityValue(ReservationServiceSummary service) {
  final trips = service.transportationDetails?.trips;
  if (trips == null || trips.isEmpty) {
    return '-';
  }
  //CALCULATIONS كمية خدمة المواصلات = مجموع quantity لكل الرحلات التابعة للخدمة.
  final total = trips.fold<int>(0, (sum, trip) => sum + trip.quantity);
  return total == 0 ? '-' : total.toString();
}

String _routeLabel(String from, String to) {
  if (from.isEmpty && to.isEmpty) {
    return '';
  }
  if (from.isEmpty) {
    return to;
  }
  if (to.isEmpty) {
    return from;
  }
  return '$from → $to';
}

IconData _serviceIcon(ReservationServiceType type) {
  switch (type) {
    case ReservationServiceType.agent:
      return Icons.hotel;
    case ReservationServiceType.general:
      return Icons.miscellaneous_services;
    case ReservationServiceType.transportation:
      return Icons.directions_bus;
  }
}

Color _serviceIconColor(ReservationServiceType type) {
  switch (type) {
    case ReservationServiceType.agent:
      return AppColors.actionGreen;
    case ReservationServiceType.general:
      return AppColors.textSecondary;
    case ReservationServiceType.transportation:
      return AppColors.primary;
  }
}
