/// Valores monetários representados como centavos inteiros, para evitar
/// erros de ponto flutuante (ex.: `73.06999999999999` vindo do Excel).
abstract final class Money {
  /// Converte um valor em reais (double) para centavos, arredondando.
  static int fromDouble(double reais) => (reais * 100).round();

  /// `123456` -> `R$ 1.234,56`
  static String format(int centavos) => 'R\$ ${formatSemSimbolo(centavos)}';

  /// `123456` -> `1.234,56`
  static String formatSemSimbolo(int centavos) {
    final negativo = centavos < 0;
    final abs = centavos.abs();
    final reais = _agruparMilhares((abs ~/ 100).toString());
    final cents = (abs % 100).toString().padLeft(2, '0');
    return '${negativo ? '-' : ''}$reais,$cents';
  }

  /// Interpreta um texto digitado no padrão brasileiro e devolve centavos.
  ///
  /// Aceita `R$ 1.234,56`, `1234,5`, `7`, `7.50`. Retorna `null` se inválido.
  static int? parse(String texto) {
    var t = texto.replaceAll('R\$', '').replaceAll(RegExp(r'\s'), '');
    if (t.isEmpty) return null;
    final negativo = t.startsWith('-');
    if (negativo) t = t.substring(1);

    String inteiro;
    String decimal;
    if (t.contains(',')) {
      final partes = t.split(',');
      if (partes.length != 2) return null;
      inteiro = partes[0].replaceAll('.', '');
      decimal = partes[1];
    } else {
      final ultimoPonto = t.lastIndexOf('.');
      if (ultimoPonto >= 0 && t.length - ultimoPonto - 1 <= 2) {
        inteiro = t.substring(0, ultimoPonto).replaceAll('.', '');
        decimal = t.substring(ultimoPonto + 1);
      } else {
        inteiro = t.replaceAll('.', '');
        decimal = '';
      }
    }
    if (inteiro.isEmpty) inteiro = '0';
    if (decimal.length > 2) return null;
    if (!RegExp(r'^\d+$').hasMatch(inteiro) ||
        (decimal.isNotEmpty && !RegExp(r'^\d+$').hasMatch(decimal))) {
      return null;
    }
    final valor = int.parse(inteiro) * 100 + int.parse(decimal.padRight(2, '0'));
    return negativo ? -valor : valor;
  }

  static String _agruparMilhares(String digitos) {
    final buffer = StringBuffer();
    for (var i = 0; i < digitos.length; i++) {
      if (i > 0 && (digitos.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digitos[i]);
    }
    return buffer.toString();
  }
}

/// Formatação de inteiros com separador de milhar (`1200` -> `1.200`).
String formatInteiro(int valor) {
  final s = valor.abs().toString();
  final buffer = StringBuffer(valor < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return buffer.toString();
}
