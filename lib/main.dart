import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math' as math;

import 'package:projeto_1/components/nota_input.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum Status {
  aprovado,
  recuperacao,
  reprovado;

  @override
  String toString() {
    switch (this) {
      case Status.aprovado:
        return "Aprovado";
      case Status.recuperacao:
        return "Em Recuperação";
      case Status.reprovado:
        return "Reprovado";
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  double? _nota1;
  double? _nota2;
  double? _nota3;
  double? _nota4;
  double mediaParcial = 0;
  double mediaFinal = 0;
  double? notaFaltando;
  Status? status;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _precisaNota4() {
    return _nota1 != null &&
        _nota2 != null &&
        _nota3 != null &&
        mediaParcial >= 3.5 &&
        mediaParcial < 7;
  }

  _update() {
    setState(() {
      mediaParcial = ((_nota1 ?? 0) + (_nota2 ?? 0) + (_nota3 ?? 0)) / 3;
      mediaParcial = (mediaParcial * 10).roundToDouble() / 10;

      if (_nota1 != null && _nota2 != null) {
        notaFaltando = 21 - (_nota1! + _nota2!);
      } else if (_nota1 != null && _nota3 != null) {
        notaFaltando = 21 - (_nota1! + _nota3!);
      } else if (_nota2 != null && _nota3 != null) {
        notaFaltando = 21 - (_nota2! + _nota3!);
      } else {
        notaFaltando = null;
      }

      if (mediaParcial < 3.5) {
        status = Status.reprovado;
      } else if (mediaParcial < 7) {
        status = Status.recuperacao;
      } else {
        status = Status.aprovado;
      }

      if (_nota1 == null || _nota2 == null || _nota3 == null) {
        status = null;
      }

      if (_precisaNota4()) {
        mediaFinal = (mediaParcial * 6 + (_nota4 ?? 0) * 4) / 10;
        mediaFinal = (mediaFinal * 10).roundToDouble() / 10;

        if (_nota4 == null) {
          notaFaltando = (50 - (mediaParcial * 6)) / 4;
          status = Status.recuperacao;
        } else {
          notaFaltando = null;
          if (mediaFinal >= 5) {
            status = Status.aprovado;
          } else {
            status = Status.reprovado;
          }
        }
      } else {
        mediaFinal = mediaParcial;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title:
            Image.asset('assets/logoufersa_simples_p.png', fit: BoxFit.cover),
      ),
      body: Center(
          child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            NotaInput(
              hint: "Nota 1",
              onChanged: (value) {
                _nota1 = value;
                _update();
              },
            ),
            NotaInput(
              hint: "Nota 2",
              onChanged: (value) {
                _nota2 = value;
                _update();
              },
            ),
            NotaInput(
              hint: "Nota 3",
              onChanged: (value) {
                _nota3 = value;
                _update();
              },
            ),
            if (_precisaNota4())
              NotaInput(
                hint: "Nota 4",
                onChanged: (value) {
                  _nota4 = value;
                  _update();
                },
              ),
            Center(
              child: Text(
                  "Sua média parcial é: ${mediaParcial.toStringAsFixed(1)}",
                  style: const TextStyle(fontSize: 20)),
            ),
            if (notaFaltando != null)
              Center(
                child: Text(
                    "Você precisa de: ${notaFaltando!.toStringAsFixed(1)}",
                    style: const TextStyle(fontSize: 20)),
              ),
            Center(
              child: Text("Sua média final é: ${mediaFinal.toStringAsFixed(1)}",
                  style: const TextStyle(fontSize: 20)),
            ),
            if (status != null)
              Center(
                child: Text("Você está: $status",
                    style: const TextStyle(fontSize: 20)),
              ),
          ],
        ),
      )),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter(this.min, this.max, {this.decimalRange})
      : assert(decimalRange == null || decimalRange > 0);

  final int min;
  final int max;
  final int? decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    if (decimalRange != null) {
      String value = newValue.text;

      if (value.contains(".") &&
          value.substring(value.indexOf(".") + 1).length > decimalRange!) {
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
    return newValue;
  }
}
