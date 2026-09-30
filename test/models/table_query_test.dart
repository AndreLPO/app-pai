import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/table_query.dart';
import 'package:flutter_test/flutter_test.dart';

import 'database/helpers.dart';

void main() {
  group('TableQuery', () {
    test('comFiltro substitui o filtro da mesma coluna e volta à página 0', () {
      const q = TableQuery(pagina: 3, filtros: [FiltroContem('cidade', 'A')]);
      final r = q.comFiltro(const FiltroContem('cidade', 'B'));
      expect(r.pagina, 0);
      expect(r.filtros, hasLength(1));
      expect((r.filtros.single as FiltroContem).texto, 'B');
    });

    test('semFiltro remove só o filtro da coluna', () {
      const q = TableQuery(filtros: [
        FiltroContem('cidade', 'A'),
        FiltroIntervalo('preco', minimo: 1),
      ]);
      final r = q.semFiltro('cidade');
      expect(r.filtros.map((f) => f.colunaId), ['preco']);
    });

    test('offset considera página e tamanho', () {
      expect(const TableQuery(pagina: 2, tamanhoPagina: 50).offset, 100);
    });

    test('descrição dos chips', () {
      expect(
        const FiltroIntervalo('p', minimo: 500, maximo: 1000, moeda: true)
            .descrever('Preço'),
        r'Preço entre R$ 5,00 e R$ 10,00',
      );
      expect(
        FiltroPeriodo('d', de: DateTime(2026, 1, 1), ate: DateTime(2026, 3, 31))
            .descrever('Data'),
        'Data de 01/01/2026 a 31/03/2026',
      );
    });
  });

  group('WHERE montado a partir das colunas', () {
    late AppDatabase db;

    setUp(() async {
      db = bancoDeTeste();
      await novoCliente(db, 'MERCADO SÃO LUIZ', cidade: 'LIMEIRA');
      await novoCliente(db, 'SAO LUIZ FILIAL', cidade: 'CAMPINAS');
      await novoCliente(db, 'SOUSA', razao: 'SOUSA E SÃO LTDA', cidade: 'LIMEIRA');
      await novoCliente(db, 'BOM PREÇO', cidade: 'LIMEIRA');
    });
    tearDown(() => db.close());

    Future<List<String>> fantasias(TableQuery q) async => [
          for (final l in (await db.clientesDao.buscarPagina(q)).linhas)
            l.registro.fantasia,
        ];

    test('busca geral sem acento em qualquer coluna de texto', () async {
      expect(await fantasias(const TableQuery(busca: 'sao luiz')),
          ['MERCADO SÃO LUIZ', 'SAO LUIZ FILIAL']);
      // Encontra pela razão social.
      expect(await fantasias(const TableQuery(busca: 'e sao')), ['SOUSA']);
    });

    test('busca E filtros combinados', () async {
      const q = TableQuery(
        busca: 'são',
        filtros: [FiltroIgual('cidade', {'LIMEIRA'})],
      );
      expect(await fantasias(q), ['MERCADO SÃO LUIZ', 'SOUSA']);

      final q2 = q.comFiltro(const FiltroContem('fantasia', 'mercado'));
      expect(await fantasias(q2), ['MERCADO SÃO LUIZ']);
    });

    test('caracteres de LIKE são tratados como texto', () async {
      expect(await fantasias(const TableQuery(busca: '%')), isEmpty);
      expect(await fantasias(const TableQuery(busca: '_')), isEmpty);
    });

    test('colunas desconhecidas são ignoradas', () async {
      const q = TableQuery(filtros: [FiltroContem('naoExiste', 'x')]);
      expect(await fantasias(q), hasLength(4));
    });
  });
}
