import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/database/daos/consulta_dao.dart';
import 'package:app_pai/models/table_query.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = bancoDeTeste());
  tearDown(() => db.close());

  test('18 colunas na ordem da planilha', () {
    expect([for (final c in db.consultaDao.colunas) c.rotulo], [
      'Fantasia', 'DDD', 'Zap', 'Contato', 'Razão Social', 'CNPJ',
      'Insc. Estadual', 'Sequência', 'CEP', 'Rua', 'Bairro', 'Cidade',
      'Data', 'Reduzido', 'Qtde', 'Produto', 'Valor Unitário', 'Valor Total',
    ]);
  });

  test('filtra cidade + produto', () async {
    final campinas =
        await novoCliente(db, 'SOUSA', cidade: 'CAMPINAS', cnpj: '70193852000128');
    final limeira = await novoCliente(db, 'OUTRO', cidade: 'LIMEIRA');
    final cafe = await novoProduto(db, 1, 'CAFE TORRADO 500G');
    final leite = await novoProduto(db, 2, 'LEITE');
    final esperada = await novaCompra(db, cliente: campinas, produto: cafe,
        data: DateTime(2026, 2, 1), quantidade: 3, valor: 1500, sequencia: 10);
    await novaCompra(db, cliente: campinas, produto: leite, data: DateTime(2026, 2, 1));
    await novaCompra(db, cliente: limeira, produto: cafe, data: DateTime(2026, 2, 1));

    final pag = await db.consultaDao.buscarPagina(const TableQuery(filtros: [
      FiltroIgual('cidade', {'CAMPINAS'}),
      FiltroIgual('produto', {'CAFE TORRADO 500G'}),
    ]));
    expect(pag.total, 1);
    final l = pag.linhas.single;
    expect(l.registro, esperada);
    expect(l.valores[ConsultaDao.colFantasia.id], 'SOUSA');
    expect(l.valores[ConsultaDao.colCnpj.id], '70.193.852/0001-28');
    expect(l.valores[ConsultaDao.colTotal.id], 4500);
    expect(l.valores[ConsultaDao.colData.id], DateTime(2026, 2, 1));
    expect(pag.somas[ConsultaDao.colQtde.id], 3);
    expect(pag.somas[ConsultaDao.colTotal.id], 4500);

    expect(await db.consultaDao.valoresDistintos('cidade'), ['CAMPINAS', 'LIMEIRA']);
  });

  test('mostra os dados atuais do cliente e do produto', () async {
    final c = await novoCliente(db, 'SOUSA');
    final p = await novoProduto(db, 3068, 'REFRI');
    await novaCompra(db, cliente: c, produto: p, data: DateTime(2026, 1, 1));
    final produto = (await db.produtosDao.porId(p))!;
    await db.produtosDao.atualizar(produto.copyWith(descricao: 'REFRIGERANTE 2L'));
    final pag = await db.consultaDao.buscarPagina(const TableQuery());
    expect(pag.linhas.single.valores[ConsultaDao.colProduto.id], 'REFRIGERANTE 2L');
  });
}
