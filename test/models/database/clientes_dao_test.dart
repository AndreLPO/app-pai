import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/database/daos/clientes_dao.dart';
import 'package:app_pai/models/table_query.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  final hoje = DateTime(2026, 6, 30);

  setUp(() => db = bancoDeTeste(relogio: () => hoje));
  tearDown(() => db.close());

  Future<List<String>> nomes(TableQuery q) async => [
        for (final l in (await db.clientesDao.buscarPagina(q)).linhas)
          l.registro.fantasia,
      ];

  test('CNPJ duplicado é recusado e encontrado pelo DAO', () async {
    final id = await novoCliente(db, 'A', cnpj: '70193852000128');
    expect(() => novoCliente(db, 'B', cnpj: '70193852000128'), throwsA(anything));
    expect((await db.clientesDao.porCnpj('70.193.852/0001-28'))!.id, id);
    expect(await db.clientesDao.porCnpj('70193852000128', excetoId: id), isNull);
  });

  test('clientes sem CNPJ não conflitam entre si', () async {
    await novoCliente(db, 'A');
    await novoCliente(db, 'B');
    expect((await db.clientesDao.buscarPagina(const TableQuery())).total, 2);
  });

  test('busca sem acento', () async {
    await novoCliente(db, 'MERCADO SÃO LUIZ');
    await novoCliente(db, 'OUTRO');
    expect(await nomes(const TableQuery(busca: 'sao luiz')), ['MERCADO SÃO LUIZ']);
  });

  test('busca por CNPJ, exibido com máscara', () async {
    await novoCliente(db, 'A', cnpj: '70193852000128');
    await novoCliente(db, 'B');
    final p = await db.clientesDao.buscarPagina(const TableQuery(busca: '70193852'));
    expect([for (final l in p.linhas) l.registro.fantasia], ['A']);
    expect(p.linhas.single.valores[ClientesDao.colCnpj.id], '70.193.852/0001-28');
  });

  test('ordenação padrão por fantasia; sem compras por último no decrescente', () async {
    final p = await novoProduto(db, 1, 'X');
    final b = await novoCliente(db, 'BETA');
    final a = await novoCliente(db, 'ALFA');
    await novoCliente(db, 'GAMA');
    await novaCompra(db, cliente: a, produto: p, data: DateTime(2026, 1, 1));
    await novaCompra(db, cliente: b, produto: p, data: DateTime(2026, 5, 1));

    expect(await nomes(const TableQuery()), ['ALFA', 'BETA', 'GAMA']);
    expect(await nomes(const TableQuery(ordenarPor: 'ultimaCompra', crescente: false)),
        ['BETA', 'ALFA', 'GAMA']);
    final pag = await db.clientesDao.buscarPagina(const TableQuery());
    expect(pag.linhas.last.valores[ClientesDao.colUltimaCompra.id], isNull);
    expect(pag.linhas.first.valores[ClientesDao.colUltimaCompra.id], DateTime(2026, 1, 1));
  });

  test('filtro de inativos (sem compra há mais de 60 dias)', () async {
    final p = await novoProduto(db, 1, 'X');
    final recente = await novoCliente(db, 'RECENTE');
    final antigo = await novoCliente(db, 'ANTIGO');
    await novoCliente(db, 'NUNCA');
    // Limite: 30/06/2026 - 60 dias = 01/05/2026.
    await novaCompra(db, cliente: recente, produto: p, data: DateTime(2026, 5, 1));
    await novaCompra(db, cliente: antigo, produto: p, data: DateTime(2026, 4, 30));

    expect(await nomes(const TableQuery(filtros: [ClientesDao.filtroInativos])),
        ['ANTIGO', 'NUNCA']);
    expect(await db.clientesDao.contarInativos(), 2);
  });

  test('contagem de compras vinculadas e histórico', () async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 1, 'X');
    for (var i = 1; i <= 3; i++) {
      await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, i, 1));
    }
    expect(await db.clientesDao.contarCompras(c), 3);
    final h = await db.clientesDao.historico(c);
    expect([for (final e in h) e.compra.data.month], [3, 2, 1]);
  });

  test('valores distintos de cidade', () async {
    await novoCliente(db, 'A', cidade: 'LIMEIRA');
    await novoCliente(db, 'B', cidade: 'CAMPINAS');
    await novoCliente(db, 'C', cidade: 'LIMEIRA');
    await novoCliente(db, 'D');
    expect(await db.clientesDao.valoresDistintos('cidade'), ['CAMPINAS', 'LIMEIRA']);
  });
}
