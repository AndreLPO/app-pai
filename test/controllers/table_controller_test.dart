import 'package:app_pai/controllers/table_controller.dart';
import 'package:app_pai/models/table_query.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fonte em memória: registra as consultas recebidas.
class FonteFalsa implements FonteTabela<int> {
  FonteFalsa(this.total);

  int total;
  final consultas = <TableQuery>[];

  @override
  List<ColunaTabela> get colunas => const [
        ColunaTabela(id: 'nome', rotulo: 'Nome', tipo: TipoColuna.texto),
        ColunaTabela(id: 'valor', rotulo: 'Valor', tipo: TipoColuna.moeda),
      ];

  @override
  ({String coluna, bool crescente}) get ordenacaoPadrao =>
      (coluna: 'nome', crescente: true);

  @override
  Future<PaginaTabela<int>> buscarPagina(TableQuery query) async {
    consultas.add(query);
    final inicio = query.offset;
    final fim = (inicio + query.tamanhoPagina).clamp(0, total);
    return PaginaTabela(
      total: total,
      somas: {'valor': total * 10},
      linhas: [
        for (var i = inicio; i < fim; i++) LinhaTabela(i, {'nome': 'L$i', 'valor': 10}),
      ],
    );
  }

  @override
  Future<List<String>> valoresDistintos(String colunaId) async => ['A', 'B'];
}

void main() {
  late FonteFalsa fonte;
  late TableController<int> c;

  setUp(() {
    fonte = FonteFalsa(120);
    c = TableController(fonte, debounce: const Duration(milliseconds: 20));
  });
  tearDown(() => c.dispose());

  test('carrega a primeira página com total e somas', () async {
    expect(c.carregou, isFalse);
    await c.garantirCarregado();
    expect(c.carregou, isTrue);
    expect(c.linhas, hasLength(50));
    expect(c.total, 120);
    expect(c.totalPaginas, 3);
    expect(c.somas['valor'], 1200);
    await c.garantirCarregado();
    expect(fonte.consultas, hasLength(1));
  });

  test('ordenação: padrão, crescente no 1º toque e inverte no 2º', () async {
    await c.recarregar();
    expect(c.ordenacao, (coluna: 'nome', crescente: true));

    c.ordenarPor('valor');
    expect(c.ordenacao, (coluna: 'valor', crescente: true));
    c.ordenarPor('valor');
    expect(c.ordenacao, (coluna: 'valor', crescente: false));
    // Coluna padrão já ativa: o toque inverte.
    c.ordenarPor('nome');
    expect(c.ordenacao, (coluna: 'nome', crescente: true));
    c.ordenarPor('nome');
    expect(c.ordenacao, (coluna: 'nome', crescente: false));
  });

  test('busca com debounce: só a última digitação consulta', () async {
    await c.recarregar();
    c.buscar('a');
    c.buscar('ab');
    c.buscar('abc');
    expect(c.query.busca, '');
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(c.query.busca, 'abc');
    expect(fonte.consultas.map((q) => q.busca), ['', 'abc']);
  });

  test('paginação limitada ao intervalo e filtros voltam à página 0', () async {
    await c.recarregar();
    c.irParaPagina(2);
    await pumpEventQueue();
    expect(c.query.pagina, 2);
    expect(c.linhas, hasLength(20));

    c.irParaPagina(9);
    await pumpEventQueue();
    expect(c.query.pagina, 2);

    c.aplicarFiltro(const FiltroContem('nome', 'x'));
    await pumpEventQueue();
    expect(c.query.pagina, 0);
    expect(c.query.filtros, hasLength(1));

    c.removerFiltro('nome');
    await pumpEventQueue();
    expect(c.query.filtros, isEmpty);
  });

  test('limparFiltros remove busca, filtros e ordenação', () async {
    c.buscar('x');
    await Future<void>.delayed(const Duration(milliseconds: 40));
    c.aplicarFiltro(const FiltroContem('nome', 'x'));
    c.ordenarPor('valor');
    await pumpEventQueue();

    c.limparFiltros();
    await pumpEventQueue();
    expect(c.query.busca, '');
    expect(c.query.filtros, isEmpty);
    expect(c.ordenacao, fonte.ordenacaoPadrao);
    expect(c.query.pagina, 0);
  });

  test('volta à última página quando a atual fica vazia', () async {
    await c.recarregar();
    c.irParaPagina(2);
    await pumpEventQueue();
    fonte.total = 60;
    await c.recarregar();
    expect(c.query.pagina, 1);
    expect(c.linhas, hasLength(10));
  });

  test('notifica e expõe carregando', () async {
    final estados = <bool>[];
    c.addListener(() => estados.add(c.carregando));
    await c.recarregar();
    expect(estados, [true, false]);
  });
}
