import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/database/daos/compras_dao.dart';
import 'package:app_pai/models/table_query.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = bancoDeTeste());
  tearDown(() => db.close());

  test('ordenação padrão por data decrescente e total calculado', () async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 1, 5));
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 3, 5),
        quantidade: 93, valor: 7307);
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 2, 5));

    final pag = await db.comprasDao.buscarPagina(const TableQuery());
    expect([for (final l in pag.linhas) l.registro.compra.data.month], [3, 2, 1]);
    expect(pag.linhas.first.valores[ComprasDao.colTotal.id], 679551);
    expect(pag.linhas.first.valores[ComprasDao.colCliente.id], 'SOUSA');
    expect(pag.linhas.first.valores[ComprasDao.colData.id], DateTime(2026, 3, 5));
  });

  test('somas consideram todas as páginas e os filtros', () async {
    final c = await novoCliente(db, 'SOUSA');
    final leite = await novoProduto(db, 1, 'LEITE INTEGRAL 1L');
    final cafe = await novoProduto(db, 2, 'CAFE');
    await db.transaction(() async {
      for (var i = 0; i < 120; i++) {
        await novaCompra(db, cliente: c, produto: leite, data: DateTime(2026, 1, 1),
            quantidade: 2, valor: 350);
      }
    });
    await novaCompra(db, cliente: c, produto: cafe, data: DateTime(2026, 1, 1),
        quantidade: 7, valor: 1000);

    final pag = await db.comprasDao.buscarPagina(const TableQuery(
      filtros: [FiltroIgual('produto', {'LEITE INTEGRAL 1L'})],
    ));
    expect(pag.linhas, hasLength(50));
    expect(pag.total, 120);
    expect(pag.somas[ComprasDao.colQuantidade.id], 240);
    expect(pag.somas[ComprasDao.colTotal.id], 120 * 700);

    final ultima = await db.comprasDao.buscarPagina(const TableQuery(pagina: 2));
    expect(ultima.linhas, hasLength(21));
    expect(ultima.somas[ComprasDao.colQuantidade.id], 247);
  });

  test('somas zeradas sem resultados', () async {
    final pag = await db.comprasDao.buscarPagina(const TableQuery());
    expect(pag.total, 0);
    expect(pag.somas[ComprasDao.colTotal.id], 0);
  });

  test('CRUD, porId e duplicata', () async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 1, 'X');
    final id = await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 1, 1),
        quantidade: 3, sequencia: 3345336);
    final lida = (await db.comprasDao.porId(id))!;
    expect(lida.cliente.fantasia, 'SOUSA');
    expect(lida.produto.reduzido, 1);

    expect(
      await db.comprasDao.existeDuplicata(clienteId: c, produtoId: p,
          data: DateTime(2026, 1, 1), sequencia: 3345336, quantidade: 3),
      isTrue,
    );
    expect(
      await db.comprasDao.existeDuplicata(clienteId: c, produtoId: p,
          data: DateTime(2026, 1, 1), sequencia: null, quantidade: 3),
      isFalse,
    );

    await db.comprasDao.atualizar(lida.compra.copyWith(quantidade: 4));
    expect((await db.comprasDao.porId(id))!.compra.quantidade, 4);
    await db.comprasDao.excluir(id);
    expect(await db.comprasDao.porId(id), isNull);
  });
}
