import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../provider/rms_bridge_data_providers.dart';
import '../widgets/rms_bridge_reservation_preview.dart';

class RmsBridgeReservationDetailsScreen extends ConsumerWidget {
  const RmsBridgeReservationDetailsScreen({
    super.key,
    required this.reservationId,
  });

  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trimmedReservationId = reservationId.trim();
    if (trimmedReservationId.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadii.r8),
            border: Border.all(color: AppColors.danger),
          ),
          child: const Padding(
            padding: EdgeInsets.all(AppSpacing.s12),
            child: Text(
              AppStrings.missingReservationId,
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ),
      );
    }

    final previewAsync = ref.watch(
      rmsBridgeReservationPreviewProvider(trimmedReservationId),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: AppStrings.back,
                onPressed: () => context.go('/rms-bridge/import'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                AppStrings.rmsBridgeReservationDetailsTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          previewAsync.when(
            data: (preview) =>
                RmsBridgeReservationPreviewView(preview: preview),
            error: (error, _) => DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadii.r8),
                border: Border.all(color: AppColors.danger),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.danger),
                    const SizedBox(width: AppSpacing.s10),
                    Expanded(
                      child: Text(
                        '$error',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
