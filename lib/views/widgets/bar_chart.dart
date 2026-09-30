import 'package:flutter/material.dart';

import '../../core/datas.dart';
import '../../core/money.dart';
import '../../models/database/daos/analitico_dao.dart';

/// Gráfico de barras simples: valor vendido por mês.
class GraficoMensal extends StatelessWidget {
  const GraficoMensal({super.key, required this.meses, this.altura = 220});

  final List<ValorMes> meses;
  final double altura;

  static String rotuloMes(DateTime m) =>
      '${nomesMesesAbrev[m.month - 1]}/${(m.year % 100).toString().padLeft(2, '0')}';

  /// Valor curto para caber sobre a barra (`12,3 mil`).
  static String valorCurto(int centavos) {
    final reais = centavos / 100;
    if (reais >= 1000000) return '${(reais / 1000000).toStringAsFixed(1).replaceAll('.', ',')} mi';
    if (reais >= 1000) return '${(reais / 1000).toStringAsFixed(1).replaceAll('.', ',')} mil';
    return reais.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final texto = Theme.of(context).textTheme.labelSmall;
    final maximo = meses.fold<int>(0, (m, e) => e.valor > m ? e.valor : m);
    return SizedBox(
      height: altura,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final m in meses)
            Expanded(
              child: Tooltip(
                message: '${rotuloMes(m.mes)}: ${Money.format(m.valor)}',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(m.valor == 0 ? '0' : valorCurto(m.valor),
                          style: texto, maxLines: 1, overflow: TextOverflow.clip),
                      const SizedBox(height: 4),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, c) => Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              key: ValueKey('barra-${formatarDataIso(m.mes).substring(0, 7)}'),
                              height: maximo == 0 ? 0 : c.maxHeight * m.valor / maximo,
                              decoration: BoxDecoration(
                                color: cores.primary,
                                borderRadius:
                                    const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(rotuloMes(m.mes), style: texto),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
