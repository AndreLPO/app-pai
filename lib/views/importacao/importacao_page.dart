import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../app_scope.dart';
import '../../controllers/import_controller.dart';
import '../../core/money.dart';
import '../../models/services/planilha_import_service.dart';
import '../widgets/dialogos.dart';

/// Seletor de `.xlsx` padrão do app.
Future<ArquivoEscolhido?> escolherPlanilha() async {
  final arquivo = await FilePicker.pickFile(
    dialogTitle: 'Escolher planilha',
    type: FileType.custom,
    allowedExtensions: const ['xlsx'],
  );
  if (arquivo == null) return null;
  return (nome: arquivo.name, bytes: await arquivo.xFile.readAsBytes());
}

class ImportacaoPage extends StatefulWidget {
  const ImportacaoPage({super.key, this.escolherArquivo = escolherPlanilha});

  final Future<ArquivoEscolhido?> Function() escolherArquivo;

  @override
  State<ImportacaoPage> createState() => _ImportacaoPageState();
}

class _ImportacaoPageState extends State<ImportacaoPage> {
  late final ImportController _c;

  @override
  void initState() {
    super.initState();
    final scope = AppScope.read(context);
    _c = ImportController(
      scope.importacao,
      scope.exportacao,
      escolherArquivo: widget.escolherArquivo,
      aoGravar: scope.dadosAlterados,
      relogio: scope.db.relogio,
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _exportar() async {
    final ({String nome, Uint8List bytes}) arquivo;
    try {
      arquivo = await _c.exportar();
    } catch (e) {
      if (mounted) mostrarMensagem(context, 'Falha ao exportar: $e');
      return;
    }
    if (!mounted) return;
    final acao = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportação pronta'),
        content: Text('Arquivo: ${arquivo.nome}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
          OutlinedButton.icon(
            icon: const Icon(Icons.save_alt),
            label: const Text('Salvar'),
            onPressed: () => Navigator.pop(context, 'salvar'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Compartilhar'),
            onPressed: () => Navigator.pop(context, 'compartilhar'),
          ),
        ],
      ),
    );
    if (!mounted || acao == null) return;
    const mime = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    try {
      if (acao == 'salvar') {
        final uri = await FilePicker.saveFile(
          fileName: arquivo.nome,
          bytes: arquivo.bytes,
          mimeType: mime,
          type: FileType.custom,
          allowedExtensions: const ['xlsx'],
        );
        if (uri != null && mounted) mostrarMensagem(context, 'Arquivo salvo');
      } else {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}${Platform.pathSeparator}${arquivo.nome}');
        await file.writeAsBytes(arquivo.bytes, flush: true);
        await SharePlus.instance.share(ShareParams(
          files: [XFile(file.path, mimeType: mime, name: arquivo.nome)],
          subject: arquivo.nome,
        ));
      }
    } catch (e) {
      if (mounted) mostrarMensagem(context, 'Falha: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Importar / Exportar')),
        body: ListenableBuilder(
          listenable: _c,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Importar planilha', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text(
                        'Arquivo .xlsx no layout de DADOS.xlsx (FANTASIA, DDD, ZAP, ..., '
                        'PRODUTO, VALOR). Os dados são mesclados com os existentes, sem '
                        'duplicar. Nada é gravado antes da sua confirmação.',
                      ),
                      const SizedBox(height: 16),
                      _conteudoImportacao(context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exportar dados', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      const Text(
                        'Gera um .xlsx com todos os clientes e compras, no mesmo layout da '
                        'importação. Use também como backup (ex.: envie para você por '
                        'WhatsApp ou e-mail).',
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: _c.exportando
                            ? const SizedBox.square(
                                dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.file_download_outlined),
                        label: const Text('Exportar'),
                        onPressed: _c.ocupado ? null : _exportar,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _conteudoImportacao(BuildContext context) {
    final erro = _c.erro;
    final corErro = Theme.of(context).colorScheme.error;
    final botaoEscolher = FilledButton.icon(
      icon: const Icon(Icons.upload_file),
      label: const Text('Escolher arquivo'),
      onPressed: _c.ocupado ? null : _c.escolherEAnalisar,
    );
    switch (_c.etapa) {
      case EtapaImportacao.inicio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (erro != null) Text(erro, style: TextStyle(color: corErro)),
            botaoEscolher,
          ],
        );
      case EtapaImportacao.analisando:
        return const Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Lendo e validando o arquivo...'),
        ]);
      case EtapaImportacao.gravando:
        return const Row(children: [
          CircularProgressIndicator(),
          SizedBox(width: 16),
          Text('Gravando...'),
        ]);
      case EtapaImportacao.concluida:
        final p = _c.plano!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Importação concluída: ${p.comprasNovas} compras, '
              '${p.clientesNovos} clientes e ${p.produtosNovos} produtos novos.',
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _c.cancelar, child: const Text('Importar outro arquivo')),
          ],
        );
      case EtapaImportacao.resumo:
        final p = _c.plano!;
        return _Resumo(
          nomeArquivo: _c.nomeArquivo ?? '',
          plano: p,
          erro: erro,
          aoConfirmar: _c.confirmar,
          aoCancelar: _c.cancelar,
        );
    }
  }
}

class _Resumo extends StatelessWidget {
  const _Resumo({
    required this.nomeArquivo,
    required this.plano,
    required this.erro,
    required this.aoConfirmar,
    required this.aoCancelar,
  });

  final String nomeArquivo;
  final PlanoImportacao plano;
  final String? erro;
  final VoidCallback aoConfirmar;
  final VoidCallback aoCancelar;

  @override
  Widget build(BuildContext context) {
    final corErro = Theme.of(context).colorScheme.error;
    Widget linha(String rotulo, int valor) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            SizedBox(width: 260, child: Text(rotulo)),
            Text(formatInteiro(valor), style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        );
    return Column(
      key: const ValueKey('resumo'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Arquivo: $nomeArquivo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (erro != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(erro!, style: TextStyle(color: corErro)),
          ),
        if (plano.erro == null) ...[
          linha('Clientes a criar', plano.clientesNovos),
          linha('Clientes a atualizar', plano.clientesAtualizados),
          linha('Produtos a criar', plano.produtosNovos),
          linha('Produtos a atualizar', plano.produtosAtualizados),
          linha('Compras a criar', plano.comprasNovas),
          linha('Compras já existentes (ignoradas)', plano.comprasDuplicadas),
          linha('Linhas rejeitadas', plano.rejeitadas.length),
          linha('Avisos', plano.avisos.length),
        ],
        if (plano.rejeitadas.isNotEmpty)
          _Ocorrencias('Linhas rejeitadas (não serão importadas)', plano.rejeitadas, corErro),
        if (plano.avisos.isNotEmpty) _Ocorrencias('Avisos', plano.avisos, null),
        const SizedBox(height: 16),
        Row(children: [
          OutlinedButton(onPressed: aoCancelar, child: const Text('Cancelar')),
          const SizedBox(width: 12),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Confirmar importação'),
            onPressed: plano.podeAplicar ? aoConfirmar : null,
          ),
        ]),
      ],
    );
  }
}

class _Ocorrencias extends StatelessWidget {
  const _Ocorrencias(this.titulo, this.itens, this.cor);

  final String titulo;
  final List<Ocorrencia> itens;
  final Color? cor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          initiallyExpanded: itens.length <= 10,
          title: Text('$titulo (${itens.length})', style: TextStyle(color: cor)),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final o in itens)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('$o'),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
}
