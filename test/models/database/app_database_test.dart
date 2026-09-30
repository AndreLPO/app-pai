import 'package:app_pai/models/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = bancoDeTeste());
  tearDown(() => db.close());

  test('função unaccent remove acentos e passa para minúsculas', () async {
    final r = await db.customSelect("SELECT unaccent('SÃO') AS v").getSingle();
    expect(r.read<String>('v'), 'sao');
  });

  test('foreign keys ativas: excluir cliente com compra falha', () async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 1, 5));

    expect(() => db.clientesDao.excluir(c), throwsA(anything));
    expect(await db.clientesDao.porId(c), isNotNull);
  });

  test('quantidade precisa ser maior que zero', () async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    expect(
      () => novaCompra(db, cliente: c, produto: p, data: DateTime(2026), quantidade: 0),
      throwsA(anything),
    );
  });

  test('data é gravada como aaaammdd', () async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 3068, 'REFRIGERANTE 2L');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2025, 9, 11));
    final r = await db.customSelect('SELECT data FROM compras').getSingle();
    expect(r.read<int>('data'), 20250911);
  });
}
