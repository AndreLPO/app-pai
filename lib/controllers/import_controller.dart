import 'package:flutter/foundation.dart';

import '../models/services/planilha_export_service.dart';
import '../models/services/planilha_import_service.dart';

enum EtapaImportacao { inicio, analisando, resumo, gravando, concluida }

/// Arquivo escolhido pelo usuário.
typedef ArquivoEscolhido = ({String nome, List<int> bytes});

/// Fluxo de importação (escolher, analisar, revisar e confirmar) e de
/// exportação da planilha.
class ImportController extends ChangeNotifier {
  ImportController(
    this._importacao,
    this._exportacao, {
    required this.escolherArquivo,
    this.aoGravar,
    DateTime Function()? relogio,
  }) : _agora = relogio ?? DateTime.now;

  final PlanilhaImportService _importacao;
  final PlanilhaExportService _exportacao;
  final DateTime Function() _agora;

  /// Abre o seletor de arquivo (`null` = cancelado).
  final Future<ArquivoEscolhido?> Function() escolherArquivo;

  /// Chamado depois de gravar a importação.
  final VoidCallback? aoGravar;

  EtapaImportacao _etapa = EtapaImportacao.inicio;
  EtapaImportacao get etapa => _etapa;

  String? _nomeArquivo;
  String? get nomeArquivo => _nomeArquivo;

  PlanoImportacao? _plano;
  PlanoImportacao? get plano => _plano;

  String? _erro;
  String? get erro => _erro;

  bool _exportando = false;
  bool get exportando => _exportando;

  bool get ocupado =>
      _exportando ||
      _etapa == EtapaImportacao.analisando ||
      _etapa == EtapaImportacao.gravando;

  void _ir(EtapaImportacao etapa, {String? erro}) {
    _etapa = etapa;
    _erro = erro;
    notifyListeners();
  }

  Future<void> escolherEAnalisar() async {
    final arquivo = await escolherArquivo();
    if (arquivo == null) return;
    await analisar(arquivo);
  }

  Future<void> analisar(ArquivoEscolhido arquivo) async {
    _nomeArquivo = arquivo.nome;
    _plano = null;
    _ir(EtapaImportacao.analisando);
    try {
      final plano = await _importacao.analisar(arquivo.bytes);
      _plano = plano;
      _ir(EtapaImportacao.resumo, erro: plano.erro);
    } catch (e) {
      _ir(EtapaImportacao.inicio, erro: 'Não foi possível ler o arquivo: $e');
    }
  }

  /// Grava o plano revisado.
  Future<void> confirmar() async {
    final plano = _plano;
    if (plano == null || !plano.podeAplicar) return;
    _ir(EtapaImportacao.gravando);
    try {
      await _importacao.aplicar(plano);
      _ir(EtapaImportacao.concluida);
      aoGravar?.call();
    } catch (e) {
      _ir(EtapaImportacao.resumo, erro: 'A importação falhou e nada foi gravado: $e');
    }
  }

  /// Descarta o resumo sem gravar nada.
  void cancelar() {
    _plano = null;
    _nomeArquivo = null;
    _ir(EtapaImportacao.inicio);
  }

  /// Gera a planilha de exportação.
  Future<({String nome, Uint8List bytes})> exportar() async {
    _exportando = true;
    notifyListeners();
    try {
      final bytes = await _exportacao.gerar();
      return (nome: PlanilhaExportService.nomeArquivo(_agora()), bytes: Uint8List.fromList(bytes));
    } finally {
      _exportando = false;
      notifyListeners();
    }
  }
}
