import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../controllers/tabelas_controllers.dart';
import '../compras/compras_page.dart';
import '../widgets/filtros.dart';

/// Visão no layout da planilha: uma linha por compra, somente leitura.
class ConsultaPage extends StatelessWidget {
  const ConsultaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final consulta = AppScope.of(context).consulta;
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta Geral')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: consulta.colunasOcultas,
        builder: (context, _, _) => TabelaCompleta<int>(
          controller: consulta,
          colunas: consulta.colunasVisiveis,
          fixarPrimeiraColuna: true,
          aoTocarLinha: (id) => abrirCompraPorId(context, id),
          filtrosRapidos: const {
            'cidade': 'Cidade',
            'produto': 'Produto',
            'fantasia': 'Cliente',
            'data': 'Período',
          },
          acoes: [
            OutlinedButton.icon(
              key: const ValueKey('colunas'),
              icon: const Icon(Icons.view_column_outlined),
              label: const Text('Colunas'),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => _ColunasDialog(consulta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColunasDialog extends StatelessWidget {
  const _ColunasDialog(this.consulta);

  final ConsultaController consulta;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Colunas visíveis'),
        content: SizedBox(
          width: 360,
          height: 480,
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: consulta.colunasOcultas,
            builder: (context, ocultas, _) => ListView(
              children: [
                for (final c in consulta.colunas)
                  CheckboxListTile(
                    dense: true,
                    title: Text(c.rotulo),
                    value: !ocultas.contains(c.id),
                    onChanged: c.id == ConsultaController.colunaFixa
                        ? null
                        : (v) => consulta.alternarColuna(c.id, visivel: v!),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: consulta.mostrarTodasColunas,
            child: const Text('Mostrar todas'),
          ),
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
        ],
      );
}
