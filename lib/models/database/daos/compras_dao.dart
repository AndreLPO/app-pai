import 'package:drift/drift.dart';

import '../../table_query.dart';
import '../app_database.dart';
import 'consulta_sql.dart';

part 'compras_dao.g.dart';

/// Compra com o cliente e o produto vinculados.
typedef CompraCompleta = ({Compra compra, Cliente cliente, Produto produto});

@DriftAccessor(tables: [Compras, Clientes, Produtos])
class ComprasDao extends DatabaseAccessor<AppDatabase>
    with _$ComprasDaoMixin
    implements FonteTabela<CompraCompleta> {
  ComprasDao(super.attachedDatabase);

  static const colData =
      ColunaTabela(id: 'data', rotulo: 'Data', tipo: TipoColuna.data, largura: 120);
  static const colSequencia =
      ColunaTabela(id: 'sequencia', rotulo: 'Sequência', tipo: TipoColuna.inteiro, largura: 120);
  static const colCliente =
      ColunaTabela(id: 'cliente', rotulo: 'Cliente', tipo: TipoColuna.texto, largura: 220);
  static const colReduzido =
      ColunaTabela(id: 'reduzido', rotulo: 'Reduzido', tipo: TipoColuna.inteiro, largura: 110);
  static const colProduto =
      ColunaTabela(id: 'produto', rotulo: 'Produto', tipo: TipoColuna.categoria, largura: 240);
  static const colQuantidade =
      ColunaTabela(id: 'quantidade', rotulo: 'Qtde', tipo: TipoColuna.inteiro, largura: 100);
  static const colValorUnitario = ColunaTabela(
      id: 'valorUnitario', rotulo: 'Valor Unitário', tipo: TipoColuna.moeda, largura: 140);
  static const colTotal =
      ColunaTabela(id: 'total', rotulo: 'Valor Total', tipo: TipoColuna.moeda, largura: 150);

  /// `quantidade * valor_unitario` (o total não é gravado).
  Expression<int> get totalExpr => compras.quantidade * compras.valorUnitarioCentavos;

  List<Join> get _joins => [
        innerJoin(clientes, clientes.id.equalsExp(compras.clienteId)),
        innerJoin(produtos, produtos.id.equalsExp(compras.produtoId)),
      ];

  List<ColunaSql> get _colunasSql => [
        ColunaSql(colData, compras.data),
        ColunaSql(colSequencia, compras.sequencia),
        ColunaSql(colCliente, clientes.fantasia),
        ColunaSql(colReduzido, produtos.reduzido),
        ColunaSql(colProduto, produtos.descricao),
        ColunaSql(colQuantidade, compras.quantidade),
        ColunaSql(colValorUnitario, compras.valorUnitarioCentavos),
        ColunaSql(colTotal, totalExpr),
      ];

  @override
  List<ColunaTabela> get colunas => [for (final c in _colunasSql) c.coluna];

  @override
  ({String coluna, bool crescente}) get ordenacaoPadrao =>
      (coluna: colData.id, crescente: false);

  @override
  Future<PaginaTabela<CompraCompleta>> buscarPagina(TableQuery q) async {
    final cols = _colunasSql;
    final mapa = indexar(cols);
    final where = montarWhere(q, mapa);

    final consulta = select(compras).join(_joins)..addColumns([totalExpr]);
    if (where != null) consulta.where(where);
    consulta
      ..orderBy(montarOrdem(q, mapa, ordenacaoPadrao,
          desempate: [OrderingTerm.desc(compras.id)]))
      ..limit(q.tamanhoPagina, offset: q.offset);
    final linhas = await consulta.get();

    final soma = await somar(where);
    return PaginaTabela(
      total: soma.registros,
      somas: {colQuantidade.id: soma.quantidade, colTotal.id: soma.total},
      linhas: [
        for (final r in linhas)
          LinhaTabela(
            (
              compra: r.readTable(compras),
              cliente: r.readTable(clientes),
              produto: r.readTable(produtos),
            ),
            {
              for (final c in cols)
                c.coluna.id: converterValor(c.coluna, r.read(c.expr)),
            },
          ),
      ],
    );
  }

  /// Contagem e somas das compras que atendem ao filtro (todas as páginas).
  Future<({int registros, int quantidade, int total})> somar(
      Expression<bool>? where) async {
    final registros = countAll();
    final quantidade = compras.quantidade.sum();
    final total = totalExpr.sum();
    final q = selectOnly(compras).join(_joins)
      ..addColumns([registros, quantidade, total]);
    if (where != null) q.where(where);
    final r = await q.getSingle();
    return (
      registros: r.read(registros) ?? 0,
      quantidade: r.read(quantidade) ?? 0,
      total: r.read(total) ?? 0,
    );
  }

  @override
  Future<List<String>> valoresDistintos(String colunaId) async {
    if (colunaId != colProduto.id) return const [];
    final q = selectOnly(produtos, distinct: true)
      ..addColumns([produtos.descricao])
      ..orderBy([OrderingTerm.asc(produtos.descricao)]);
    return q.map((r) => r.read(produtos.descricao)!).get();
  }

  Future<CompraCompleta?> porId(int id) {
    final q = select(compras).join(_joins)..where(compras.id.equals(id));
    return q
        .map((r) => (
              compra: r.readTable(compras),
              cliente: r.readTable(clientes),
              produto: r.readTable(produtos),
            ))
        .getSingleOrNull();
  }

  Future<int> inserir(ComprasCompanion compra) => into(compras).insert(compra);

  Future<void> atualizar(Compra compra) => update(compras).replace(compra);

  Future<void> excluir(int id) =>
      (delete(compras)..where((c) => c.id.equals(id))).go();

  /// Verdadeiro se já existe compra igual (critério da importação).
  Future<bool> existeDuplicata({
    required int clienteId,
    required int produtoId,
    required DateTime data,
    required int? sequencia,
    required int quantidade,
  }) async {
    final q = selectOnly(compras)
      ..addColumns([countAll()])
      ..where(compras.clienteId.equals(clienteId) &
          compras.produtoId.equals(produtoId) &
          compras.data.equals(DiaConverter.paraInt(data)) &
          compras.quantidade.equals(quantidade) &
          (sequencia == null
              ? compras.sequencia.isNull()
              : compras.sequencia.equals(sequencia)));
    final n = await q.map((r) => r.read(countAll())!).getSingle();
    return n > 0;
  }
}
