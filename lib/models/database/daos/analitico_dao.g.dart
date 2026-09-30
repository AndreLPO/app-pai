// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analitico_dao.dart';

// ignore_for_file: type=lint
mixin _$AnaliticoDaoMixin on DatabaseAccessor<AppDatabase> {
  $ClientesTable get clientes => attachedDatabase.clientes;
  $ProdutosTable get produtos => attachedDatabase.produtos;
  $ComprasTable get compras => attachedDatabase.compras;
  AnaliticoDaoManager get managers => AnaliticoDaoManager(this);
}

class AnaliticoDaoManager {
  final _$AnaliticoDaoMixin _db;
  AnaliticoDaoManager(this._db);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db.attachedDatabase, _db.clientes);
  $$ProdutosTableTableManager get produtos =>
      $$ProdutosTableTableManager(_db.attachedDatabase, _db.produtos);
  $$ComprasTableTableManager get compras =>
      $$ComprasTableTableManager(_db.attachedDatabase, _db.compras);
}
