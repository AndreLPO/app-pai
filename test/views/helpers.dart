import 'package:app_pai/app.dart';
import 'package:app_pai/app_scope.dart';
import 'package:app_pai/controllers/auth_controller.dart';
import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/services/pin_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

export '../models/database/helpers.dart';

/// Tela de tablet em paisagem.
void usarTelaDeTablet(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Monta o app completo. Com [desbloqueado], já entra com o PIN 1234.
Future<AppScope> montarApp(
  WidgetTester tester,
  AppDatabase db, {
  bool desbloqueado = true,
  DateTime Function()? relogio,
}) async {
  usarTelaDeTablet(tester);
  final auth = AuthController(PinService(db.configDao), relogio: relogio ?? db.relogio);
  if (desbloqueado) {
    await tester.runAsync(() async {
      await PinService(db.configDao).definir('1234');
      await auth.iniciar();
      await auth.entrar('1234');
    });
  }
  final scope = AppScope(
    db: db,
    auth: auth,
    debounceBusca: const Duration(milliseconds: 10),
    child: const App(),
  );
  await tester.pumpWidget(scope);
  await tester.pumpAndSettle();
  return scope;
}

/// Vai para uma aba pelo menu lateral.
Future<void> irPara(WidgetTester tester, String rotulo) async {
  await tester.tap(find.descendant(of: find.byType(NavigationRail), matching: find.text(rotulo)));
  await tester.pumpAndSettle();
}

/// Texto exibido em uma célula da tabela.
Finder celula(String texto) => find.descendant(
      of: find.byType(Scaffold).last,
      matching: find.text(texto),
    );
