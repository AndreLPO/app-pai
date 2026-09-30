import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../clientes/clientes_page.dart';
import '../compras/compras_page.dart';
import '../consulta/consulta_page.dart';
import '../home/home_page.dart';
import '../importacao/importacao_page.dart';
import '../pin/pin_pages.dart';
import '../produtos/produtos_page.dart';

class _Destino {
  const _Destino(this.aba, this.rotulo, this.icone, this.iconeSelecionado);

  final Aba aba;
  final String rotulo;
  final IconData icone;
  final IconData iconeSelecionado;
}

const _destinos = [
  _Destino(Aba.home, 'Home', Icons.home_outlined, Icons.home),
  _Destino(Aba.consulta, 'Consulta Geral', Icons.table_chart_outlined, Icons.table_chart),
  _Destino(Aba.clientes, 'Clientes', Icons.store_outlined, Icons.store),
  _Destino(Aba.produtos, 'Produtos', Icons.inventory_2_outlined, Icons.inventory_2),
  _Destino(Aba.compras, 'Compras', Icons.shopping_cart_outlined, Icons.shopping_cart),
  _Destino(Aba.importacao, 'Importar/Exportar', Icons.import_export_outlined,
      Icons.import_export),
  _Destino(Aba.trocarPin, 'Trocar PIN', Icons.password_outlined, Icons.password),
];

/// Menu lateral e a página da aba selecionada. Cada aba visitada fica
/// montada, para manter rolagem e estado ao alternar.
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  final _visitadas = <Aba>{};

  Widget _pagina(Aba aba) => switch (aba) {
        Aba.home => const HomePage(),
        Aba.consulta => const ConsultaPage(),
        Aba.clientes => const ClientesPage(),
        Aba.produtos => const ProdutosPage(),
        Aba.compras => const ComprasPage(),
        Aba.importacao => const ImportacaoPage(),
        Aba.trocarPin => const TrocarPinPage(),
      };

  @override
  Widget build(BuildContext context) {
    final navegacao = AppScope.of(context).navegacao;
    return ValueListenableBuilder<Aba>(
      valueListenable: navegacao,
      builder: (context, atual, _) {
        _visitadas.add(atual);
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                SingleChildScrollView(
                  child: IntrinsicHeight(
                    child: NavigationRail(
                      selectedIndex: _destinos.indexWhere((d) => d.aba == atual),
                      labelType: NavigationRailLabelType.all,
                      onDestinationSelected: (i) => navegacao.value = _destinos[i].aba,
                      destinations: [
                        for (final d in _destinos)
                          NavigationRailDestination(
                            icon: Icon(d.icone),
                            selectedIcon: Icon(d.iconeSelecionado),
                            label: Text(d.rotulo, textAlign: TextAlign.center),
                          ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(
                    index: Aba.values.indexOf(atual),
                    children: [
                      for (final aba in Aba.values)
                        _visitadas.contains(aba)
                            ? TickerMode(enabled: aba == atual, child: _pagina(aba))
                            : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
