import '../../core/text_normalize.dart';

/// Colunas do layout de `DADOS.xlsx`, na ordem da planilha.
enum ColunaPlanilha {
  fantasia('FANTASIA'),
  ddd('DDD'),
  zap('ZAP'),
  contato('CONTATO'),
  razaoSocial('RAZÃO SOCIAL'),
  cnpj('CNPJ'),
  inscEstadual('INSC. ESTADUAL'),
  sequencia('SEQUÊNC'),
  cep('CEP'),
  rua('RUA'),
  bairro('BAIRRO'),
  cidade('CID'),
  data('DATA'),
  red('RED'),
  qtde('QTDE'),
  produto('PRODUTO'),
  valor('VALOR');

  const ColunaPlanilha(this.cabecalho);

  /// Cabeçalho gravado na exportação.
  final String cabecalho;

  /// Forma usada para reconhecer o cabeçalho no arquivo importado.
  String get chave => normalizarCabecalho(cabecalho);

  static String normalizarCabecalho(String texto) =>
      removerAcentos(texto).trim().toUpperCase();
}

/// Coluna extra gravada na exportação e ignorada na importação.
const cabecalhoTotal = 'TOTAL';

/// Nome da aba gerada na exportação.
const abaExportacao = 'CLIENTES';
