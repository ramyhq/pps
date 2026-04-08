import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pps/core/constants/app_colors.dart';

class SegmentedTimePicker extends StatefulWidget {
  final String label;
  final bool isRequired;
  final TextEditingController? controller;
  final bool enabled;

  const SegmentedTimePicker({
    super.key,
    required this.label,
    this.isRequired = false,
    this.controller,
    this.enabled = true,
  });

  @override
  State<SegmentedTimePicker> createState() => _SegmentedTimePickerState();
}

class _SegmentedTimePickerState extends State<SegmentedTimePicker> {
  final FocusNode _focusNode = FocusNode();
  int _selectedSegment = -1; // 0: hour, 1: minute, 2: period

  int? _hour; // 1-12
  int? _minute; // 0-59
  bool? _isAm; // true: AM, false: PM

  String _typedBuffer = '';

  @override
  void initState() {
    super.initState();
    _loadFromController();
    widget.controller?.addListener(_onControllerChanged);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _selectedSegment == -1) {
        setState(() => _selectedSegment = 0);
      } else if (!_focusNode.hasFocus) {
        setState(() {
          _selectedSegment = -1;
          _typedBuffer = '';
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant SegmentedTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
      _loadFromController();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!_focusNode.hasFocus) {
      _loadFromController();
    }
  }

  void _loadFromController() {
    final text = widget.controller?.text ?? '';
    final match = RegExp(r'^(\d{1,2}):(\d{1,2})$').firstMatch(text.trim());
    if (match != null) {
      int h = int.parse(match.group(1)!);
      int m = int.parse(match.group(2)!);
      setState(() {
        _minute = m;
        _isAm = h < 12;
        if (h == 0) {
          _hour = 12;
        } else if (h > 12) {
          _hour = h - 12;
        } else {
          _hour = h;
        }
      });
    } else {
      setState(() {
        _hour = null;
        _minute = null;
        _isAm = null;
      });
    }
  }

  void _saveToController() {
    if (widget.controller == null) return;
    if (_hour == null || _minute == null || _isAm == null) {
      if (widget.controller!.text != '') {
        widget.controller!.text = '';
      }
      return;
    }
    int h = _hour!;
    if (_isAm!) {
      if (h == 12) h = 0;
    } else {
      if (h != 12) h += 12;
    }
    final text =
        '${h.toString().padLeft(2, '0')}:${_minute!.toString().padLeft(2, '0')}';
    if (widget.controller!.text != text) {
      widget.controller!.text = text;
    }
  }

  bool _handleKey(KeyEvent event) {
    if (!widget.enabled) return false;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight) {
      setState(() => _selectedSegment = (_selectedSegment + 1) % 3);
      _typedBuffer = '';
      return true;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      setState(() => _selectedSegment = (_selectedSegment - 1) % 3);
      if (_selectedSegment < 0) _selectedSegment += 3;
      _typedBuffer = '';
      return true;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _incrementSegment(1);
      _typedBuffer = '';
      return true;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _incrementSegment(-1);
      _typedBuffer = '';
      return true;
    } else if (key.keyId >= LogicalKeyboardKey.digit0.keyId &&
        key.keyId <= LogicalKeyboardKey.digit9.keyId) {
      final digit = key.keyId - LogicalKeyboardKey.digit0.keyId;
      _handleDigit(digit);
      return true;
    } else if (key.keyId >= LogicalKeyboardKey.numpad0.keyId &&
        key.keyId <= LogicalKeyboardKey.numpad9.keyId) {
      final digit = key.keyId - LogicalKeyboardKey.numpad0.keyId;
      _handleDigit(digit);
      return true;
    } else if (key == LogicalKeyboardKey.keyA) {
      if (_selectedSegment == 2) {
        setState(() => _isAm = true);
        _saveToController();
      }
      return true;
    } else if (key == LogicalKeyboardKey.keyP) {
      if (_selectedSegment == 2) {
        setState(() => _isAm = false);
        _saveToController();
      }
      return true;
    }
    return false;
  }

  void _handleDigit(int digit) {
    if (_selectedSegment == 0) {
      // Hour
      _typedBuffer += digit.toString();
      int val = int.tryParse(_typedBuffer) ?? 0;
      if (val >= 10 && val <= 23) {
        setState(() {
          if (val >= 12) {
            _isAm = false;
            _hour = val > 12 ? val - 12 : 12;
          } else {
            _isAm = true;
            _hour = val == 0 ? 12 : val;
          }
          _selectedSegment = 1; // Auto move to minutes
          _typedBuffer = '';
        });
      } else if (val >= 1 && val <= 9) {
        setState(() {
          _hour = val;
          if (_typedBuffer.length == 2 || val >= 3) {
            _selectedSegment = 1;
            _typedBuffer = '';
          }
        });
      } else if (val == 0) {
        if (_typedBuffer.length == 2) {
          setState(() {
            _hour = 12;
            _selectedSegment = 1;
            _typedBuffer = '';
          });
        }
      } else {
        _typedBuffer = digit.toString();
        setState(() => _hour = int.tryParse(_typedBuffer) ?? 0);
      }
    } else if (_selectedSegment == 1) {
      // Minute
      _typedBuffer += digit.toString();
      int val = int.tryParse(_typedBuffer) ?? 0;
      if (val >= 60) {
        _typedBuffer = digit.toString();
        val = digit;
      }
      setState(() {
        _minute = val;
        if (_typedBuffer.length == 2 || val >= 6) {
          _selectedSegment = 2; // Auto move to period
          _typedBuffer = '';
        }
      });
    }
    _saveToController();
  }

  void _incrementSegment(int delta) {
    setState(() {
      if (_selectedSegment == 0) {
        int h = (_hour ?? 12) + delta;
        if (h > 12) h = 1;
        if (h < 1) h = 12;
        _hour = h;
      } else if (_selectedSegment == 1) {
        int m = (_minute ?? 0) + delta;
        if (m > 59) m = 0;
        if (m < 0) m = 59;
        _minute = m;
      } else if (_selectedSegment == 2) {
        _isAm = !(_isAm ?? true);
      }
    });
    _saveToController();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty)
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
        if (widget.label.isNotEmpty) const SizedBox(height: AppSpacing.s4),
        Focus(
          focusNode: _focusNode,
          onKeyEvent: (node, event) {
            final handled = _handleKey(event);
            return handled ? KeyEventResult.handled : KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: () {
              if (widget.enabled && !_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
            },
            child: Container(
              height: AppHeights.field34,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10),
              decoration: BoxDecoration(
                color: widget.enabled ? Colors.white : AppColors.light,
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.primary
                      : const Color(0xFFD5DEEE),
                ),
                borderRadius: BorderRadius.circular(AppRadii.r6),
              ),
              child: Row(
                children: [
                  _buildSegment(0, _hour?.toString().padLeft(2, '0') ?? '--'),
                  const Text(
                    ':',
                    style: TextStyle(
                      fontSize: AppFontSizes.label11,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _buildSegment(1, _minute?.toString().padLeft(2, '0') ?? '--'),
                  const SizedBox(width: AppSpacing.s4),
                  _buildSegment(
                    2,
                    _isAm == null ? '--' : (_isAm! ? 'AM' : 'PM'),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.access_time,
                    size: AppIconSizes.s14,
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

  Widget _buildSegment(int index, String text) {
    final isSelected = _selectedSegment == index;
    return GestureDetector(
      onTap: () {
        if (!widget.enabled) return;
        _focusNode.requestFocus();
        setState(() {
          _selectedSegment = index;
          _typedBuffer = '';
        });
      },
      child: Container(
        color: isSelected ? const Color(0xFFD1E9FF) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppFontSizes.label11,
            fontWeight: FontWeight.w500,
            color: widget.enabled
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
