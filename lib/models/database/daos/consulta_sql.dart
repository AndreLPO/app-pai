import 'package:drift/drift.dart';

import '../../../core/text_normalize.dart';
import '../../table_query.dart';
import '../tables.dart';

/// Liga uma coluna de tabela à expressão SQL que a calcula.
class ColunaSql {
  const ColunaSql(this.coluna, this.expr);

  final ColunaTabela coluna;
  final Expression<Object> expr;
}

/// `unaccent(x)`: função registrada na abertura do banco (minúsculas e sem
/// acento), usada em buscas e na ordenação de textos.
Expression<String> unaccent(Expression<Object> e) =>
    FunctionCallExpression<String>('unaccent', [e]);

String _escaparLike(String t) =>
    t.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

Expression<bool> contemSql(Expression<Object> e, String texto) =>
    unaccent(e).like('%${_escaparLike(normalizar(texto.trim()))}%', escapeChar: r'\');

Expression<bool> _todos(List<Expression<bool>> partes) =>
    partes.reduce((a, b) => a & b);

Expression<bool> _algum(List<Expression<bool>> partes) =>
    partes.reduce((a, b) => a | b);

/// Monta o `WHERE` de uma consulta de tabela: busca geral (em todas as
/// colunas de texto) E todos os filtros.
Expression<bool>? montarWhere(
  TableQuery q,
  Map<String, ColunaSql> colunas, {
  Expression<bool>? Function(FiltroEspecial filtro)? especial,
}) {
  final partes = <Expression<bool>>[];

  final busca = q.busca.trim();
  if (busca.isNotEmpty) {
    final textos = [
      for (final c in colunas.values)
        if (c.coluna.tipo == TipoColuna.texto ||
            c.coluna.tipo == TipoColuna.categoria)
          contemSql(c.expr, busca),
    ];
    if (textos.isNotEmpty) partes.add(_algum(textos));
  }

  for (final f in q.filtros) {
    if (f is FiltroEspecial) {
      final e = especial?.call(f);
      if (e != null) partes.add(e);
      continue;
    }
    final c = colunas[f.colunaId];
    if (c == null) continue;
    switch (f) {
      case FiltroContem(:final texto):
        partes.add(contemSql(c.expr, texto));
      case FiltroIgual(:final valores):
        if (valores.isNotEmpty) {
          partes.add((c.expr as Expression<String>).isIn(valores));
        }
      case FiltroIntervalo(:final minimo, :final maximo):
        final e = c.expr as Expression<int>;
        if (minimo != null) partes.add(e.isBiggerOrEqualValue(minimo));
        if (maximo != null) partes.add(e.isSmallerOrEqualValue(maximo));
      case FiltroPeriodo(:final de, :final ate):
        final e = c.expr as Expression<int>;
        if (de != null) partes.add(e.isBiggerOrEqualValue(DiaConverter.paraInt(de)));
        if (ate != null) partes.add(e.isSmallerOrEqualValue(DiaConverter.paraInt(ate)));
      case FiltroEspecial():
        break;
    }
  }

  return partes.isEmpty ? null : _todos(partes);
}

/// Ordenação: textos sem acento/caixa, demais pelo valor.
List<OrderingTerm> montarOrdem(
  TableQuery q,
  Map<String, ColunaSql> colunas,
  ({String coluna, bool crescente}) padrao, {
  List<OrderingTerm> desempate = const [],
}) {
  final id = q.ordenarPor ?? padrao.coluna;
  final crescente = q.ordenarPor == null ? padrao.crescente : q.crescente;
  final c = colunas[id] ?? colunas[padrao.coluna]!;
  final texto =
      c.coluna.tipo == TipoColuna.texto || c.coluna.tipo == TipoColuna.categoria;
  final expr = texto ? unaccent(c.expr) : c.expr;
  return [
    OrderingTerm(
      expression: expr,
      mode: crescente ? OrderingMode.asc : OrderingMode.desc,
      // Vazios sempre por último.
      nulls: NullsOrder.last,
    ),
    ...desempate,
  ];
}

Map<String, ColunaSql> indexar(List<ColunaSql> colunas) =>
    {for (final c in colunas) c.coluna.id: c};

/// Converte o valor lido de uma coluna para o tipo exibido.
Object? converterValor(ColunaTabela coluna, Object? valor) {
  if (valor == null) return null;
  if (coluna.tipo == TipoColuna.data && valor is int) {
    return DiaConverter.deInt(valor);
  }
  return valor;
}
