import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/database/daos/analitico_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  final hoje = DateTime(2026, 6, 15);

  setUp(() => db = bancoDeTeste(relogio: () => hoje));
  tearDown(() => db.close());

  test('indicadores do cenário da spec', () async {
    final a = await novoCliente(db, 'A');
    final b = await novoCliente(db, 'B');
    final p = await novoProduto(db, 1, 'X');
    await novaCompra(db, cliente: a, produto: p, data: DateTime(2026, 6, 1), valor: 10000);
    await novaCompra(db, cliente: a, produto: p, data: DateTime(2026, 6, 2), valor: 5000);
    await novaCompra(db, cliente: b, produto: p, data: DateTime(2026, 6, 3), valor: 3000);
    // Fora do mês atual.
    await novaCompra(db, cliente: b, produto: p, data: DateTime(2026, 5, 31), valor: 99900);

    final i = await db.analiticoDao.indicadores(PeriodoHome.mesAtual);
    expect(i.valorTotal, 18000);
    expect(i.registros, 3);
    expect(i.unidades, 3);
    expect(i.clientes, 2);
    expect(i.ticketMedio, 9000);
  });

  test('período sem compras zera os indicadores', () async {
    final i = await db.analiticoDao.indicadores(PeriodoHome.mesAtual);
    expect(i.valorTotal, 0);
    expect(i.registros, 0);
    expect(i.ticketMedio, 0);
  });

  test('intervalos de período', () {
    expect(PeriodoHome.ultimos3Meses.intervalo(hoje),
        (de: DateTime(2026, 4), ate: DateTime(2026, 6, 15)));
    expect(PeriodoHome.ultimos12Meses.intervalo(hoje).de, DateTime(2025, 7));
    expect(PeriodoHome.anoAtual.intervalo(hoje).de, DateTime(2026));
    expect(PeriodoHome.tudo.intervalo(hoje), (de: null, ate: null));
  });

  test('top 5 produtos e clientes em ordem decrescente', () async {
    final clientes = [for (var i = 0; i < 7; i++) await novoCliente(db, 'C$i')];
    final produtos = [for (var i = 0; i < 8; i++) await novoProduto(db, i + 1, 'P$i')];
    for (var i = 0; i < 8; i++) {
      await novaCompra(db, cliente: clientes[i % 7], produto: produtos[i],
          data: DateTime(2026, 6, 1), valor: (i + 1) * 100);
    }
    final top = await db.analiticoDao.topProdutos(PeriodoHome.mesAtual);
    expect([for (final t in top) t.nome], ['P7', 'P6', 'P5', 'P4', 'P3']);
    expect(top.first.valor, 800);

    final topC = await db.analiticoDao.topClientes(PeriodoHome.mesAtual);
    expect(topC, hasLength(5));
    // C0 comprou P0 (100) + P7 (800).
    expect(topC.first, (nome: 'C0', valor: 900));
  });

  test('últimos 12 meses com meses vazios zerados', () async {
    final c = await novoCliente(db, 'A');
    final p = await novoProduto(db, 1, 'X');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2025, 7, 1), valor: 100);
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 6, 30), valor: 200);
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 6, 1), valor: 50);
    // Fora da janela.
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2025, 6, 30), valor: 999);

    final serie = await db.analiticoDao.ultimos12Meses();
    expect(serie, hasLength(12));
    expect(serie.first, (mes: DateTime(2025, 7), valor: 100));
    expect(serie.last, (mes: DateTime(2026, 6), valor: 250));
    expect(serie.where((m) => m.valor == 0), hasLength(10));
  });

  test('clientes inativos', () async {
    final p = await novoProduto(db, 1, 'X');
    final ativo = await novoCliente(db, 'ATIVO');
    await novoCliente(db, 'NUNCA');
    await novaCompra(db, cliente: ativo, produto: p, data: DateTime(2026, 6, 1));
    expect(await db.analiticoDao.clientesInativos(), 1);
    expect(await db.analiticoDao.totalClientes(), 2);
  });
}
