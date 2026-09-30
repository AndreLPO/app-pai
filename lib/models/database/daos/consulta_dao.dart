import 'package:drift/drift.dart';

import '../../../core/cnpj.dart';
import '../../table_query.dart';
import '../app_database.dart';
import 'consulta_sql.dart';

part 'consulta_dao.g.dart';

/// Consulta Geral: uma linha por compra, no layout da planilha.
/// O registro de cada linha é o id da compra.
@DriftAccessor(tables: [Compras, Clientes, Produtos])
class ConsultaDao extends DatabaseAccessor<AppDatabase>
    with _$ConsultaDaoMixin
    implements FonteTabela<int> {
  ConsultaDao(super.attachedDatabase);

  static const colFantasia =
      ColunaTabela(id: 'fantasia', rotulo: 'Fantasia', tipo: TipoColuna.texto, largura: 220);
  static const colDdd =
      ColunaTabela(id: 'ddd', rotulo: 'DDD', tipo: TipoColuna.texto, largura: 80);
  static const colZap =
      ColunaTabela(id: 'zap', rotulo: 'Zap', tipo: TipoColuna.texto, largura: 140);
  static const colContato =
      ColunaTabela(id: 'contato', rotulo: 'Contato', tipo: TipoColuna.texto, largura: 150);
  static const colRazao = ColunaTabela(
      id: 'razaoSocial', rotulo: 'Razão Social', tipo: TipoColuna.texto, largura: 240);
  static const colCnpj =
      ColunaTabela(id: 'cnpj', rotulo: 'CNPJ', tipo: TipoColuna.texto, largura: 170);
  static const colIe = ColunaTabela(
      id: 'inscEstadual', rotulo: 'Insc. Estadual', tipo: TipoColuna.texto, largura: 160);
  static const colSequencia =
      ColunaTabela(id: 'sequencia', rotulo: 'Sequência', tipo: TipoColuna.inteiro, largura: 120);
  static const colCep =
      ColunaTabela(id: 'cep', rotulo: 'CEP', tipo: TipoColuna.texto, largura: 110);
  static const colRua =
      ColunaTabela(id: 'rua', rotulo: 'Rua', tipo: TipoColuna.texto, largura: 260);
  static const colBairro =
      ColunaTabela(id: 'bairro', rotulo: 'Bairro', tipo: TipoColuna.texto, largura: 180);
  static const colCidade =
      ColunaTabela(id: 'cidade', rotulo: 'Cidade', tipo: TipoColuna.categoria, largura: 140);
  static const colData =
      ColunaTabela(id: 'data', rotulo: 'Data', tipo: TipoColuna.data, largura: 120);
  static const colReduzido =
      ColunaTabela(id: 'reduzido', rotulo: 'Reduzido', tipo: TipoColuna.inteiro, largura: 110);
  static const colQtde =
      ColunaTabela(id: 'qtde', rotulo: 'Qtde', tipo: TipoColuna.inteiro, largura: 100);
  static const colProduto =
      ColunaTabela(id: 'produto', rotulo: 'Produto', tipo: TipoColuna.categoria, largura: 240);
  static const colValor = ColunaTabela(
      id: 'valorUnitario', rotulo: 'Valor Unitário', tipo: TipoColuna.moeda, largura: 140);
  static const colTotal =
      ColunaTabela(id: 'total', rotulo: 'Valor Total', tipo: TipoColuna.moeda, largura: 150);

  Expression<int> get _total => compras.quantidade * compras.valorUnitarioCentavos;

  List<Join> get _joins => [
        innerJoin(clientes, clientes.id.equalsExp(compras.clienteId)),
        innerJoin(produtos, produtos.id.equalsExp(compras.produtoId)),
      ];

  List<ColunaSql> get _colunasSql => [
        ColunaSql(colFantasia, clientes.fantasia),
        ColunaSql(colDdd, clientes.ddd),
        ColunaSql(colZap, clientes.telefone),
        ColunaSql(colContato, clientes.contato),
        ColunaSql(colRazao, clientes.razaoSocial),
        ColunaSql(colCnpj, clientes.cnpj),
        ColunaSql(colIe, clientes.inscEstadual),
        ColunaSql(colSequencia, compras.sequencia),
        ColunaSql(colCep, clientes.cep),
        ColunaSql(colRua, clientes.rua),
        ColunaSql(colBairro, clientes.bairro),
        ColunaSql(colCidade, clientes.cidade),
        ColunaSql(colData, compras.data),
        ColunaSql(colReduzido, produtos.reduzido),
        ColunaSql(colQtde, compras.quantidade),
        ColunaSql(colProduto, produtos.descricao),
        ColunaSql(colValor, compras.valorUnitarioCentavos),
        ColunaSql(colTotal, _total),
      ];

  @override
  List<ColunaTabela> get colunas => [for (final c in _colunasSql) c.coluna];

  @override
  ({String coluna, bool crescente}) get ordenacaoPadrao =>
      (coluna: colData.id, crescente: false);

  @override
  Future<PaginaTabela<int>> buscarPagina(TableQuery q) async {
    final cols = _colunasSql;
    final mapa = indexar(cols);
    final where = montarWhere(q, mapa);

    final consulta = selectOnly(compras).join(_joins)
      ..addColumns([compras.id, for (final c in cols) c.expr]);
    if (where != null) consulta.where(where);
    consulta
      ..orderBy(montarOrdem(q, mapa, ordenacaoPadrao,
          desempate: [OrderingTerm.desc(compras.id)]))
      ..limit(q.tamanhoPagina, offset: q.offset);
    final linhas = await consulta.get();

    final registros = countAll();
    final qtde = compras.quantidade.sum();
    final total = _total.sum();
    final somas = selectOnly(compras).join(_joins)
      ..addColumns([registros, qtde, total]);
    if (where != null) somas.where(where);
    final s = await somas.getSingle();

    return PaginaTabela(
      total: s.read(registros) ?? 0,
      somas: {colQtde.id: s.read(qtde) ?? 0, colTotal.id: s.read(total) ?? 0},
      linhas: [
        for (final r in linhas)
          LinhaTabela(r.read(compras.id)!, {
            for (final c in cols)
              c.coluna.id: c.coluna.id == colCnpj.id
                  ? _cnpj(r.read(c.expr) as String?)
                  : converterValor(c.coluna, r.read(c.expr)),
          }),
      ],
    );
  }

  static String? _cnpj(String? v) => v == null ? null : Cnpj.formatar(v);

  @override
  Future<List<String>> valoresDistintos(String colunaId) async {
    final Expression<String>? expr = switch (colunaId) {
      'cidade' => clientes.cidade,
      'produto' => produtos.descricao,
      _ => null,
    };
    if (expr == null) return const [];
    final q = selectOnly(compras, distinct: true).join(_joins)
      ..addColumns([expr])
      ..where(expr.isNotNull())
      ..orderBy([OrderingTerm.asc(expr)]);
    return q.map((r) => r.read(expr)!).get();
  }
}
