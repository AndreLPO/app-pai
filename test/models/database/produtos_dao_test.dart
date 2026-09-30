import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/database/daos/produtos_dao.dart';
import 'package:app_pai/models/table_query.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = bancoDeTeste());
  tearDown(() => db.close());

  test('reduzido duplicado é recusado pelo banco e encontrado pelo DAO', () async {
    final id = await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    expect(() => novoProduto(db, 3068, 'OUTRO'), throwsA(anything));
    expect((await db.produtosDao.porReduzido(3068))!.id, id);
    expect(await db.produtosDao.porReduzido(3068, excetoId: id), isNull);
  });

  test('ordenação padrão por descrição, sem diferenciar acento', () async {
    await novoProduto(db, 1, 'FEIJÃO');
    await novoProduto(db, 2, 'ÁGUA');
    await novoProduto(db, 3, 'CAFÉ');
    final p = await db.produtosDao.buscarPagina(const TableQuery());
    expect([for (final l in p.linhas) l.registro.descricao], ['ÁGUA', 'CAFÉ', 'FEIJÃO']);
  });

  test('ordenação numérica do reduzido', () async {
    await novoProduto(db, 100, 'A');
    await novoProduto(db, 9, 'B');
    await novoProduto(db, 10, 'C');
    final p = await db.produtosDao.buscarPagina(
        const TableQuery(ordenarPor: 'reduzido', crescente: true));
    expect([for (final l in p.linhas) l.registro.reduzido], [9, 10, 100]);
  });

  test('filtro por faixa de preço', () async {
    await novoProduto(db, 1, 'BARATO', preco: 499);
    await novoProduto(db, 2, 'MEDIO', preco: 799);
    await novoProduto(db, 3, 'LIMITE', preco: 1000);
    await novoProduto(db, 4, 'CARO', preco: 1001);
    final p = await db.produtosDao.buscarPagina(const TableQuery(filtros: [
      FiltroIntervalo('preco', minimo: 500, maximo: 1000, moeda: true),
    ]));
    expect([for (final l in p.linhas) l.registro.descricao], ['LIMITE', 'MEDIO']);
    expect(p.total, 2);
  });

  test('quantidade vendida, última venda e compras vinculadas', () async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    await novoProduto(db, 1, 'SEM VENDA');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 1, 5), quantidade: 10);
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 3, 2), quantidade: 5);

    final pag = await db.produtosDao.buscarPagina(const TableQuery());
    final vendido = pag.linhas.firstWhere((l) => l.registro.id == p).valores;
    expect(vendido[ProdutosDao.colQtdeVendida.id], 15);
    expect(vendido[ProdutosDao.colUltimaVenda.id], DateTime(2026, 3, 2));
    final semVenda = pag.linhas.firstWhere((l) => l.registro.id != p).valores;
    expect(semVenda[ProdutosDao.colQtdeVendida.id], 0);
    expect(semVenda[ProdutosDao.colUltimaVenda.id], isNull);

    expect(await db.produtosDao.contarCompras(p), 2);
  });

  test('busca por reduzido ou descrição nas sugestões', () async {
    await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    await novoProduto(db, 12, 'CAFÉ TORRADO 500G');
    expect([for (final p in await db.produtosDao.sugestoes('3068')) p.reduzido], [3068]);
    expect([for (final p in await db.produtosDao.sugestoes('cafe')) p.reduzido], [12]);
  });

  test('atualizar e excluir', () async {
    final id = await novoProduto(db, 1, 'X', preco: 799);
    final p = (await db.produtosDao.porId(id))!;
    await db.produtosDao.atualizar(p.copyWith(precoPadraoCentavos: 849));
    expect((await db.produtosDao.porId(id))!.precoPadraoCentavos, 849);
    await db.produtosDao.excluir(id);
    expect(await db.produtosDao.porId(id), isNull);
  });
}
