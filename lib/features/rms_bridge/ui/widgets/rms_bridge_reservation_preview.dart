import 'package:flutter/material.dart';
import 'package:decimal/decimal.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/models/rms_bridge_reservation_preview.dart';

class RmsBridgeReservationPreviewView extends StatelessWidget {
  const RmsBridgeReservationPreviewView({
    super.key,
    required this.preview,
    this.onOpenDetails,
  });

  final RmsBridgeReservationPreview preview;
  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final totals = _sumTotals(preview);
    final dateRange = _dateRange(preview);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s12),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.s16,
                    runSpacing: AppSpacing.s8,
                    children: [
                      _MetaChip(
                        label: AppStrings.fromDate,
                        value: dateRange.$1 ?? '-',
                      ),
                      _MetaChip(
                        label: AppStrings.toDate,
                        value: dateRange.$2 ?? '-',
                      ),
                      _MetaChip(
                        label: AppStrings.totalSale,
                        value: _formatMoney(totals.$1),
                      ),
                      _MetaChip(
                        label: AppStrings.totalCost,
                        value: _formatMoney(totals.$2),
                      ),
                      _MetaChip(
                        label: AppStrings.rmsBridgeReservationIdLabel,
                        value: preview.reservationId,
                      ),
                      _MetaChip(
                        label: AppStrings.rmsBridgeReservationNoLabel,
                        value: preview.reservationNo ?? '-',
                      ),
                      _MetaChip(
                        label: AppStrings.rmsBridgeClientIdLabel,
                        value: preview.clientId ?? '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                if (onOpenDetails != null)
                  ElevatedButton.icon(
                    onPressed: onOpenDetails,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text(AppStrings.rmsBridgeOpenDetailsButton),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Text(
          AppStrings.rmsBridgeHotelsPreviewTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        if (preview.hotelSegments.isEmpty)
          Text(
            AppStrings.rmsBridgeNoHotelsFound,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          )
        else
          Column(
            children: [
              for (final segment in preview.hotelSegments)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.hotel_outlined,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      segment.label ??
                                          AppStrings.rmsBridgeUnnamedHotel,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.s2),
                                    Text(
                                      segment.type ?? '-',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s10),
                          Wrap(
                            spacing: AppSpacing.s16,
                            runSpacing: AppSpacing.s8,
                            children: [
                              _MetaChip(
                                label: AppStrings.arrivalDate,
                                value: segment.arrivalDate ?? '-',
                              ),
                              _MetaChip(
                                label: AppStrings.departureDate,
                                value: segment.departureDate ?? '-',
                              ),
                              _MetaChip(
                                label: AppStrings.totalSale,
                                value: segment.totalSale ?? '-',
                              ),
                              _MetaChip(
                                label: AppStrings.totalCost,
                                value: segment.totalCost ?? '-',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

Decimal _parseDecimal(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return Decimal.parse('0');
  final normalized = value
      .replaceAll(',', '')
      .replaceAll(RegExp(r'[^0-9.\-]'), '');
  if (normalized.isEmpty) return Decimal.parse('0');
  return Decimal.tryParse(normalized) ?? Decimal.parse('0');
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

(Decimal, Decimal) _sumTotals(RmsBridgeReservationPreview preview) {
  var totalSale = Decimal.parse('0');
  var totalCost = Decimal.parse('0');
  for (final segment in preview.hotelSegments) {
    totalSale += _parseDecimal(segment.totalSale);
    totalCost += _parseDecimal(segment.totalCost);
  }
  return (totalSale, totalCost);
}

(String?, String?) _dateRange(RmsBridgeReservationPreview preview) {
  DateTime? minArrival;
  DateTime? maxDeparture;

  for (final segment in preview.hotelSegments) {
    final arrival = DateTime.tryParse((segment.arrivalDate ?? '').trim());
    final departure = DateTime.tryParse((segment.departureDate ?? '').trim());
    if (arrival != null) {
      minArrival = (minArrival == null || arrival.isBefore(minArrival))
          ? arrival
          : minArrival;
    }
    if (departure != null) {
      maxDeparture = (maxDeparture == null || departure.isAfter(maxDeparture))
          ? departure
          : maxDeparture;
    }
  }

  final fromText = minArrival?.toIso8601String().split('T').first;
  final toText = maxDeparture?.toIso8601String().split('T').first;
  return (fromText, toText);
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(AppRadii.r8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s10,
          vertical: AppSpacing.s6,
        ),
        child: RichText(
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            children: [
              TextSpan(text: '$label '),
              TextSpan(
                text: value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
