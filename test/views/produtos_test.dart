import 'package:app_pai/models/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = bancoDeTeste(relogio: () => DateTime(2026, 6, 15)));
  tearDown(() => db.close());

  Future<void> abrirProdutos(WidgetTester tester) async {
    await montarApp(tester, db);
    await irPara(tester, 'Produtos');
  }

  Future<void> preencher(WidgetTester tester,
      {String? reduzido, String? descricao, String? preco}) async {
    if (reduzido != null) await tester.enterText(find.byKey(const ValueKey('reduzido')), reduzido);
    if (descricao != null) {
      await tester.enterText(find.byKey(const ValueKey('descricao')), descricao);
    }
    if (preco != null) await tester.enterText(find.byKey(const ValueKey('preco')), preco);
  }

  Future<void> salvar(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();
  }

  testWidgets('tabela lista os produtos do banco com as colunas da spec', (tester) async {
    await novoProduto(db, 3068, 'REFRIGERANTE 2L', preco: 799);
    await novoProduto(db, 12, 'ÁGUA MINERAL', preco: 7307);
    await abrirProdutos(tester);

    for (final c in ['Reduzido', 'Descrição', 'Preço Padrão', 'Qtde Vendida', 'Última Venda']) {
      expect(find.text(c), findsOneWidget);
    }
    expect(find.text('REFRIGERANTE 2L'), findsOneWidget);
    expect(find.text(r'R$ 73,07'), findsOneWidget);
    // Ordenação padrão por descrição.
    final agua = tester.getTopLeft(find.text('ÁGUA MINERAL')).dy;
    final refri = tester.getTopLeft(find.text('REFRIGERANTE 2L')).dy;
    expect(agua, lessThan(refri));
    expect(find.text('2 registros'), findsOneWidget);
  });

  testWidgets('adicionar: salva, volta, confirma e mostra na tabela', (tester) async {
    await abrirProdutos(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();
    expect(find.text('Novo produto'), findsOneWidget);

    await preencher(tester, reduzido: '3068', descricao: 'refrigerante 2l', preco: '799');
    expect(find.text('7,99'), findsOneWidget);
    await salvar(tester);

    expect(find.text('Novo produto'), findsNothing);
    expect(find.text('Produto salvo'), findsOneWidget);
    expect(find.text('REFRIGERANTE 2L'), findsOneWidget);
    expect(find.text(r'R$ 7,99'), findsOneWidget);
  });

  testWidgets('reduzido duplicado informa qual produto usa o código', (tester) async {
    await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    await abrirProdutos(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();
    await preencher(tester, reduzido: '3068', descricao: 'OUTRO', preco: '100');
    await salvar(tester);

    expect(find.text('Código já usado por "REFRIGERANTE 2L"'), findsOneWidget);
    expect(find.text('Novo produto'), findsOneWidget);
    expect(await db.select(db.produtos).get(), hasLength(1));
  });

  testWidgets('campos obrigatórios', (tester) async {
    await abrirProdutos(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();
    await salvar(tester);
    expect(find.text('Informe um código maior que zero'), findsOneWidget);
    expect(find.text('Informe a descrição'), findsOneWidget);
    expect(find.text('Informe o preço'), findsOneWidget);
  });

  testWidgets('editar: reajuste de preço não altera compras antigas', (tester) async {
    final p = await novoProduto(db, 3068, 'REFRIGERANTE 2L', preco: 799);
    final c = await novoCliente(db, 'SOUSA');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 6, 1), valor: 799);
    await abrirProdutos(tester);

    await tester.tap(find.text('REFRIGERANTE 2L'));
    await tester.pumpAndSettle();
    expect(find.text('Editar produto'), findsOneWidget);
    await preencher(tester, preco: '849');
    await salvar(tester);

    expect(find.text(r'R$ 8,49'), findsOneWidget);
    final compra = (await db.select(db.compras).get()).single;
    expect(compra.valorUnitarioCentavos, 799);
  });

  testWidgets('excluir produto com compras é recusado com a contagem', (tester) async {
    final p = await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    final c = await novoCliente(db, 'SOUSA');
    for (var i = 0; i < 10; i++) {
      await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 6, 1));
    }
    await abrirProdutos(tester);
    await tester.tap(find.text('REFRIGERANTE 2L'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Não é possível excluir: existem 10 compras vinculadas'), findsOneWidget);
    expect(await db.produtosDao.porId(p), isNotNull);
  });

  testWidgets('exclusão confirmada remove da tabela', (tester) async {
    await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    await abrirProdutos(tester);
    await tester.tap(find.text('REFRIGERANTE 2L'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir o produto "REFRIGERANTE 2L"?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Produto excluído'), findsOneWidget);
    expect(find.text('REFRIGERANTE 2L'), findsNothing);
    expect(find.text('Nenhum registro encontrado'), findsOneWidget);
  });

  testWidgets('sair com alterações pede confirmação', (tester) async {
    await abrirProdutos(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Adicionar'));
    await tester.pumpAndSettle();
    await preencher(tester, descricao: 'X');
    await tester.pump();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Descartar alterações?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Novo produto'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Descartar'));
    await tester.pumpAndSettle();
    expect(find.text('Novo produto'), findsNothing);
  });

  testWidgets('filtros e ordenação são mantidos ao voltar do formulário', (tester) async {
    await novoProduto(db, 1, 'CAFE');
    await novoProduto(db, 2, 'LEITE');
    await abrirProdutos(tester);
    await tester.enterText(find.byKey(const ValueKey('busca')), 'lei');
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('cabecalho-reduzido')));
    await tester.pumpAndSettle();
    expect(find.text('CAFE'), findsNothing);

    await tester.tap(find.text('LEITE'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('CAFE'), findsNothing);
    expect(find.text('LEITE'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('busca'))).controller!.text, 'lei');
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });
}
