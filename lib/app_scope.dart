import 'package:flutter/widgets.dart';

import 'controllers/auth_controller.dart';
import 'controllers/table_controller.dart';
import 'controllers/tabelas_controllers.dart';
import 'models/database/app_database.dart';
import 'models/services/pin_service.dart';
import 'models/services/planilha_export_service.dart';
import 'models/services/planilha_import_service.dart';

/// Itens do menu lateral.
enum Aba { home, consulta, clientes, produtos, compras, importacao, trocarPin }

/// Dependências do app, disponíveis para toda a árvore de widgets.
///
/// Os controllers das tabelas vivem aqui (e não nas páginas) para manter
/// busca, filtros, ordenação e página durante a sessão.
class AppScope extends InheritedWidget {
  const AppScope._({
    required this.db,
    required this.pinService,
    required this.importacao,
    required this.exportacao,
    required this.auth,
    required this.produtos,
    required this.clientes,
    required this.compras,
    required this.consulta,
    required this.navegacao,
    required this.versaoDados,
    required super.child,
  });

  factory AppScope({
    required AppDatabase db,
    required Widget child,
    AuthController? auth,
    Duration debounceBusca = const Duration(milliseconds: 300),
  }) {
    final pin = PinService(db.configDao);
    return AppScope._(
      db: db,
      pinService: pin,
      importacao: PlanilhaImportService(db),
      exportacao: PlanilhaExportService(db),
      auth: auth ?? AuthController(pin, relogio: db.relogio),
      produtos: ProdutosController(db.produtosDao, debounce: debounceBusca),
      clientes: ClientesController(db.clientesDao, debounce: debounceBusca),
      compras: ComprasController(db.comprasDao, debounce: debounceBusca),
      consulta: ConsultaController(db.consultaDao, debounce: debounceBusca),
      navegacao: ValueNotifier(Aba.home),
      versaoDados: ValueNotifier(0),
      child: child,
    );
  }

  final AppDatabase db;
  final PinService pinService;
  final PlanilhaImportService importacao;
  final PlanilhaExportService exportacao;
  final AuthController auth;
  final ProdutosController produtos;
  final ClientesController clientes;
  final ComprasController compras;
  final ConsultaController consulta;

  /// Aba selecionada no menu lateral.
  final ValueNotifier<Aba> navegacao;

  /// Incrementado a cada alteração de dados (a Home recarrega ao mudar).
  final ValueNotifier<int> versaoDados;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore');
    return scope!;
  }

  /// Como [of], sem registrar dependência (pode ser usado em `initState`).
  static AppScope read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore');
    return scope!;
  }

  /// Recarrega todas as tabelas (depois de salvar, excluir ou importar).
  void dadosAlterados() {
    for (final TableController<Object?> t in [produtos, clientes, compras, consulta]) {
      if (t.carregou) t.recarregar();
    }
    versaoDados.value++;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => db != oldWidget.db;
}
