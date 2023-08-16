import 'package:flutter/material.dart';

import 'package:projeto_1/decimal_text_input_formatter.dart';

class NotaInput extends StatelessWidget {
  const NotaInput({super.key, required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.all(20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          onChanged(double.tryParse(value));
        },
        inputFormatters: [DecimalTextInputFormatter(0, 10, decimalRange: 1)],
        validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }
}
