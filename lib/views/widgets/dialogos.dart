import 'package:flutter/material.dart';

/// Pergunta de sim/não. Retorna `true` só se o usuário confirmar.
Future<bool> confirmar(
  BuildContext context, {
  required String titulo,
  required String mensagem,
  String textoConfirmar = 'Confirmar',
  bool destrutivo = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: destrutivo
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(textoConfirmar),
        ),
      ],
    ),
  );
  return r ?? false;
}

/// Aviso simples com um botão OK.
Future<void> avisar(BuildContext context, {required String titulo, required String mensagem}) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );

void mostrarMensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

/// Pede confirmação antes de sair de um formulário com alterações.
class GuardaAlteracoes extends StatelessWidget {
  const GuardaAlteracoes({super.key, required this.sujo, required this.child});

  final bool sujo;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
        canPop: !sujo,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final sair = await confirmar(
            context,
            titulo: 'Descartar alterações?',
            mensagem: 'Existem alterações não salvas. Deseja sair sem salvar?',
            textoConfirmar: 'Descartar',
            destrutivo: true,
          );
          if (sair && context.mounted) Navigator.of(context).pop();
        },
        child: child,
      );
}
