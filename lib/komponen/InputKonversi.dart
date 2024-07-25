import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    // Hilangkan titik pemisah ribuan dan koma desimal
    int value = int.parse(newValue.text.replaceAll('.', '').replaceAll(',', ''));

    final formatter = NumberFormat('#,###');
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText.replaceAll(',', '.'), // Ganti koma dengan titik sebagai desimal
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
