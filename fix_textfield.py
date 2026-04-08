import re
import sys

def main():
    file_path = "lib/core/widgets/custom_form_fields.dart"
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Step 1: Replace CustomTextField
    old_class = """class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final bool isRequired;
  final Widget? suffixIcon;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.suffixIcon,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveInputFormatters = <TextInputFormatter>[
      ArabicDigitsToEnglishInputFormatter(),
      ...?inputFormatters,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: effectiveInputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSizes.body12,
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: suffixIcon,
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
            contentPadding: AppInsets.inputContentDense,
            isDense: true,
          ),
          style: const TextStyle(
            fontSize: AppFontSizes.body12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}"""

    new_class = """class HoverNumericStepperWrapper extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final Widget child;
  final int minValue;

  const HoverNumericStepperWrapper({
    super.key,
    required this.controller,
    required this.child,
    this.focusNode,
    this.onChanged,
    this.minValue = 1,
  });

  @override
  State<HoverNumericStepperWrapper> createState() => _HoverNumericStepperWrapperState();
}

class _HoverNumericStepperWrapperState extends State<HoverNumericStepperWrapper> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant HoverNumericStepperWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      widget.focusNode?.addListener(_onFocusChange);
      _onFocusChange();
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = widget.focusNode?.hasFocus ?? false;
      });
    }
  }

  void _increment() {
    final currentValue = int.tryParse(widget.controller.text) ?? 0;
    final newValue = (currentValue + 1).toString();
    widget.controller.text = newValue;
    widget.onChanged?.call(newValue);
  }

  void _decrement() {
    final currentValue = int.tryParse(widget.controller.text) ?? 0;
    if (currentValue > widget.minValue) {
      final newValue = (currentValue - 1).toString();
      widget.controller.text = newValue;
      widget.onChanged?.call(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showStepper = _isHovered || _isFocused;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.centerRight,
        children: [
          widget.child,
          if (showStepper)
            Positioned(
              right: 1,
              top: 1,
              bottom: 1,
              child: Container(
                width: 18,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                  border: Border(left: BorderSide(color: AppColors.border)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _increment,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(3),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.border),
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_drop_up,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: _decrement,
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_drop_down,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool isRequired;
  final Widget? suffixIcon;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool showStepper;
  final int stepperMinValue;
  final double fieldHeight;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.isRequired = false,
    this.suffixIcon,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.showStepper = false,
    this.stepperMinValue = 1,
    this.fieldHeight = AppHeights.field34,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _internalController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != oldWidget.controller) {
      _internalController = widget.controller!;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveInputFormatters = <TextInputFormatter>[
      ArabicDigitsToEnglishInputFormatter(),
      ...?widget.inputFormatters,
    ];

    Widget textField = SizedBox(
      height: widget.fieldHeight,
      child: TextFormField(
        controller: _internalController,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        keyboardType: widget.keyboardType,
        inputFormatters: effectiveInputFormatters,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppFontSizes.body12,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: widget.suffixIcon,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
          // isDense: true, // Removed per user request
        ),
        style: const TextStyle(
          fontSize: AppFontSizes.body12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

    if (widget.showStepper) {
      textField = HoverNumericStepperWrapper(
        controller: _internalController,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        minValue: widget.stepperMinValue,
        child: textField,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                  fontSize: AppFontSizes.label11,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        textField,
      ],
    );
  }
}"""

    if old_class in content:
        content = content.replace(old_class, new_class)
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        print("Success")
    else:
        print("Failed to find class block")

if __name__ == "__main__":
    main()
