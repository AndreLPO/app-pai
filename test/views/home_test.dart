import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/database/daos/analitico_dao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = bancoDeTeste(relogio: () => DateTime(2026, 6, 15)));
  tearDown(() => db.close());

  Finder cartao(String rotulo) => find.ancestor(of: find.text(rotulo), matching: find.byType(Card));

  String? valorDoCartao(WidgetTester tester, String rotulo) {
    final textos = tester
        .widgetList<Text>(find.descendant(of: cartao(rotulo), matching: find.byType(Text)))
        .map((t) => t.data)
        .toList();
    return textos[textos.indexOf(rotulo) + 1];
  }

  testWidgets('indicadores do mês atual (cenário da spec)', (tester) async {
    final a = await novoCliente(db, 'A');
    final b = await novoCliente(db, 'B');
    final p = await novoProduto(db, 1, 'CAFE');
    await novaCompra(db, cliente: a, produto: p, data: DateTime(2026, 6, 1), valor: 10000);
    await novaCompra(db, cliente: a, produto: p, data: DateTime(2026, 6, 2), valor: 5000);
    await novaCompra(db, cliente: b, produto: p, data: DateTime(2026, 6, 3), valor: 3000);
    await novaCompra(db, cliente: b, produto: p, data: DateTime(2025, 12, 3), valor: 100000);
    await montarApp(tester, db);

    expect(find.text('Mês atual'), findsOneWidget);
    expect(valorDoCartao(tester, 'Valor total vendido'), r'R$ 180,00');
    expect(valorDoCartao(tester, 'Registros de compra'), '3');
    expect(valorDoCartao(tester, 'Clientes que compraram'), '2');
    expect(valorDoCartao(tester, 'Ticket médio por cliente'), r'R$ 90,00');
    expect(find.text('Sem dados no período'), findsNothing);
  });

  testWidgets('trocar o período recalcula', (tester) async {
    final a = await novoCliente(db, 'A');
    final p = await novoProduto(db, 1, 'CAFE');
    await novaCompra(db, cliente: a, produto: p, data: DateTime(2026, 6, 1), valor: 10000);
    await novaCompra(db, cliente: a, produto: p, data: DateTime(2025, 12, 3), valor: 5000);
    await montarApp(tester, db);

    await tester.tap(find.byKey(const ValueKey('periodo')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(PeriodoHome.ultimos12Meses.rotulo).last);
    await tester.pumpAndSettle();
    expect(valorDoCartao(tester, 'Valor total vendido'), r'R$ 150,00');
    expect(valorDoCartao(tester, 'Registros de compra'), '2');
  });

  testWidgets('período sem compras mostra zero e o aviso', (tester) async {
    await montarApp(tester, db);
    expect(find.text('Sem dados no período'), findsWidgets);
    expect(valorDoCartao(tester, 'Valor total vendido'), r'R$ 0,00');
    expect(valorDoCartao(tester, 'Ticket médio por cliente'), r'R$ 0,00');
  });

  testWidgets('ranking dos 5 produtos de maior valor', (tester) async {
    final c = await novoCliente(db, 'A');
    for (var i = 1; i <= 8; i++) {
      final p = await novoProduto(db, i, 'PRODUTO $i');
      await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 6, 1), valor: i * 100);
    }
    await montarApp(tester, db);
    final ranking = find.byKey(const ValueKey('topProdutos'));
    final nomes = [
      for (final t in tester.widgetList<Text>(find.descendant(of: ranking, matching: find.byType(Text))))
        if (t.data?.startsWith('PRODUTO') ?? false) t.data,
    ];
    expect(nomes, ['PRODUTO 8', 'PRODUTO 7', 'PRODUTO 6', 'PRODUTO 5', 'PRODUTO 4']);
  });

  testWidgets('gráfico com 12 barras, mês sem vendas zerado', (tester) async {
    final c = await novoCliente(db, 'A');
    final p = await novoProduto(db, 1, 'CAFE');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 6, 1), valor: 1000);
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2025, 7, 1), valor: 500);
    await montarApp(tester, db);
    await tester.ensureVisible(find.byKey(const ValueKey('barra-2026-06')));
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate((w) =>
        w is Container && '${w.key}'.startsWith("[<'barra-")), findsNWidgets(12));
    double altura(String mes) => tester.getSize(find.byKey(ValueKey('barra-$mes'))).height;
    expect(altura('2026-06'), greaterThan(0));
    expect(altura('2025-07'), closeTo(altura('2026-06') / 2, 0.5));
    expect(altura('2026-01'), 0);
    expect(find.text('jul/25'), findsOneWidget);
    expect(find.text('jun/26'), findsOneWidget);
  });

  testWidgets('card de clientes inativos abre a tabela de Clientes filtrada', (tester) async {
    final p = await novoProduto(db, 1, 'CAFE');
    final ativo = await novoCliente(db, 'ATIVO');
    await novoCliente(db, 'NUNCA COMPROU');
    await novaCompra(db, cliente: ativo, produto: p, data: DateTime(2026, 6, 1));
    await montarApp(tester, db);
    expect(valorDoCartao(tester, 'Clientes sem compra há mais de 60 dias'), '1');

    await tester.tap(find.byKey(const ValueKey('inativos')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Clientes').hitTestable(), findsOneWidget);
    expect(find.text('Sem compra há mais de 60 dias'), findsOneWidget);
    expect(find.text('NUNCA COMPROU'), findsOneWidget);
    expect(find.text('ATIVO'), findsNothing);
  });

  testWidgets('a Home recarrega após salvar uma compra', (tester) async {
    final c = await novoCliente(db, 'A');
    final p = await novoProduto(db, 1, 'CAFE');
    final scope = await montarApp(tester, db);
    expect(valorDoCartao(tester, 'Registros de compra'), '0');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 6, 1), valor: 100);
    scope.dadosAlterados();
    await tester.pumpAndSettle();
    expect(valorDoCartao(tester, 'Registros de compra'), '1');
  });
}
