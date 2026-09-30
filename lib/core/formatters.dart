import 'package:flutter/services.dart';

import 'money.dart';

/// Converte tudo o que é digitado para maiúsculas.
class MaiusculasFormatter extends TextInputFormatter {
  const MaiusculasFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Máscara fixa onde `0` representa um dígito (ex.: `00000-000`).
class MascaraFormatter extends TextInputFormatter {
  const MascaraFormatter(this.mascara);

  final String mascara;

  static String aplicar(String mascara, String texto) {
    final digitos = texto.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    var i = 0;
    for (final c in mascara.split('')) {
      if (i >= digitos.length) break;
      if (c == '0') {
        buffer.write(digitos[i++]);
      } else {
        buffer.write(c);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = aplicar(mascara, newValue.text);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// CEP: `00000-000`.
const cepFormatter = MascaraFormatter('00000-000');

/// CNPJ: `00.000.000/0000-00`.
const cnpjFormatter = MascaraFormatter('00.000.000/0000-00');

/// Telefone: `0000-0000` (8 dígitos) ou `0 0000-0000` (9 dígitos).
class TelefoneFormatter extends TextInputFormatter {
  const TelefoneFormatter();

  static String aplicar(String texto) {
    final d = texto.replaceAll(RegExp(r'\D'), '');
    final limitado = d.length > 9 ? d.substring(0, 9) : d;
    return MascaraFormatter.aplicar(
      limitado.length == 9 ? '0 0000-0000' : '0000-0000',
      limitado,
    );
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = aplicar(newValue.text);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

/// DDD: somente 2 dígitos.
final List<TextInputFormatter> dddFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(2),
];

/// Moeda estilo caixa eletrônico: os dígitos entram pela direita como
/// centavos (`7`, `79`, `799` -> `7,99`).
class MoedaFormatter extends TextInputFormatter {
  const MoedaFormatter();

  static String aplicar(String texto) {
    final d = texto.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return '';
    final limitado = d.length > 12 ? d.substring(0, 12) : d;
    return Money.formatSemSimbolo(int.parse(limitado));
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final texto = aplicar(newValue.text);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}
