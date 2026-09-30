// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consulta_dao.dart';

// ignore_for_file: type=lint
mixin _$ConsultaDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClientesTable get clientes => attachedDatabase.clientes;
  $ProdutosTable get produtos => attachedDatabase.produtos;
  $ComprasTable get compras => attachedDatabase.compras;
  ConsultaDaoManager get managers => ConsultaDaoManager(this);
}

class ConsultaDaoManager {
  final _$ConsultaDaoMixin _db;
  ConsultaDaoManager(this._db);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db.attachedDatabase, _db.clientes);
  $$ProdutosTableTableManager get produtos =>
      $$ProdutosTableTableManager(_db.attachedDatabase, _db.produtos);
  $$ComprasTableTableManager get compras =>
      $$ComprasTableTableManager(_db.attachedDatabase, _db.compras);
}
