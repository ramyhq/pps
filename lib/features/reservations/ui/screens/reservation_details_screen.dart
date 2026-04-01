import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pps/core/constants/app_colors.dart';
import 'package:pps/core/constants/app_strings.dart';
import 'package:pps/core/widgets/app_drop_menu_button.dart';
import 'package:pps/features/reservations/data/models/agent_reservation_draft.dart';
import 'package:pps/features/reservations/data/models/client.dart';
import 'package:pps/features/reservations/data/models/reservation_details.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/reservations/data/models/reservation_service.dart';
import 'package:pps/features/reservations/data/models/transportation_service_draft.dart';
import 'package:pps/features/reservations/provider/reservations_data_providers.dart';
import 'package:pps/features/reservations/ui/utils/reservation_details_calculations.dart';
import 'package:pps/features/reservations/ui/utils/reservation_details_pdf_generator.dart';

class ReservationDetailsScreen extends ConsumerWidget {
  const ReservationDetailsScreen({super.key, required this.reservationId});

  final String? reservationId;

  static const double _labelFontSize = AppFontSizes.label11;
  static const double _valueFontSize = AppFontSizes.body12;
  static const _dateFormat = 'dd/MM/yyyy';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = reservationId;
    if (id == null || id.trim().isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text(AppStrings.missingReservationId)),
      );
    }

    final detailsAsync = ref.watch(reservationDetailsProvider(id));

    return Scaffold(
      backgroundColor: AppColors.light,
      body: SelectionArea(
        child: detailsAsync.when(
          data: (details) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s12,
                AppSpacing.s16,
                AppSpacing.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToolbar(context, ref, id, details),
                  const SizedBox(height: AppSpacing.s14),
                  _buildMainCard(context, ref, details.order, details.services),
                ],
              ),
            );
          },
          error: (error, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s12,
                AppSpacing.s16,
                AppSpacing.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToolbar(context, ref, id, null),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    WidgetRef ref,
    String id,
    ReservationDetails? details,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.detailsTitle,
              style: TextStyle(
                fontSize: AppFontSizes.title20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.s4),
            const Row(
              children: [
                Text(
                  AppStrings.reservationsTitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppFontSizes.body12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                  child: Text(
                    '•',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  AppStrings.detailsTitle,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppFontSizes.body12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        //TODO: Hide fact_check until implemented.
        // SizedBox(
        //   width: AppHeights.button32,
        //   height: AppHeights.button32,
        //   child: Material(
        //     color: AppColors.info,
        //     borderRadius: BorderRadius.circular(AppRadii.r4),
        //     child: InkWell(
        //       onTap: () {},
        //       borderRadius: BorderRadius.circular(AppRadii.r4),
        //       child: const Center(
        //         child: Icon(
        //           Icons.fact_check_outlined,
        //           color: Colors.white,
        //           size: AppIconSizes.s18,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(width: AppSpacing.s8),
        AppDropMenuButton<_ReservationToolbarAction>(
          onSelected: (action) {
            () async {
              switch (action) {
                case _ReservationToolbarAction.print:
                  final payload = details;
                  if (payload == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(AppStrings.print)),
                    );
                    return;
                  }
                  try {
                    final bytes = await ReservationDetailsPdfGenerator.buildPdf(
                      payload,
                    );
                    await Printing.layoutPdf(onLayout: (format) async => bytes);
                  } catch (e) {
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                  return;
                case _ReservationToolbarAction.delete:
                  await _confirmDeleteReservationOrder(context, ref, id);
                  return;
              }
            }();
          },
          entries: const [
            AppDropMenuEntry.action(
              value: _ReservationToolbarAction.print,
              label: AppStrings.print,
              icon: Icons.print_outlined,
              isDanger: true,
            ),
            AppDropMenuEntry.action(
              value: _ReservationToolbarAction.delete,
              label: AppStrings.delete,
              icon: Icons.delete_outline,
              isDanger: true,
            ),
          ],
          child: Container(
            height: AppHeights.iconButton28,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppRadii.r4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.more_vert,
                  size: AppIconSizes.s14,
                  color: Colors.white,
                ),
                SizedBox(width: AppSpacing.s6),
                Text(
                  AppStrings.actions,
                  style: TextStyle(
                    fontSize: AppFontSizes.body12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                SizedBox(width: AppSpacing.s3),
                _TriangleDownIcon(color: Colors.white),
              ],
            ),
          ),
        ),
        /*
        PDF Preview button is temporarily hidden (will be re-enabled later for PDF layout tuning).
        DO NOT DELETE.

        const SizedBox(width: AppSpacing.s8),
        SizedBox(
          height: AppHeights.iconButton28,
          child: OutlinedButton.icon(
            onPressed: () =>
                context.go('/reservations/pdf-preview?reservationId=$id'),
            icon: const Icon(
              Icons.picture_as_pdf_outlined,
              size: AppIconSizes.s14,
            ),
            label: const Text(AppStrings.pdfPreview),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.r4),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s10,
                vertical: AppSpacing.s0,
              ),
              fixedSize: const Size.fromHeight(AppHeights.iconButton28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(
                fontSize: AppFontSizes.body12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        */
        const SizedBox(width: AppSpacing.s8),
        SizedBox(
          height: AppHeights.iconButton28,
          child: OutlinedButton.icon(
            onPressed: () => context.go('/reservations'),
            icon: const Icon(Icons.chevron_left, size: AppIconSizes.s14),
            label: const Text(AppStrings.back),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.r4),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s10,
                vertical: AppSpacing.s0,
              ),
              fixedSize: const Size.fromHeight(AppHeights.iconButton28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              textStyle: const TextStyle(
                fontSize: AppFontSizes.body12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(
    BuildContext context,
    WidgetRef ref,
    ReservationOrder order,
    List<ReservationServiceSummary> services,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.secondary, width: 1.2),
        borderRadius: BorderRadius.circular(AppRadii.r6),
      ),
      padding: const EdgeInsets.all(AppSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReservationHeaderRow(order),
          const SizedBox(height: AppSpacing.s10),
          _buildReservationMainInfoPanel(context, ref, order, services),
          const SizedBox(height: AppSpacing.s16),
          _buildReservationDetailsPanel(context, ref, order, services),
          const SizedBox(height: AppSpacing.s16),
          _buildTotalsRow(services),
          const SizedBox(height: AppSpacing.s12),
          _AddMoreForReservationSection(reservationId: order.id),
        ],
      ),
    );
  }

  Widget _buildReservationHeaderRow(ReservationOrder order) {
    final createdAtText = DateFormat(
      'dd/MM/yyyy hh:mm:ss a',
    ).format(order.createdAt);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: AppSpacing.s12,
            runSpacing: AppSpacing.s8,
            children: [
              _buildHeaderLabelValue(
                label: AppStrings.reservationIdLabel,
                value: '${order.reservationNo} ,',
              ),
              _buildHeaderLabelValue(
                label: AppStrings.creatorLabel,
                value: '- ,',
              ),
              // TODO(auth): Replace creator placeholder when authentication is implemented.
              _buildHeaderLabelValue(
                label: AppStrings.dateLabel,
                value: createdAtText,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderLabelValue({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: _labelFontSize,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(width: AppSpacing.s4),
        Text(
          value,
          style: const TextStyle(
            fontSize: _valueFontSize,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildReservationMainInfoPanel(
    BuildContext context,
    WidgetRef ref,
    ReservationOrder order,
    List<ReservationServiceSummary> services,
  ) {
    final optionDate = order.clientOptionDate == null
        ? '-'
        : DateFormat(_dateFormat).format(order.clientOptionDate!);
    final dateRange = _reservationDateRange(services);
    final fromDateText = dateRange.from == null
        ? '-'
        : DateFormat(_dateFormat).format(dateRange.from!);
    final toDateText = dateRange.to == null
        ? '-'
        : DateFormat(_dateFormat).format(dateRange.to!);

    return _DetailsAccordion(
      title: AppStrings.reservationMainInfoTitle,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () =>
                  _showEditReservationMainInfoDialog(context, ref, order),
              icon: const Icon(Icons.edit, color: AppColors.primary, size: 16),
              tooltip: AppStrings.editInfoTooltip,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop =
                  constraints.maxWidth >= AppBreakpoints.detailsDesktop;
              if (isDesktop) {
                const gap = AppSpacing.s12;
                final colWidth =
                    (constraints.maxWidth - (gap * 3)).clamp(
                      0.0,
                      double.infinity,
                    ) /
                    4;
                return Column(
                  children: [
                    const SizedBox(height: AppSpacing.s12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: AppSpacing.s12),

                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            AppStrings.client,
                            order.client.label,
                            icon: Icons.swap_horiz,
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            AppStrings.fromDate,
                            fromDateText,
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            AppStrings.toDate,
                            toDateText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: AppSpacing.s12),

                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            AppStrings.guestName,
                            order.guestName ?? '-',
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            AppStrings.clientOptionDate,
                            optionDate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                  ],
                );
              }

              double clampWidth(double desired) =>
                  desired > constraints.maxWidth
                  ? constraints.maxWidth
                  : desired;

              return Wrap(
                spacing: AppSpacing.s12,
                runSpacing: AppSpacing.s6,
                children: [
                  SizedBox(
                    width: clampWidth(
                      ReservationDetailsLayout.mainInfoClientWidth,
                    ),
                    child: _buildMainInfoItem(
                      AppStrings.client,
                      order.client.label,
                      icon: Icons.swap_horiz,
                    ),
                  ),
                  SizedBox(
                    width: clampWidth(
                      ReservationDetailsLayout.mainInfoFromWidth,
                    ),
                    child: _buildMainInfoItem(
                      AppStrings.fromDate,
                      fromDateText,
                    ),
                  ),
                  SizedBox(
                    width: clampWidth(ReservationDetailsLayout.mainInfoToWidth),
                    child: _buildMainInfoItem(AppStrings.toDate, toDateText),
                  ),
                  SizedBox(
                    width: clampWidth(
                      ReservationDetailsLayout.mainInfoGuestWidth,
                    ),
                    child: _buildMainInfoItem(
                      AppStrings.guestName,
                      order.guestName ?? '-',
                    ),
                  ),
                  SizedBox(
                    width: clampWidth(
                      ReservationDetailsLayout.mainInfoOptionDateWidth,
                    ),
                    child: _buildMainInfoItem(
                      AppStrings.clientOptionDate,
                      optionDate,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showEditReservationMainInfoDialog(
    BuildContext context,
    WidgetRef ref,
    ReservationOrder order,
  ) async {
    final repository = ref.read(reservationsRepositoryProvider);
    late final List<Client> clients;
    try {
      clients = await repository.listClients();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return;
    }
    if (!context.mounted) {
      return;
    }
    int selectedClientId = order.client.id;
    final guestNameController = TextEditingController(text: order.guestName);

    final format = DateFormat(_dateFormat);
    DateTime? optionDate = order.clientOptionDate;
    final optionDateController = TextEditingController(
      text: optionDate == null ? '' : format.format(optionDate),
    );

    bool isSaving = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickOptionDate() async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: optionDate ?? now,
                firstDate: DateTime(now.year - 10),
                lastDate: DateTime(now.year + 10),
              );
              if (picked == null) return;
              setState(() {
                optionDate = picked;
                optionDateController.text = format.format(picked);
              });
            }

            InputDecoration decoration(String label, {Widget? suffixIcon}) {
              return InputDecoration(
                labelText: label,
                isDense: true,
                contentPadding: AppInsets.inputContent,
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
                suffixIcon: suffixIcon,
              );
            }

            Future<void> save() async {
              if (isSaving) return;
              setState(() => isSaving = true);
              try {
                await repository.updateReservationMainInfo(
                  reservationId: order.id,
                  clientId: selectedClientId,
                  guestName: guestNameController.text.trim().isEmpty
                      ? null
                      : guestNameController.text.trim(),
                  guestNationality: order.guestNationality,
                  clientOptionDate: optionDate,
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                ref.invalidate(reservationDetailsProvider(order.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(AppStrings.saved)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
                setState(() => isSaving = false);
              }
            }

            final screenHeight = MediaQuery.of(dialogContext).size.height;
            return Dialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.r6),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ReservationDetailsLayout.editDialogMaxWidth,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.r6),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight:
                            (screenHeight *
                                    ReservationDetailsLayout
                                        .editDialogMaxHeightRatio)
                                .clamp(
                                  0,
                                  ReservationDetailsLayout.editDialogMinHeight,
                                ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
                            child: Row(
                              children: [
                                const Text(
                                  AppStrings.editInfoTitle,
                                  style: TextStyle(
                                    fontSize: AppFontSizes.title14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    height: 1.0,
                                  ),
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: isSaving
                                      ? null
                                      : () => Navigator.of(dialogContext).pop(),
                                  icon: const Icon(Icons.close, size: 18),
                                  constraints: const BoxConstraints.tightFor(
                                    width: AppHeights.iconButton28,
                                    height: AppHeights.iconButton28,
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const gap = AppSpacing.s14;
                                final maxWidth = constraints.maxWidth;
                                final clientWidth =
                                    maxWidth >= AppBreakpoints.dialogLg
                                    ? ReservationDetailsLayout.editClientWidthLg
                                    : maxWidth >= AppBreakpoints.dialogMd
                                    ? ReservationDetailsLayout.editClientWidthMd
                                    : maxWidth;
                                final guestWidth =
                                    maxWidth >= AppBreakpoints.dialogLg
                                    ? ReservationDetailsLayout.editGuestWidthLg
                                    : maxWidth >= AppBreakpoints.dialogMd
                                    ? ReservationDetailsLayout.editGuestWidthMd
                                    : maxWidth;
                                final dateWidth =
                                    maxWidth >= AppBreakpoints.dialogLg
                                    ? ReservationDetailsLayout.editDateWidthLg
                                    : maxWidth >= AppBreakpoints.dialogMd
                                    ? ReservationDetailsLayout.editDateWidthMd
                                    : maxWidth;

                                final isRow =
                                    maxWidth >=
                                    (clientWidth +
                                        guestWidth +
                                        dateWidth +
                                        (gap * 2));

                                final fieldClient = SizedBox(
                                  width: clientWidth,
                                  child: DropdownButtonFormField<int>(
                                    value: selectedClientId,
                                    items: clients
                                        .map(
                                          (c) => DropdownMenuItem<int>(
                                            value: c.id,
                                            child: Text(
                                              c.label,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )
                                        .toList(growable: false),
                                    onChanged: isSaving
                                        ? null
                                        : (v) => setState(() {
                                            selectedClientId =
                                                v ?? selectedClientId;
                                          }),
                                    decoration: decoration(AppStrings.client),
                                    isExpanded: true,
                                    isDense: true,
                                  ),
                                );

                                final fieldGuest = SizedBox(
                                  width: guestWidth,
                                  child: TextField(
                                    controller: guestNameController,
                                    decoration: decoration(
                                      AppStrings.guestName,
                                    ),
                                  ),
                                );

                                final fieldDate = SizedBox(
                                  width: dateWidth,
                                  child: TextField(
                                    controller: optionDateController,
                                    readOnly: true,
                                    onTap: isSaving ? null : pickOptionDate,
                                    decoration: decoration(
                                      AppStrings.clientOptionDate,
                                      suffixIcon: const Icon(
                                        Icons.calendar_today,
                                        size: AppIconSizes.s16,
                                      ),
                                    ),
                                  ),
                                );

                                if (isRow) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      fieldClient,
                                      const SizedBox(width: gap),
                                      fieldGuest,
                                      const SizedBox(width: gap),
                                      fieldDate,
                                    ],
                                  );
                                }

                                return Wrap(
                                  spacing: gap,
                                  runSpacing: AppSpacing.s10,
                                  children: [
                                    fieldClient,
                                    fieldGuest,
                                    fieldDate,
                                  ],
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Row(
                              children: [
                                const Spacer(),
                                OutlinedButton(
                                  onPressed: isSaving
                                      ? null
                                      : () => Navigator.of(dialogContext).pop(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: const BorderSide(
                                      color: AppColors.secondary,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s16,
                                      vertical: AppSpacing.s0,
                                    ),
                                    minimumSize: const Size(
                                      0,
                                      AppHeights.button32,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.r4,
                                      ),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: AppFontSizes.body12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  child: const Text(AppStrings.close),
                                ),
                                const SizedBox(width: AppSpacing.s10),
                                ElevatedButton(
                                  onPressed: isSaving ? null : save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s18,
                                      vertical: AppSpacing.s0,
                                    ),
                                    minimumSize: const Size(
                                      0,
                                      AppHeights.button32,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.r4,
                                      ),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: AppFontSizes.body12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          width: AppIconSizes.s14,
                                          height: AppIconSizes.s14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(AppStrings.save),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    guestNameController.dispose();
    optionDateController.dispose();
  }

  Widget _buildReservationDetailsPanel(
    BuildContext context,
    WidgetRef ref,
    ReservationOrder order,
    List<ReservationServiceSummary> services,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.secondary, width: 1.2),
        borderRadius: BorderRadius.circular(AppRadii.r6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: AppInsets.sectionHeader,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F8FA),
              border: Border(bottom: BorderSide(color: AppColors.secondary)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadii.r6),
                topRight: Radius.circular(AppRadii.r6),
              ),
            ),
            child: const Text(
              AppStrings.reservationDetailsTitle,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: AppFontSizes.body12,
                height: 1.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: services.isEmpty
                ? const Align(alignment: Alignment.centerLeft, child: Text('-'))
                : Column(
                    children: [
                      for (final service in services) ...[
                        _buildServiceAccordion(context, ref, order, service),
                        const SizedBox(height: AppSpacing.s8),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceAccordion(
    BuildContext context,
    WidgetRef ref,
    ReservationOrder order,
    ReservationServiceSummary service,
  ) {
    late final String title;
    final tag = '(#${service.displayNo})';

    late final Widget summary;
    late final Widget details;
    String? typePillText;

    switch (service.type) {
      case ReservationServiceType.transportation:
        final transportation = service.transportationDetails;
        title = _serviceTitle(service);
        summary = LayoutBuilder(
          builder: (context, constraints) {
            const gap = 12.0;
            final colWidth = (constraints.maxWidth - (gap * 3)) / 6;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  SizedBox(
                    width: 300,
                    child: _buildServiceInfoColumn(
                      AppStrings.vehicleProvider,
                      _valueOrDash(transportation?.supplierName),
                      icon: Icons.people,
                    ),
                  ),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: colWidth,
                    child: _buildServiceInfoColumn(
                      AppStrings.serviceRoute,
                      _transportationRouteLabel(transportation),
                    ),
                  ),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: colWidth,
                    child: _buildServiceInfoColumn(
                      AppStrings.totalSale,
                      _formatMoney(service.totalSale),
                    ),
                  ),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: colWidth,
                    child: _buildServiceInfoColumn(
                      AppStrings.totalCost,
                      _formatMoney(service.totalCost),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        details = _buildTransportationServiceBody(service);
      case ReservationServiceType.agent:
        final agent = service.agentDetails;
        title = _serviceTitle(service);
        typePillText = AppStrings.agentDirect;
        summary = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),

          child: LayoutBuilder(
            builder: (context, constraints) {
              const gap = 12.0;
              const minColWidth = 140.0;
              const maxColWidth = 220.0;
              final computed = (constraints.maxWidth - (gap * 5)) / 6;
              final colWidth = computed.clamp(minColWidth, maxColWidth);
              return Wrap(
                spacing: gap,
                runSpacing: 6,
                children: [
                  SizedBox(
                    width: colWidth,
                    child: _buildServiceInfoColumn(
                      AppStrings.arrivalDate,
                      _formatDateValue(agent?.arrivalDate),
                    ),
                  ),
                  SizedBox(
                    width: colWidth,
                    child: _buildServiceInfoColumn(
                      AppStrings.nights,
                      _agentNights(agent).toString(),
                    ),
                  ),
                  SizedBox(
                    width: colWidth,
                    child: _buildServiceInfoColumn(
                      AppStrings.departureDate,
                      _formatDateValue(agent?.departureDate),
                    ),
                  ),
                  SizedBox(
                    width: colWidth,
                    child: _buildServiceInfoColumn(
                      AppStrings.totalRn,
                      _agentTotalRn(agent).toString(),
                    ),
                  ),
                  SizedBox(
                    width: colWidth,
                    child: _buildServiceInfoColumn(
                      AppStrings.totalSale,
                      _formatMoney(service.totalSale),
                    ),
                  ),
                  SizedBox(
                    width: colWidth,
                    child: _buildServiceInfoColumn(
                      AppStrings.totalCost,
                      _formatMoney(service.totalCost),
                    ),
                  ),
                ],
              );
            },
          ),
        );
        details = _buildHotelDirectServiceBody(service, order);
      case ReservationServiceType.general:
        final general = service.generalDetails;
        title = _serviceTitle(service);
        summary = LayoutBuilder(
          builder: (context, constraints) {
            double w(double desired) =>
                desired > constraints.maxWidth ? constraints.maxWidth : desired;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  SizedBox(
                    width: w(260),
                    child: _buildServiceInfoColumn(
                      AppStrings.serviceName,
                      general?.serviceName.trim().isNotEmpty == true
                          ? general!.serviceName.trim()
                          : AppStrings.generalService,
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ),
                  SizedBox(
                    width: w(120),
                    child: _buildServiceInfoColumn(
                      AppStrings.quantity,
                      (general?.quantity ?? 1).toString(),
                    ),
                  ),
                  SizedBox(
                    width: w(160),
                    child: _buildServiceInfoColumn(
                      AppStrings.salePrice,
                      _formatMoney(general?.salePerItem ?? service.totalSale),
                    ),
                  ),
                  SizedBox(
                    width: w(160),
                    child: _buildServiceInfoColumn(
                      AppStrings.costPrice,
                      _formatMoney(general?.costPerItem ?? service.totalCost),
                    ),
                  ),
                  SizedBox(
                    width: w(160),
                    child: _buildServiceInfoColumn(
                      AppStrings.totalSale,
                      _formatMoney(service.totalSale),
                    ),
                  ),
                  SizedBox(
                    width: w(160),
                    child: _buildServiceInfoColumn(
                      AppStrings.totalCost,
                      _formatMoney(service.totalCost),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        details = _buildGeneralServiceBody(service, order);
    }

    return _ServiceAccordionCard(
      title: title,
      tag: tag,
      icon: _serviceIcon(service.type),
      typePillText: typePillText,
      summary: summary,
      details: details,
      initiallyExpanded: true,
      onEdit: () {
        final reservationId = order.id;
        final serviceId = service.id;
        switch (service.type) {
          case ReservationServiceType.transportation:
            context.go(
              '/reservations/create-transportation?reservationId=$reservationId&serviceId=$serviceId',
            );
          case ReservationServiceType.agent:
            context.go(
              '/reservations/create-agent?reservationId=$reservationId&serviceId=$serviceId',
            );
          case ReservationServiceType.general:
            context.go(
              '/reservations/create-general?reservationId=$reservationId&serviceId=$serviceId',
            );
        }
      },
      onDelete: () => _confirmDeleteService(context, ref, order.id, service),
    );
  }

  Future<void> _confirmDeleteService(
    BuildContext context,
    WidgetRef ref,
    String reservationId,
    ReservationServiceSummary service,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.deleteReservationTitle),
          content: const Text(AppStrings.deleteServiceMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(reservationsRepositoryProvider)
          .deleteReservationService(serviceId: service.id);
      ref.invalidate(reservationDetailsProvider(reservationId));
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text(AppStrings.deleted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Widget _buildHotelDirectServiceBody(
    ReservationServiceSummary service,
    ReservationOrder order,
  ) {
    final agent = service.agentDetails;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHotelReservationsTable(service),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(color: AppColors.border, height: 1, thickness: 1),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            double w(double desired) =>
                desired > constraints.maxWidth ? constraints.maxWidth : desired;
            return Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                SizedBox(
                  width: w(120),
                  child: _buildServiceInfoColumn(
                    AppStrings.pax,
                    agent == null ? '-' : agent.totalPax.toString(),
                  ),
                ),
                SizedBox(
                  width: w(260),
                  child: _buildServiceInfoColumn(
                    AppStrings.supplier,
                    _valueOrDash(agent?.supplierName),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            double w(double desired) =>
                desired > constraints.maxWidth ? constraints.maxWidth : desired;
            return Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                SizedBox(
                  width: w(260),
                  child: _buildServiceInfoColumn(
                    AppStrings.hotel,
                    _valueOrDash(agent?.hotelName),
                  ),
                ),
                SizedBox(
                  width: w(200),
                  child: _buildServiceInfoColumn(
                    AppStrings.clientOptionDate,
                    _formatDateValue(order.clientOptionDate),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildGeneralServiceBody(
    ReservationServiceSummary service,
    ReservationOrder order,
  ) {
    final general = service.generalDetails;
    final format = DateFormat(_dateFormat);
    final dateOfService = general?.dateOfService;
    final endDate = general?.endDate;
    final dateOfServiceText = dateOfService == null
        ? '-'
        : format.format(dateOfService);
    final endDateText = endDate == null ? '-' : format.format(endDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(color: AppColors.border, height: 1, thickness: 1),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            double w(double desired) =>
                desired > constraints.maxWidth ? constraints.maxWidth : desired;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  SizedBox(
                    width: w(200),
                    child: _buildServiceInfoColumn(
                      AppStrings.dateOfService,
                      dateOfServiceText,
                    ),
                  ),
                  SizedBox(
                    width: w(200),
                    child: _buildServiceInfoColumn(
                      AppStrings.endDate,
                      endDateText,
                    ),
                  ),
                  SizedBox(
                    width: w(260),
                    child: _buildServiceInfoColumn(
                      AppStrings.termsAndConditions,
                      general?.termsAndConditions?.trim().isNotEmpty == true
                          ? general!.termsAndConditions!.trim()
                          : '-',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        const SizedBox(width: AppSpacing.s6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: _buildServiceInfoColumn(
            AppStrings.serviceDescription,
            general?.description.trim().isNotEmpty == true
                ? general!.description.trim()
                : '-',
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          child: _buildServiceInfoColumn(
            AppStrings.providerRemarks,
            general?.providerRemarks?.trim().isNotEmpty == true
                ? general!.providerRemarks!.trim()
                : '-',
          ),
        ),
      ],
    );
  }

  Widget _buildTransportationServiceBody(ReservationServiceSummary service) {
    final transportation = service.transportationDetails;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Divider(color: AppColors.border, height: 1, thickness: 1),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            double w(double desired) =>
                desired > constraints.maxWidth ? constraints.maxWidth : desired;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),

              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  SizedBox(
                    width: w(260),
                    child: _buildServiceInfoColumn(
                      AppStrings.termsAndConditions,
                      _valueOrDash(transportation?.termsAndConditions),
                    ),
                  ),
                  SizedBox(
                    width: w(200),
                    child: _buildServiceInfoColumn(
                      AppStrings.providerOptionDate,
                      _formatDateValue(transportation?.providerOptionDate),
                    ),
                  ),
                  SizedBox(
                    width: w(200),
                    child: _buildServiceInfoColumn(
                      AppStrings.transactionsNotes,
                      _valueOrDash(transportation?.transactionNotes),
                    ),
                  ),

                  SizedBox(
                    width: w(200),
                    child: _buildServiceInfoColumn(
                      AppStrings.providerRemarks,
                      _valueOrDash(transportation?.providerRemarks),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 12),
        const Text(
          AppStrings.tripsDetails,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        _buildTripAccordion(service),
      ],
    );
  }

  Widget _buildHotelReservationsTable(ReservationServiceSummary service) {
    String roomRateTextFor(AgentReservationDraft? agent) {
      final rates = agent?.roomRates ?? const <AgentReservationRoomRate>[];
      if (rates.isEmpty) {
        return '-';
      }
      final raw = rates.first.saleRoom.trim();
      if (raw.isEmpty) {
        return '-';
      }
      final normalized = raw.replaceAll(',', '');
      final parsed = Decimal.tryParse(normalized);
      return parsed == null ? raw : _formatMoney(parsed);
    }

    final headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondary.withValues(alpha: 0.95),
      height: 1.0,
    );
    const cellStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
      height: 1.0,
    );
    const footerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.0,
    );

    final totalSaleText = _formatMoney(service.totalSale);
    final totalCostText = _formatMoney(service.totalCost);
    final agent = service.agentDetails;
    final roomRateText = roomRateTextFor(agent);
    final summaries =
        agent?.roomsSummary ?? const <AgentReservationRoomSummary>[];
    final totalRooms = summaries.fold<int>(
      0,
      (sum, room) => sum + room.numberOfRooms,
    );
    final totalRn = summaries.fold<int>(0, (sum, room) => sum + room.totalRn);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary, width: 1.2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 140 + (120 * 4) + (140 * 2) + 90,
            ),
            child: Column(
              children: [
                _buildTableRow(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.06),
                  bottomBorder: const BorderSide(color: AppColors.primary),
                  textStyle: headerStyle,
                  cells: const [
                    _TableCellData(text: AppStrings.roomType, width: 140),
                    _TableCellData(
                      text: AppStrings.mealPlan,
                      width: 120,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: AppStrings.noOfRooms,
                      width: 120,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: AppStrings.totalRn,
                      width: 120,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: AppStrings.roomRate,
                      width: 120,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: AppStrings.totalSale,
                      width: 140,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: AppStrings.totalCost,
                      width: 140,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: AppStrings.actions,
                      width: 90,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                if (summaries.isEmpty)
                  _buildTableRow(
                    backgroundColor: Colors.white,
                    bottomBorder: const BorderSide(color: AppColors.border),
                    textStyle: cellStyle,
                    cells: [
                      const _TableCellData(text: '-', width: 140),
                      const _TableCellData(
                        text: '-',
                        width: 120,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                      ),
                      const _TableCellData(
                        text: '0',
                        width: 120,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                      ),
                      const _TableCellData(
                        text: '0',
                        width: 120,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                      ),
                      _TableCellData(
                        text: roomRateText,
                        width: 120,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                      ),
                      _TableCellData(
                        text: totalSaleText,
                        width: 140,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                      ),
                      _TableCellData(
                        text: totalCostText,
                        width: 140,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                      ),
                      const _TableCellData(
                        icon: Icons.visibility,
                        width: 90,
                        alignment: Alignment.center,
                      ),
                    ],
                  )
                else
                  for (final room in summaries)
                    _buildTableRow(
                      backgroundColor: Colors.white,
                      bottomBorder: const BorderSide(color: AppColors.border),
                      textStyle: cellStyle,
                      cells: [
                        _TableCellData(text: room.roomType, width: 140),
                        _TableCellData(
                          text: room.mealPlan,
                          width: 120,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                        ),
                        _TableCellData(
                          text: room.numberOfRooms.toString(),
                          width: 120,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                        ),
                        _TableCellData(
                          text: room.totalRn.toString(),
                          width: 120,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                        ),
                        _TableCellData(
                          text: roomRateText,
                          width: 120,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                        ),
                        _TableCellData(
                          text: _formatMoney(room.totalSale),
                          width: 140,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                        ),
                        _TableCellData(
                          text: _formatMoney(room.totalCost),
                          width: 140,
                          alignment: Alignment.center,
                          textAlign: TextAlign.center,
                        ),
                        const _TableCellData(
                          icon: Icons.visibility,
                          width: 90,
                          alignment: Alignment.center,
                        ),
                      ],
                    ),
                _buildTableRow(
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.7),
                  bottomBorder: BorderSide.none,
                  textStyle: footerStyle,
                  cells: [
                    const _TableCellData(text: AppStrings.total, width: 140),
                    const _TableCellData(
                      text: '',
                      width: 120,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: totalRooms.toString(),
                      width: 120,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: totalRn.toString(),
                      width: 120,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    const _TableCellData(
                      text: '',
                      width: 120,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: totalSaleText,
                      width: 140,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    _TableCellData(
                      text: totalCostText,
                      width: 140,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                    const _TableCellData(
                      text: '',
                      width: 90,
                      alignment: Alignment.center,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableRow({
    required List<_TableCellData> cells,
    required Color backgroundColor,
    required BorderSide bottomBorder,
    required TextStyle textStyle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: bottomBorder == BorderSide.none
              ? BorderSide.none
              : BorderSide(
                  color: bottomBorder.color,
                  width: bottomBorder.width,
                ),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            Container(
              width: cells[i].width,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  right: i == cells.length - 1
                      ? BorderSide.none
                      : const BorderSide(color: AppColors.border),
                ),
              ),
              child: cells[i].icon == null
                  ? Align(
                      alignment: cells[i].alignment,
                      child: Text(
                        cells[i].text ?? '',
                        style: textStyle,
                        overflow: TextOverflow.ellipsis,
                        textAlign: cells[i].textAlign,
                      ),
                    )
                  : Align(
                      alignment: cells[i].alignment,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          cells[i].icon,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildTripAccordion(ReservationServiceSummary service) {
    final trips = service.transportationDetails?.trips ?? const [];
    if (trips.isEmpty) {
      return const _TripDetailsAccordionCard(
        tripTag: '(#T-1)',
        from: '-',
        to: '-',
        dateTimeText: '-',
        vehicleText: '-',
        qtyText: '-',
        paxText: '-',
        totalSale: '0.00',
        totalCost: '0.00',
        notes: '-',
      );
    }
    return Column(
      children: [
        for (var index = 0; index < trips.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          _TripDetailsAccordionCard(
            tripTag: '(#T-${index + 1})',
            from: _valueOrDash(trips[index].fromDestination),
            to: _valueOrDash(trips[index].toDestination),
            dateTimeText: _tripDateTimeLabel(trips[index]),
            vehicleText: _valueOrDash(trips[index].vehicle),
            qtyText: trips[index].quantity.toString(),
            paxText: trips[index].pax.toString(),
            totalSale: _formatMoney(
              //CALCULATIONS إجمالي بيع الرحلة = سعر البيع لكل مشوار × كمية هذه الرحلة.
              trips[index].salePerItem * Decimal.fromInt(trips[index].quantity),
            ),
            totalCost: _formatMoney(
              //CALCULATIONS إجمالي تكلفة الرحلة = سعر التكلفة لكل مشوار × كمية هذه الرحلة.
              trips[index].costPerItem * Decimal.fromInt(trips[index].quantity),
            ),
            notes: _valueOrDash(trips[index].notes),
          ),
        ],
      ],
    );
  }

  Widget _buildServiceInfoColumn(
    String label,
    String value, {
    IconData? icon,
    IconData? actionIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: _labelFontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: _valueFontSize,
                  fontWeight: FontWeight.w500,
                  color: value == '-'
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ),
            if (actionIcon != null) ...[
              const SizedBox(width: 6),
              Icon(actionIcon, size: 14, color: AppColors.primary),
            ],
          ],
        ),
      ],
    );
  }

  IconData _serviceIcon(ReservationServiceType type) {
    switch (type) {
      case ReservationServiceType.agent:
        return Icons.hotel;
      case ReservationServiceType.general:
        return Icons.shopping_cart_outlined;
      case ReservationServiceType.transportation:
        return Icons.directions_bus;
    }
  }

  String _serviceTitle(ReservationServiceSummary service) {
    switch (service.type) {
      case ReservationServiceType.agent:
        final hotelName = service.agentDetails?.hotelName?.trim() ?? '';
        final city = service.agentDetails?.hotelCity?.trim() ?? '';
        return hotelName.isEmpty
            ? AppStrings.agentDirect
            : city.isEmpty
            ? '${service.serviceNo} - $hotelName'
            : '${service.serviceNo} - $hotelName - $city';
      case ReservationServiceType.general:
        final name = service.generalDetails?.serviceName.trim() ?? '';
        return name.isEmpty
            ? AppStrings.generalService
            : '${AppStrings.generalServicePrefix}$name';
      case ReservationServiceType.transportation:
        final route = _transportationRouteLabel(service.transportationDetails);
        return route == '-'
            ? AppStrings.transportationService
            : '${AppStrings.transportationPrefix}$route';
    }
  }

  int _agentNights(AgentReservationDraft? agent) {
    if (agent == null) {
      return 0;
    }
    //CALCULATIONS عدد الليالي في التفاصيل = تاريخ المغادرة - تاريخ الوصول.
    final diff = agent.departureDate.difference(agent.arrivalDate).inDays;
    return diff < 0 ? 0 : diff;
  }

  int _agentTotalRn(AgentReservationDraft? agent) {
    if (agent == null) {
      return 0;
    }
    //CALCULATIONS إجمالي RN في التفاصيل = مجموع totalRn لكل صف غرفة محفوظ في الخدمة.
    return agent.roomsSummary.fold<int>(0, (sum, room) => sum + room.totalRn);
  }

  String _formatDateValue(DateTime? value) {
    if (value == null) {
      return '-';
    }
    return DateFormat(_dateFormat).format(value);
  }

  String _tripDateTimeLabel(TransportationTripDraft trip) {
    final dateText = _formatDateValue(trip.date);
    final timeText = trip.time.trim();
    if (timeText.isEmpty) {
      return dateText;
    }
    return '$dateText $timeText';
  }

  String _transportationRouteLabel(TransportationServiceDraft? transportation) {
    if (transportation == null) {
      return '-';
    }
    final serviceRoute = transportation.serviceRoute?.trim() ?? '';
    if (serviceRoute.isNotEmpty) {
      return serviceRoute;
    }
    if (transportation.trips.isEmpty) {
      return '-';
    }
    final firstTrip = transportation.trips.first;
    final from = firstTrip.fromDestination.trim();
    final to = firstTrip.toDestination.trim();
    if (from.isEmpty && to.isEmpty) {
      return '-';
    }
    if (from.isEmpty) {
      return to;
    }
    if (to.isEmpty) {
      return from;
    }
    return '$from → $to';
  }

  String _valueOrDash(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '-' : trimmed;
  }

  Widget _buildTotalsRow(List<ReservationServiceSummary> services) {
    final totals = ReservationDetailsCalculations.totals(services);

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.s12),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s12,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.9),
        border: Border.all(color: AppColors.secondary, width: 1.2),
        borderRadius: BorderRadius.circular(AppRadii.r6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 140,
            child: _buildServiceInfoColumn(
              AppStrings.totalSale,
              _formatMoney(totals.totalSale),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: _buildServiceInfoColumn(
              AppStrings.totalCost,
              _formatMoney(totals.totalCost),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(Decimal value) {
    final text = value.toString();
    final isNegative = text.startsWith('-');
    final unsigned = isNegative ? text.substring(1) : text;
    final parts = unsigned.split('.');

    final intPart = parts.isEmpty ? '0' : parts[0];
    final fracPart = parts.length > 1 ? parts[1] : '';

    final groupedInt = intPart.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );

    final twoDigits = fracPart.isEmpty
        ? '00'
        : (fracPart.length == 1 ? '${fracPart}0' : fracPart.substring(0, 2));

    return '${isNegative ? '-' : ''}$groupedInt.$twoDigits';
  }

  Widget _buildMainInfoItem(
    String label,
    String value, {
    IconData? icon,
    bool isIcon = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: _labelFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.0,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 12, color: AppColors.success),
            ],
          ],
        ),
        const SizedBox(height: 3),
        if (isIcon)
          const Icon(Icons.open_in_new, size: 12, color: AppColors.textPrimary)
        else
          Text(
            value,
            style: TextStyle(
              fontSize: _valueFontSize,
              fontWeight: FontWeight.w500,
              color: value == '-'
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              height: 1.1,
            ),
          ),
      ],
    );
  }

  Future<void> _confirmDeleteReservationOrder(
    BuildContext context,
    WidgetRef ref,
    String reservationId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.deleteReservationTitle),
          content: const Text(AppStrings.deleteReservationMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(reservationsRepositoryProvider)
          .deleteReservationOrder(reservationId: reservationId);
      ref.invalidate(reservationOrdersProvider);
      if (context.mounted) {
        context.go('/reservations');
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  _DateRange _reservationDateRange(List<ReservationServiceSummary> services) {
    DateTime? min;
    DateTime? max;

    void consider(DateTime? value) {
      if (value == null) return;
      if (min == null || value.isBefore(min!)) {
        min = value;
      }
      if (max == null || value.isAfter(max!)) {
        max = value;
      }
    }

    void considerRange(DateTime? from, DateTime? to) {
      consider(from);
      consider(to);
    }

    for (final service in services) {
      switch (service.type) {
        case ReservationServiceType.agent:
          final details = service.agentDetails;
          considerRange(details?.arrivalDate, details?.departureDate);
          continue;
        case ReservationServiceType.general:
          final details = service.generalDetails;
          considerRange(details?.dateOfService, details?.endDate);
          continue;
        case ReservationServiceType.transportation:
          final trips = service.transportationDetails?.trips ?? const [];
          for (final trip in trips) {
            consider(trip.date);
          }
          continue;
      }
    }

    return _DateRange(from: min, to: max);
  }
}

class _DateRange {
  const _DateRange({required this.from, required this.to});

  final DateTime? from;
  final DateTime? to;
}

class _AddMoreForReservationSection extends StatelessWidget {
  const _AddMoreForReservationSection({required this.reservationId});

  final String reservationId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.25),
          child: Text(
            AppStrings.addMoreForYourReservation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 43.5859),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16.25,
              runSpacing: 8,
              children: [
                _AddMoreDropdown(
                  width: 85.8359,
                  label: AppStrings.hotels,
                  icon: const FaIcon(
                    FontAwesomeIcons.hotel,
                    size: 17.7812,
                    color: AppColors.primary,
                  ),
                  items: [
                    _AddMoreMenuItem(
                      label: AppStrings.agentDirectReservation,
                      onTap: () {
                        context.go(
                          '/reservations/create-agent?reservationId=$reservationId',
                        );
                      },
                    ),
                  ],
                ),
                _AddMoreDropdown(
                  width: 103.508,
                  label: AppStrings.services,
                  icon: const FaIcon(
                    FontAwesomeIcons.cartShopping,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  items: [
                    _AddMoreMenuItem(
                      label: AppStrings.generalService,
                      onTap: () {
                        context.go(
                          '/reservations/create-general?reservationId=$reservationId',
                        );
                      },
                    ),
                    _AddMoreMenuItem(
                      label: AppStrings.transportation,
                      onTap: () {
                        context.go(
                          '/reservations/create-transportation?reservationId=$reservationId',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AddMoreMenuItem {
  const _AddMoreMenuItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}

class _AddMoreDropdown extends StatefulWidget {
  const _AddMoreDropdown({
    required this.width,
    required this.label,
    required this.icon,
    required this.items,
  });

  final double width;
  final String label;
  final Widget icon;
  final List<_AddMoreMenuItem> items;

  @override
  State<_AddMoreDropdown> createState() => _AddMoreDropdownState();
}

class _AddMoreDropdownState extends State<_AddMoreDropdown> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: 44,
      child: AppDropMenuButton<_AddMoreMenuItem>(
        menuExtraWidth: 110,
        menuMinWidth: 160,
        menuMaxWidth: 220,
        menuOffsetY: 2,
        triggerBorderRadius: BorderRadius.circular(AppRadii.r6),
        triggerHoverColor: AppColors.border.withValues(alpha: 0.20),
        onSelected: (item) => item.onTap(),
        entries: [
          for (final item in widget.items)
            AppDropMenuEntry.action(value: item, label: item.label),
        ],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: widget.icon),
            const SizedBox(width: 5),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 14.3,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
            const SizedBox(width: 3.6465),
            const Padding(
              padding: EdgeInsets.only(top: 3.6465),
              child: _TriangleDownIcon(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TriangleDownIcon extends StatelessWidget {
  const _TriangleDownIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(7, 4),
      painter: _TriangleDownPainter(color),
    );
  }
}

class _TriangleDownPainter extends CustomPainter {
  _TriangleDownPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TriangleDownPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

enum _ReservationToolbarAction { print, delete }

enum _ServiceAction { print, attachments, delete }

class _TableCellData {
  const _TableCellData({
    this.text,
    this.icon,
    required this.width,
    this.alignment = Alignment.centerLeft,
    this.textAlign = TextAlign.start,
  });

  final String? text;
  final IconData? icon;
  final double width;
  final Alignment alignment;
  final TextAlign textAlign;
}

class _DetailsAccordion extends StatefulWidget {
  const _DetailsAccordion({
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  @override
  State<_DetailsAccordion> createState() => _DetailsAccordionState();
}

class _DetailsAccordionState extends State<_DetailsAccordion>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.r6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.secondary, width: 1.2),
          borderRadius: BorderRadius.circular(AppRadii.r6),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.white,
              child: InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  padding: AppInsets.accordionHeader,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F8FA),

                    border: Border(
                      bottom: BorderSide(color: AppColors.secondary),
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: _isExpanded ? 0 : -0.25,
                        duration: AppDurations.accordion,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: AppIconSizes.s14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSizes.title13,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: AppDurations.accordion,
              tween: Tween<double>(
                begin: _isExpanded ? 1 : 0,
                end: _isExpanded ? 1 : 0,
              ),
              child: Padding(
                padding: AppInsets.accordionBody,
                child: widget.child,
              ),
              builder: (context, value, child) {
                return ClipRect(
                  child: Align(heightFactor: value, child: child),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceAccordionCard extends StatefulWidget {
  const _ServiceAccordionCard({
    required this.title,
    required this.tag,
    required this.icon,
    this.typePillText,
    required this.summary,
    required this.details,
    this.initiallyExpanded = true,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String tag;
  final IconData icon;
  final String? typePillText;
  final Widget summary;
  final Widget details;
  final bool initiallyExpanded;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_ServiceAccordionCard> createState() => _ServiceAccordionCardState();
}

class _ServiceAccordionCardState extends State<_ServiceAccordionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.r6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.secondary, width: 1.2),
          borderRadius: BorderRadius.circular(AppRadii.r6),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.white,
              child: InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,

                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8,
                    vertical: AppSpacing.s4,
                  ),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: _isExpanded ? 0 : -0.25,
                        duration: AppDurations.accordion,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: AppIconSizes.s14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Icon(
                        widget.icon,
                        size: AppIconSizes.s16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSizes.title13,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        widget.tag,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppFontSizes.label11,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                        ),
                      ),
                      if (widget.typePillText != null) ...[
                        const SizedBox(width: AppSpacing.s8),
                        Container(
                          height: AppHeights.chip16,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(
                              alpha: AppAlphas.surface15,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.r3),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.typePillText!,
                            style: const TextStyle(
                              color: AppColors.info,
                              fontSize: AppFontSizes.badge10,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        onPressed: widget.onEdit,
                        icon: const Icon(
                          Icons.open_in_new,
                          size: AppIconSizes.s14,
                        ),
                        color: AppColors.primary,
                        constraints: const BoxConstraints.tightFor(
                          width: AppHeights.iconButton24,
                          height: AppHeights.iconButton24,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        tooltip: AppStrings.edit,
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      AppDropMenuButton<_ServiceAction>(
                        menuExtraWidth:
                            ReservationDetailsLayout.actionsMenuExtraWidth,
                        menuMinWidth:
                            ReservationDetailsLayout.actionsMenuMinWidth,
                        menuMaxWidth:
                            ReservationDetailsLayout.actionsMenuMaxWidth,
                        menuOffsetY: AppSpacing.s6,
                        triggerBorderRadius: BorderRadius.circular(AppRadii.r6),
                        triggerHoverColor: Colors.white.withValues(
                          alpha: AppAlphas.hover08,
                        ),
                        entries: const [
                          AppDropMenuEntry.action(
                            value: _ServiceAction.print,
                            label: AppStrings.print,
                            icon: Icons.print_outlined,
                            isDanger: true,
                          ),
                          AppDropMenuEntry.divider(),
                          AppDropMenuEntry.action(
                            value: _ServiceAction.delete,
                            label: AppStrings.delete,
                            icon: Icons.delete_outline,
                            isDanger: true,
                          ),
                        ],
                        onSelected: (selected) {
                          switch (selected) {
                            case _ServiceAction.delete:
                              widget.onDelete();
                              return;
                            case _ServiceAction.print:
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text(AppStrings.print)),
                              );
                              return;
                            case _ServiceAction.attachments:
                              return;
                          }
                        },
                        child: Container(
                          height: AppHeights.iconButton24,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s8,
                            vertical: AppSpacing.s0,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadii.r6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.more_vert,
                                size: AppIconSizes.s12,
                                color: Colors.white,
                              ),
                              SizedBox(width: AppSpacing.s5),
                              Text(
                                AppStrings.actions,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: AppFontSizes.label11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                              ),
                              SizedBox(width: AppSpacing.s4),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: AppIconSizes.s13,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
              duration: AppDurations.accordion,
              tween: Tween<double>(
                begin: _isExpanded ? 1 : 0,
                end: _isExpanded ? 1 : 0,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.s8,
                  AppSpacing.s4,
                  AppSpacing.s8,
                  AppSpacing.s8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.summary,
                    const SizedBox(height: AppSpacing.s8),
                    widget.details,
                  ],
                ),
              ),
              builder: (context, value, child) {
                return ClipRect(
                  child: Align(heightFactor: value, child: child),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TripDetailsAccordionCard extends StatefulWidget {
  const _TripDetailsAccordionCard({
    required this.tripTag,
    required this.from,
    required this.to,
    required this.dateTimeText,
    required this.vehicleText,
    required this.qtyText,
    required this.paxText,
    required this.totalSale,
    required this.totalCost,
    required this.notes,
  });

  final String tripTag;
  final String from;
  final String to;
  final String dateTimeText;
  final String vehicleText;
  final String qtyText;
  final String paxText;
  final String totalSale;
  final String totalCost;
  final String notes;

  @override
  State<_TripDetailsAccordionCard> createState() =>
      _TripDetailsAccordionCardState();
}

class _TripDetailsAccordionCardState extends State<_TripDetailsAccordionCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.r6),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 244, 248, 251),
          border: Border.all(color: AppColors.secondary, width: 1.2),
          borderRadius: BorderRadius.circular(AppRadii.r6),
        ),
        child: Column(
          children: [
            Material(
              color: const Color.fromARGB(255, 244, 248, 251),

              child: InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,

                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: AppInsets.accordionHeader,
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: _isExpanded ? 0 : -0.25,
                        duration: AppDurations.accordion,
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          size: AppIconSizes.s16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s4),
                      const Icon(
                        Icons.route,
                        size: AppIconSizes.s18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        widget.tripTag,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.from,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.to,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                      const Spacer(),
                      //TODO: Hide Operation Info until implemented.
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(Icons.badge, size: 14),
                      //   color: AppColors.primary,
                      //   constraints: const BoxConstraints.tightFor(
                      //     width: 24,
                      //     height: 24,
                      //   ),
                      //   padding: EdgeInsets.zero,
                      //   visualDensity: VisualDensity.compact,
                      //   tooltip: 'Operation Info',
                      // ),
                      const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 120),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 4,
                      ),
                      child: Wrap(
                        spacing: 52,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _TripMetaItem(
                            icon: Icons.calendar_today_outlined,
                            text: widget.dateTimeText,
                          ),
                          _TripMetaItem(
                            icon: Icons.directions_bus,
                            text: widget.vehicleText,
                          ),
                          _TripQtyItem(qty: widget.qtyText),
                          _TripMetaItem(
                            icon: Icons.people,
                            text: widget.paxText,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 0,
                      ),

                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const gap = 12.0;
                          const fixed = 130.0;
                          final remainingRaw =
                              constraints.maxWidth - (fixed * 2) - (gap * 2);
                          final remaining = remainingRaw >= 150
                              ? remainingRaw
                              : constraints.maxWidth;
                          return Wrap(
                            spacing: gap,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            children: [
                              SizedBox(
                                width: fixed,
                                child: _TripLabelValue(
                                  label: AppStrings.totalSale,
                                  value: widget.totalSale,
                                ),
                              ),
                              SizedBox(
                                width: fixed,
                                child: _TripLabelValue(
                                  label: AppStrings.totalCost,
                                  value: widget.totalCost,
                                ),
                              ),
                              SizedBox(
                                width: remaining,
                                child: _TripLabelValue(
                                  label: AppStrings.tripNotes,
                                  value: widget.notes,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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
}

class _TripMetaItem extends StatelessWidget {
  const _TripMetaItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class ReservationDetailsPdfPreviewScreen extends ConsumerWidget {
  const ReservationDetailsPdfPreviewScreen({
    super.key,
    required this.reservationId,
  });

  final String? reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = reservationId;
    if (id == null || id.trim().isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text(AppStrings.missingReservationId)),
      );
    }

    final detailsAsync = ref.watch(reservationDetailsProvider(id));

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: AppColors.light,
        elevation: 0,
        leading: IconButton(
          onPressed: () =>
              context.go('/reservations/details?reservationId=$id'),
          icon: const Icon(Icons.chevron_left),
        ),
        title: const Text(AppStrings.pdfPreview),
      ),
      body: detailsAsync.when(
        data: (details) {
          return PdfPreview(
            key: UniqueKey(),
            initialPageFormat: PdfPageFormat.a4,
            canChangeOrientation: false,
            canChangePageFormat: false,
            build: (format) => ReservationDetailsPdfGenerator.buildPdf(details),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(e.toString())),
      ),
    );
  }
}

class _TripQtyItem extends StatelessWidget {
  const _TripQtyItem({required this.qty});

  final String qty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          AppStrings.qty,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          qty,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _TripLabelValue extends StatelessWidget {
  const _TripLabelValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: ReservationDetailsScreen._labelFontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: ReservationDetailsScreen._valueFontSize,
            fontWeight: FontWeight.w500,
            color: value == '-'
                ? AppColors.textSecondary
                : AppColors.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
