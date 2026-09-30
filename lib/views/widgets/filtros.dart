import 'package:flutter/material.dart';

import '../../controllers/table_controller.dart';
import '../../core/datas.dart';
import '../../core/formatters.dart';
import '../../core/money.dart';
import '../../core/text_normalize.dart';
import '../../models/table_query.dart';
import 'data_table_view.dart';

/// Abre o diálogo de filtro adequado ao tipo da coluna e aplica o resultado.
Future<void> abrirFiltro<T>(
  BuildContext context,
  TableController<T> controller,
  ColunaTabela coluna,
) async {
  Filtro? atual;
  for (final f in controller.query.filtros) {
    if (f.colunaId == coluna.id) atual = f;
  }
  final resultado = await showDialog<_ResultadoFiltro>(
    context: context,
    builder: (context) => switch (coluna.tipo) {
      TipoColuna.texto => _FiltroTextoDialog(coluna, atual as FiltroContem?),
      TipoColuna.categoria => _FiltroCategoriaDialog(
          coluna, atual as FiltroIgual?, controller.valoresDistintos(coluna.id)),
      TipoColuna.inteiro ||
      TipoColuna.moeda =>
        _FiltroIntervaloDialog(coluna, atual as FiltroIntervalo?),
      TipoColuna.data => _FiltroPeriodoDialog(coluna, atual as FiltroPeriodo?),
    },
  );
  if (resultado == null) return;
  final filtro = resultado.filtro;
  filtro == null ? controller.removerFiltro(coluna.id) : controller.aplicarFiltro(filtro);
}

/// `filtro == null` significa remover o filtro da coluna.
class _ResultadoFiltro {
  const _ResultadoFiltro(this.filtro);

  final Filtro? filtro;
}

class _DialogoFiltro extends StatelessWidget {
  const _DialogoFiltro({
    required this.coluna,
    required this.conteudo,
    required this.aoAplicar,
    this.podeRemover = false,
  });

  final ColunaTabela coluna;
  final Widget conteudo;
  final Filtro? Function() aoAplicar;
  final bool podeRemover;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Filtrar: ${coluna.rotulo}'),
        content: SizedBox(width: 420, child: conteudo),
        actions: [
          if (podeRemover)
            TextButton(
              onPressed: () => Navigator.pop(context, const _ResultadoFiltro(null)),
              child: const Text('Remover filtro'),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, _ResultadoFiltro(aoAplicar())),
            child: const Text('Aplicar'),
          ),
        ],
      );
}

class _FiltroTextoDialog extends StatefulWidget {
  const _FiltroTextoDialog(this.coluna, this.atual);

  final ColunaTabela coluna;
  final FiltroContem? atual;

  @override
  State<_FiltroTextoDialog> createState() => _FiltroTextoDialogState();
}

class _FiltroTextoDialogState extends State<_FiltroTextoDialog> {
  late final _texto = TextEditingController(text: widget.atual?.texto);

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Filtro? _filtro() {
    final t = _texto.text.trim();
    return t.isEmpty ? null : FiltroContem(widget.coluna.id, t);
  }

  @override
  Widget build(BuildContext context) => _DialogoFiltro(
        coluna: widget.coluna,
        podeRemover: widget.atual != null,
        aoAplicar: _filtro,
        conteudo: TextField(
          controller: _texto,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Contém'),
          onSubmitted: (_) => Navigator.pop(context, _ResultadoFiltro(_filtro())),
        ),
      );
}

class _FiltroCategoriaDialog extends StatefulWidget {
  const _FiltroCategoriaDialog(this.coluna, this.atual, this.valores);

  final ColunaTabela coluna;
  final FiltroIgual? atual;
  final Future<List<String>> valores;

  @override
  State<_FiltroCategoriaDialog> createState() => _FiltroCategoriaDialogState();
}

class _FiltroCategoriaDialogState extends State<_FiltroCategoriaDialog> {
  late final Set<String> _selecionados = {...?widget.atual?.valores};
  String _busca = '';

  @override
  Widget build(BuildContext context) => _DialogoFiltro(
        coluna: widget.coluna,
        podeRemover: widget.atual != null,
        aoAplicar: () =>
            _selecionados.isEmpty ? null : FiltroIgual(widget.coluna.id, {..._selecionados}),
        conteudo: FutureBuilder<List<String>>(
          future: widget.valores,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const SizedBox(
                  height: 120, child: Center(child: CircularProgressIndicator()));
            }
            final valores = [
              for (final v in snap.data!)
                if (contemNormalizado(v, _busca)) v,
            ];
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search), hintText: 'Procurar'),
                  onChanged: (t) => setState(() => _busca = t),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 320,
                  child: valores.isEmpty
                      ? const Center(child: Text('Nenhum valor'))
                      : ListView(
                          children: [
                            for (final v in valores)
                              CheckboxListTile(
                                dense: true,
                                title: Text(v),
                                value: _selecionados.contains(v),
                                onChanged: (s) => setState(() =>
                                    s! ? _selecionados.add(v) : _selecionados.remove(v)),
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      );
}

class _FiltroIntervaloDialog extends StatefulWidget {
  const _FiltroIntervaloDialog(this.coluna, this.atual);

  final ColunaTabela coluna;
  final FiltroIntervalo? atual;

  @override
  State<_FiltroIntervaloDialog> createState() => _FiltroIntervaloDialogState();
}

class _FiltroIntervaloDialogState extends State<_FiltroIntervaloDialog> {
  bool get _moeda => widget.coluna.tipo == TipoColuna.moeda;

  String _fmt(int? v) =>
      v == null ? '' : (_moeda ? Money.formatSemSimbolo(v) : '$v');

  late final _min = TextEditingController(text: _fmt(widget.atual?.minimo));
  late final _max = TextEditingController(text: _fmt(widget.atual?.maximo));

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  int? _ler(String t) => _moeda ? Money.parse(t) : int.tryParse(t.replaceAll('.', ''));

  Widget _campo(TextEditingController c, String rotulo) => Expanded(
        child: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [if (_moeda) const MoedaFormatter()],
          decoration: InputDecoration(labelText: rotulo, prefixText: _moeda ? 'R\$ ' : null),
        ),
      );

  @override
  Widget build(BuildContext context) => _DialogoFiltro(
        coluna: widget.coluna,
        podeRemover: widget.atual != null,
        aoAplicar: () {
          final min = _ler(_min.text), max = _ler(_max.text);
          if (min == null && max == null) return null;
          return FiltroIntervalo(widget.coluna.id, minimo: min, maximo: max, moeda: _moeda);
        },
        conteudo: Row(
          children: [
            _campo(_min, 'Mínimo'),
            const SizedBox(width: 16),
            _campo(_max, 'Máximo'),
          ],
        ),
      );
}

class _FiltroPeriodoDialog extends StatefulWidget {
  const _FiltroPeriodoDialog(this.coluna, this.atual);

  final ColunaTabela coluna;
  final FiltroPeriodo? atual;

  @override
  State<_FiltroPeriodoDialog> createState() => _FiltroPeriodoDialogState();
}

class _FiltroPeriodoDialogState extends State<_FiltroPeriodoDialog> {
  late DateTime? _de = widget.atual?.de;
  late DateTime? _ate = widget.atual?.ate;

  Future<DateTime?> _escolher(DateTime? inicial) => showDatePicker(
        context: context,
        initialDate: inicial ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

  Widget _botao(String rotulo, DateTime? valor, ValueChanged<DateTime?> definir) =>
      Expanded(
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: rotulo,
            suffixIcon: valor == null
                ? null
                : IconButton(
                    tooltip: 'Limpar',
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => definir(null)),
                  ),
          ),
          child: InkWell(
            onTap: () async {
              final d = await _escolher(valor);
              if (d != null) setState(() => definir(d));
            },
            child: Text(valor == null ? 'Escolher' : formatarData(valor)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => _DialogoFiltro(
        coluna: widget.coluna,
        podeRemover: widget.atual != null,
        aoAplicar: () => _de == null && _ate == null
            ? null
            : FiltroPeriodo(widget.coluna.id, de: _de, ate: _ate),
        conteudo: Row(
          children: [
            _botao('De', _de, (d) => _de = d),
            const SizedBox(width: 16),
            _botao('Até', _ate, (d) => _ate = d),
          ],
        ),
      );
}

/// Busca geral, menu de filtros por coluna, chips dos filtros ativos e
/// "Limpar filtros".
class FilterBar<T> extends StatefulWidget {
  const FilterBar({
    super.key,
    required this.controller,
    this.filtrosRapidos = const {},
    this.acoes = const [],
  });

  final TableController<T> controller;

  /// Botões de filtro sempre visíveis: id da coluna -> rótulo do botão.
  final Map<String, String> filtrosRapidos;

  /// Botões extras à direita (ex.: "Adicionar").
  final List<Widget> acoes;

  @override
  State<FilterBar<T>> createState() => _FilterBarState<T>();
}

class _FilterBarState<T> extends State<FilterBar<T>> {
  late final _busca = TextEditingController(text: widget.controller.buscaDigitada);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sincronizar);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sincronizar);
    _busca.dispose();
    super.dispose();
  }

  /// Mantém o campo igual à busca do controller (ex.: após "Limpar").
  void _sincronizar() {
    final t = widget.controller.buscaDigitada;
    if (_busca.text != t) _busca.text = t;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final filtraveis = [for (final col in c.colunas) if (col.filtravel) col];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('busca'),
                      controller: _busca,
                      onChanged: c.buscar,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar',
                        isDense: true,
                        border: const OutlineInputBorder(),
                        suffixIcon: _busca.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Limpar busca',
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _busca.clear();
                                  c.buscar('');
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MenuAnchor(
                    builder: (context, menu, _) => OutlinedButton.icon(
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filtros'),
                      onPressed: () => menu.isOpen ? menu.close() : menu.open(),
                    ),
                    menuChildren: [
                      for (final col in filtraveis)
                        MenuItemButton(
                          onPressed: () => abrirFiltro(context, c, col),
                          child: Text(col.rotulo),
                        ),
                    ],
                  ),
                  for (final a in widget.acoes) ...[const SizedBox(width: 8), a],
                ],
              ),
              if (widget.filtrosRapidos.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final MapEntry(key: id, value: rotulo)
                          in widget.filtrosRapidos.entries)
                        if (c.coluna(id) case final col?)
                          ActionChip(
                            key: ValueKey('filtro-rapido-$id'),
                            avatar: const Icon(Icons.filter_alt_outlined, size: 18),
                            label: Text(rotulo),
                            onPressed: () => abrirFiltro(context, c, col),
                          ),
                    ],
                  ),
                ),
              if (c.temFiltros)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final f in c.query.filtros)
                        InputChip(
                          label: Text(f.descrever(c.coluna(f.colunaId)?.rotulo ?? '')),
                          onPressed: c.coluna(f.colunaId) == null
                              ? null
                              : () => abrirFiltro(context, c, c.coluna(f.colunaId)!),
                          onDeleted: () => c.removerFiltro(f.colunaId),
                          deleteButtonTooltipMessage: 'Remover filtro',
                        ),
                      TextButton.icon(
                        icon: const Icon(Icons.filter_alt_off_outlined),
                        label: const Text('Limpar filtros'),
                        onPressed: c.limparFiltros,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Contagem de registros, somas das colunas e navegação entre páginas.
class RodapeTabela<T> extends StatelessWidget {
  const RodapeTabela({super.key, required this.controller});

  final TableController<T> controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final c = controller;
          final pagina = c.query.pagina;
          final ultima = c.totalPaginas - 1;
          final estilo = Theme.of(context).textTheme.bodyMedium;
          return Material(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 24,
                      children: [
                        Text(
                          '${formatInteiro(c.total)} ${c.total == 1 ? 'registro' : 'registros'}',
                          style: estilo?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        for (final e in c.somas.entries)
                          if (c.coluna(e.key) case final col?)
                            Text('${col.rotulo}: ${col.formatar(e.value)}',
                                key: ValueKey('soma-${col.id}'), style: estilo),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Primeira página',
                    icon: const Icon(Icons.first_page),
                    onPressed: pagina > 0 ? () => c.irParaPagina(0) : null,
                  ),
                  IconButton(
                    tooltip: 'Página anterior',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: pagina > 0 ? () => c.irParaPagina(pagina - 1) : null,
                  ),
                  Text('Página ${pagina + 1} de ${c.totalPaginas}', style: estilo),
                  IconButton(
                    tooltip: 'Próxima página',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: pagina < ultima ? () => c.irParaPagina(pagina + 1) : null,
                  ),
                  IconButton(
                    tooltip: 'Última página',
                    icon: const Icon(Icons.last_page),
                    onPressed: pagina < ultima ? () => c.irParaPagina(ultima) : null,
                  ),
                ],
              ),
            ),
          );
        },
      );
}

/// Tela de tabela completa: filtros, grade e rodapé.
class TabelaCompleta<T> extends StatefulWidget {
  const TabelaCompleta({
    super.key,
    required this.controller,
    this.colunas,
    this.fixarPrimeiraColuna = false,
    this.aoTocarLinha,
    this.filtrosRapidos = const {},
    this.acoes = const [],
  });

  final TableController<T> controller;
  final List<ColunaTabela>? colunas;
  final bool fixarPrimeiraColuna;
  final ValueChanged<T>? aoTocarLinha;
  final Map<String, String> filtrosRapidos;
  final List<Widget> acoes;

  @override
  State<TabelaCompleta<T>> createState() => _TabelaCompletaState<T>();
}

class _TabelaCompletaState<T> extends State<TabelaCompleta<T>> {
  @override
  void initState() {
    super.initState();
    // Fora do build: o carregamento notifica os ouvintes.
    Future.microtask(widget.controller.garantirCarregado);
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          FilterBar<T>(
            controller: widget.controller,
            filtrosRapidos: widget.filtrosRapidos,
            acoes: widget.acoes,
          ),
          Expanded(
            child: DataTableView<T>(
              controller: widget.controller,
              colunas: widget.colunas,
              fixarPrimeiraColuna: widget.fixarPrimeiraColuna,
              aoTocarLinha: widget.aoTocarLinha,
            ),
          ),
          RodapeTabela<T>(controller: widget.controller),
        ],
      );
}
