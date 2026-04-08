import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class ArabicDigitsToEnglishInputFormatter extends TextInputFormatter {
  static const _arabicIndic = <String, String>{
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
  };

  static const _easternArabicIndic = <String, String>{
    '۰': '0',
    '۱': '1',
    '۲': '2',
    '۳': '3',
    '۴': '4',
    '۵': '5',
    '۶': '6',
    '۷': '7',
    '۸': '8',
    '۹': '9',
  };

  static String _normalize(String text) {
    if (text.isEmpty) {
      return text;
    }
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      final mapped = _arabicIndic[char] ?? _easternArabicIndic[char];
      buffer.write(mapped ?? char);
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = _normalize(newValue.text);
    if (normalized == newValue.text) {
      return newValue;
    }
    final delta = normalized.length - newValue.text.length;
    final nextSelection = newValue.selection.copyWith(
      baseOffset: (newValue.selection.baseOffset + delta).clamp(
        0,
        normalized.length,
      ),
      extentOffset: (newValue.selection.extentOffset + delta).clamp(
        0,
        normalized.length,
      ),
    );
    return newValue.copyWith(text: normalized, selection: nextSelection);
  }
}

class HoverNumericStepperWrapper extends StatefulWidget {
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
  State<HoverNumericStepperWrapper> createState() =>
      _HoverNumericStepperWrapperState();
}

class _HoverNumericStepperWrapperState
    extends State<HoverNumericStepperWrapper> {
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
                  border: Border(
                    left: BorderSide(color: const Color(0xFFD5DEEE)),
                  ),
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
                                bottom: BorderSide(color: Color(0xFFD5DEEE)),
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
    _internalController =
        widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null &&
        widget.controller != oldWidget.controller) {
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
            borderSide: const BorderSide(color: Color(0xFFD5DEEE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.r4),
            borderSide: const BorderSide(color: Color(0xFFD5DEEE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.r4),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s10,
          ),
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
}

class CustomDropdown extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final bool isRequired;
  final String hint;
  final ValueChanged<String?>? onChanged;
  final bool enabled;
  final bool searchable;
  final double popupMaxHeight;
  final double fieldHeight;
  final String searchHintText;
  final String noResultsText;

  const CustomDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.isRequired = false,
    this.hint = 'Select',
    this.onChanged,
    this.enabled = true,
    this.searchable = true,
    this.popupMaxHeight = 170,
    this.fieldHeight = AppHeights.field34,
    this.searchHintText = 'Search',
    this.noResultsText = 'No results found',
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late TextEditingController _searchController;
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedValue = _normalizeValue(widget.value);
  }

  @override
  void didUpdateWidget(covariant CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value || widget.items != oldWidget.items) {
      _selectedValue = _normalizeValue(widget.value);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    super.dispose();
  }

  String? _normalizeValue(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!widget.items.contains(value)) {
      return null;
    }
    return value;
  }

  void _toggleOverlay() {
    if (!widget.enabled) {
      return;
    }
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _searchController.clear();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<String> _filteredItems() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.items;
    }
    return widget.items
        .where((item) => item.toLowerCase().contains(query))
        .toList(growable: false);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final fieldWidth =
        renderBox?.size.width ?? AppWidths.dropdownFallbackFieldWidth;
    return OverlayEntry(
      builder: (overlayContext) {
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
                      final filteredItems = _filteredItems();
                      return Container(
                        width: fieldWidth,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadii.r4),
                          border: Border.all(color: const Color(0xFFD5DEEE)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.searchable)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.s4,
                                  AppSpacing.s4,
                                  AppSpacing.s4,
                                  AppSpacing.s2,
                                ),
                                child: SizedBox(
                                  height: AppHeights.dropdownSearch30,
                                  child: TextField(
                                    controller: _searchController,
                                    autofocus: true,
                                    onChanged: (_) => setOverlayState(() {}),
                                    style: const TextStyle(
                                      fontSize: AppFontSizes.body12,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: widget.searchHintText,
                                      hintStyle: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: AppFontSizes.body12,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.s8,
                                            vertical: AppSpacing.s8,
                                          ),
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.r3,
                                        ),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD5DEEE),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.r3,
                                        ),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFD5DEEE),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadii.r3,
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: widget.popupMaxHeight,
                              ),
                              child: filteredItems.isEmpty
                                  ? Container(
                                      height: AppHeights.dropdownItem28,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.s8,
                                      ),
                                      child: Text(
                                        widget.noResultsText,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: AppFontSizes.body12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        final isSelected =
                                            item == _selectedValue;
                                        return Material(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.white,
                                          child: InkWell(
                                            hoverColor: const Color(0xFFF3F8FF),
                                            onTap: () {
                                              setState(() {
                                                _selectedValue = item;
                                              });
                                              widget.onChanged?.call(item);
                                              _removeOverlay();
                                            },
                                            child: Container(
                                              height: AppHeights.dropdownItem28,
                                              alignment: Alignment.centerLeft,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: AppSpacing.s8,
                                                  ),
                                              child: Text(
                                                item,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: AppFontSizes.body12,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors.textPrimary,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
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
    final valueText = _selectedValue ?? widget.hint;
    final showHint = _selectedValue == null;

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
        CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            onTap: _toggleOverlay,
            borderRadius: BorderRadius.circular(AppRadii.r4),
            child: Container(
              height: widget.fieldHeight,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
              decoration: BoxDecoration(
                color: widget.enabled ? Colors.white : AppColors.light,
                borderRadius: BorderRadius.circular(AppRadii.r4),
                border: Border.all(color: const Color(0xFFD5DEEE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      valueText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: showHint
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: AppFontSizes.label11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: AppIconSizes.s16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDatePickerField extends StatefulWidget {
  final String label;
  final bool isRequired;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onChanged;
  final String hintText;
  final double popupWidth;
  final bool enabled;
  final bool startEmpty;
  final bool autoOpen;
  final bool highlightToday;

  const CustomDatePickerField({
    super.key,
    required this.label,
    this.isRequired = false,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.hintText = 'dd/mm/yyyy',
    this.popupWidth = AppWidths.datePickerPopup,
    this.enabled = true,
    this.startEmpty = false,
    this.autoOpen = false,
    this.highlightToday = true,
  });

  @override
  State<CustomDatePickerField> createState() => _CustomDatePickerFieldState();
}

class _CustomDatePickerFieldState extends State<CustomDatePickerField> {
  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  DateTime? _selectedDate;
  DateTime? _hoveredDate;
  late DateTime _visibleMonth;
  late bool _isPristine;
  bool _didAutoOpen = false;

  DateTime get _effectiveFirstDate => widget.firstDate ?? DateTime(2000, 1, 1);
  DateTime get _effectiveLastDate => widget.lastDate ?? DateTime(2100, 12, 31);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final visibleBase = widget.initialDate ?? now;
    _isPristine = widget.startEmpty;
    _selectedDate = widget.startEmpty ? null : widget.initialDate;
    _visibleMonth = DateTime(visibleBase.year, visibleBase.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!widget.autoOpen || _didAutoOpen) {
        return;
      }
      _didAutoOpen = true;
      _openOverlay();
    });
  }

  @override
  void didUpdateWidget(covariant CustomDatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != oldWidget.initialDate) {
      final now = DateTime.now();
      final visibleBase = widget.initialDate ?? now;
      if (!_isPristine || widget.initialDate == null) {
        _selectedDate = widget.initialDate;
      } else if (oldWidget.initialDate != null) {
        _selectedDate = widget.initialDate;
        _isPristine = false;
      }
      _visibleMonth = DateTime(visibleBase.year, visibleBase.month, 1);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleOverlay() {
    if (!widget.enabled) {
      return;
    }
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _openOverlay();
  }

  void _openOverlay() {
    if (!widget.enabled) {
      return;
    }
    if (_overlayEntry != null) {
      return;
    }
    _hoveredDate = null;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _hoveredDate = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (overlayContext) {
        final screenWidth = MediaQuery.sizeOf(overlayContext).width;
        var popupWidth = widget.popupWidth;
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadii.r8),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s10,
                          vertical: AppSpacing.s8,
                        ),
                        child: _buildCalendarPopup(
                          onStateChanged: () => setOverlayState(() {}),
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

  Widget _buildCalendarPopup({required VoidCallback onStateChanged}) {
    final days = _buildCalendarDays(_visibleMonth);
    final selected = _selectedDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final monthLabel =
        '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                _visibleMonth = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month - 1,
                  1,
                );
                onStateChanged();
              },
              child: const SizedBox(
                width: AppDatePickerLayout.navButtonSize,
                height: AppDatePickerLayout.navButtonSize,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: AppIconSizes.s16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s6),
            Expanded(
              child: Text(
                monthLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSizes.body12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s6),
            GestureDetector(
              onTap: () {
                _visibleMonth = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month + 1,
                  1,
                );
                onStateChanged();
              },
              child: const SizedBox(
                width: AppDatePickerLayout.navButtonSize,
                height: AppDatePickerLayout.navButtonSize,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: AppIconSizes.s16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s4),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CalendarWeekdayLabel('Mo'),
            _CalendarWeekdayLabel('Tu'),
            _CalendarWeekdayLabel('We'),
            _CalendarWeekdayLabel('Th'),
            _CalendarWeekdayLabel('Fr'),
            _CalendarWeekdayLabel('Sa'),
            _CalendarWeekdayLabel('Su'),
          ],
        ),
        const SizedBox(height: AppSpacing.s2),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final day = days[index];
            final isCurrentMonth = day.month == _visibleMonth.month;
            final isSelected = selected != null && _isSameDate(day, selected);
            final isHovered =
                _hoveredDate != null && _isSameDate(day, _hoveredDate!);
            final isEnabled =
                !day.isBefore(_effectiveFirstDate) &&
                !day.isAfter(_effectiveLastDate);
            final isToday =
                widget.highlightToday && isEnabled && _isSameDate(day, today);

            final dayColor = !isEnabled
                ? AppColors.textSecondary.withValues(alpha: 0.35)
                : isCurrentMonth
                ? AppColors.textPrimary.withValues(alpha: 0.78)
                : AppColors.textSecondary.withValues(alpha: 0.5);

            return MouseRegion(
              cursor: isEnabled
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              onEnter: (_) {
                if (!isEnabled) return;
                _hoveredDate = day;
                onStateChanged();
              },
              onExit: (_) {
                if (_hoveredDate != null && _isSameDate(_hoveredDate!, day)) {
                  _hoveredDate = null;
                  onStateChanged();
                }
              },
              child: GestureDetector(
                onTap: isEnabled
                    ? () {
                        setState(() {
                          _isPristine = false;
                          _selectedDate = day;
                          _visibleMonth = DateTime(day.year, day.month, 1);
                        });
                        widget.onChanged?.call(day);
                        _removeOverlay();
                      }
                    : null,
                child: Center(
                  child: Container(
                    width: AppDatePickerLayout.dayCellSize,
                    height: AppDatePickerLayout.dayCellSize,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                          ? const Color(0xFFEAF3FF)
                          : isHovered && isEnabled
                          ? const Color(0xFFF3F8FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.r6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isToday || (isHovered && isEnabled))
                            ? AppColors.primary
                            : dayColor,
                        fontSize: AppFontSizes.badge10,
                        fontWeight: (isSelected || isToday)
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<DateTime> _buildCalendarDays(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final startOffset = (firstOfMonth.weekday + 6) % 7;
    final firstVisibleDate = firstOfMonth.subtract(Duration(days: startOffset));
    return List<DateTime>.generate(
      42,
      (index) => firstVisibleDate.add(Duration(days: index)),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final valueText = _selectedDate != null
        ? formatter.format(_selectedDate!)
        : widget.hintText;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
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
          InkWell(
            onTap: _toggleOverlay,
            borderRadius: BorderRadius.circular(AppRadii.r6),
            child: Container(
              height: AppHeights.field34,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
              decoration: BoxDecoration(
                color: widget.enabled ? Colors.white : AppColors.light,
                borderRadius: BorderRadius.circular(AppRadii.r6),
                border: Border.all(color: const Color(0xFFD5DEEE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      valueText,
                      style: TextStyle(
                        color: _selectedDate == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: AppFontSizes.label11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: AppIconSizes.s14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarWeekdayLabel extends StatelessWidget {
  final String text;

  const _CalendarWeekdayLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppDatePickerLayout.dayCellSize,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: AppFontSizes.badge10,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class CustomTimePickerField extends StatefulWidget {
  final String label;
  final bool isRequired;
  final TextEditingController? controller;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onChanged;
  final String hintText;
  final bool enabled;

  const CustomTimePickerField({
    super.key,
    required this.label,
    this.isRequired = false,
    this.controller,
    this.initialTime,
    this.onChanged,
    this.hintText = 'HH:mm',
    this.enabled = true,
  });

  @override
  State<CustomTimePickerField> createState() => _CustomTimePickerFieldState();
}

class _CustomTimePickerFieldState extends State<CustomTimePickerField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = _initialTimeFromWidget();
    _syncController();
  }

  @override
  void didUpdateWidget(covariant CustomTimePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller ||
        widget.initialTime != oldWidget.initialTime) {
      _selectedTime = _initialTimeFromWidget();
      _syncController();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  TimeOfDay _initialTimeFromWidget() {
    final parsed = _tryParse(widget.controller?.text ?? '');
    if (parsed != null) {
      return parsed;
    }
    if (widget.initialTime != null) {
      return widget.initialTime!;
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  TimeOfDay? _tryParse(String raw) {
    final text = raw.trim();
    final match = RegExp(r'^(\d{1,2}):(\d{1,2})$').firstMatch(text);
    if (match == null) {
      return null;
    }
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _format(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _syncController() {
    final controller = widget.controller;
    if (controller == null) {
      return;
    }
    final nextText = _format(_selectedTime);
    if (controller.text != nextText) {
      controller.text = nextText;
    }
  }

  void _toggleOverlay() {
    if (!widget.enabled) {
      return;
    }
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

  void _setTime(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
    _syncController();
    widget.onChanged?.call(time);
  }

  TimeOfDay _withHour(int hour) {
    final normalized = hour % 24;
    return TimeOfDay(hour: normalized, minute: _selectedTime.minute);
  }

  TimeOfDay _withMinute(int minute) {
    final normalized = minute % 60;
    return TimeOfDay(hour: _selectedTime.hour, minute: normalized);
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final fieldWidth =
        renderBox?.size.width ?? AppTimePickerLayout.minPopupWidth;
    final popupWidth = fieldWidth < AppTimePickerLayout.minPopupWidth
        ? AppTimePickerLayout.minPopupWidth
        : fieldWidth;

    return OverlayEntry(
      builder: (overlayContext) {
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
                  child: Container(
                    width: popupWidth,
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadii.r8),
                      border: Border.all(color: const Color(0xFFD5DEEE)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x16000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TimeSpinnerColumn(
                          valueText: _selectedTime.hour.toString().padLeft(
                            2,
                            '0',
                          ),
                          onIncrement: () =>
                              _setTime(_withHour(_selectedTime.hour + 1)),
                          onDecrement: () =>
                              _setTime(_withHour(_selectedTime.hour - 1)),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s6,
                          ),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: AppFontSizes.title14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        _TimeSpinnerColumn(
                          valueText: _selectedTime.minute.toString().padLeft(
                            2,
                            '0',
                          ),
                          onIncrement: () =>
                              _setTime(_withMinute(_selectedTime.minute + 1)),
                          onDecrement: () =>
                              _setTime(_withMinute(_selectedTime.minute - 1)),
                        ),
                      ],
                    ),
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
    final valueText = _format(_selectedTime);
    final showHint =
        widget.controller == null &&
        widget.initialTime == null &&
        valueText == '00:00';

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
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
          InkWell(
            onTap: _toggleOverlay,
            borderRadius: BorderRadius.circular(AppRadii.r6),
            child: Container(
              height: AppHeights.field34,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
              decoration: BoxDecoration(
                color: widget.enabled ? Colors.white : AppColors.light,
                borderRadius: BorderRadius.circular(AppRadii.r6),
                border: Border.all(color: const Color(0xFFD5DEEE)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      showHint ? widget.hintText : valueText,
                      style: TextStyle(
                        color: showHint
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: AppFontSizes.label11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.access_time,
                    size: AppIconSizes.s14,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeSpinnerColumn extends StatelessWidget {
  final String valueText;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _TimeSpinnerColumn({
    required this.valueText,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppTimePickerLayout.spinnerWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onIncrement,
            borderRadius: BorderRadius.circular(AppRadii.r4),
            child: const SizedBox(
              height: AppTimePickerLayout.arrowButtonHeight,
              width: AppTimePickerLayout.spinnerWidth,
              child: Icon(
                Icons.keyboard_arrow_up,
                size: AppIconSizes.s18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            height: AppTimePickerLayout.valueHeight,
            width: AppTimePickerLayout.spinnerWidth,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD5DEEE)),
              borderRadius: BorderRadius.circular(AppRadii.r4),
              color: Colors.white,
            ),
            child: Text(
              valueText,
              style: const TextStyle(
                fontSize: AppFontSizes.body12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          InkWell(
            onTap: onDecrement,
            borderRadius: BorderRadius.circular(AppRadii.r4),
            child: const SizedBox(
              height: AppTimePickerLayout.arrowButtonHeight,
              width: AppTimePickerLayout.spinnerWidth,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: AppIconSizes.s18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
