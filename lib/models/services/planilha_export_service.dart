import 'package:drift/drift.dart';
import 'package:excel/excel.dart';

import '../../core/cnpj.dart';
import '../../core/datas.dart';
import '../database/app_database.dart';
import 'planilha_layout.dart';

/// Exporta clientes e compras no layout de `DADOS.xlsx` (+ coluna TOTAL).
class PlanilhaExportService {
  PlanilhaExportService(this._db);

  final AppDatabase _db;

  /// `dados_aaaa-mm-dd.xlsx`
  static String nomeArquivo(DateTime dia) => 'dados_${formatarDataIso(dia)}.xlsx';

  Future<List<int>> gerar() async {
    final db = _db;
    final linhas = await (db.select(db.compras).join([
      innerJoin(db.clientes, db.clientes.id.equalsExp(db.compras.clienteId)),
      innerJoin(db.produtos, db.produtos.id.equalsExp(db.compras.produtoId)),
    ])
          ..orderBy([
            OrderingTerm.asc(db.clientes.fantasia),
            OrderingTerm.asc(db.clientes.id),
            OrderingTerm.asc(db.compras.data),
            OrderingTerm.asc(db.compras.id),
          ]))
        .get();

    final comCompra = <int>{};
    final excel = Excel.createExcel();
    final padrao = excel.getDefaultSheet()!;
    excel.rename(padrao, abaExportacao);
    final aba = excel[abaExportacao];

    final cabecalho = [
      for (final c in ColunaPlanilha.values) c.cabecalho,
      cabecalhoTotal,
    ];
    for (var i = 0; i < cabecalho.length; i++) {
      aba.updateCell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        TextCellValue(cabecalho[i]),
        cellStyle: CellStyle(bold: true),
      );
    }

    var linha = 1;
    void escrever(Cliente cliente, Compra? compra, Produto? produto) {
      final valores = <ColunaPlanilha, CellValue?>{
        ColunaPlanilha.fantasia: _txt(cliente.fantasia),
        ColunaPlanilha.ddd: _txt(cliente.ddd),
        ColunaPlanilha.zap: _txt(cliente.telefone),
        ColunaPlanilha.contato: _txt(cliente.contato),
        ColunaPlanilha.razaoSocial: _txt(cliente.razaoSocial),
        ColunaPlanilha.cnpj: _txt(cliente.cnpj == null ? null : Cnpj.formatar(cliente.cnpj!)),
        ColunaPlanilha.inscEstadual: _txt(cliente.inscEstadual),
        ColunaPlanilha.cep: _txt(cliente.cep),
        ColunaPlanilha.rua: _txt(cliente.rua),
        ColunaPlanilha.bairro: _txt(cliente.bairro),
        ColunaPlanilha.cidade: _txt(cliente.cidade),
        if (compra != null && produto != null) ...{
          ColunaPlanilha.sequencia:
              compra.sequencia == null ? null : IntCellValue(compra.sequencia!),
          ColunaPlanilha.data: DateCellValue(
              year: compra.data.year, month: compra.data.month, day: compra.data.day),
          ColunaPlanilha.red: IntCellValue(produto.reduzido),
          ColunaPlanilha.qtde: IntCellValue(compra.quantidade),
          ColunaPlanilha.produto: _txt(produto.descricao),
          ColunaPlanilha.valor: DoubleCellValue(compra.valorUnitarioCentavos / 100),
        },
      };
      for (final e in valores.entries) {
        final v = e.value;
        if (v == null) continue;
        aba.updateCell(
          CellIndex.indexByColumnRow(columnIndex: e.key.index, rowIndex: linha),
          v,
          cellStyle: v is DateCellValue
              ? CellStyle(numberFormat: NumFormat.defaultDate)
              : null,
        );
      }
      if (compra != null) {
        aba.updateCell(
          CellIndex.indexByColumnRow(
              columnIndex: ColunaPlanilha.values.length, rowIndex: linha),
          DoubleCellValue(compra.quantidade * compra.valorUnitarioCentavos / 100),
        );
      }
      linha++;
    }

    for (final r in linhas) {
      final cliente = r.readTable(db.clientes);
      comCompra.add(cliente.id);
      escrever(cliente, r.readTable(db.compras), r.readTable(db.produtos));
    }

    // Clientes sem compras: uma linha só com os dados do cliente.
    final semCompra = await (db.select(db.clientes)
          ..where((c) => c.id.isNotIn(comCompra))
          ..orderBy([(c) => OrderingTerm.asc(c.fantasia), (c) => OrderingTerm.asc(c.id)]))
        .get();
    for (final c in semCompra) {
      escrever(c, null, null);
    }

    return excel.encode()!;
  }

  static CellValue? _txt(String? v) => v == null ? null : TextCellValue(v);
}
