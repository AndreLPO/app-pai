import 'package:app_pai/app_scope.dart';
import 'package:app_pai/controllers/auth_controller.dart';
import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/services/pin_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late DateTime agora;

  setUp(() {
    agora = DateTime(2026, 6, 15, 10);
    db = bancoDeTeste(relogio: () => agora);
  });
  tearDown(() => db.close());

  Future<void> digitarPin(WidgetTester tester, String chave, String pin) =>
      tester.enterText(find.byKey(ValueKey(chave)), pin);

  Finder shell() => find.byType(NavigationRail);

  testWidgets('primeiro acesso: Criar PIN antes de qualquer tela', (tester) async {
    await montarApp(tester, db, desbloqueado: false);
    expect(find.text('Criar PIN'), findsOneWidget);
    expect(shell(), findsNothing);

    await digitarPin(tester, 'pin', '1234');
    await digitarPin(tester, 'confirmacao', '1234');
    await tester.tap(find.text('Salvar'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.text('Criar PIN'), findsNothing);
    expect(shell(), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
    expect(await tester.runAsync(() => PinService(db.configDao).verificar('1234')), isTrue);
  });

  testWidgets('confirmação diferente não salva e pede de novo', (tester) async {
    await montarApp(tester, db, desbloqueado: false);
    await digitarPin(tester, 'pin', '1234');
    await digitarPin(tester, 'confirmacao', '1235');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Os PINs não conferem'), findsOneWidget);
    expect(find.text('Criar PIN'), findsOneWidget);
    final campo = tester.widget<TextField>(
        find.descendant(of: find.byKey(const ValueKey('pin')), matching: find.byType(TextField)));
    expect(campo.controller!.text, isEmpty);
    expect(await tester.runAsync(() => PinService(db.configDao).temPin()), isFalse);
  });

  testWidgets('PIN com tamanho inválido', (tester) async {
    await montarApp(tester, db, desbloqueado: false);
    await digitarPin(tester, 'pin', '123');
    await digitarPin(tester, 'confirmacao', '123');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('O PIN deve ter de 4 a 6 dígitos'), findsOneWidget);
  });

  Future<AppScope> abrirComPin(WidgetTester tester) async {
    await tester.runAsync(() => PinService(db.configDao).definir('1234'));
    return montarApp(tester, db, desbloqueado: false);
  }

  Future<void> entrar(WidgetTester tester, String pin) async {
    await digitarPin(tester, 'pin', pin);
    await tester.tap(find.text('Entrar'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
  }

  testWidgets('PIN correto abre a Home; incorreto avisa e limpa', (tester) async {
    await abrirComPin(tester);
    expect(find.text('Digite seu PIN'), findsOneWidget);
    expect(shell(), findsNothing);

    await entrar(tester, '0000');
    expect(find.text('PIN incorreto'), findsOneWidget);
    expect(find.text('Digite seu PIN'), findsOneWidget);
    final campo = tester.widget<TextField>(
        find.descendant(of: find.byKey(const ValueKey('pin')), matching: find.byType(TextField)));
    expect(campo.controller!.text, isEmpty);

    await entrar(tester, '1234');
    expect(find.text('Digite seu PIN'), findsNothing);
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
  });

  testWidgets('5 erros bloqueiam por 30 s e mostram o tempo restante', (tester) async {
    await abrirComPin(tester);
    for (var i = 0; i < 5; i++) {
      await entrar(tester, '0000');
    }
    expect(find.textContaining('Aguarde 30 s'), findsOneWidget);
    final botao = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Entrar'));
    expect(botao.onPressed, isNull);

    agora = agora.add(const Duration(seconds: 12));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Aguarde 18 s'), findsOneWidget);

    agora = agora.add(const Duration(seconds: 18));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Aguarde'), findsNothing);
    await entrar(tester, '1234');
    expect(shell(), findsOneWidget);
  });

  testWidgets('rebloqueio preserva a tela em que o usuário estava', (tester) async {
    final scope = await abrirComPin(tester);
    await entrar(tester, '1234');
    await irPara(tester, 'Produtos');

    scope.auth.aoIrParaSegundoPlano();
    agora = agora.add(const Duration(minutes: 5));
    scope.auth.aoRetomar();
    await tester.pumpAndSettle();
    expect(find.text('Digite seu PIN'), findsOneWidget);
    expect(scope.auth.estado, EstadoAuth.bloqueado);

    await entrar(tester, '1234');
    expect(find.widgetWithText(AppBar, 'Produtos').hitTestable(), findsOneWidget);
  });

  testWidgets('trocar PIN', (tester) async {
    await montarApp(tester, db);
    await irPara(tester, 'Trocar PIN');

    Future<void> trocar(String atual, String novo, String conf) async {
      await digitarPin(tester, 'atual', atual);
      await digitarPin(tester, 'novo', novo);
      await digitarPin(tester, 'confirmacao', conf);
      await tester.tap(find.widgetWithText(FilledButton, 'Trocar PIN'));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();
    }

    await trocar('9999', '5678', '5678');
    expect(find.text('PIN atual incorreto'), findsOneWidget);
    expect(await tester.runAsync(() => PinService(db.configDao).verificar('1234')), isTrue);

    await trocar('1234', '5678', '5678');
    expect(find.text('PIN alterado'), findsOneWidget);
    final pin = PinService(db.configDao);
    expect(await tester.runAsync(() => pin.verificar('5678')), isTrue);
    expect(await tester.runAsync(() => pin.verificar('1234')), isFalse);
  });
}
