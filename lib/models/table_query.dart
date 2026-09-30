import '../core/datas.dart';
import '../core/money.dart';

/// Tipo de dado de uma coluna de tabela: define formatação, ordenação e o
/// tipo de filtro oferecido.
enum TipoColuna { texto, categoria, inteiro, moeda, data }

/// Descrição de uma coluna exibida em uma tabela.
class ColunaTabela {
  const ColunaTabela({
    required this.id,
    required this.rotulo,
    required this.tipo,
    this.largura = 150,
    this.ordenavel = true,
    this.filtravel = true,
  });

  final String id;
  final String rotulo;
  final TipoColuna tipo;
  final double largura;
  final bool ordenavel;
  final bool filtravel;

  /// Texto exibido para um valor desta coluna.
  String formatar(Object? valor) {
    if (valor == null) return '';
    return switch (tipo) {
      TipoColuna.moeda => Money.format(valor as int),
      TipoColuna.inteiro => valor is int ? formatInteiro(valor) : '$valor',
      TipoColuna.data => formatarData(valor as DateTime),
      _ => '$valor',
    };
  }
}

/// Filtro aplicado a uma coluna (ou filtro especial, tratado pelo DAO).
sealed class Filtro {
  const Filtro(this.colunaId);

  final String colunaId;

  /// Texto do chip do filtro.
  String descrever(String rotuloColuna);
}

/// Texto contém (sem diferenciar maiúsculas e acentos).
class FiltroContem extends Filtro {
  const FiltroContem(super.colunaId, this.texto);

  final String texto;

  @override
  String descrever(String rotuloColuna) => '$rotuloColuna contém "$texto"';
}

/// Valor igual a um dos valores escolhidos (colunas categóricas).
class FiltroIgual extends Filtro {
  const FiltroIgual(super.colunaId, this.valores);

  final Set<String> valores;

  @override
  String descrever(String rotuloColuna) =>
      '$rotuloColuna = ${valores.join(', ')}';
}

/// Intervalo numérico. Para moeda, os limites estão em centavos.
class FiltroIntervalo extends Filtro {
  const FiltroIntervalo(super.colunaId, {this.minimo, this.maximo, this.moeda = false});

  final int? minimo;
  final int? maximo;
  final bool moeda;

  String _fmt(int v) => moeda ? Money.format(v) : formatInteiro(v);

  @override
  String descrever(String rotuloColuna) {
    if (minimo != null && maximo != null) {
      return '$rotuloColuna entre ${_fmt(minimo!)} e ${_fmt(maximo!)}';
    }
    if (minimo != null) return '$rotuloColuna ≥ ${_fmt(minimo!)}';
    return '$rotuloColuna ≤ ${_fmt(maximo!)}';
  }
}

/// Intervalo de datas (inclusivo).
class FiltroPeriodo extends Filtro {
  const FiltroPeriodo(super.colunaId, {this.de, this.ate});

  final DateTime? de;
  final DateTime? ate;

  @override
  String descrever(String rotuloColuna) {
    if (de != null && ate != null) {
      return '$rotuloColuna de ${formatarData(de!)} a ${formatarData(ate!)}';
    }
    if (de != null) return '$rotuloColuna a partir de ${formatarData(de!)}';
    return '$rotuloColuna até ${formatarData(ate!)}';
  }
}

/// Filtro com regra própria, interpretado pelo DAO da tabela
/// (ex.: clientes sem compra recente).
class FiltroEspecial extends Filtro {
  const FiltroEspecial(super.colunaId, this.rotulo);

  final String rotulo;

  @override
  String descrever(String rotuloColuna) => rotulo;
}

/// Estado completo de uma consulta de tabela: busca, filtros, ordenação e
/// página. Imutável.
class TableQuery {
  const TableQuery({
    this.busca = '',
    this.filtros = const [],
    this.ordenarPor,
    this.crescente = true,
    this.pagina = 0,
    this.tamanhoPagina = 50,
  });

  final String busca;
  final List<Filtro> filtros;
  final String? ordenarPor;
  final bool crescente;
  final int pagina;
  final int tamanhoPagina;

  int get offset => pagina * tamanhoPagina;

  TableQuery copyWith({
    String? busca,
    List<Filtro>? filtros,
    String? ordenarPor,
    bool? crescente,
    int? pagina,
    int? tamanhoPagina,
  }) =>
      TableQuery(
        busca: busca ?? this.busca,
        filtros: filtros ?? this.filtros,
        ordenarPor: ordenarPor ?? this.ordenarPor,
        crescente: crescente ?? this.crescente,
        pagina: pagina ?? this.pagina,
        tamanhoPagina: tamanhoPagina ?? this.tamanhoPagina,
      );

  /// Substitui (ou adiciona) o filtro da mesma coluna e volta à 1ª página.
  TableQuery comFiltro(Filtro filtro) => copyWith(
        filtros: [
          for (final f in filtros)
            if (f.colunaId != filtro.colunaId) f,
          filtro,
        ],
        pagina: 0,
      );

  TableQuery semFiltro(String colunaId) => copyWith(
        filtros: [for (final f in filtros) if (f.colunaId != colunaId) f],
        pagina: 0,
      );
}

/// Uma linha de tabela: o registro de origem e os valores por coluna.
class LinhaTabela<T> {
  const LinhaTabela(this.registro, this.valores);

  final T registro;
  final Map<String, Object?> valores;
}

/// Resultado de uma página.
class PaginaTabela<T> {
  const PaginaTabela({
    required this.linhas,
    required this.total,
    this.somas = const {},
  });

  final List<LinhaTabela<T>> linhas;
  final int total;

  /// Somas por coluna das linhas filtradas (todas as páginas).
  final Map<String, int> somas;
}

/// Fonte de dados de uma tabela (implementada pelos DAOs).
abstract interface class FonteTabela<T> {
  List<ColunaTabela> get colunas;

  /// Ordenação usada quando o usuário não escolheu outra.
  ({String coluna, bool crescente}) get ordenacaoPadrao;

  Future<PaginaTabela<T>> buscarPagina(TableQuery query);

  /// Valores distintos de uma coluna categórica, para montar o filtro.
  Future<List<String>> valoresDistintos(String colunaId);
}
