import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../controllers/form_controllers.dart';
import 'dialogos.dart';

/// Abre um formulário. Ao voltar com uma mensagem (salvo ou excluído),
/// mostra a confirmação e recarrega as tabelas.
Future<void> abrirFormulario(BuildContext context, Widget formulario) async {
  final scope = AppScope.of(context);
  final mensagem = await Navigator.of(context).push<String>(
    MaterialPageRoute(builder: (_) => formulario),
  );
  if (mensagem == null) return;
  scope.dadosAlterados();
  if (context.mounted) mostrarMensagem(context, mensagem);
}

/// Estrutura comum dos formulários: título, Excluir, Salvar, confirmação
/// ao sair com alterações e corpo com largura limitada.
class LayoutFormulario extends StatelessWidget {
  const LayoutFormulario({
    super.key,
    required this.titulo,
    required this.controller,
    required this.aoSalvar,
    this.aoExcluir,
    required this.children,
  });

  final String titulo;
  final FormController controller;
  final VoidCallback aoSalvar;
  final VoidCallback? aoExcluir;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) => GuardaAlteracoes(
          sujo: controller.sujo,
          child: Scaffold(
            appBar: AppBar(
              title: Text(titulo),
              actions: [
                if (aoExcluir != null)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Excluir'),
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error),
                    onPressed: controller.salvando ? null : aoExcluir,
                  ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Salvar'),
                  onPressed: controller.salvando ? null : aoSalvar,
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

/// Linha de campos lado a lado (tablet).
class LinhaCampos extends StatelessWidget {
  const LinhaCampos({super.key, required this.children, this.flex});

  final List<Widget> children;
  final List<int>? flex;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(flex: flex?[i] ?? 1, child: children[i]),
            ],
          ],
        ),
      );
}

/// Confirma e executa a exclusão de um registro.
Future<void> excluirComConfirmacao(
  BuildContext context, {
  required String descricao,
  required Future<String?> Function() excluir,
  required String mensagemSucesso,
}) async {
  final ok = await confirmar(
    context,
    titulo: 'Excluir $descricao?',
    mensagem: 'Esta ação não pode ser desfeita.',
    textoConfirmar: 'Excluir',
    destrutivo: true,
  );
  if (!ok || !context.mounted) return;
  final erro = await excluir();
  if (!context.mounted) return;
  if (erro != null) {
    await avisar(context, titulo: 'Exclusão não permitida', mensagem: erro);
  } else {
    Navigator.of(context).pop(mensagemSucesso);
  }
}
