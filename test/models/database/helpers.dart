import 'package:app_pai/models/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// Banco em memória com as mesmas funções SQL do app.
AppDatabase bancoDeTeste({DateTime Function()? relogio}) => AppDatabase(
      NativeDatabase.memory(setup: registrarFuncoesSql),
      relogio: relogio,
    );

Future<int> novoCliente(
  AppDatabase db,
  String fantasia, {
  String? razao,
  String? cnpj,
  String? cidade,
}) =>
    db.clientesDao.inserir(ClientesCompanion.insert(
      fantasia: fantasia,
      razaoSocial: Value(razao),
      cnpj: Value(cnpj),
      cidade: Value(cidade),
    ));

Future<int> novoProduto(AppDatabase db, int reduzido, String descricao,
        {int preco = 100}) =>
    db.produtosDao.inserir(ProdutosCompanion.insert(
      reduzido: reduzido,
      descricao: descricao,
      precoPadraoCentavos: preco,
    ));

Future<int> novaCompra(
  AppDatabase db, {
  required int cliente,
  required int produto,
  required DateTime data,
  int quantidade = 1,
  int valor = 100,
  int? sequencia,
}) =>
    db.comprasDao.inserir(ComprasCompanion.insert(
      clienteId: cliente,
      produtoId: produto,
      data: data,
      quantidade: quantidade,
      valorUnitarioCentavos: valor,
      sequencia: Value(sequencia),
    ));
