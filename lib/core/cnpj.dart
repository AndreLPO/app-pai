/// Validação e formatação de CNPJ.
abstract final class Cnpj {
  /// Mantém só os dígitos.
  static String limpar(String texto) => texto.replaceAll(RegExp(r'\D'), '');

  /// Verifica tamanho (14 dígitos) e dígitos verificadores.
  static bool isValido(String texto) {
    final d = limpar(texto);
    if (d.length != 14) return false;
    if (RegExp(r'^(\d)\1{13}$').hasMatch(d)) return false;
    final numeros = d.split('').map(int.parse).toList();
    return numeros[12] == _digito(numeros.sublist(0, 12)) &&
        numeros[13] == _digito(numeros.sublist(0, 13));
  }

  /// `70193852000128` -> `70.193.852/0001-28`. Textos sem 14 dígitos são
  /// devolvidos como estão.
  static String formatar(String texto) {
    final d = limpar(texto);
    if (d.length != 14) return texto;
    return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/'
        '${d.substring(8, 12)}-${d.substring(12)}';
  }

  static int _digito(List<int> base) {
    final pesos = base.length == 12
        ? const [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
        : const [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    var soma = 0;
    for (var i = 0; i < base.length; i++) {
      soma += base[i] * pesos[i];
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }
}
