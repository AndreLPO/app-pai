import 'package:flutter/material.dart';

/// Campo com busca digitada e lista de sugestões (cliente, produto).
class CampoBusca<T extends Object> extends StatelessWidget {
  const CampoBusca({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.exibir,
    required this.buscar,
    required this.aoSelecionar,
    this.aoLimpar,
    this.erro,
    this.autofocus = false,
  });

  final String rotulo;
  final T? valor;
  final String Function(T) exibir;
  final Future<List<T>> Function(String texto) buscar;
  final ValueChanged<T> aoSelecionar;

  /// Chamado quando o usuário edita o texto de uma seleção já feita.
  final VoidCallback? aoLimpar;
  final String? erro;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => Autocomplete<T>(
        initialValue: TextEditingValue(text: valor == null ? '' : exibir(valor as T)),
        displayStringForOption: exibir,
        optionsBuilder: (v) => buscar(v.text),
        onSelected: aoSelecionar,
        fieldViewBuilder: (context, controller, foco, aoEnviar) => TextField(
          controller: controller,
          focusNode: foco,
          autofocus: autofocus,
          textCapitalization: TextCapitalization.characters,
          onChanged: (_) {
            if (valor != null) aoLimpar?.call();
          },
          onSubmitted: (_) => aoEnviar(),
          decoration: InputDecoration(
            labelText: rotulo,
            errorText: erro,
            hintText: 'Digite para buscar',
            suffixIcon: const Icon(Icons.search),
          ),
        ),
      );
}
