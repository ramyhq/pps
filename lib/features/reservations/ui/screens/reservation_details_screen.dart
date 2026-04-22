import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pps/core/constants/app_colors.dart';
import 'package:pps/core/constants/app_strings.dart';
import 'package:pps/core/widgets/app_dialog.dart';
import 'package:pps/core/widgets/app_drop_menu_button.dart';
import 'package:pps/core/widgets/custom_form_fields.dart';
import 'package:pps/features/reservations/data/models/agent_reservation_draft.dart';
import 'package:pps/features/reservations/data/models/client.dart';
import 'package:pps/features/reservations/data/models/reservation_details.dart';
import 'package:pps/features/reservations/data/models/reservation_order.dart';
import 'package:pps/features/reservations/data/models/reservation_service.dart';
import 'package:pps/features/reservations/data/models/transportation_service_draft.dart';
import 'package:pps/features/reservations/provider/reservations_data_providers.dart';
import 'package:pps/features/reservations/ui/utils/reservation_details_calculations.dart';
import 'package:pps/features/reservations/ui/utils/reservation_details_pdf_generator.dart';
import 'package:pps/features/reservations/ui/utils/reservation_details_pdf_generator_2.dart';
import 'package:pps/l10n/app_localizations.dart';

class ReservationDetailsScreen extends ConsumerStatefulWidget {
  const ReservationDetailsScreen({super.key, required this.reservationId});

  final String? reservationId;

  @override
  ConsumerState<ReservationDetailsScreen> createState() =>
      _ReservationDetailsScreenState();
}

class _ReservationDetailsScreenState
    extends ConsumerState<ReservationDetailsScreen> {
  static const double _labelFontSize = AppFontSizes.label11;
  static const double _valueFontSize = AppFontSizes.body12;
  static const _dateFormat = 'dd/MM/yyyy';

  ReservationDetails? _cachedDetails;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final id = widget.reservationId;
    if (id == null || id.trim().isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text(l10n.missingReservationId)),
      );
    }

    final detailsAsync = ref.watch(reservationDetailsProvider(id));
    ref.listen<AsyncValue<ReservationDetails>>(reservationDetailsProvider(id), (
      previous,
      next,
    ) {
      final value = next.asData?.value;
      if (value != null) {
        if (mounted) {
          setState(() => _cachedDetails = value);
        }
      }
      if (next.hasError && previous?.hasError != true && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
        if (GoRouter.of(context).canPop()) {
          context.pop();
        } else {
          context.go('/reservations');
        }
      }
    });

    final details = detailsAsync.asData?.value ?? _cachedDetails;
    final isBlocking = detailsAsync.isLoading;

    final reservationNo = details?.order.reservationNo;
    final title = reservationNo != null
        ? '${l10n.detailsTitle} $reservationNo'
        : l10n.detailsTitle;

    return Title(
      title: title,
      color: Theme.of(context).colorScheme.primary,
      child: Scaffold(
        backgroundColor: AppColors.light,
        body: Stack(
          children: [
            SelectionArea(
              child: AbsorbPointer(
                absorbing: isBlocking,
                child: details == null
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.s16,
                          AppSpacing.s12,
                          AppSpacing.s16,
                          AppSpacing.s16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [_buildToolbar(context, ref, id, null)],
                        ),
                      )
                    : SingleChildScrollView(
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
                            _buildMainCard(
                              context,
                              ref,
                              details.order,
                              details.services,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            if (isBlocking)
              Positioned.fill(
                child: Stack(
                  children: [
                    ModalBarrier(
                      dismissible: false,
                      color: Colors.black.withValues(alpha: 0.18),
                    ),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
          ],
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
    final l10n = AppLocalizations.of(context)!;
    final printTotalsTooltip = l10n.printTotalsHintTooltip;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.detailsTitle,
              style: TextStyle(
                fontSize: AppFontSizes.title20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.s4),
            Row(
              children: [
                Text(
                  l10n.reservationsTitle,
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
                  l10n.detailsTitle,
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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.print)));
                    return;
                  }
                  final print1Diffs = <String>[];
                  final canUsePrint1 = _canUsePrintSimple(payload, print1Diffs);
                  if (!canUsePrint1) {
                    await _showPrint1SimpleBlockedDialog(context, print1Diffs);
                    return;
                  }
                  final rmsText = (payload.order.rmsInvoiceNo ?? '').trim();
                  if (rmsText.isNotEmpty) {
                    await _printReservationPdf(context, payload);
                    return;
                  }
                  await _showRmsInvoiceBeforePrintDialog(
                    context,
                    ref,
                    payload,
                    onPrint: _printReservationPdf,
                  );
                  return;
                case _ReservationToolbarAction.print2:
                  final payload = details;
                  if (payload == null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(AppStrings.print2)));
                    return;
                  }
                  final rmsText = (payload.order.rmsInvoiceNo ?? '').trim();
                  if (rmsText.isNotEmpty) {
                    await _printReservationPdf2(context, payload);
                    return;
                  }
                  await _showRmsInvoiceBeforePrintDialog(
                    context,
                    ref,
                    payload,
                    onPrint: _printReservationPdf2,
                  );
                  return;
                case _ReservationToolbarAction.guide:
                case _ReservationToolbarAction.printUsage:
                case _ReservationToolbarAction.delete:
                  return;
              }
            }();
          },
          menuExtraWidth: 120,
          menuMinWidth: 220,
          menuMaxWidth: 280,
          entries: [
            const AppDropMenuEntry.action(
              value: _ReservationToolbarAction.print,
              label: AppStrings.print1Summary,
              icon: Icons.print_outlined,
              isDanger: true,
            ),
            AppDropMenuEntry.action(
              value: _ReservationToolbarAction.print2,
              label: AppStrings.print2Summary,
              icon: Icons.print_outlined,
              trailing: Tooltip(
                message: printTotalsTooltip,
                waitDuration: const Duration(milliseconds: 200),
                child: const SizedBox(
                  width: 10,
                  height: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              isDanger: true,
            ),
          ],
          child: Container(
            height: AppHeights.iconButton28,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadii.r4),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.print_outlined,
                  size: AppIconSizes.s14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  l10n.print,
                  style: const TextStyle(
                    fontSize: AppFontSizes.body12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                const _TriangleDownIcon(color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        AppDropMenuButton<_ReservationToolbarAction>(
          onSelected: (action) {
            () async {
              switch (action) {
                case _ReservationToolbarAction.guide:
                  if (!context.mounted) {
                    return;
                  }
                  await _showCalculationsGuideDialog(context);
                  return;
                case _ReservationToolbarAction.printUsage:
                  if (!context.mounted) {
                    return;
                  }
                  await _showPrintUsageDialog(context);
                  return;
                case _ReservationToolbarAction.print:
                case _ReservationToolbarAction.print2:
                  return;
                case _ReservationToolbarAction.delete:
                  await _confirmDeleteReservationOrder(context, ref, id);
                  return;
              }
            }();
          },
          entries: [
            AppDropMenuEntry.action(
              value: _ReservationToolbarAction.printUsage,
              label: l10n.printUsageTitle,
              icon: Icons.help_outline,
            ),
            AppDropMenuEntry.action(
              value: _ReservationToolbarAction.guide,
              label: l10n.calculationsGuide,
              icon: Icons.info_outline,
            ),
            const AppDropMenuEntry.divider(),
            AppDropMenuEntry.action(
              value: _ReservationToolbarAction.delete,
              label: l10n.delete,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.more_vert,
                  size: AppIconSizes.s14,
                  color: Colors.white,
                ),
                const SizedBox(width: AppSpacing.s6),
                Text(
                  l10n.actions,
                  style: const TextStyle(
                    fontSize: AppFontSizes.body12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: AppSpacing.s3),
                const _TriangleDownIcon(color: Colors.white),
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
            label: Text(l10n.back),
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
    final l10n = AppLocalizations.of(context)!;
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
    final rmsInvoiceText = (order.rmsInvoiceNo ?? '').trim().isEmpty
        ? '-'
        : order.rmsInvoiceNo!.trim();

    return _DetailsAccordion(
      title: l10n.reservationMainInfoTitle,
      initiallyExpanded: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => _showEditReservationMainInfoDialog(
                context,
                ref,
                order,
                services,
              ),
              icon: const Icon(Icons.edit, color: AppColors.primary, size: 16),
              tooltip: l10n.editInfoTooltip,
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
                const leftInset = AppSpacing.s12;
                final colWidth =
                    (constraints.maxWidth - leftInset - (gap * 3)).clamp(
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
                        const SizedBox(width: leftInset),

                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            l10n.client,
                            order.client.label,
                            icon: Icons.swap_horiz,
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            l10n.fromDate,
                            fromDateText,
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(l10n.toDate, toDateText),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: leftInset),

                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            l10n.guestName,
                            order.guestName ?? '-',
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            l10n.clientOptionDate,
                            optionDate,
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            l10n.rmsInvoiceNo,
                            rmsInvoiceText,
                            indicatorDotColor: AppColors.primary,
                            indicatorMessage: l10n.rmsInvoiceIndicatorTooltip,
                            emphasizeValue: true,
                          ),
                        ),
                        const SizedBox(width: gap),
                        SizedBox(
                          width: colWidth,
                          child: _buildMainInfoItem(
                            AppStrings.partyPaxManual,
                            order.partyPaxManual?.toString() ?? '-',
                            indicatorDotColor:
                                _hasPartyPaxMismatch(order, services)
                                ? AppColors.danger
                                : null,
                            indicatorMessage:
                                AppStrings.partyPaxManualIndicatorTooltip,
                            emphasizeValue: true,
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
                      l10n.client,
                      order.client.label,
                      icon: Icons.swap_horiz,
                    ),
                  ),
                  SizedBox(
                    width: clampWidth(
                      ReservationDetailsLayout.mainInfoFromWidth,
                    ),
                    child: _buildMainInfoItem(l10n.fromDate, fromDateText),
                  ),
                  SizedBox(
                    width: clampWidth(ReservationDetailsLayout.mainInfoToWidth),
                    child: _buildMainInfoItem(l10n.toDate, toDateText),
                  ),
                  SizedBox(
                    width: clampWidth(
                      ReservationDetailsLayout.mainInfoGuestWidth,
                    ),
                    child: _buildMainInfoItem(
                      l10n.guestName,
                      order.guestName ?? '-',
                    ),
                  ),
                  SizedBox(
                    width: clampWidth(
                      ReservationDetailsLayout.mainInfoOptionDateWidth,
                    ),
                    child: _buildMainInfoItem(
                      l10n.clientOptionDate,
                      optionDate,
                    ),
                  ),
                  SizedBox(
                    width: clampWidth(
                      ReservationDetailsLayout.mainInfoRmsInvoiceWidth,
                    ),
                    child: _buildMainInfoItem(
                      l10n.rmsInvoiceNo,
                      rmsInvoiceText,
                      indicatorDotColor: AppColors.primary,
                      indicatorMessage: l10n.rmsInvoiceIndicatorTooltip,
                      emphasizeValue: true,
                    ),
                  ),
                  SizedBox(
                    width: clampWidth(ReservationDetailsLayout.mainInfoToWidth),
                    child: _buildMainInfoItem(
                      AppStrings.partyPaxManual,
                      order.partyPaxManual?.toString() ?? '-',
                      indicatorDotColor: _hasPartyPaxMismatch(order, services)
                          ? AppColors.danger
                          : null,
                      indicatorMessage:
                          AppStrings.partyPaxManualIndicatorTooltip,
                      emphasizeValue: true,
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
    List<ReservationServiceSummary> services,
  ) async {
    final l10n = AppLocalizations.of(context)!;
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
    final rmsInvoiceController = TextEditingController(
      text: order.rmsInvoiceNo,
    );
    final partyPaxController = TextEditingController(
      text: order.partyPaxManual?.toString() ?? '',
    );

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
                final entered = rmsInvoiceController.text.trim();
                final rawParty = partyPaxController.text.trim();
                final parsedParty = int.tryParse(rawParty);
                final partyPaxManual = (parsedParty == null || parsedParty <= 0)
                    ? null
                    : parsedParty;
                if (partyPaxManual != null) {
                  final mismatchLines = _partyPaxMismatchLines(
                    partyPaxManual,
                    services,
                  );
                  if (mismatchLines.isNotEmpty && dialogContext.mounted) {
                    final shouldContinue = await AppDialog.show<bool>(
                      context: dialogContext,
                      barrierDismissible: false,
                      title: const Text(AppStrings.partyPaxMismatchTitle),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.partyPaxMismatchBodyPrefix} ${partyPaxManual.toString()}',
                          ),
                          const SizedBox(height: AppSpacing.s10),
                          for (final line in mismatchLines) Text('- $line'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text(AppStrings.fixNow),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(l10n.continueAnyway),
                        ),
                      ],
                    );
                    if (shouldContinue != true) {
                      setState(() => isSaving = false);
                      return;
                    }
                  }
                }
                final updated = await repository.updateReservationMainInfo(
                  reservationId: order.id,
                  clientId: selectedClientId,
                  guestName: guestNameController.text.trim().isEmpty
                      ? null
                      : guestNameController.text.trim(),
                  guestNationality: order.guestNationality,
                  clientOptionDate: optionDate,
                  rmsInvoiceNo: entered.isEmpty ? null : entered,
                  setRmsInvoiceNo: true,
                  partyPaxManual: partyPaxManual,
                  setPartyPaxManual: true,
                );
                if (entered.isNotEmpty &&
                    (updated.rmsInvoiceNo ?? '').trim() != entered &&
                    context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.rmsInvoiceMissingColumn)),
                  );
                }
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
                ref.invalidate(reservationDetailsProvider(order.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.saved)));
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
                                Text(
                                  l10n.editInfoTitle,
                                  style: const TextStyle(
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
                                final rmsInvoiceWidth =
                                    maxWidth >= AppBreakpoints.dialogLg
                                    ? ReservationDetailsLayout
                                          .editRmsInvoiceWidthLg
                                    : maxWidth >= AppBreakpoints.dialogMd
                                    ? ReservationDetailsLayout
                                          .editRmsInvoiceWidthMd
                                    : maxWidth;
                                final partyPaxWidth =
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
                                        rmsInvoiceWidth +
                                        partyPaxWidth +
                                        (gap * 4));

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

                                final fieldRmsInvoice = SizedBox(
                                  width: rmsInvoiceWidth,
                                  child: TextField(
                                    controller: rmsInvoiceController,
                                    inputFormatters: [
                                      ArabicDigitsToEnglishInputFormatter(),
                                    ],
                                    decoration: decoration(
                                      AppStrings.rmsInvoiceNo,
                                    ),
                                  ),
                                );

                                final fieldPartyPax = SizedBox(
                                  width: partyPaxWidth,
                                  child: TextField(
                                    controller: partyPaxController,
                                    inputFormatters: [
                                      ArabicDigitsToEnglishInputFormatter(),
                                    ],
                                    decoration:
                                        decoration(
                                          AppStrings.partyPaxManual,
                                        ).copyWith(
                                          hintText:
                                              AppStrings.partyPaxManualHint,
                                        ),
                                    keyboardType: TextInputType.number,
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
                                      const SizedBox(width: gap),
                                      fieldRmsInvoice,
                                      const SizedBox(width: gap),
                                      fieldPartyPax,
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
                                    fieldRmsInvoice,
                                    fieldPartyPax,
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
                                  child: Text(l10n.close),
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
                                      : Text(l10n.save),
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
    rmsInvoiceController.dispose();
    partyPaxController.dispose();
  }

  Future<void> _printReservationPdf(
    BuildContext context,
    ReservationDetails details,
  ) async {
    try {
      final bytes = await ReservationDetailsPdfGenerator.buildPdf(details);
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _printReservationPdf2(
    BuildContext context,
    ReservationDetails details,
  ) async {
    try {
      final bytes = await ReservationDetailsPdfGenerator2.buildPdf(details);
      await Printing.layoutPdf(onLayout: (format) async => bytes);
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showRmsInvoiceBeforePrintDialog(
    BuildContext context,
    WidgetRef ref,
    ReservationDetails details, {
    required Future<void> Function(BuildContext, ReservationDetails) onPrint,
  }) async {
    final order = details.order;
    final repository = ref.read(reservationsRepositoryProvider);

    final rmsInvoiceController = TextEditingController(
      text: order.rmsInvoiceNo,
    );
    bool isSaving = false;
    ReservationOrder? updatedOrder;

    final result = await showDialog<_RmsInvoicePrintAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final l10n = AppLocalizations.of(context)!;

            InputDecoration decoration(String label) {
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
              );
            }

            Future<void> saveAndClose() async {
              if (isSaving) return;
              setState(() => isSaving = true);
              try {
                final entered = rmsInvoiceController.text.trim();
                final updated = await repository.updateReservationMainInfo(
                  reservationId: order.id,
                  clientId: order.client.id,
                  guestName: order.guestName,
                  guestNationality: order.guestNationality,
                  clientOptionDate: order.clientOptionDate,
                  rmsInvoiceNo: entered.isEmpty ? null : entered,
                  setRmsInvoiceNo: true,
                  partyPaxManual: order.partyPaxManual,
                );
                if (entered.isNotEmpty &&
                    (updated.rmsInvoiceNo ?? '').trim() != entered &&
                    context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppStrings.rmsInvoiceMissingColumn),
                    ),
                  );
                }

                updatedOrder = (updated.rmsInvoiceNo ?? '').trim() == entered
                    ? updated
                    : ReservationOrder(
                        id: updated.id,
                        reservationNo: updated.reservationNo,
                        client: updated.client,
                        guestName: updated.guestName,
                        guestNationality: updated.guestNationality,
                        clientOptionDate: updated.clientOptionDate,
                        rmsInvoiceNo: entered.isEmpty
                            ? updated.rmsInvoiceNo
                            : entered,
                        partyPaxManual: updated.partyPaxManual,
                        createdAt: updated.createdAt,
                      );
                ref.invalidate(reservationDetailsProvider(order.id));
                if (dialogContext.mounted) {
                  Navigator.of(
                    dialogContext,
                  ).pop(_RmsInvoicePrintAction.saveAndPrint);
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
                  maxWidth: 360,
                  maxHeight: 280,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.r6),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
                          child: Row(
                            children: [
                              Text(
                                l10n.rmsInvoiceDialogTitle,
                                style: const TextStyle(
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
                                    : () => Navigator.of(
                                        dialogContext,
                                      ).pop(_RmsInvoicePrintAction.cancel),
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
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.rmsInvoiceDialogHint,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppFontSizes.body12,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s10),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final fieldWidth = (constraints.maxWidth)
                                      .clamp(0, 240)
                                      .toDouble();
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: fieldWidth,
                                      child: TextField(
                                        controller: rmsInvoiceController,
                                        inputFormatters: [
                                          ArabicDigitsToEnglishInputFormatter(),
                                        ],
                                        decoration: decoration(
                                          l10n.rmsInvoiceNo,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
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
                                    : () => Navigator.of(dialogContext).pop(
                                        _RmsInvoicePrintAction.continueOnly,
                                      ),
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
                                child: Text(l10n.continueWithout),
                              ),
                              const SizedBox(width: AppSpacing.s10),
                              ElevatedButton(
                                onPressed: isSaving ? null : saveAndClose,
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
                                    : Text(l10n.saveAndPrint),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    rmsInvoiceController.dispose();

    if (!context.mounted) {
      return;
    }

    switch (result ?? _RmsInvoicePrintAction.cancel) {
      case _RmsInvoicePrintAction.cancel:
        return;
      case _RmsInvoicePrintAction.continueOnly:
        await onPrint(context, details);
        return;
      case _RmsInvoicePrintAction.saveAndPrint:
        final orderToPrint = updatedOrder ?? details.order;
        await onPrint(
          context,
          ReservationDetails(order: orderToPrint, services: details.services),
        );
        return;
    }
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
                        _buildServiceAccordion(
                          context,
                          ref,
                          order,
                          service,
                          services,
                        ),
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
    List<ReservationServiceSummary> services,
  ) {
    late final String title;
    final tag = '(#${service.displayNo})';

    late final Widget summary;
    late final Widget details;
    String? typePillText;
    String? secondaryPillText;
    Color? secondaryPillColor;
    String? secondaryPillWarningMessage;
    Color? indicatorDotColor;
    String? indicatorDotMessage;

    String? locationCodeForAgent(AgentReservationDraft? agent) {
      final rawLocation = agent?.hotelLocation?.trim().toLowerCase();
      final rawCity = agent?.hotelCity?.trim().toLowerCase();
      final isMed =
          rawLocation == AppStrings.madinah.toLowerCase() ||
          rawLocation == AppStrings.med.toLowerCase() ||
          rawLocation == 'المدينة' ||
          rawLocation == 'المدينه' ||
          rawLocation == 'مدينه' ||
          rawLocation == 'مدينة' ||
          (rawLocation != null &&
              (rawLocation.contains('med') || rawLocation.contains('madin'))) ||
          (rawLocation == null &&
              rawCity != null &&
              (rawCity.contains('med') || rawCity.contains('madin')));
      final isMak =
          rawLocation == AppStrings.makkah.toLowerCase() ||
          rawLocation == AppStrings.mak.toLowerCase() ||
          rawLocation == 'مكة' ||
          rawLocation == 'مكه' ||
          (rawLocation == null &&
              rawCity != null &&
              (rawCity.contains('makk') || rawCity.contains('mak')));
      if (isMed) {
        return AppStrings.med;
      }
      if (isMak) {
        return AppStrings.mak;
      }
      return null;
    }

    Map<String, int> locationSegmentPaxTotals() {
      final totals = <String, int>{};
      for (final s in services) {
        if (s.type != ReservationServiceType.agent) {
          continue;
        }
        final agent = s.agentDetails;
        final code = locationCodeForAgent(agent);
        if (code == null) {
          continue;
        }
        final pax = agent?.totalPax ?? 0;
        if (pax <= 0) {
          continue;
        }
        totals[code] = (totals[code] ?? 0) + pax;
      }
      return totals;
    }

    final manualPartyPax = order.partyPaxManual;
    final locationTotals = locationSegmentPaxTotals();
    final hasManual = manualPartyPax != null && manualPartyPax > 0;
    final medTotal = locationTotals[AppStrings.med] ?? 0;
    final makTotal = locationTotals[AppStrings.mak] ?? 0;
    final warnLowerLocation =
        (!hasManual && medTotal > 0 && makTotal > 0 && medTotal != makTotal)
        ? (medTotal < makTotal ? AppStrings.med : AppStrings.mak)
        : null;

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
        final rawLocation = agent?.hotelLocation?.trim().toLowerCase();
        final rawCity = agent?.hotelCity?.trim().toLowerCase();
        final isMed =
            rawLocation == AppStrings.madinah.toLowerCase() ||
            rawLocation == AppStrings.med.toLowerCase() ||
            rawLocation == 'مدينة' ||
            rawLocation == 'المدينة' ||
            (rawLocation == null &&
                rawCity != null &&
                (rawCity.contains('med') || rawCity.contains('madin')));
        final isMak =
            rawLocation == AppStrings.makkah.toLowerCase() ||
            rawLocation == AppStrings.mak.toLowerCase() ||
            rawLocation == 'مكة' ||
            rawLocation == 'مكه' ||
            (rawLocation == null &&
                rawCity != null &&
                (rawCity.contains('makk') || rawCity.contains('mak')));
        if (isMed) {
          secondaryPillText = AppStrings.med;
          secondaryPillColor = AppColors.actionGreen;
        } else if (isMak) {
          secondaryPillText = AppStrings.mak;
          secondaryPillColor = AppColors.dangerAccent;
        }
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
        details = _buildHotelDirectServiceBody(service, order, services);
        final locCode = locationCodeForAgent(agent);
        final locationPax = locCode == null ? null : locationTotals[locCode];
        final hasLocationMismatchWithManual =
            hasManual &&
            locCode != null &&
            (locationPax ?? 0) > 0 &&
            locationPax != manualPartyPax;
        final hasLowerLocationMismatch =
            !hasManual &&
            warnLowerLocation != null &&
            locCode != null &&
            locCode == warnLowerLocation;
        if (hasLocationMismatchWithManual || hasLowerLocationMismatch) {
          indicatorDotColor = AppColors.danger;
          indicatorDotMessage = AppStrings.warningIndicatorDefaultTooltip;
        }
        if (secondaryPillText != null) {
          if (hasLocationMismatchWithManual) {
            secondaryPillWarningMessage = AppStrings.locationPaxMismatchTemplate
                .replaceAll('{place}', secondaryPillText)
                .replaceAll('{locationPax}', locationPax.toString())
                .replaceAll('{manualPax}', manualPartyPax.toString());
          } else if (hasLowerLocationMismatch) {
            final otherCode = warnLowerLocation == AppStrings.med
                ? AppStrings.mak
                : AppStrings.med;
            final otherPax = locationTotals[otherCode] ?? 0;
            secondaryPillWarningMessage = AppStrings
                .locationPaxDifferenceTemplate
                .replaceAll('{place}', secondaryPillText)
                .replaceAll('{placePax}', locationPax.toString())
                .replaceAll('{otherPlace}', otherCode)
                .replaceAll('{otherPax}', otherPax.toString());
          }
          if (secondaryPillWarningMessage != null) {
            indicatorDotMessage = secondaryPillWarningMessage;
          }
        }
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
                      warningMessage:
                          (manualPartyPax != null &&
                              manualPartyPax > 0 &&
                              general != null &&
                              general.quantity > 0 &&
                              general.quantity != manualPartyPax)
                          ? AppStrings.generalQtyMismatchTemplate
                                .replaceAll(
                                  '{qty}',
                                  general.quantity.toString(),
                                )
                                .replaceAll(
                                  '{manualPax}',
                                  manualPartyPax.toString(),
                                )
                          : null,
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
      secondaryPillText: secondaryPillText,
      secondaryPillColor: secondaryPillColor,
      secondaryPillWarningMessage: secondaryPillWarningMessage,
      indicatorDotColor: indicatorDotColor,
      indicatorDotMessage: indicatorDotMessage,
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
        final l10n = AppLocalizations.of(context)!;
        return AppDialog(
          title: Text(
            l10n.deleteReservationTitle,
            style: const TextStyle(
              fontSize: AppFontSizes.title14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            l10n.deleteServiceMessage,
            style: const TextStyle(
              fontSize: AppFontSizes.body12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
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
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                minimumSize: const Size(110, AppHeights.button32),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                ),
              ),
              child: Text(l10n.delete),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.deleted)),
        );
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
    List<ReservationServiceSummary> services,
  ) {
    final agent = service.agentDetails;
    final manual = order.partyPaxManual;
    final location = agent?.hotelLocation?.trim();
    final city = agent?.hotelCity?.trim();
    final place = (location != null && location.isNotEmpty)
        ? location
        : (city != null && city.isNotEmpty
              ? city
              : AppLocalizations.of(context)!.hotel);
    final hasManual = manual != null && manual > 0;

    String? locationCodeForAgent(AgentReservationDraft? agent) {
      final rawLocation = agent?.hotelLocation?.trim().toLowerCase();
      final rawCity = agent?.hotelCity?.trim().toLowerCase();
      final isMed =
          rawLocation == AppStrings.madinah.toLowerCase() ||
          rawLocation == AppStrings.med.toLowerCase() ||
          rawLocation == 'المدينة' ||
          rawLocation == 'المدينه' ||
          rawLocation == 'مدينه' ||
          rawLocation == 'مدينة' ||
          (rawLocation != null &&
              (rawLocation.contains('med') || rawLocation.contains('madin'))) ||
          (rawLocation == null &&
              rawCity != null &&
              (rawCity.contains('med') || rawCity.contains('madin')));
      final isMak =
          rawLocation == AppStrings.makkah.toLowerCase() ||
          rawLocation == AppStrings.mak.toLowerCase() ||
          rawLocation == 'مكة' ||
          rawLocation == 'مكه' ||
          (rawLocation == null &&
              rawCity != null &&
              (rawCity.contains('makk') || rawCity.contains('mak')));
      if (isMed) {
        return AppStrings.med;
      }
      if (isMak) {
        return AppStrings.mak;
      }
      return null;
    }

    Map<String, int> locationTotals() {
      final totals = <String, int>{};
      for (final s in services) {
        if (s.type != ReservationServiceType.agent) {
          continue;
        }
        final code = locationCodeForAgent(s.agentDetails);
        if (code == null) {
          continue;
        }
        final pax = s.agentDetails?.totalPax ?? 0;
        if (pax <= 0) {
          continue;
        }
        totals[code] = (totals[code] ?? 0) + pax;
      }
      return totals;
    }

    String? paxWarningMessage;
    final code = locationCodeForAgent(agent);
    final totals = locationTotals();
    final locationPax = code == null ? null : totals[code];
    final medTotal = totals[AppStrings.med] ?? 0;
    final makTotal = totals[AppStrings.mak] ?? 0;
    final warnLowerLocation =
        (!hasManual && medTotal > 0 && makTotal > 0 && medTotal != makTotal)
        ? (medTotal < makTotal ? AppStrings.med : AppStrings.mak)
        : null;

    final shouldWarnForThisService = hasManual
        ? (code != null && (locationPax ?? 0) > 0 && locationPax != manual)
        : (warnLowerLocation != null && code == warnLowerLocation);

    if (shouldWarnForThisService) {
      if (hasManual) {
        paxWarningMessage = AppStrings.locationPaxMismatchTemplate
            .replaceAll('{place}', place)
            .replaceAll('{locationPax}', (locationPax ?? 0).toString())
            .replaceAll('{manualPax}', manual.toString());
      } else {
        final otherCode = warnLowerLocation == AppStrings.med
            ? AppStrings.mak
            : AppStrings.med;
        final otherPax = totals[otherCode] ?? 0;
        paxWarningMessage = AppStrings.locationPaxDifferenceTemplate
            .replaceAll('{place}', place)
            .replaceAll('{placePax}', (locationPax ?? 0).toString())
            .replaceAll('{otherPlace}', otherCode)
            .replaceAll('{otherPax}', otherPax.toString());
      }
    }

    final paxMessage = paxWarningMessage;
    final hasMismatch = paxMessage != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasMismatch) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Text(
              paxMessage,
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: AppFontSizes.body12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                    warningMessage: paxWarningMessage,
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

    String roomRateTextForSummary(AgentReservationRoomSummary room) {
      int paxPerRoomForRoomType(String roomType) {
        final normalized = roomType.trim().toLowerCase();
        if (normalized == 'triple' || normalized == 'trip') {
          return 3;
        }
        if (normalized == 'quad') {
          return 4;
        }
        if (normalized == 'quent' || normalized == 'quint') {
          return 5;
        }
        return 2;
      }

      Decimal parseMoney(String raw) {
        final trimmed = raw.trim();
        if (trimmed.isEmpty) {
          return Decimal.zero;
        }
        final normalized = trimmed.replaceAll(',', '');
        return Decimal.tryParse(normalized) ?? Decimal.zero;
      }

      final rates = room.roomRates;
      if (rates.isEmpty) {
        return '-';
      }
      final firstNonEmpty = rates.firstWhere(
        (r) =>
            r.saleRoom.trim().isNotEmpty || r.saleMealPerPax.trim().isNotEmpty,
        orElse: () => rates.first,
      );
      final paxPerRoom = paxPerRoomForRoomType(room.roomType);
      final unit =
          parseMoney(firstNonEmpty.saleRoom) +
          (parseMoney(firstNonEmpty.saleMealPerPax) *
              Decimal.fromInt(paxPerRoom));
      return _formatMoney(unit);
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
                          text: roomRateTextForSummary(room),
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
    final pricingPerTrip =
        service.transportationDetails?.pricingPerTrip ?? true;
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
            totalSale: pricingPerTrip
                ? _formatMoney(
                    trips[index].salePerItem *
                        Decimal.fromInt(trips[index].quantity),
                  )
                : '-',
            totalCost: pricingPerTrip
                ? _formatMoney(
                    trips[index].costPerItem *
                        Decimal.fromInt(trips[index].quantity),
                  )
                : '-',
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
    String? warningMessage,
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
              Tooltip(
                message: label,
                child: Icon(icon, size: 13, color: AppColors.textSecondary),
              ),
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
            if (warningMessage != null) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: warningMessage,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
            if (actionIcon != null) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: label,
                child: Icon(actionIcon, size: 14, color: AppColors.primary),
              ),
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
    Color? indicatorDotColor,
    String? indicatorMessage,
    String? iconMessage,
    bool emphasizeValue = false,
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
            if (indicatorDotColor != null) ...[
              const SizedBox(width: 6),
              Tooltip(
                message:
                    indicatorMessage ??
                    AppStrings.warningIndicatorDefaultTooltip,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: indicatorDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
            if (icon != null) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: iconMessage ?? label,
                child: Icon(icon, size: 12, color: AppColors.success),
              ),
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
              fontWeight: emphasizeValue && value != '-'
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: value == '-'
                  ? AppColors.textSecondary
                  : emphasizeValue
                  ? AppColors.primary
                  : AppColors.textPrimary,
              height: 1.1,
            ),
          ),
      ],
    );
  }

  bool _hasPartyPaxMismatch(
    ReservationOrder order,
    List<ReservationServiceSummary> services,
  ) {
    final manual = order.partyPaxManual;
    if (manual == null || manual <= 0) {
      return false;
    }
    for (final s in services) {
      if (s.type != ReservationServiceType.agent) {
        continue;
      }
      final p = s.agentDetails?.totalPax ?? 0;
      if (p > 0 && p != manual) {
        return true;
      }
    }
    return false;
  }

  List<String> _partyPaxMismatchLines(
    int manual,
    List<ReservationServiceSummary> services,
  ) {
    final lines = <String>[];
    for (final s in services) {
      if (s.type != ReservationServiceType.agent) {
        continue;
      }
      final a = s.agentDetails;
      if (a == null) {
        continue;
      }
      final p = a.totalPax;
      if (p <= 0 || p == manual) {
        continue;
      }
      final location = a.hotelLocation?.trim();
      final city = a.hotelCity?.trim();
      final place = (location != null && location.isNotEmpty)
          ? location
          : (city != null && city.isNotEmpty ? city : AppStrings.hotel);
      final hotelName = a.hotelName?.trim().isNotEmpty == true
          ? a.hotelName!.trim()
          : AppStrings.hotel;
      lines.add('$place — $hotelName — $p');
    }
    return lines;
  }

  Future<void> _showCalculationsGuideDialog(BuildContext context) {
    return _showPrintQaDialog(context);
  }

  Future<void> _showPrintUsageDialog(BuildContext context) {
    return AppDialog.show<void>(
      context: context,
      title: const Text(AppStrings.printUsageTitle),
      content: const SingleChildScrollView(
        child: Text(AppStrings.printUsageBody),
      ),
      maxWidth: 640,
      barrierDismissible: false,
      actions: [
        Builder(
          builder: (dialogContext) {
            return TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(AppStrings.close),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showPrintQaDialog(BuildContext context) {
    var isArabic = true;
    Widget languageChip({
      required String label,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.r8),
          hoverColor: AppColors.primary.withValues(alpha: 0.06),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s10,
              vertical: AppSpacing.s6,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.r8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppFontSizes.label11,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                height: 1.0,
              ),
            ),
          ),
        ),
      );
    }

    Widget languageToggle({
      required bool isArabicSelected,
      required ValueChanged<bool> onChanged,
    }) {
      return Align(
        alignment: Alignment.center,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.light,
            borderRadius: BorderRadius.circular(AppRadii.r12),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                languageChip(
                  label: AppStrings.printQaLanguageAr,
                  isSelected: isArabicSelected,
                  onTap: () => onChanged(true),
                ),
                const SizedBox(width: AppSpacing.s6),
                languageChip(
                  label: AppStrings.printQaLanguageEn,
                  isSelected: !isArabicSelected,
                  onTap: () => onChanged(false),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget qaTile({
      required String question,
      required String answer,
      required TextAlign textAlign,
    }) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadii.r12),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.r12),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.s12,
              AppSpacing.s0,
              AppSpacing.s12,
              AppSpacing.s12,
            ),
            title: Text(
              question,
              textAlign: textAlign,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: AppFontSizes.title13,
              ),
            ),
            children: [
              SelectableText(
                answer,
                textAlign: textAlign,
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final textDirection = isArabic
                ? ui.TextDirection.rtl
                : ui.TextDirection.ltr;
            final textAlign = isArabic ? TextAlign.right : TextAlign.left;

            final q1 = isArabic
                ? AppStrings.printQaQ1Ar
                : AppStrings.printQaQ1En;
            final a1 = isArabic
                ? AppStrings.printQaA1Ar
                : AppStrings.printQaA1En;
            final q2 = isArabic
                ? AppStrings.printQaQuestionAr
                : AppStrings.printQaQuestionEn;
            final a2 = isArabic
                ? AppStrings.printQaAnswerAr
                : AppStrings.printQaAnswerEn;
            final q3 = isArabic
                ? AppStrings.printQaQ3Ar
                : AppStrings.printQaQ3En;
            final a3 = isArabic
                ? AppStrings.printQaA3Ar
                : AppStrings.printQaA3En;

            return Directionality(
              textDirection: textDirection,
              child: AppDialog(
                title: const Text(AppStrings.calculationsGuide),
                maxWidth: 720,
                barrierDismissible: false,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    languageToggle(
                      isArabicSelected: isArabic,
                      onChanged: (value) => setState(() => isArabic = value),
                    ),
                    const SizedBox(height: AppSpacing.s10),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: Column(
                            children: [
                              qaTile(
                                question: q1,
                                answer: a1,
                                textAlign: textAlign,
                              ),
                              const SizedBox(height: AppSpacing.s6),
                              qaTile(
                                question: q2,
                                answer: a2,
                                textAlign: textAlign,
                              ),
                              const SizedBox(height: AppSpacing.s6),
                              qaTile(
                                question: q3,
                                answer: a3,
                                textAlign: textAlign,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text(AppStrings.printQaClose),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _canUsePrintSimple(ReservationDetails details, List<String> diffs) {
    final agentServices = details.services.where(
      (s) => s.type == ReservationServiceType.agent,
    );

    final med = <String, int>{};
    final mak = <String, int>{};

    for (final s in agentServices) {
      final a = s.agentDetails;
      if (a == null) {
        continue;
      }
      final locationCode = _normalizeHotelLocationKey(
        a.hotelLocation,
        a.hotelCity,
      );
      if (locationCode == null) {
        continue;
      }
      final target = locationCode == AppStrings.med
          ? med
          : (locationCode == AppStrings.mak ? mak : null);
      if (target == null) {
        continue;
      }
      for (final room in a.roomsSummary) {
        final t = room.roomType.trim();
        if (t.isEmpty) {
          continue;
        }
        final qty = room.numberOfRooms;
        if (qty <= 0) {
          continue;
        }
        target[t] = (target[t] ?? 0) + qty;
      }
    }

    final hasMed = med.values.any((v) => v > 0);
    final hasMak = mak.values.any((v) => v > 0);
    if (!hasMed || !hasMak) {
      return true;
    }

    final roomTypes = <String>{...med.keys, ...mak.keys}.toList()
      ..sort((a, b) {
        final byOrder = _roomTypeSortOrder(a).compareTo(_roomTypeSortOrder(b));
        if (byOrder != 0) {
          return byOrder;
        }
        return a.compareTo(b);
      });

    for (final t in roomTypes) {
      final medQty = med[t] ?? 0;
      final makQty = mak[t] ?? 0;
      if (medQty != makQty) {
        diffs.add('$t: MED=$medQty, MAK=$makQty');
      }
    }

    return diffs.isEmpty;
  }

  int _roomTypeSortOrder(String rawRoomType) {
    final normalized = rawRoomType.trim().toLowerCase();
    if (normalized == 'single' || normalized == 'sgl' || normalized == 'sng') {
      return 1;
    }
    if (normalized == 'double' || normalized == 'dbl') {
      return 2;
    }
    if (normalized == 'triple' || normalized == 'trip') {
      return 3;
    }
    if (normalized == 'quad') {
      return 4;
    }
    if (normalized == 'quent' || normalized == 'quint') {
      return 5;
    }
    return 99;
  }

  String? _normalizeHotelLocationKey(String? rawLocation, String? rawCity) {
    final normalizedLocation = rawLocation?.trim().toLowerCase();
    if (normalizedLocation == 'med' ||
        normalizedLocation == 'madinah' ||
        normalizedLocation == 'مدينة' ||
        normalizedLocation == 'المدينة') {
      return AppStrings.med;
    }
    if (normalizedLocation == 'mak' ||
        normalizedLocation == 'makkah' ||
        normalizedLocation == 'مكة' ||
        normalizedLocation == 'مكه') {
      return AppStrings.mak;
    }

    final normalizedCity = rawCity?.trim().toLowerCase();
    if (normalizedCity == null || normalizedCity.isEmpty) {
      return null;
    }
    if (normalizedCity.contains('med') || normalizedCity.contains('madin')) {
      return AppStrings.med;
    }
    if (normalizedCity.contains('makk') || normalizedCity.contains('mak')) {
      return AppStrings.mak;
    }
    return null;
  }

  Future<void> _showPrint1SimpleBlockedDialog(
    BuildContext context,
    List<String> diffLines,
  ) {
    final body = StringBuffer()
      ..write(AppStrings.print1SimpleBlockedBodyIntro)
      ..writeAll(diffLines.map((l) => '• $l\n'))
      ..write('\n')
      ..write('استخدم Print 2 — Mix detailed في الحالة دي.');

    return AppDialog.show<void>(
      context: context,
      title: const Text(AppStrings.print1SimpleBlockedTitle),
      content: SingleChildScrollView(child: Text(body.toString())),
      maxWidth: 640,
      barrierDismissible: false,
      actions: [
        Builder(
          builder: (dialogContext) {
            final l10n = AppLocalizations.of(dialogContext)!;
            return TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Future(() async {
                  if (!context.mounted) {
                    return;
                  }
                  await _showPrintUsageDialog(context);
                });
              },
              child: Text(l10n.more),
            );
          },
        ),
        Builder(
          builder: (dialogContext) {
            final l10n = AppLocalizations.of(dialogContext)!;
            return ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.ok),
            );
          },
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
        final l10n = AppLocalizations.of(context)!;
        return AppDialog(
          title: Text(
            l10n.deleteReservationTitle,
            style: const TextStyle(
              fontSize: AppFontSizes.title14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            l10n.deleteReservationMessage,
            style: const TextStyle(
              fontSize: AppFontSizes.body12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
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
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                minimumSize: const Size(110, AppHeights.button32),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                ),
              ),
              child: Text(l10n.delete),
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

enum _ReservationToolbarAction { print, print2, printUsage, guide, delete }

enum _ServiceAction { print, attachments, delete }

enum _RmsInvoicePrintAction { cancel, continueOnly, saveAndPrint }

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
    this.secondaryPillText,
    this.secondaryPillColor,
    this.secondaryPillWarningMessage,
    this.indicatorDotColor,
    this.indicatorDotMessage,
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
  final String? secondaryPillText;
  final Color? secondaryPillColor;
  final String? secondaryPillWarningMessage;
  final Color? indicatorDotColor;
  final String? indicatorDotMessage;
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
                        Tooltip(
                          message: widget.typePillText!,
                          child: Container(
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
                        ),
                      ],
                      if (widget.secondaryPillText != null &&
                          widget.secondaryPillColor != null) ...[
                        const SizedBox(width: AppSpacing.s8),
                        Tooltip(
                          message:
                              widget.secondaryPillWarningMessage ??
                              widget.secondaryPillText!,
                          child: Container(
                            height: AppHeights.chip16,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.secondaryPillColor!.withValues(
                                alpha: AppAlphas.surface15,
                              ),
                              borderRadius: BorderRadius.circular(AppRadii.r3),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              widget.secondaryPillText!,
                              style: TextStyle(
                                color: widget.secondaryPillColor!,
                                fontSize: AppFontSizes.badge10,
                                fontWeight: FontWeight.w600,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        if (widget.secondaryPillWarningMessage != null) ...[
                          const SizedBox(width: 6),
                          Tooltip(
                            message: widget.secondaryPillWarningMessage!,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ],
                      if (widget.indicatorDotColor != null &&
                          widget.secondaryPillWarningMessage == null) ...[
                        const SizedBox(width: AppSpacing.s8),
                        Tooltip(
                          message:
                              widget.indicatorDotMessage ??
                              AppStrings.warningIndicatorDefaultTooltip,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: widget.indicatorDotColor,
                              shape: BoxShape.circle,
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
            fontSize: AppFontSizes.label11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.body12,
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
