import 'package:app_pai/controllers/table_controller.dart';
import 'package:app_pai/core/text_normalize.dart';
import 'package:app_pai/models/table_query.dart';
import 'package:app_pai/views/widgets/filtros.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// Fonte em memória que aplica ordenação, filtro "contém" e paginação.
class FonteMemoria implements FonteTabela<int> {
  FonteMemoria(this.dados);

  final List<({String nome, int valor})> dados;

  @override
  List<ColunaTabela> get colunas => const [
        ColunaTabela(id: 'nome', rotulo: 'Nome', tipo: TipoColuna.texto),
        ColunaTabela(id: 'valor', rotulo: 'Valor', tipo: TipoColuna.moeda),
      ];

  @override
  ({String coluna, bool crescente}) get ordenacaoPadrao => (coluna: 'nome', crescente: true);

  @override
  Future<PaginaTabela<int>> buscarPagina(TableQuery q) async {
    var linhas = [
      for (var i = 0; i < dados.length; i++)
        if (q.filtros.every((f) =>
            f is! FiltroContem || contemNormalizado(dados[i].nome, f.texto)))
          i,
    ];
    final coluna = q.ordenarPor ?? 'nome';
    final crescente = q.ordenarPor == null ? true : q.crescente;
    linhas.sort((a, b) {
      final r = coluna == 'nome'
          ? dados[a].nome.compareTo(dados[b].nome)
          : dados[a].valor.compareTo(dados[b].valor);
      return crescente ? r : -r;
    });
    final total = linhas.length;
    linhas = linhas.skip(q.offset).take(q.tamanhoPagina).toList();
    return PaginaTabela(
      total: total,
      somas: {'valor': total * 100},
      linhas: [
        for (final i in linhas)
          LinhaTabela(i, {'nome': dados[i].nome, 'valor': dados[i].valor}),
      ],
    );
  }

  @override
  Future<List<String>> valoresDistintos(String colunaId) async => const [];
}

void main() {
  late TableController<int> c;
  int? tocado;

  Future<void> montar(WidgetTester tester, List<({String nome, int valor})> dados) async {
    usarTelaDeTablet(tester);
    c = TableController(FonteMemoria(dados), debounce: const Duration(milliseconds: 10));
    addTearDown(c.dispose);
    tocado = null;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TabelaCompleta<int>(controller: c, aoTocarLinha: (i) => tocado = i),
      ),
    ));
    await tester.pumpAndSettle();
  }

  List<String> nomesVisiveis(WidgetTester tester) => [
        for (final t in tester.widgetList<Text>(find.byType(Text)))
          if (t.data != null && RegExp(r'^L\d+$').hasMatch(t.data!)) t.data!,
      ];

  testWidgets('toque no cabeçalho ordena crescente e depois decrescente', (tester) async {
    await montar(tester, [(nome: 'L1', valor: 100), (nome: 'L2', valor: 9), (nome: 'L3', valor: 10)]);
    expect(nomesVisiveis(tester), ['L1', 'L2', 'L3']);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cabecalho-valor')));
    await tester.pumpAndSettle();
    expect(nomesVisiveis(tester), ['L2', 'L3', 'L1']);
    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cabecalho-valor')));
    await tester.pumpAndSettle();
    expect(nomesVisiveis(tester), ['L1', 'L3', 'L2']);
    expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    expect(find.text(r'R$ 1,00'), findsOneWidget);
  });

  testWidgets('filtro vira chip removível e "Limpar filtros" restaura', (tester) async {
    await montar(tester, [(nome: 'L1', valor: 1), (nome: 'L22', valor: 2)]);

    await tester.tap(find.text('Filtros'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Nome'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '22');
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(InputChip, 'Nome contém "22"'), findsOneWidget);
    expect(nomesVisiveis(tester), ['L22']);
    expect(find.text('1 registro'), findsOneWidget);

    await tester.tap(find.byTooltip('Remover filtro'));
    await tester.pumpAndSettle();
    expect(find.byType(InputChip), findsNothing);
    expect(nomesVisiveis(tester), ['L1', 'L22']);

    await tester.tap(find.byKey(const ValueKey('cabecalho-valor')));
    await tester.enterText(find.byKey(const ValueKey('busca')), 'x');
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpar filtros'));
    await tester.pumpAndSettle();
    expect(c.query.busca, '');
    expect(c.ordenacao, (coluna: 'nome', crescente: true));
    expect(tester.widget<TextField>(find.byKey(const ValueKey('busca'))).controller!.text, '');
  });

  testWidgets('paginação de 50, contagem e toque na linha', (tester) async {
    await montar(tester, [for (var i = 0; i < 120; i++) (nome: 'L${1000 + i}', valor: i)]);
    expect(find.text('120 registros'), findsOneWidget);
    expect(find.text('Página 1 de 3'), findsOneWidget);
    expect(find.byKey(const ValueKey('soma-valor')), findsOneWidget);

    await tester.tap(find.byTooltip('Próxima página'));
    await tester.pumpAndSettle();
    expect(find.text('Página 2 de 3'), findsOneWidget);
    expect(nomesVisiveis(tester).first, 'L1050');

    await tester.tap(find.byTooltip('Última página'));
    await tester.pumpAndSettle();
    expect(find.text('Página 3 de 3'), findsOneWidget);
    expect(c.linhas, hasLength(20));

    await tester.tap(find.text('L1100'));
    expect(tocado, 100);
  });
}
