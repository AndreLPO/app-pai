import 'package:drift/drift.dart';

import '../../table_query.dart';
import '../app_database.dart';
import 'consulta_sql.dart';

part 'produtos_dao.g.dart';

@DriftAccessor(tables: [Produtos, Compras])
class ProdutosDao extends DatabaseAccessor<AppDatabase>
    with _$ProdutosDaoMixin
    implements FonteTabela<Produto> {
  ProdutosDao(super.attachedDatabase);

  static const colReduzido =
      ColunaTabela(id: 'reduzido', rotulo: 'Reduzido', tipo: TipoColuna.inteiro, largura: 110);
  static const colDescricao =
      ColunaTabela(id: 'descricao', rotulo: 'Descrição', tipo: TipoColuna.texto, largura: 280);
  static const colPreco =
      ColunaTabela(id: 'preco', rotulo: 'Preço Padrão', tipo: TipoColuna.moeda, largura: 140);
  static const colQtdeVendida = ColunaTabela(
      id: 'qtdeVendida', rotulo: 'Qtde Vendida', tipo: TipoColuna.inteiro, largura: 140);
  static const colUltimaVenda = ColunaTabela(
      id: 'ultimaVenda', rotulo: 'Última Venda', tipo: TipoColuna.data, largura: 140);

  Expression<int> get _qtdeVendida => coalesce([
        subqueryExpression<int>(selectOnly(compras)
          ..addColumns([compras.quantidade.sum()])
          ..where(compras.produtoId.equalsExp(produtos.id))),
        const Constant(0),
      ]);

  Expression<int> get _ultimaVenda => subqueryExpression<int>(selectOnly(compras)
    ..addColumns([compras.data.max()])
    ..where(compras.produtoId.equalsExp(produtos.id)));

  List<ColunaSql> get _colunasSql => [
        ColunaSql(colReduzido, produtos.reduzido),
        ColunaSql(colDescricao, produtos.descricao),
        ColunaSql(colPreco, produtos.precoPadraoCentavos),
        ColunaSql(colQtdeVendida, _qtdeVendida),
        ColunaSql(colUltimaVenda, _ultimaVenda),
      ];

  @override
  List<ColunaTabela> get colunas => [for (final c in _colunasSql) c.coluna];

  @override
  ({String coluna, bool crescente}) get ordenacaoPadrao =>
      (coluna: colDescricao.id, crescente: true);

  @override
  Future<PaginaTabela<Produto>> buscarPagina(TableQuery q) async {
    final cols = _colunasSql;
    final mapa = indexar(cols);
    final where = montarWhere(q, mapa);

    final consulta = select(produtos).addColumns([for (final c in cols) c.expr]);
    if (where != null) consulta.where(where);
    consulta
      ..orderBy(montarOrdem(q, mapa, ordenacaoPadrao,
          desempate: [OrderingTerm.asc(produtos.id)]))
      ..limit(q.tamanhoPagina, offset: q.offset);

    final linhas = await consulta.get();
    final contagem = selectOnly(produtos)..addColumns([countAll()]);
    if (where != null) contagem.where(where);
    final total = await contagem.map((r) => r.read(countAll())!).getSingle();

    return PaginaTabela(
      total: total,
      linhas: [
        for (final r in linhas)
          LinhaTabela(r.readTable(produtos), {
            for (final c in cols) c.coluna.id: converterValor(c.coluna, r.read(c.expr)),
          }),
      ],
    );
  }

  @override
  Future<List<String>> valoresDistintos(String colunaId) async => const [];

  Future<Produto?> porId(int id) =>
      (select(produtos)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<Produto?> porReduzido(int reduzido, {int? excetoId}) {
    final q = select(produtos)..where((p) => p.reduzido.equals(reduzido));
    if (excetoId != null) q.where((p) => p.id.equals(excetoId).not());
    return q.getSingleOrNull();
  }

  Future<List<Produto>> todos() =>
      (select(produtos)..orderBy([(p) => OrderingTerm.asc(p.descricao)])).get();

  /// Sugestões para o campo Produto (por reduzido ou descrição).
  Future<List<Produto>> sugestoes(String texto, {int limite = 20}) {
    final t = texto.trim();
    final q = select(produtos);
    if (t.isNotEmpty) {
      q.where((p) =>
          p.reduzido.cast<String>().like('$t%') | contemSql(p.descricao, t));
    }
    q
      ..orderBy([(p) => OrderingTerm.asc(unaccent(p.descricao))])
      ..limit(limite);
    return q.get();
  }

  Future<int> inserir(ProdutosCompanion produto) => into(produtos).insert(produto);

  Future<void> atualizar(Produto produto) => update(produtos).replace(produto);

  Future<int> contarCompras(int produtoId) async {
    final q = selectOnly(compras)
      ..addColumns([countAll()])
      ..where(compras.produtoId.equals(produtoId));
    return q.map((r) => r.read(countAll())!).getSingle();
  }

  Future<void> excluir(int id) =>
      (delete(produtos)..where((p) => p.id.equals(id))).go();
}
