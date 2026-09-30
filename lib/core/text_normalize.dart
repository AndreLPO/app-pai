const _comAcento = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖòóôõöÙÚÛÜùúûüÇçÑñÝýÿ';
const _semAcento = 'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOoooooUUUUuuuuCcNnYyy';

/// Remove acentos preservando maiúsculas/minúsculas.
String removerAcentos(String texto) {
  final buffer = StringBuffer();
  for (final rune in texto.runes) {
    final c = String.fromCharCode(rune);
    final i = _comAcento.indexOf(c);
    buffer.write(i >= 0 ? _semAcento[i] : c);
  }
  return buffer.toString();
}

/// Forma usada em buscas e ordenação: minúsculas e sem acento.
String normalizar(String texto) => removerAcentos(texto).toLowerCase();

/// Compara dois textos ignorando maiúsculas e acentos.
bool contemNormalizado(String texto, String busca) =>
    normalizar(texto).contains(normalizar(busca));

/// Maiúsculas, sem espaços nas pontas; `null` quando vazio.
String? maiusculasOuNulo(String? texto) {
  final t = texto?.trim();
  if (t == null || t.isEmpty) return null;
  return t.toUpperCase();
}
