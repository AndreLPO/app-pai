// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_dao.dart';

// ignore_for_file: type=lint
mixin _$ConfigDaoMixin on DatabaseAccessor<AppDatabase> {
  $ConfiguracoesTable get configuracoes => attachedDatabase.configuracoes;
  ConfigDaoManager get managers => ConfigDaoManager(this);
}

class ConfigDaoManager {
  final _$ConfigDaoMixin _db;
  ConfigDaoManager(this._db);
  $$ConfiguracoesTableTableManager get configuracoes =>
      $$ConfiguracoesTableTableManager(_db.attachedDatabase, _db.configuracoes);
}
