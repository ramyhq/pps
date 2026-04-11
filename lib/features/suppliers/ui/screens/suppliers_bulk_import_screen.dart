import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pps/core/constants/app_colors.dart';
import 'package:pps/core/widgets/app_dialog.dart';
import '../../../../core/widgets/module_bulk_import_layout.dart';
import '../../provider/suppliers_bulk_import_provider.dart';

class SuppliersBulkImportScreen extends ConsumerStatefulWidget {
  const SuppliersBulkImportScreen({super.key});

  @override
  ConsumerState<SuppliersBulkImportScreen> createState() =>
      _SuppliersBulkImportScreenState();
}

class _SuppliersBulkImportScreenState
    extends ConsumerState<SuppliersBulkImportScreen> {
  late final ProviderSubscription<SuppliersBulkImportState>
  _pendingImportSubscription;

  @override
  void initState() {
    super.initState();
    _pendingImportSubscription = ref.listenManual(suppliersBulkImportProvider, (
      previous,
      next,
    ) {
      final pending = next.pendingImport;
      if (pending == null) return;
      if (previous?.pendingImport == pending) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showConfirmDialog(pending);
      });
    });
  }

  @override
  void dispose() {
    _pendingImportSubscription.close();
    super.dispose();
  }

  Future<void> _showConfirmDialog(SuppliersPendingImport pending) async {
    final notifier = ref.read(suppliersBulkImportProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AppDialog(
          title: const Text(
            'Confirm Import',
            style: TextStyle(
              fontSize: AppFontSizes.title14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File: ${pending.fileName}',
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Rows: ${pending.totalRecords} (Valid: ${pending.validRecords}, Invalid: ${pending.invalidRecords})',
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.s6),
              Text(
                'Existing codes in DB: ${pending.existingCodesInDb}',
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (pending.duplicateCodesInFile > 0) ...[
                const SizedBox(height: AppSpacing.s6),
                Text(
                  'Duplicate codes in file: ${pending.duplicateCodesInFile} (will be skipped)',
                  style: const TextStyle(
                    fontSize: AppFontSizes.body12,
                    color: AppColors.warning,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.s12),
              const Text(
                'Warning: Existing records with the same code may be overridden. This cannot be undone.',
                style: TextStyle(
                  fontSize: AppFontSizes.body12,
                  color: AppColors.danger,
                  height: 1.35,
                ),
              ),
            ],
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(110, AppHeights.button32),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.r8),
                ),
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      await notifier.confirmImport();
    } else {
      notifier.cancelPendingImport();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(suppliersBulkImportProvider);
    final notifier = ref.read(suppliersBulkImportProvider.notifier);

    return ModuleBulkImportLayout(
      title: 'Bulk Import Suppliers',
      description:
          'Download the template, fill in your suppliers data, and upload to import them all at once.',
      onDownloadTemplate: notifier.downloadTemplate,
      onUploadData: notifier.prepareUpload,
      logs: state.logs,
      isUploading: state.isUploading,
    );
  }
}
