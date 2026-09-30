import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../../controllers/table_controller.dart';
import '../../models/table_query.dart';

/// Grade de dados com cabeçalho fixo, primeira coluna fixa opcional e
/// ordenação por toque no cabeçalho.
class DataTableView<T> extends StatefulWidget {
  const DataTableView({
    super.key,
    required this.controller,
    this.colunas,
    this.fixarPrimeiraColuna = false,
    this.aoTocarLinha,
  });

  final TableController<T> controller;

  /// Colunas exibidas (padrão: todas as da fonte).
  final List<ColunaTabela>? colunas;
  final bool fixarPrimeiraColuna;
  final ValueChanged<T>? aoTocarLinha;

  static const alturaLinha = 44.0;
  static const alturaCabecalho = 48.0;

  @override
  State<DataTableView<T>> createState() => _DataTableViewState<T>();
}

class _DataTableViewState<T> extends State<DataTableView<T>> {
  final _vertical = ScrollController();
  final _horizontal = ScrollController();
  TableQuery? _ultimaQuery;

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  static bool _numerica(ColunaTabela c) =>
      c.tipo == TipoColuna.inteiro || c.tipo == TipoColuna.moeda;

  /// Volta ao topo quando a página, os filtros ou a ordenação mudam.
  void _voltarAoTopoSeMudou(TableQuery q) {
    if (_ultimaQuery != null && !identical(_ultimaQuery, q)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_vertical.hasClients) _vertical.jumpTo(0);
      });
    }
    _ultimaQuery = q;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final c = widget.controller;
        final colunas = widget.colunas ?? c.colunas;
        final linhas = c.linhas;
        final ordem = c.ordenacao;
        if (c.carregou) _voltarAoTopoSeMudou(c.query);

        final borda = BorderSide(color: tema.colorScheme.outlineVariant);
        final tabela = TableView.builder(
          verticalDetails: ScrollableDetails.vertical(controller: _vertical),
          horizontalDetails: ScrollableDetails.horizontal(controller: _horizontal),
          diagonalDragBehavior: DiagonalDragBehavior.free,
          pinnedRowCount: 1,
          pinnedColumnCount: widget.fixarPrimeiraColuna && colunas.isNotEmpty ? 1 : 0,
          columnCount: colunas.length,
          rowCount: linhas.length + 1,
          columnBuilder: (i) => TableSpan(
            extent: FixedTableSpanExtent(colunas[i].largura),
            foregroundDecoration: widget.fixarPrimeiraColuna && i == 0
                ? TableSpanDecoration(border: TableSpanBorder(trailing: borda))
                : null,
          ),
          rowBuilder: (i) => TableSpan(
            extent: FixedTableSpanExtent(
                i == 0 ? DataTableView.alturaCabecalho : DataTableView.alturaLinha),
            backgroundDecoration: TableSpanDecoration(
              color: i == 0
                  ? tema.colorScheme.surfaceContainerHighest
                  : i.isEven
                      ? tema.colorScheme.surfaceContainerLow
                      : tema.colorScheme.surface,
              border: TableSpanBorder(trailing: borda),
            ),
          ),
          cellBuilder: (context, v) {
            final coluna = colunas[v.column];
            final alinhamento =
                _numerica(coluna) ? Alignment.centerRight : Alignment.centerLeft;
            if (v.row == 0) {
              final ativa = ordem.coluna == coluna.id;
              return TableViewCell(
                child: InkWell(
                  key: ValueKey('cabecalho-${coluna.id}'),
                  onTap: coluna.ordenavel ? () => c.ordenarPor(coluna.id) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment: alinhamento,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              coluna.rotulo,
                              overflow: TextOverflow.ellipsis,
                              style: tema.textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (ativa)
                            Icon(
                              ordem.crescente ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 16,
                              semanticLabel: ordem.crescente ? 'crescente' : 'decrescente',
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            final linha = linhas[v.row - 1];
            return TableViewCell(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.aoTocarLinha == null
                    ? null
                    : () => widget.aoTocarLinha!(linha.registro),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: alinhamento,
                    child: Text(
                      coluna.formatar(linha.valores[coluna.id]),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            );
          },
        );

        return Column(
          children: [
            SizedBox(
              height: 3,
              child: c.carregando ? const LinearProgressIndicator() : null,
            ),
            Expanded(
              child: Stack(
                children: [
                  tabela,
                  if (c.erro != null)
                    Center(child: Text('Erro ao carregar: ${c.erro}'))
                  else if (c.carregou && linhas.isEmpty)
                    const Center(child: Text('Nenhum registro encontrado')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
