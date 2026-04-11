import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pps/core/constants/app_colors.dart';
import 'package:pps/core/widgets/custom_form_fields.dart';
import 'package:pps/features/hotels/provider/hotels_add_provider.dart';

class HotelsAddScreen extends ConsumerStatefulWidget {
  const HotelsAddScreen({super.key});

  @override
  ConsumerState<HotelsAddScreen> createState() => _HotelsAddScreenState();
}

class _HotelsAddScreenState extends ConsumerState<HotelsAddScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _supplierIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _cityController.dispose();
    _categoryController.dispose();
    _supplierIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final city = _cityController.text.trim();
    final category = _categoryController.text.trim();
    final supplierIdRaw = _supplierIdController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required.')),
      );
      return;
    }

    int? supplierId;
    if (supplierIdRaw.isNotEmpty) {
      supplierId = int.tryParse(supplierIdRaw);
      if (supplierId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier ID must be a number.')),
        );
        return;
      }
    }

    final notifier = ref.read(hotelsAddProvider.notifier);
    final error = await notifier.submit(
      name: name,
      code: code.isEmpty ? null : code,
      city: city.isEmpty ? null : city,
      category: category.isEmpty ? null : category,
      supplierId: supplierId,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hotel saved successfully.')),
      );
      context.go('/hotels');
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hotelsAddProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleSection(context),
            const SizedBox(height: AppSpacing.s24),
            _buildDetailsCard(),
            const SizedBox(height: AppSpacing.s24),
            _buildBottomActions(context, isSaving: state.isSaving),
            const SizedBox(height: AppSpacing.s40),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Hotel', style: AppTextStyles.heading),
            const SizedBox(height: AppSpacing.s4),
            Row(
              children: [
                const Text(
                  'Hotels',
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
                  'Add',
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
          onPressed: () => context.go('/hotels'),
          icon: const Icon(Icons.arrow_back, size: AppIconSizes.s16),
          label: const Text('Back'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r4),
            ),
            backgroundColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
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
                  'Hotel details',
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
                final isDesktop = constraints.maxWidth > 900;

                if (isDesktop) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Name',
                              isRequired: true,
                              controller: _nameController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s16),
                          Expanded(
                            child: CustomTextField(
                              label: 'Code',
                              controller: _codeController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'City',
                              controller: _cityController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s16),
                          Expanded(
                            child: CustomTextField(
                              label: 'Category',
                              controller: _categoryController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              label: 'Supplier ID',
                              controller: _supplierIdController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Name',
                      isRequired: true,
                      controller: _nameController,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    CustomTextField(
                      label: 'Code',
                      controller: _codeController,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    CustomTextField(
                      label: 'City',
                      controller: _cityController,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    CustomTextField(
                      label: 'Category',
                      controller: _categoryController,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    CustomTextField(
                      label: 'Supplier ID',
                      controller: _supplierIdController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

  Widget _buildBottomActions(BuildContext context, {required bool isSaving}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: isSaving ? null : () => context.go('/hotels'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.white,
            side: const BorderSide(color: AppColors.inputBorder),
            minimumSize: const Size(110, AppHeights.button32),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r6),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: AppSpacing.s8),
        ElevatedButton.icon(
          onPressed: isSaving ? null : _submit,
          icon: const Icon(Icons.save, size: AppIconSizes.s16),
          label: const Text('Save'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.actionGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size(120, AppHeights.button32),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.r6),
            ),
          ),
        ),
      ],
    );
  }
}

