// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produtos_dao.dart';

// ignore_for_file: type=lint
mixin _$ProdutosDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProdutosTable get produtos => attachedDatabase.produtos;
  $ClientesTable get clientes => attachedDatabase.clientes;
  $ComprasTable get compras => attachedDatabase.compras;
  ProdutosDaoManager get managers => ProdutosDaoManager(this);
}

class ProdutosDaoManager {
  final _$ProdutosDaoMixin _db;
  ProdutosDaoManager(this._db);
  $$ProdutosTableTableManager get produtos =>
      $$ProdutosTableTableManager(_db.attachedDatabase, _db.produtos);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db.attachedDatabase, _db.clientes);
  $$ComprasTableTableManager get compras =>
      $$ComprasTableTableManager(_db.attachedDatabase, _db.compras);
}
