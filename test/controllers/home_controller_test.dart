import 'package:app_pai/controllers/home_controller.dart';
import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/database/daos/analitico_dao.dart';
import 'package:flutter_test/flutter_test.dart';

import '../models/database/helpers.dart';

void main() {
  late AppDatabase db;
  late HomeController home;

  setUp(() async {
    db = bancoDeTeste(relogio: () => DateTime(2026, 6, 15));
    home = HomeController(db.analiticoDao);
    final c = await novoCliente(db, 'A');
    final p = await novoProduto(db, 1, 'X');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 6, 1), valor: 1000);
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2025, 12, 1), valor: 500);
  });
  tearDown(() async {
    home.dispose();
    await db.close();
  });

  test('carrega o mês atual por padrão', () async {
    expect(home.periodo, PeriodoHome.mesAtual);
    await home.carregar();
    expect(home.dados!.indicadores.valorTotal, 1000);
    expect(home.dados!.meses, hasLength(12));
    expect(home.dados!.semDados, isFalse);
  });

  test('trocar o período recarrega os indicadores', () async {
    await home.carregar();
    home.selecionarPeriodo(PeriodoHome.ultimos12Meses);
    expect(home.carregando, isTrue);
    await pumpEventQueue();
    expect(home.carregando, isFalse);
    expect(home.periodo, PeriodoHome.ultimos12Meses);
    expect(home.dados!.indicadores.valorTotal, 1500);
    expect(home.dados!.indicadores.registros, 2);
  });

  test('período sem compras', () async {
    await db.delete(db.compras).go();
    await home.carregar();
    expect(home.dados!.semDados, isTrue);
    expect(home.dados!.indicadores.valorTotal, 0);
    expect(home.dados!.clientesInativos, 1);
  });
}
