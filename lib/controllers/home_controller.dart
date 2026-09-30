import 'package:flutter/foundation.dart';

import '../models/database/daos/analitico_dao.dart';

/// Dados da Home para o período selecionado.
class DadosHome {
  const DadosHome({
    required this.indicadores,
    required this.topProdutos,
    required this.topClientes,
    required this.meses,
    required this.clientesInativos,
  });

  final Indicadores indicadores;
  final List<ItemRanking> topProdutos;
  final List<ItemRanking> topClientes;
  final List<ValorMes> meses;
  final int clientesInativos;

  bool get semDados => indicadores.registros == 0;
}

class HomeController extends ChangeNotifier {
  HomeController(this._dao);

  final AnaliticoDao _dao;

  PeriodoHome _periodo = PeriodoHome.mesAtual;
  PeriodoHome get periodo => _periodo;

  DadosHome? _dados;
  DadosHome? get dados => _dados;

  bool _carregando = false;
  bool get carregando => _carregando;

  Object? _erro;
  Object? get erro => _erro;

  int _geracao = 0;
  bool _descartado = false;

  void selecionarPeriodo(PeriodoHome periodo) {
    if (periodo == _periodo) return;
    _periodo = periodo;
    carregar();
  }

  Future<void> carregar() async {
    final geracao = ++_geracao;
    final periodo = _periodo;
    _carregando = true;
    _notificar();
    try {
      final dados = DadosHome(
        indicadores: await _dao.indicadores(periodo),
        topProdutos: await _dao.topProdutos(periodo),
        topClientes: await _dao.topClientes(periodo),
        meses: await _dao.ultimos12Meses(),
        clientesInativos: await _dao.clientesInativos(),
      );
      if (geracao != _geracao) return;
      _dados = dados;
      _erro = null;
    } catch (e) {
      if (geracao != _geracao) return;
      _erro = e;
    }
    _carregando = false;
    _notificar();
  }

  void _notificar() {
    if (!_descartado) notifyListeners();
  }

  @override
  void dispose() {
    _descartado = true;
    super.dispose();
  }
}
