import 'package:app_pai/models/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = bancoDeTeste(relogio: () => DateTime(2026, 6, 15)));
  tearDown(() => db.close());

  Future<void> abrirClientes(WidgetTester tester) async {
    await montarApp(tester, db);
    await irPara(tester, 'Clientes');
  }

  Future<void> novoFormulario(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();
  }

  Future<void> digitar(WidgetTester tester, String campo, String texto) =>
      tester.enterText(find.byKey(ValueKey(campo)), texto);

  String textoDoCampo(WidgetTester tester, String campo) => tester
      .widget<TextField>(
          find.descendant(of: find.byKey(ValueKey(campo)), matching: find.byType(TextField)))
      .controller!
      .text;

  Future<void> salvar(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
  }

  testWidgets('tabela: colunas e ordenação padrão por Fantasia', (tester) async {
    await novoCliente(db, 'ZETA');
    await novoCliente(db, 'ALFA');
    await novoCliente(db, 'ÁGUIA');
    await abrirClientes(tester);

    for (final c in ['Fantasia', 'Razão Social', 'CNPJ', 'Contato', 'Telefone', 'Cidade',
        'Bairro', 'Última Compra']) {
      expect(find.text(c), findsOneWidget, reason: c);
    }
    double y(String t) => tester.getTopLeft(find.text(t)).dy;
    expect(y('ÁGUIA'), lessThan(y('ALFA')));
    expect(y('ALFA'), lessThan(y('ZETA')));
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });

  testWidgets('cadastro mínimo em maiúsculas', (tester) async {
    await abrirClientes(tester);
    await novoFormulario(tester);
    await digitar(tester, 'fantasia', 'mercado são luiz');
    expect(textoDoCampo(tester, 'fantasia'), 'MERCADO SÃO LUIZ');
    await salvar(tester);

    expect(find.text('Cliente salvo'), findsOneWidget);
    expect(find.text('MERCADO SÃO LUIZ'), findsOneWidget);
  });

  testWidgets('Nome Fantasia vazio bloqueia o salvamento', (tester) async {
    await abrirClientes(tester);
    await novoFormulario(tester);
    await digitar(tester, 'razaoSocial', 'X');
    await salvar(tester);
    expect(find.text('Informe o Nome Fantasia'), findsOneWidget);
    expect(find.text('Novo cliente'), findsOneWidget);
    expect(await db.select(db.clientes).get(), isEmpty);
  });

  testWidgets('máscaras de CNPJ, CEP, DDD e telefone', (tester) async {
    await abrirClientes(tester);
    await novoFormulario(tester);
    await digitar(tester, 'cep', '11071486');
    await digitar(tester, 'cnpj', '70193852000128');
    await digitar(tester, 'ddd', '199');
    await digitar(tester, 'telefone', '960345419');
    expect(textoDoCampo(tester, 'cep'), '11071-486');
    expect(textoDoCampo(tester, 'cnpj'), '70.193.852/0001-28');
    expect(textoDoCampo(tester, 'ddd'), '19');
    expect(textoDoCampo(tester, 'telefone'), '9 6034-5419');
  });

  testWidgets('CNPJ inválido e CNPJ duplicado', (tester) async {
    await novoCliente(db, 'SOUSA', cnpj: '70193852000128');
    await abrirClientes(tester);
    await novoFormulario(tester);
    await digitar(tester, 'fantasia', 'OUTRO');
    await digitar(tester, 'cnpj', '70193852000129');
    await salvar(tester);
    expect(find.text('CNPJ inválido'), findsOneWidget);

    await digitar(tester, 'cnpj', '70193852000128');
    await salvar(tester);
    expect(find.text('CNPJ já usado por "SOUSA"'), findsOneWidget);
    expect(await db.select(db.clientes).get(), hasLength(1));
  });

  testWidgets('excluir cliente com 3 compras é recusado', (tester) async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 1, 'CAFE');
    for (var i = 1; i <= 3; i++) {
      await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, i, 1));
    }
    await abrirClientes(tester);
    await tester.tap(find.text('SOUSA'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Não é possível excluir: existem 3 compras vinculadas'), findsOneWidget);
  });

  testWidgets('histórico de compras e "Nova compra" com o cliente preenchido', (tester) async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 1, 10), quantidade: 2);
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 3, 10), quantidade: 5);
    await abrirClientes(tester);
    await tester.tap(find.text('SOUSA'));
    await tester.pumpAndSettle();

    expect(find.text('10/03/2026'), findsOneWidget);
    expect(find.text('10/01/2026'), findsOneWidget);
    expect(tester.getTopLeft(find.text('10/03/2026')).dy,
        lessThan(tester.getTopLeft(find.text('10/01/2026')).dy));

    await tester.tap(find.text('Nova compra'));
    await tester.pumpAndSettle();
    expect(find.text('Nova compra'), findsWidgets);
    expect(textoDoCampo(tester, 'cliente'), 'SOUSA');
  });

  testWidgets('edição altera o registro na tabela', (tester) async {
    await novoCliente(db, 'SOUSA');
    await abrirClientes(tester);
    await tester.tap(find.text('SOUSA'));
    await tester.pumpAndSettle();
    await digitar(tester, 'cidade', 'limeira');
    await salvar(tester);
    expect(find.text('LIMEIRA'), findsOneWidget);
  });
}
