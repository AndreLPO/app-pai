import 'dart:io';

import 'package:app_pai/app.dart';
import 'package:app_pai/app_scope.dart';
import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/views/importacao/importacao_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  final fixture = File('test/fixtures/DADOS.xlsx').readAsBytesSync();

  setUp(() => db = bancoDeTeste(relogio: () => DateTime(2026, 9, 29)));
  tearDown(() => db.close());

  Future<AppScope> montar(WidgetTester tester) async {
    usarTelaDeTablet(tester);
    final scope = AppScope(
      db: db,
      child: MaterialApp(
        theme: temaApp(),
        home: ImportacaoPage(escolherArquivo: () async => (nome: 'DADOS.xlsx', bytes: fixture)),
      ),
    );
    await tester.pumpWidget(scope);
    await tester.pumpAndSettle();
    return scope;
  }

  /// A análise roda em outro isolate: espera de verdade até o resumo aparecer.
  Future<void> esperar(WidgetTester tester, Finder alvo) async {
    for (var i = 0; i < 100 && alvo.evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(alvo, findsWidgets);
  }

  Future<int> contarCompras() async => (await db.select(db.compras).get()).length;

  testWidgets('cancelar após o resumo não grava nada', (tester) async {
    await montar(tester);
    await tester.tap(find.text('Escolher arquivo'));
    await esperar(tester, find.byKey(const ValueKey('resumo')));

    expect(find.text('Arquivo: DADOS.xlsx'), findsOneWidget);
    final linhaCompras =
        find.ancestor(of: find.text('Compras a criar'), matching: find.byType(Row)).first;
    expect(find.descendant(of: linhaCompras, matching: find.text('97')), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('resumo')), findsNothing);
    expect(find.text('Escolher arquivo'), findsOneWidget);
    expect(await tester.runAsync(contarCompras), 0);
    expect(await tester.runAsync(() => db.select(db.clientes).get()), isEmpty);
  });

  testWidgets('confirmar grava e recarrega os dados', (tester) async {
    final scope = await montar(tester);
    final versao = scope.versaoDados.value;
    await tester.tap(find.text('Escolher arquivo'));
    await esperar(tester, find.byKey(const ValueKey('resumo')));
    await tester.tap(find.text('Confirmar importação'));
    await esperar(tester, find.textContaining('Importação concluída'));

    expect(await tester.runAsync(contarCompras), 97);
    expect(scope.versaoDados.value, greaterThan(versao));
  });
}
