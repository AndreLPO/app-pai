import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/table_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  final hoje = DateTime(2026, 6, 15);

  setUp(() => db = bancoDeTeste(relogio: () => hoje));
  tearDown(() => db.close());

  Future<void> abrirCompras(WidgetTester tester) async {
    await montarApp(tester, db);
    await irPara(tester, 'Compras');
  }

  Future<void> novaCompraForm(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();
  }

  Finder campoTexto(String chave) => find.descendant(
      of: find.byKey(ValueKey(chave)), matching: find.byType(TextField), matchRoot: true);

  String texto(WidgetTester tester, String chave) =>
      tester.widget<TextField>(campoTexto(chave)).controller!.text;

  /// Digita no campo de busca e escolhe a sugestão com [opcao].
  Future<void> escolher(WidgetTester tester, String chave, String busca, String opcao) async {
    await tester.enterText(campoTexto(chave), busca);
    await tester.pumpAndSettle();
    await tester.tap(find.text(opcao).last);
    await tester.pumpAndSettle();
  }

  Future<void> salvar(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
  }

  testWidgets('tabela: colunas, ordem por data decrescente e rodapé filtrado', (tester) async {
    final c = await novoCliente(db, 'SOUSA');
    final leite = await novoProduto(db, 1, 'LEITE INTEGRAL 1L');
    final cafe = await novoProduto(db, 2, 'CAFE TORRADO 500G');
    await novaCompra(db, cliente: c, produto: leite, data: DateTime(2026, 1, 1),
        quantidade: 10, valor: 500);
    await novaCompra(db, cliente: c, produto: leite, data: DateTime(2026, 3, 1),
        quantidade: 5, valor: 500);
    await novaCompra(db, cliente: c, produto: cafe, data: DateTime(2026, 2, 1),
        quantidade: 7, valor: 1500);
    final scope = await montarApp(tester, db);
    await irPara(tester, 'Compras');

    for (final col in ['Data', 'Sequência', 'Cliente', 'Reduzido', 'Produto', 'Qtde',
        'Valor Unitário', 'Valor Total']) {
      expect(find.text(col), findsOneWidget, reason: col);
    }
    double y(String t) => tester.getTopLeft(find.text(t)).dy;
    expect(y('01/03/2026'), lessThan(y('01/02/2026')));
    expect(y('01/02/2026'), lessThan(y('01/01/2026')));
    expect(find.text('Qtde: 22'), findsOneWidget);
    expect(find.text(r'Valor Total: R$ 180,00'), findsOneWidget);

    // Filtro por produto (categoria).
    scope.compras.aplicarFiltro(const FiltroIgual('produto', {'LEITE INTEGRAL 1L'}));
    await tester.pumpAndSettle();
    expect(find.text('2 registros'), findsOneWidget);
    expect(find.text('Qtde: 15'), findsOneWidget);
    expect(find.text(r'Valor Total: R$ 75,00'), findsOneWidget);
    expect(find.text('Produto = LEITE INTEGRAL 1L'), findsOneWidget);
  });

  testWidgets('filtro de produto pelo diálogo de valores', (tester) async {
    final c = await novoCliente(db, 'SOUSA');
    await novaCompra(db, cliente: c, produto: await novoProduto(db, 1, 'LEITE INTEGRAL 1L'),
        data: DateTime(2026, 1, 1), quantidade: 3);
    await novaCompra(db, cliente: c, produto: await novoProduto(db, 2, 'CAFE'),
        data: DateTime(2026, 1, 1), quantidade: 4);
    await abrirCompras(tester);

    await tester.tap(find.text('Filtros'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Produto'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'LEITE INTEGRAL 1L'));
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
    expect(find.text('Qtde: 3'), findsOneWidget);
  });

  testWidgets('preço sugerido, total ao vivo e preço negociado', (tester) async {
    await novoCliente(db, 'SOUSA');
    await novoProduto(db, 3068, 'REFRIGERANTE 2L', preco: 7307);
    await abrirCompras(tester);
    await novaCompraForm(tester);

    expect(find.text('15/06/2026'), findsOneWidget); // data padrão = hoje
    await escolher(tester, 'cliente', 'sou', 'SOUSA');
    await escolher(tester, 'produto', '3068', '3068 - REFRIGERANTE 2L');
    expect(texto(tester, 'valorUnitario'), '73,07');

    await tester.enterText(find.byKey(const ValueKey('quantidade')), '93');
    await tester.pump();
    expect(find.text(r'R$ 6.795,51'), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('valorUnitario')), '7000');
    await tester.pump();
    expect(find.text(r'R$ 6.510,00'), findsOneWidget);
    await salvar(tester);

    expect(find.text('Compra salva'), findsOneWidget);
    final compra = (await db.select(db.compras).get()).single;
    expect(compra.valorUnitarioCentavos, 7000);
    expect(compra.quantidade, 93);
    expect(compra.data, hoje);
    expect((await db.produtosDao.porReduzido(3068))!.precoPadraoCentavos, 7307);
  });

  testWidgets('trocar de produto substitui o valor editado', (tester) async {
    await novoProduto(db, 1, 'CAFE', preco: 799);
    await novoProduto(db, 2, 'LEITE', preco: 799);
    await abrirCompras(tester);
    await novaCompraForm(tester);

    await escolher(tester, 'produto', 'cafe', '1 - CAFE');
    await tester.enterText(find.byKey(const ValueKey('valorUnitario')), '750');
    await escolher(tester, 'produto', 'leite', '2 - LEITE');
    expect(texto(tester, 'valorUnitario'), '7,99');
  });

  testWidgets('quantidade zero e campos obrigatórios bloqueiam', (tester) async {
    await novoCliente(db, 'SOUSA');
    await novoProduto(db, 1, 'CAFE', preco: 100);
    await abrirCompras(tester);
    await novaCompraForm(tester);
    await salvar(tester);
    expect(find.text('Selecione o cliente'), findsOneWidget);
    expect(find.text('Selecione o produto'), findsOneWidget);

    await escolher(tester, 'cliente', 'sou', 'SOUSA');
    await escolher(tester, 'produto', 'cafe', '1 - CAFE');
    await tester.enterText(find.byKey(const ValueKey('quantidade')), '0');
    await salvar(tester);
    expect(find.text('A quantidade deve ser maior que zero'), findsOneWidget);
    expect(await db.select(db.compras).get(), isEmpty);
  });

  testWidgets('duas compras com a mesma sequência', (tester) async {
    await novoCliente(db, 'SOUSA');
    await novoProduto(db, 1, 'CAFE', preco: 100);
    await novoProduto(db, 2, 'LEITE', preco: 100);
    await abrirCompras(tester);
    for (final (busca, opcao) in [('cafe', '1 - CAFE'), ('leite', '2 - LEITE')]) {
      await novaCompraForm(tester);
      await escolher(tester, 'cliente', 'sou', 'SOUSA');
      await escolher(tester, 'produto', busca, opcao);
      await tester.enterText(find.byKey(const ValueKey('quantidade')), '1');
      await tester.enterText(find.byKey(const ValueKey('sequencia')), '3345336');
      await salvar(tester);
    }
    final compras = await db.select(db.compras).get();
    expect(compras.map((c) => c.sequencia), [3345336, 3345336]);
    expect(find.text('2 registros'), findsOneWidget);
  });

  testWidgets('editar pela tabela', (tester) async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 1, 'CAFE', preco: 100);
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 6, 1), quantidade: 3);
    await abrirCompras(tester);
    await tester.tap(find.text('01/06/2026'));
    await tester.pumpAndSettle();
    expect(find.text('Editar compra'), findsOneWidget);
    expect(texto(tester, 'cliente'), 'SOUSA');
    expect(texto(tester, 'produto'), '1 - CAFE');
    await tester.enterText(find.byKey(const ValueKey('quantidade')), '4');
    await salvar(tester);
    expect((await db.select(db.compras).get()).single.quantidade, 4);
  });
}
