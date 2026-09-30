import 'package:drift/drift.dart';

import '../app_database.dart';

part 'analitico_dao.g.dart';

/// Períodos disponíveis na Home.
enum PeriodoHome {
  mesAtual('Mês atual'),
  ultimos3Meses('Últimos 3 meses'),
  ultimos12Meses('Últimos 12 meses'),
  anoAtual('Ano atual'),
  tudo('Tudo');

  const PeriodoHome(this.rotulo);

  final String rotulo;

  /// Intervalo de datas (inclusivo). `null` = sem limite.
  ({DateTime? de, DateTime? ate}) intervalo(DateTime hoje) {
    final h = DateTime(hoje.year, hoje.month, hoje.day);
    return switch (this) {
      PeriodoHome.mesAtual => (de: DateTime(h.year, h.month), ate: h),
      PeriodoHome.ultimos3Meses => (de: DateTime(h.year, h.month - 2), ate: h),
      PeriodoHome.ultimos12Meses => (de: DateTime(h.year, h.month - 11), ate: h),
      PeriodoHome.anoAtual => (de: DateTime(h.year), ate: h),
      PeriodoHome.tudo => (de: null, ate: null),
    };
  }
}

class Indicadores {
  const Indicadores({
    required this.valorTotal,
    required this.unidades,
    required this.registros,
    required this.clientes,
  });

  final int valorTotal;
  final int unidades;
  final int registros;
  final int clientes;

  /// Valor total dividido pelos clientes distintos (centavos).
  int get ticketMedio => clientes == 0 ? 0 : (valorTotal / clientes).round();
}

typedef ItemRanking = ({String nome, int valor});
typedef ValorMes = ({DateTime mes, int valor});

@DriftAccessor(tables: [Compras, Clientes, Produtos])
class AnaliticoDao extends DatabaseAccessor<AppDatabase> with _$AnaliticoDaoMixin {
  AnaliticoDao(super.attachedDatabase);

  Expression<int> get _total => compras.quantidade * compras.valorUnitarioCentavos;

  Expression<bool>? _periodo(({DateTime? de, DateTime? ate}) p) {
    Expression<bool>? e;
    if (p.de != null) e = compras.data.isBiggerOrEqualValue(DiaConverter.paraInt(p.de!));
    if (p.ate != null) {
      final ate = compras.data.isSmallerOrEqualValue(DiaConverter.paraInt(p.ate!));
      e = e == null ? ate : e & ate;
    }
    return e;
  }

  Future<Indicadores> indicadores(PeriodoHome periodo) async {
    final valor = _total.sum();
    final unidades = compras.quantidade.sum();
    final registros = countAll();
    final clientesDistintos = compras.clienteId.count(distinct: true);
    final q = selectOnly(compras)
      ..addColumns([valor, unidades, registros, clientesDistintos]);
    final w = _periodo(periodo.intervalo(attachedDatabase.relogio()));
    if (w != null) q.where(w);
    final r = await q.getSingle();
    return Indicadores(
      valorTotal: r.read(valor) ?? 0,
      unidades: r.read(unidades) ?? 0,
      registros: r.read(registros) ?? 0,
      clientes: r.read(clientesDistintos) ?? 0,
    );
  }

  Future<List<ItemRanking>> topProdutos(PeriodoHome periodo, {int limite = 5}) async {
    final valor = _total.sum();
    final q = selectOnly(compras).join([
      innerJoin(produtos, produtos.id.equalsExp(compras.produtoId)),
    ])
      ..addColumns([produtos.descricao, valor])
      ..groupBy([produtos.id])
      ..orderBy([OrderingTerm.desc(valor)])
      ..limit(limite);
    final w = _periodo(periodo.intervalo(attachedDatabase.relogio()));
    if (w != null) q.where(w);
    return q.map((r) => (nome: r.read(produtos.descricao)!, valor: r.read(valor) ?? 0)).get();
  }

  Future<List<ItemRanking>> topClientes(PeriodoHome periodo, {int limite = 5}) async {
    final valor = _total.sum();
    final q = selectOnly(compras).join([
      innerJoin(clientes, clientes.id.equalsExp(compras.clienteId)),
    ])
      ..addColumns([clientes.fantasia, valor])
      ..groupBy([clientes.id])
      ..orderBy([OrderingTerm.desc(valor)])
      ..limit(limite);
    final w = _periodo(periodo.intervalo(attachedDatabase.relogio()));
    if (w != null) q.where(w);
    return q.map((r) => (nome: r.read(clientes.fantasia)!, valor: r.read(valor) ?? 0)).get();
  }

  /// Valor vendido em cada um dos últimos 12 meses (inclui meses zerados),
  /// do mais antigo para o mais recente.
  Future<List<ValorMes>> ultimos12Meses() async {
    final hoje = attachedDatabase.relogio();
    final meses = [for (var i = 11; i >= 0; i--) DateTime(hoje.year, hoje.month - i)];
    // Divisão inteira no SQLite: aaaammdd / 100 = aaaamm.
    final mes = compras.data / const Constant(100);
    final valor = _total.sum();
    final q = selectOnly(compras)
      ..addColumns([mes, valor])
      ..where(compras.data.isBiggerOrEqualValue(DiaConverter.paraInt(meses.first)) &
          compras.data.isSmallerOrEqualValue(DiaConverter.paraInt(
              DateTime(hoje.year, hoje.month + 1, 0))))
      ..groupBy([mes]);
    final porMes = {
      for (final r in await q.get()) r.read(mes)!: r.read(valor) ?? 0,
    };
    return [
      for (final m in meses) (mes: m, valor: porMes[m.year * 100 + m.month] ?? 0),
    ];
  }

  Future<int> clientesInativos() => attachedDatabase.clientesDao.contarInativos();

  Future<int> totalClientes() async {
    final q = selectOnly(clientes)..addColumns([countAll()]);
    return q.map((r) => r.read(countAll())!).getSingle();
  }
}
