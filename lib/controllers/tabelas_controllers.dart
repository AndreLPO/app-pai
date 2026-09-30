import 'package:flutter/foundation.dart';

import '../models/database/app_database.dart';
import '../models/database/daos/clientes_dao.dart';
import '../models/database/daos/compras_dao.dart';
import '../models/database/daos/consulta_dao.dart';
import '../models/database/daos/produtos_dao.dart';
import '../models/table_query.dart';
import 'table_controller.dart';

class ProdutosController extends TableController<Produto> {
  ProdutosController(ProdutosDao super.dao, {super.debounce});
}

class ClientesController extends TableController<Cliente> {
  ClientesController(ClientesDao super.dao, {super.debounce});

  /// Atalho da Home: só os clientes sem compra recente.
  void mostrarInativos() => substituirQuery(TableQuery(
        tamanhoPagina: query.tamanhoPagina,
        filtros: const [ClientesDao.filtroInativos],
      ));
}

class ComprasController extends TableController<CompraCompleta> {
  ComprasController(ComprasDao super.dao, {super.debounce});
}

/// Consulta Geral: além da tabela, guarda as colunas ocultas da sessão.
class ConsultaController extends TableController<int> {
  ConsultaController(ConsultaDao super.dao, {super.debounce});

  /// Colunas que o usuário ocultou (Fantasia não pode ser oculta).
  final colunasOcultas = ValueNotifier<Set<String>>(const {});

  static const colunaFixa = 'fantasia';

  List<ColunaTabela> get colunasVisiveis => [
        for (final c in colunas)
          if (!colunasOcultas.value.contains(c.id)) c,
      ];

  void alternarColuna(String id, {required bool visivel}) {
    if (id == colunaFixa) return;
    final atual = {...colunasOcultas.value};
    visivel ? atual.remove(id) : atual.add(id);
    colunasOcultas.value = atual;
  }

  void mostrarTodasColunas() => colunasOcultas.value = const {};

  @override
  void dispose() {
    colunasOcultas.dispose();
    super.dispose();
  }
}
