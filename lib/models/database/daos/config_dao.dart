import 'package:drift/drift.dart';

import '../app_database.dart';

part 'config_dao.g.dart';

/// Chave/valor para configurações do app (ex.: hash do PIN).
@DriftAccessor(tables: [Configuracoes])
class ConfigDao extends DatabaseAccessor<AppDatabase> with _$ConfigDaoMixin {
  ConfigDao(super.attachedDatabase);

  Future<String?> ler(String chave) async {
    final linha = await (select(configuracoes)
          ..where((c) => c.chave.equals(chave)))
        .getSingleOrNull();
    return linha?.valor;
  }

  Future<void> gravar(String chave, String valor) => into(configuracoes)
      .insertOnConflictUpdate(ConfiguracoesCompanion.insert(chave: chave, valor: valor));

  Future<void> gravarVarios(Map<String, String> valores) => transaction(() async {
        for (final e in valores.entries) {
          await gravar(e.key, e.value);
        }
      });
}
