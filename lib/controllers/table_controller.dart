import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/table_query.dart';

/// Estado de uma tela de tabela: consulta (busca, filtros, ordenação e
/// página) e o resultado da página atual. Vive durante a sessão para que a
/// tela mantenha os filtros ao voltar de um formulário.
class TableController<T> extends ChangeNotifier {
  TableController(
    this.fonte, {
    this.debounce = const Duration(milliseconds: 300),
    int tamanhoPagina = 50,
  }) : _query = TableQuery(tamanhoPagina: tamanhoPagina);

  final FonteTabela<T> fonte;
  final Duration debounce;

  TableQuery _query;
  TableQuery get query => _query;

  bool _carregando = false;
  bool get carregando => _carregando;

  bool _carregou = false;

  /// Verdadeiro depois do primeiro carregamento concluído.
  bool get carregou => _carregou;

  Object? _erro;
  Object? get erro => _erro;

  PaginaTabela<T> _pagina = PaginaTabela<T>(linhas: const [], total: 0);
  List<LinhaTabela<T>> get linhas => _pagina.linhas;
  int get total => _pagina.total;
  Map<String, int> get somas => _pagina.somas;

  int get totalPaginas =>
      total == 0 ? 1 : (total + _query.tamanhoPagina - 1) ~/ _query.tamanhoPagina;

  List<ColunaTabela> get colunas => fonte.colunas;

  ColunaTabela? coluna(String id) {
    for (final c in colunas) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Coluna e direção efetivas (a escolhida ou a padrão da tabela).
  ({String coluna, bool crescente}) get ordenacao => _query.ordenarPor == null
      ? fonte.ordenacaoPadrao
      : (coluna: _query.ordenarPor!, crescente: _query.crescente);

  String _buscaDigitada = '';

  /// Texto do campo de busca, inclusive o que ainda aguarda o debounce.
  String get buscaDigitada => _buscaDigitada;

  Timer? _timer;
  int _geracao = 0;
  bool _descartado = false;

  /// Carrega na primeira vez; depois disso não faz nada.
  Future<void> garantirCarregado() async {
    if (!_carregou && !_carregando) await recarregar();
  }

  Future<void> recarregar() async {
    final geracao = ++_geracao;
    _carregando = true;
    _notificar();
    try {
      final pagina = await fonte.buscarPagina(_query);
      if (geracao != _geracao || _descartado) return;
      // Se a página ficou além do fim (ex.: após excluir), volta à última.
      if (pagina.linhas.isEmpty && _query.pagina > 0 && pagina.total > 0) {
        _query = _query.copyWith(
            pagina: (pagina.total - 1) ~/ _query.tamanhoPagina);
        await recarregar();
        return;
      }
      _pagina = pagina;
      _erro = null;
    } catch (e) {
      if (geracao != _geracao || _descartado) return;
      _erro = e;
    }
    _carregando = false;
    _carregou = true;
    _notificar();
  }

  /// Aplica a nova consulta. Com [manterBusca], o texto ainda em debounce
  /// entra junto, para não se perder.
  void _alterar(TableQuery nova, {bool manterBusca = true}) {
    _timer?.cancel();
    if (manterBusca && nova.busca != _buscaDigitada) {
      nova = nova.copyWith(busca: _buscaDigitada, pagina: 0);
    }
    _query = nova;
    _buscaDigitada = nova.busca;
    recarregar();
  }

  /// Troca a consulta inteira de uma vez (ex.: atalho da Home).
  void substituirQuery(TableQuery nova) => _alterar(nova, manterBusca: false);

  /// Busca geral, aplicada após [debounce] sem digitação.
  void buscar(String texto) {
    _buscaDigitada = texto;
    _timer?.cancel();
    _timer = Timer(debounce, () {
      if (texto == _query.busca) return;
      _alterar(_query.copyWith(busca: texto, pagina: 0));
    });
  }

  /// Primeiro toque ordena crescente; tocar de novo inverte.
  void ordenarPor(String colunaId) {
    final atual = ordenacao;
    final crescente = atual.coluna == colunaId ? !atual.crescente : true;
    _alterar(_query.copyWith(ordenarPor: colunaId, crescente: crescente, pagina: 0));
  }

  void aplicarFiltro(Filtro filtro) => _alterar(_query.comFiltro(filtro));

  void removerFiltro(String colunaId) => _alterar(_query.semFiltro(colunaId));

  /// Remove busca e filtros e volta à ordenação padrão.
  void limparFiltros() => _alterar(TableQuery(tamanhoPagina: _query.tamanhoPagina),
      manterBusca: false);

  bool get temFiltros =>
      _buscaDigitada.isNotEmpty || _query.filtros.isNotEmpty || _query.ordenarPor != null;

  void irParaPagina(int pagina) {
    final p = pagina.clamp(0, totalPaginas - 1);
    if (p == _query.pagina) return;
    _alterar(_query.copyWith(pagina: p));
  }

  Future<List<String>> valoresDistintos(String colunaId) =>
      fonte.valoresDistintos(colunaId);

  void _notificar() {
    if (!_descartado) notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    _timer?.cancel();
    super.dispose();
  }
}
