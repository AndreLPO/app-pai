import 'package:app_pai/models/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = bancoDeTeste(relogio: () => DateTime(2026, 6, 15)));
  tearDown(() => db.close());

  testWidgets('cada item do menu abre a página correspondente', (tester) async {
    await montarApp(tester, db);

    // A Home é a página inicial.
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

    const destinos = {
      'Consulta Geral': 'Consulta Geral',
      'Clientes': 'Clientes',
      'Produtos': 'Produtos',
      'Compras': 'Compras',
      'Importar/Exportar': 'Importar / Exportar',
      'Trocar PIN': 'Trocar PIN',
      'Home': 'Home',
    };
    for (final MapEntry(key: item, value: titulo) in destinos.entries) {
      await irPara(tester, item);
      final appBarVisivel = find.byWidgetPredicate(
        (w) => w is AppBar && (w.title as Text?)?.data == titulo,
      );
      expect(appBarVisivel.hitTestable(), findsOneWidget, reason: item);
    }
  });

  testWidgets('tema Material 3 e locale pt-BR', (tester) async {
    await montarApp(tester, db);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.locale, const Locale('pt', 'BR'));
    expect(app.theme!.useMaterial3, isTrue);
  });
}
