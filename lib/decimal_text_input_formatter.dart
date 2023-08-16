import 'package:flutter/services.dart';

import 'dart:math' as math;

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter(this.min, this.max, {required this.decimalRange})
      : assert(decimalRange > 0);

  final int min;
  final int max;
  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    double? number = double.tryParse(truncated);

    if (number != null) {
      if (number < min) {
        truncated = min.toStringAsFixed(decimalRange!);
      } else if (number > max) {
        truncated = max.toStringAsFixed(decimalRange!);
      }
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}
