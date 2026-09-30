import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../controllers/home_controller.dart';
import '../../core/money.dart';
import '../../models/database/daos/analitico_dao.dart';
import '../widgets/bar_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _c;
  late final AppScope _scope;

  @override
  void initState() {
    super.initState();
    _scope = AppScope.read(context);
    _c = HomeController(_scope.db.analiticoDao)..carregar();
    _scope.versaoDados.addListener(_c.carregar);
  }

  @override
  void dispose() {
    _scope.versaoDados.removeListener(_c.carregar);
    _c.dispose();
    super.dispose();
  }

  void _abrirInativos() {
    _scope.clientes.mostrarInativos();
    _scope.navegacao.value = Aba.clientes;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ListenableBuilder(
                listenable: _c,
                builder: (context, _) => DropdownButton<PeriodoHome>(
                  key: const ValueKey('periodo'),
                  value: _c.periodo,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final p in PeriodoHome.values)
                      DropdownMenuItem(value: p, child: Text(p.rotulo)),
                  ],
                  onChanged: (p) => _c.selecionarPeriodo(p!),
                ),
              ),
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: _c,
          builder: (context, _) {
            final d = _c.dados;
            if (d == null) {
              return _c.erro != null
                  ? Center(child: Text('Erro ao carregar: ${_c.erro}'))
                  : const Center(child: CircularProgressIndicator());
            }
            final i = d.indicadores;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_c.carregando) const LinearProgressIndicator(),
                if (d.semDados)
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Sem dados no período'),
                      subtitle: Text('Não há compras registradas no período selecionado.'),
                    ),
                  ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _Indicador('Valor total vendido', Money.format(i.valorTotal),
                        Icons.payments_outlined),
                    _Indicador('Unidades', formatInteiro(i.unidades), Icons.inventory_outlined),
                    _Indicador('Registros de compra', formatInteiro(i.registros),
                        Icons.receipt_long_outlined),
                    _Indicador('Clientes que compraram', formatInteiro(i.clientes),
                        Icons.store_outlined),
                    _Indicador('Ticket médio por cliente', Money.format(i.ticketMedio),
                        Icons.trending_up),
                    _Indicador(
                      'Clientes sem compra há mais de 60 dias',
                      formatInteiro(d.clientesInativos),
                      Icons.person_off_outlined,
                      key: const ValueKey('inativos'),
                      aoTocar: _abrirInativos,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, c) {
                    final rankings = [
                      _Ranking('Top 5 produtos', d.topProdutos, key: const ValueKey('topProdutos')),
                      _Ranking('Top 5 clientes', d.topClientes, key: const ValueKey('topClientes')),
                    ];
                    if (c.maxWidth < 700) return Column(children: rankings);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: rankings[0]),
                        const SizedBox(width: 12),
                        Expanded(child: rankings[1]),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Vendas nos últimos 12 meses',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        GraficoMensal(meses: d.meses),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class _Indicador extends StatelessWidget {
  const _Indicador(this.rotulo, this.valor, this.icone, {super.key, this.aoTocar});

  final String rotulo;
  final String valor;
  final IconData icone;
  final VoidCallback? aoTocar;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 260,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: aoTocar,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icone, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
                        Text(valor, style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                  ),
                  if (aoTocar != null) const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Ranking extends StatelessWidget {
  const _Ranking(this.titulo, this.itens, {super.key});

  final String titulo;
  final List<ItemRanking> itens;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(title: Text(titulo, style: Theme.of(context).textTheme.titleMedium)),
              if (itens.isEmpty)
                const ListTile(title: Text('Sem dados no período')),
              for (var i = 0; i < itens.length; i++)
                ListTile(
                  dense: true,
                  leading: CircleAvatar(radius: 14, child: Text('${i + 1}')),
                  title: Text(itens[i].nome),
                  trailing: Text(Money.format(itens[i].valor)),
                ),
            ],
          ),
        ),
      );
}
