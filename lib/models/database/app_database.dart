import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:sqlite3/common.dart';

import '../../core/text_normalize.dart';
import 'daos/analitico_dao.dart';
import 'daos/clientes_dao.dart';
import 'daos/compras_dao.dart';
import 'daos/config_dao.dart';
import 'daos/consulta_dao.dart';
import 'daos/produtos_dao.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

/// Registra as funções SQL da aplicação (chamado a cada conexão aberta).
void registrarFuncoesSql(CommonDatabase db) {
  db.createFunction(
    functionName: 'unaccent',
    argumentCount: const AllowedArgumentCount(1),
    deterministic: true,
    function: (args) {
      final v = args[0];
      return v == null ? null : normalizar(v.toString());
    },
  );
}

@DriftDatabase(
  tables: [Clientes, Produtos, Compras, Configuracoes],
  daos: [
    ClientesDao,
    ProdutosDao,
    ComprasDao,
    ConsultaDao,
    AnaliticoDao,
    ConfigDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e, {DateTime Function()? relogio})
      : relogio = relogio ?? DateTime.now;

  /// Abre o banco do app no diretório de documentos do dispositivo.
  factory AppDatabase.abrir() => AppDatabase(
        driftDatabase(
          name: 'app_pai',
          native: const DriftNativeOptions(setup: registrarFuncoesSql),
        ),
      );

  /// Fonte da data/hora atual (substituível em testes).
  final DateTime Function() relogio;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Migrações futuras entram aqui (schemaVersion > 1).
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
