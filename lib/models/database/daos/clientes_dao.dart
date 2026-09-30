import 'package:drift/drift.dart';

import '../../../core/cnpj.dart';
import '../../table_query.dart';
import '../app_database.dart';
import 'consulta_sql.dart';

part 'clientes_dao.g.dart';

@DriftAccessor(tables: [Clientes, Compras, Produtos])
class ClientesDao extends DatabaseAccessor<AppDatabase>
    with _$ClientesDaoMixin
    implements FonteTabela<Cliente> {
  ClientesDao(super.attachedDatabase);

  /// Dias sem compra para um cliente ser considerado inativo.
  static const diasInatividade = 60;

  /// Id do filtro especial "sem compra há mais de 60 dias".
  static const filtroInativos = FiltroEspecial(
    'inativos',
    'Sem compra há mais de $diasInatividade dias',
  );

  static const colFantasia =
      ColunaTabela(id: 'fantasia', rotulo: 'Fantasia', tipo: TipoColuna.texto, largura: 220);
  static const colRazao = ColunaTabela(
      id: 'razaoSocial', rotulo: 'Razão Social', tipo: TipoColuna.texto, largura: 240);
  static const colCnpj =
      ColunaTabela(id: 'cnpj', rotulo: 'CNPJ', tipo: TipoColuna.texto, largura: 170);
  static const colContato =
      ColunaTabela(id: 'contato', rotulo: 'Contato', tipo: TipoColuna.texto, largura: 150);
  static const colTelefone =
      ColunaTabela(id: 'telefone', rotulo: 'Telefone', tipo: TipoColuna.texto, largura: 150);
  static const colCidade =
      ColunaTabela(id: 'cidade', rotulo: 'Cidade', tipo: TipoColuna.categoria, largura: 140);
  static const colBairro =
      ColunaTabela(id: 'bairro', rotulo: 'Bairro', tipo: TipoColuna.texto, largura: 180);
  static const colUltimaCompra = ColunaTabela(
      id: 'ultimaCompra', rotulo: 'Última Compra', tipo: TipoColuna.data, largura: 140);

  Expression<int> get _ultimaCompra => subqueryExpression<int>(selectOnly(compras)
    ..addColumns([compras.data.max()])
    ..where(compras.clienteId.equalsExp(clientes.id)));

  Expression<String> get _telefone =>
      (coalesce([clientes.ddd, const Constant('')]) +
              const Constant(' ') +
              coalesce([clientes.telefone, const Constant('')]))
          .trim();

  List<ColunaSql> get _colunasSql => [
        ColunaSql(colFantasia, clientes.fantasia),
        ColunaSql(colRazao, clientes.razaoSocial),
        ColunaSql(colCnpj, clientes.cnpj),
        ColunaSql(colContato, clientes.contato),
        ColunaSql(colTelefone, _telefone),
        ColunaSql(colCidade, clientes.cidade),
        ColunaSql(colBairro, clientes.bairro),
        ColunaSql(colUltimaCompra, _ultimaCompra),
      ];

  @override
  List<ColunaTabela> get colunas => [for (final c in _colunasSql) c.coluna];

  @override
  ({String coluna, bool crescente}) get ordenacaoPadrao =>
      (coluna: colFantasia.id, crescente: true);

  /// Data limite: clientes com última compra antes dela são inativos.
  DateTime get limiteInatividade {
    final hoje = attachedDatabase.relogio();
    return DateTime(hoje.year, hoje.month, hoje.day - diasInatividade);
  }

  Expression<bool> get _inativo {
    final e = _ultimaCompra;
    return e.isNull() |
        e.isSmallerThanValue(DiaConverter.paraInt(limiteInatividade));
  }

  Expression<bool>? _especial(FiltroEspecial f) =>
      f.colunaId == filtroInativos.colunaId ? _inativo : null;

  @override
  Future<PaginaTabela<Cliente>> buscarPagina(TableQuery q) async {
    final cols = _colunasSql;
    final mapa = indexar(cols);
    final where = montarWhere(q, mapa, especial: _especial);

    final consulta = select(clientes).addColumns([for (final c in cols) c.expr]);
    if (where != null) consulta.where(where);
    consulta
      ..orderBy(montarOrdem(q, mapa, ordenacaoPadrao,
          desempate: [OrderingTerm.asc(clientes.id)]))
      ..limit(q.tamanhoPagina, offset: q.offset);

    final linhas = await consulta.get();
    final contagem = selectOnly(clientes)..addColumns([countAll()]);
    if (where != null) contagem.where(where);
    final total = await contagem.map((r) => r.read(countAll())!).getSingle();

    return PaginaTabela(
      total: total,
      linhas: [
        for (final r in linhas)
          LinhaTabela(r.readTable(clientes), {
            for (final c in cols)
              c.coluna.id: c.coluna.id == colCnpj.id
                  ? _cnpjExibicao(r.read(c.expr) as String?)
                  : converterValor(c.coluna, r.read(c.expr)),
          }),
      ],
    );
  }

  static String? _cnpjExibicao(String? cnpj) =>
      cnpj == null ? null : Cnpj.formatar(cnpj);

  @override
  Future<List<String>> valoresDistintos(String colunaId) async {
    if (colunaId != colCidade.id) return const [];
    final q = selectOnly(clientes, distinct: true)
      ..addColumns([clientes.cidade])
      ..where(clientes.cidade.isNotNull())
      ..orderBy([OrderingTerm.asc(clientes.cidade)]);
    return q.map((r) => r.read(clientes.cidade)!).get();
  }

  /// Quantidade de clientes sem compra há mais de 60 dias (ou que nunca
  /// compraram).
  Future<int> contarInativos() {
    final q = selectOnly(clientes)
      ..addColumns([countAll()])
      ..where(_inativo);
    return q.map((r) => r.read(countAll())!).getSingle();
  }

  Future<Cliente?> porId(int id) =>
      (select(clientes)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<Cliente?> porCnpj(String cnpj, {int? excetoId}) {
    final q = select(clientes)..where((c) => c.cnpj.equals(Cnpj.limpar(cnpj)));
    if (excetoId != null) q.where((c) => c.id.equals(excetoId).not());
    return q.getSingleOrNull();
  }

  Future<List<Cliente>> todos() =>
      (select(clientes)..orderBy([(c) => OrderingTerm.asc(c.fantasia)])).get();

  /// Sugestões para o campo Cliente (fantasia, razão social ou CNPJ).
  Future<List<Cliente>> sugestoes(String texto, {int limite = 20}) {
    final t = texto.trim();
    final q = select(clientes);
    if (t.isNotEmpty) {
      final digitos = Cnpj.limpar(t);
      q.where((c) {
        var e = contemSql(c.fantasia, t) | contemSql(c.razaoSocial, t);
        if (digitos.isNotEmpty) e = e | c.cnpj.like('%$digitos%');
        return e;
      });
    }
    q
      ..orderBy([(c) => OrderingTerm.asc(unaccent(c.fantasia))])
      ..limit(limite);
    return q.get();
  }

  Future<int> inserir(ClientesCompanion cliente) => into(clientes).insert(cliente);

  Future<void> atualizar(Cliente cliente) => update(clientes)
      .replace(cliente.copyWith(atualizadoEm: attachedDatabase.relogio()));

  Future<int> contarCompras(int clienteId) {
    final q = selectOnly(compras)
      ..addColumns([countAll()])
      ..where(compras.clienteId.equals(clienteId));
    return q.map((r) => r.read(countAll())!).getSingle();
  }

  Future<void> excluir(int id) =>
      (delete(clientes)..where((c) => c.id.equals(id))).go();

  /// Compras do cliente, da mais recente para a mais antiga.
  Future<List<({Compra compra, Produto produto})>> historico(int clienteId) {
    final q = select(compras).join([
      innerJoin(produtos, produtos.id.equalsExp(compras.produtoId)),
    ])
      ..where(compras.clienteId.equals(clienteId))
      ..orderBy([OrderingTerm.desc(compras.data), OrderingTerm.desc(compras.id)]);
    return q
        .map((r) => (compra: r.readTable(compras), produto: r.readTable(produtos)))
        .get();
  }
}
