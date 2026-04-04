import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/rms_api/rms_runtime_state_providers.dart';
import '../../provider/rms_bridge_data_providers.dart';
import '../widgets/rms_bridge_reservation_preview.dart';

class RmsBridgeImportReservationScreen extends ConsumerStatefulWidget {
  const RmsBridgeImportReservationScreen({super.key});

  @override
  ConsumerState<RmsBridgeImportReservationScreen> createState() =>
      _RmsBridgeImportReservationScreenState();
}

class _RmsBridgeImportReservationScreenState
    extends ConsumerState<RmsBridgeImportReservationScreen> {
  final _controller = TextEditingController();
  String? _submittedReservationId;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) return;
    setState(() => _submittedReservationId = raw);
  }

  @override
  Widget build(BuildContext context) {
    final sessionId = ref.watch(rmsRuntimeStateProvider).sessionId;

    final submittedId = _submittedReservationId;
    final previewAsync = submittedId == null
        ? null
        : ref.watch(rmsBridgeReservationPreviewProvider(submittedId));

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: AppStrings.back,
                onPressed: () => context.go('/rms-bridge'),
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: AppSpacing.s8),
              Text(
                AppStrings.rmsBridgeImportReservationTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            AppStrings.rmsBridgeImportReservationHint,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.s16),
          DecoratedBox(
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
                  Wrap(
                    spacing: AppSpacing.s12,
                    runSpacing: AppSpacing.s12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 320,
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            labelText:
                                AppStrings.rmsBridgeReservationIdInputLabel,
                            hintText:
                                AppStrings.rmsBridgeReservationIdInputHint,
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.search,
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: sessionId == null ? null : _submit,
                        icon: const Icon(Icons.search),
                        label: const Text(AppStrings.rmsBridgeImportButton),
                      ),
                      if (sessionId == null)
                        OutlinedButton.icon(
                          onPressed: () => context.go('/rms-login'),
                          icon: const Icon(Icons.lock_outline),
                          label: const Text(
                            AppStrings.rmsBridgeOpenRmsLoginButton,
                          ),
                        ),
                      if (sessionId == null)
                        Text(
                          AppStrings.rmsBridgeMissingSessionHint,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.warning),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          if (previewAsync == null)
            const SizedBox.shrink()
          else
            previewAsync.when(
              data: (preview) => RmsBridgeReservationPreviewView(
                preview: preview,
                onOpenDetails: () => context.go(
                  '/rms-bridge/reservation-details?reservationId=${Uri.encodeComponent(preview.reservationId)}',
                ),
              ),
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textPrimary),
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
