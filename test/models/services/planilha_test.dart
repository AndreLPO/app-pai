import 'dart:io';

import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/services/planilha_export_service.dart';
import 'package:app_pai/models/services/planilha_import_service.dart';
import 'package:app_pai/models/services/planilha_layout.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../database/helpers.dart';

const cabecalhos = [
  'FANTASIA', 'DDD', 'ZAP', 'CONTATO', 'RAZÃO SOCIAL', 'CNPJ', 'INSC. ESTADUAL',
  'SEQUÊNC', 'CEP', 'RUA', 'BAIRRO', 'CID ', 'DATA', 'RED', 'QTDE', 'PRODUTO', 'VALOR',
];

/// Monta um `.xlsx` com o cabeçalho e as linhas dadas (mapa cabeçalho -> valor).
List<int> planilha(List<Map<String, Object?>> linhas, {List<String> colunas = cabecalhos}) {
  final excel = Excel.createExcel();
  final aba = excel[excel.getDefaultSheet()!];
  aba.appendRow([for (final c in colunas) TextCellValue(c)]);
  for (final l in linhas) {
    aba.appendRow([
      for (final c in colunas)
        switch (l[c.trim()]) {
          null => null,
          final int v => IntCellValue(v),
          final double v => DoubleCellValue(v),
          final Object v => TextCellValue('$v'),
        },
    ]);
  }
  return excel.encode()!;
}

Map<String, Object?> linha({
  String? fantasia = 'SOUSA',
  String? cnpj,
  Object? red = 3068,
  Object? qtde = 10,
  Object? data = 45911,
  Object? valor = 7.99,
  String? produto = 'REFRIGERANTE 2L',
  Object? seq,
  String? ddd,
  String? zap,
  String? razao,
}) =>
    {
      'FANTASIA': fantasia,
      'CNPJ': cnpj,
      'RED': red,
      'QTDE': qtde,
      'DATA': data,
      'VALOR': valor,
      'PRODUTO': produto,
      'SEQUÊNC': seq,
      'DDD': ddd,
      'ZAP': zap,
      'RAZÃO SOCIAL': razao,
    };

void main() {
  late AppDatabase db;
  late PlanilhaImportService importacao;

  setUp(() {
    db = bancoDeTeste(relogio: () => DateTime(2026, 9, 29));
    importacao = PlanilhaImportService(db);
  });
  tearDown(() => db.close());

  Future<({int clientes, int produtos, int compras})> contagem() async => (
        clientes: (await db.select(db.clientes).get()).length,
        produtos: (await db.select(db.produtos).get()).length,
        compras: (await db.select(db.compras).get()).length,
      );

  group('leitura', () {
    test('fixture DADOS.xlsx: colunas pelo cabeçalho, data serial e VALOR', () {
      final bytes = File('test/fixtures/DADOS.xlsx').readAsBytesSync();
      final l = lerPlanilha(bytes);
      expect(l.erro, isNull);
      // 97 linhas de dados, todas válidas; as linhas vazias do fim são
      // ignoradas.
      expect(l.linhas, hasLength(97));
      expect(l.rejeitadas, isEmpty);
      final primeira = l.linhas.first;
      expect(primeira.linha, 2);
      expect(primeira.cliente.fantasia, 'SOUSA');
      expect(primeira.cliente.cnpj, '70193852000128');
      expect(primeira.cliente.cidade, 'LIMEIRA'); // cabeçalho "CID "
      expect(primeira.cliente.telefone, '9 6034-5419');
      expect(primeira.compra!.data, DateTime(2025, 9, 11)); // 45911
      expect(primeira.compra!.valorCentavos, 7307); // 73.06999999999999
      expect(primeira.compra!.reduzido, 3068);
      expect(primeira.compra!.quantidade, 93);
      expect(primeira.compra!.sequencia, 3345336);
    });

    test('coluna PRODUTO ausente recusa a importação', () {
      final bytes = planilha(
        [linha()],
        colunas: [for (final c in cabecalhos) if (c != 'PRODUTO') c],
      );
      final l = lerPlanilha(bytes);
      expect(l.erro, contains('PRODUTO'));
      expect(l.colunasAusentes, ['PRODUTO']);
      expect(l.linhas, isEmpty);
    });

    test('coluna TOTAL extra é ignorada e cabeçalhos sem acento são aceitos', () {
      final colunas = [
        for (final c in cabecalhos) c == 'RAZÃO SOCIAL' ? ' razao social ' : c,
        'TOTAL',
      ];
      final dados = {...linha(), 'razao social': 'X', 'TOTAL': 'LIXO'};
      final l = lerPlanilha(planilha([dados], colunas: colunas));
      expect(l.erro, isNull);
      expect(l.rejeitadas, isEmpty);
      expect(l.linhas.single.cliente.razaoSocial, 'X');
    });

    test('linhas deslocadas ou incompletas são rejeitadas com motivo', () {
      final l = lerPlanilha(planilha([
        linha(), // linha 2 ok
        linha(red: null), // 3
        linha(fantasia: null), // 4
        linha(qtde: 'MUITO', data: 'ONTEM'), // 5: valores deslocados
        linha(produto: null, valor: 'R\$ 7,99'), // 6
        linha(red: 'REFRIGERANTE', qtde: 0), // 7
      ]));
      expect(l.linhas.map((e) => e.linha), [2]);
      expect([for (final r in l.rejeitadas) '$r'], [
        'Linha 3: RED ausente',
        'Linha 4: FANTASIA ausente',
        'Linha 5: QTDE inválida, DATA inválida',
        'Linha 6: PRODUTO ausente',
        'Linha 7: RED inválido, QTDE inválida',
      ]);
    });

    test('data em texto dd/mm/aaaa e VALOR em texto', () {
      final l = lerPlanilha(planilha([linha(data: '01/03/2026', valor: '7,50')]));
      expect(l.linhas.single.compra!.data, DateTime(2026, 3, 1));
      expect(l.linhas.single.compra!.valorCentavos, 750);
    });

    test('regra DDD/ZAP', () {
      final l = lerPlanilha(planilha([
        linha(ddd: '19996860960'),
        linha(ddd: '19', zap: '9 9686-0960'),
      ]));
      expect(l.linhas[0].cliente.ddd, isNull);
      expect(l.linhas[0].cliente.telefone, '19996860960');
      expect(l.linhas[1].cliente.ddd, '19');
      expect(l.linhas[1].cliente.telefone, '9 9686-0960');
    });

    test('linha só de cliente não gera compra', () {
      final l = lerPlanilha(planilha([
        linha(cnpj: '70.193.852/0001-28', red: null, qtde: null, valor: null,
            produto: null, data: null),
      ]));
      expect(l.rejeitadas, isEmpty);
      expect(l.linhas.single.compra, isNull);
    });

    test('CNPJ com dígito inválido gera aviso sem rejeitar', () {
      final l = lerPlanilha(planilha([linha(cnpj: '70.193.852/0001-29')]));
      expect(l.rejeitadas, isEmpty);
      expect(l.linhas.single.cliente.cnpj, '70193852000129');
      expect('${l.avisos.single}', startsWith('Linha 2: CNPJ inválido'));
    });

    test('arquivo que não é xlsx', () {
      expect(lerPlanilha([1, 2, 3]).erro, isNotNull);
    });
  });

  group('aplicação', () {
    test('importar o mesmo arquivo duas vezes não cria registros na segunda', () async {
      final bytes = File('test/fixtures/DADOS.xlsx').readAsBytesSync();
      final plano = await importacao.analisar(bytes);
      expect(plano.podeAplicar, isTrue);
      await importacao.aplicar(plano);
      final antes = await contagem();
      expect(antes.compras, plano.comprasNovas);
      expect(antes.clientes, plano.clientesNovos);
      expect(antes.produtos, plano.produtosNovos);

      final segundo = await importacao.analisar(bytes);
      expect(segundo.clientesNovos, 0);
      expect(segundo.produtosNovos, 0);
      expect(segundo.comprasNovas, 0);
      expect(segundo.comprasDuplicadas, antes.compras);
      await importacao.aplicar(segundo);
      expect(await contagem(), antes);
    });

    test('produto novo recebe o preço da linha mais recente', () async {
      final plano = await importacao.analisar(planilha([
        linha(data: '01/03/2026', valor: 7.99, qtde: 1),
        linha(data: '01/02/2026', valor: 7.50, qtde: 2),
      ]));
      await importacao.aplicar(plano);
      final p = (await db.produtosDao.porReduzido(3068))!;
      expect(p.precoPadraoCentavos, 799);
      expect((await contagem()).compras, 2);
    });

    test('produto existente: descrição atualizada e preço mantido', () async {
      await novoProduto(db, 3068, 'REFRI', preco: 500);
      final plano = await importacao.analisar(planilha([linha(valor: 9.99)]));
      expect(plano.produtosNovos, 0);
      expect(plano.produtosAtualizados, 1);
      await importacao.aplicar(plano);
      final p = (await db.produtosDao.porReduzido(3068))!;
      expect(p.descricao, 'REFRIGERANTE 2L');
      expect(p.precoPadraoCentavos, 500);
    });

    test('cliente identificado por CNPJ ou por Fantasia + Razão', () async {
      await novoCliente(db, 'NOME ANTIGO', cnpj: '70193852000128');
      await novoCliente(db, 'DA PAZ', razao: 'PAZ LTDA');
      final plano = await importacao.analisar(planilha([
        linha(fantasia: 'SOUSA', cnpj: '70.193.852/0001-28'),
        linha(fantasia: 'DA PAZ', razao: 'PAZ LTDA'),
        linha(fantasia: 'DA PAZ', razao: 'OUTRA'),
      ]));
      expect(plano.clientesNovos, 1);
      expect(plano.clientesAtualizados, 1);
      await importacao.aplicar(plano);
      final clientes = await db.select(db.clientes).get();
      expect(clientes, hasLength(3));
      expect((await db.clientesDao.porCnpj('70193852000128'))!.fantasia, 'SOUSA');
    });

    test('linha só de cliente cria o cliente sem compra', () async {
      final plano = await importacao.analisar(planilha([
        linha(red: null, qtde: null, valor: null, produto: null, data: null),
      ]));
      await importacao.aplicar(plano);
      expect(await contagem(), (clientes: 1, produtos: 0, compras: 0));
    });

    test('falha no meio da gravação não grava nada', () async {
      final plano = await importacao.analisar(planilha([linha()]));
      // Quantidade 0 viola o CHECK do banco na última compra.
      final quebrado = PlanoImportacao(
        leitura: LeituraPlanilha(linhas: [
          ...plano.leitura.linhas,
          LinhaImportada(
            3,
            const ClienteImportado(fantasia: 'X'),
            CompraImportada(
                reduzido: 1, descricao: 'Y', data: DateTime(2026), quantidade: 0,
                valorCentavos: 1),
          ),
        ]),
      );
      await expectLater(importacao.aplicar(quebrado), throwsA(anything));
      expect(await contagem(), (clientes: 0, produtos: 0, compras: 0));
    });
  });

  group('exportação', () {
    test('layout, datas e clientes sem compras', () async {
      final c = await novoCliente(db, 'SOUSA', cnpj: '70193852000128', cidade: 'LIMEIRA');
      await novoCliente(db, 'SEM COMPRA');
      final p = await novoProduto(db, 3068, 'REFRIGERANTE 2L');
      await novaCompra(db, cliente: c, produto: p, data: DateTime(2025, 9, 11),
          quantidade: 93, valor: 7307, sequencia: 3345336);

      final bytes = await PlanilhaExportService(db).gerar();
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.keys, [abaExportacao]);
      final rows = excel.tables[abaExportacao]!.rows;
      expect([for (final c in rows[0]) '${c?.value}'], [
        for (final c in ColunaPlanilha.values) c.cabecalho,
        'TOTAL',
      ]);
      expect(rows, hasLength(3));
      final compra = rows[1];
      expect('${compra[ColunaPlanilha.cnpj.index]?.value}', '70.193.852/0001-28');
      expect(compra[ColunaPlanilha.data.index]?.value,
          const DateCellValue(year: 2025, month: 9, day: 11));
      expect((compra[17]?.value as DoubleCellValue).value, closeTo(6795.51, 0.001));
      final semCompra = rows[2];
      expect('${semCompra[0]?.value}', 'SEM COMPRA');
      expect(semCompra[ColunaPlanilha.red.index]?.value, isNull);
    });

    test('exportar e reimportar não cria duplicatas', () async {
      final fixture = File('test/fixtures/DADOS.xlsx').readAsBytesSync();
      await importacao.aplicar(await importacao.analisar(fixture));
      await novoCliente(db, 'SEM COMPRA');
      final antes = await contagem();

      final exportado = await PlanilhaExportService(db).gerar();
      final plano = await importacao.analisar(exportado);
      expect(plano.rejeitadas, isEmpty);
      expect(plano.clientesNovos, 0);
      expect(plano.produtosNovos, 0);
      expect(plano.comprasNovas, 0);
      await importacao.aplicar(plano);
      expect(await contagem(), antes);
    });

    test('nome do arquivo', () {
      expect(PlanilhaExportService.nomeArquivo(DateTime(2026, 9, 5)), 'dados_2026-09-05.xlsx');
    });
  });
}
