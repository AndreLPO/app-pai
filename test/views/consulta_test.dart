import 'package:app_pai/models/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = bancoDeTeste(relogio: () => DateTime(2026, 6, 15)));
  tearDown(() => db.close());

  Future<void> cenario() async {
    final campinas = await novoCliente(db, 'SOUSA', cidade: 'CAMPINAS');
    final limeira = await novoCliente(db, 'PASTOR', cidade: 'LIMEIRA');
    final cafe = await novoProduto(db, 7321, 'CAFE TORRADO 500G');
    final leite = await novoProduto(db, 2139, 'LEITE INTEGRAL 1L');
    await novaCompra(db, cliente: campinas, produto: cafe, data: DateTime(2026, 5, 2),
        quantidade: 3, valor: 1261);
    await novaCompra(db, cliente: campinas, produto: leite, data: DateTime(2026, 5, 3),
        quantidade: 4, valor: 500);
    await novaCompra(db, cliente: limeira, produto: cafe, data: DateTime(2026, 5, 4),
        quantidade: 5, valor: 1261);
  }

  Future<void> abrirConsulta(WidgetTester tester) async {
    await montarApp(tester, db);
    await irPara(tester, 'Consulta Geral');
  }

  Future<void> filtroCategoria(WidgetTester tester, String coluna, String valor) async {
    await tester.tap(find.byKey(ValueKey('filtro-rapido-$coluna')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, valor));
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
  }

  testWidgets('filtros rápidos visíveis e filtro por cidade + produto', (tester) async {
    await cenario();
    await abrirConsulta(tester);
    for (final f in ['Cidade', 'Produto', 'Cliente', 'Período']) {
      expect(find.widgetWithText(ActionChip, f), findsOneWidget, reason: f);
    }
    expect(find.text('3 registros'), findsOneWidget);

    await filtroCategoria(tester, 'cidade', 'CAMPINAS');
    await filtroCategoria(tester, 'produto', 'CAFE TORRADO 500G');
    expect(find.text('1 registro'), findsOneWidget);
    expect(find.text('Qtde: 3'), findsOneWidget);
    expect(find.text(r'Valor Total: R$ 37,83'), findsOneWidget);
  });

  testWidgets('ordem das colunas, ordenação padrão e Fantasia fixa na rolagem', (tester) async {
    await cenario();
    await abrirConsulta(tester);
    for (final c in ['Fantasia', 'DDD', 'Zap', 'Contato']) {
      expect(find.text(c), findsOneWidget);
    }
    double x(String t) => tester.getTopLeft(find.text(t)).dx;
    expect(x('Fantasia'), lessThan(x('DDD')));
    expect(x('DDD'), lessThan(x('Zap')));

    // Data decrescente: a compra de 04/05 (PASTOR) vem primeiro.
    double y(String t) => tester.getTopLeft(find.text(t).first).dy;
    expect(y('PASTOR'), lessThan(y('SOUSA')));

    await tester.drag(find.byType(TableView), const Offset(-2500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Valor Total'), findsOneWidget);
    expect(find.text('Fantasia'), findsOneWidget);
    expect(find.text('DDD'), findsNothing);
  });

  testWidgets('ocultar e reexibir colunas', (tester) async {
    await cenario();
    final scope = await montarApp(tester, db);
    await irPara(tester, 'Consulta Geral');

    await tester.tap(find.byKey(const ValueKey('colunas')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Insc. Estadual'));
    await tester.tap(find.widgetWithText(CheckboxListTile, 'CEP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    final ids = [for (final c in scope.consulta.colunasVisiveis) c.id];
    expect(ids, hasLength(16));
    expect(ids, isNot(contains('inscEstadual')));
    expect(ids, isNot(contains('cep')));

    // A Fantasia não pode ser ocultada.
    await tester.tap(find.byKey(const ValueKey('colunas')));
    await tester.pumpAndSettle();
    final fantasia = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Fantasia'));
    expect(fantasia.onChanged, isNull);
    await tester.tap(find.text('Mostrar todas'));
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();
    expect(scope.consulta.colunasVisiveis, hasLength(18));

    // Mantém na sessão ao trocar de aba.
    scope.consulta.alternarColuna('cep', visivel: false);
    await irPara(tester, 'Home');
    await irPara(tester, 'Consulta Geral');
    expect(scope.consulta.colunasVisiveis, hasLength(17));
  });

  testWidgets('rodapé soma todas as páginas', (tester) async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 1, 'CAFE');
    await db.transaction(() async {
      for (var i = 0; i < 120; i++) {
        await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 1, 1),
            quantidade: 2, valor: 100);
      }
    });
    await abrirConsulta(tester);
    expect(find.text('120 registros'), findsOneWidget);
    expect(find.text('Página 1 de 3'), findsOneWidget);
    expect(find.text('Qtde: 240'), findsOneWidget);
    expect(find.text(r'Valor Total: R$ 240,00'), findsOneWidget);
  });

  testWidgets('tocar em uma linha abre o formulário da compra', (tester) async {
    await cenario();
    await abrirConsulta(tester);
    await tester.tap(find.text('PASTOR'));
    await tester.pumpAndSettle();
    expect(find.text('Editar compra'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.descendant(
              of: find.byKey(const ValueKey('cliente')), matching: find.byType(TextField)))
          .controller!
          .text,
      'PASTOR',
    );
  });
}
