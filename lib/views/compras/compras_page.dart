import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_scope.dart';
import '../../controllers/form_controllers.dart';
import '../../core/cnpj.dart';
import '../../core/datas.dart';
import '../../core/formatters.dart';
import '../../core/money.dart';
import '../../models/database/app_database.dart';
import '../../models/database/daos/compras_dao.dart';
import '../widgets/campo_busca.dart';
import '../widgets/filtros.dart';
import '../widgets/formulario.dart';

class ComprasPage extends StatelessWidget {
  const ComprasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Compras')),
      body: TabelaCompleta<CompraCompleta>(
        controller: scope.compras,
        aoTocarLinha: (c) => abrirFormulario(context, CompraFormPage(compra: c)),
        acoes: [
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
            onPressed: () => abrirFormulario(context, const CompraFormPage()),
          ),
        ],
      ),
    );
  }
}

/// Abre a compra de id [compraId] (ex.: a partir da Consulta Geral).
Future<void> abrirCompraPorId(BuildContext context, int compraId) async {
  final compra = await AppScope.read(context).db.comprasDao.porId(compraId);
  if (compra != null && context.mounted) {
    await abrirFormulario(context, CompraFormPage(compra: compra));
  }
}

class CompraFormPage extends StatefulWidget {
  const CompraFormPage({super.key, this.compra, this.cliente});

  /// Compra a editar (nula para nova).
  final CompraCompleta? compra;

  /// Cliente pré-selecionado em uma compra nova.
  final Cliente? cliente;

  @override
  State<CompraFormPage> createState() => _CompraFormPageState();
}

class _CompraFormPageState extends State<CompraFormPage> {
  late final CompraFormController _c;
  late final _quantidade =
      TextEditingController(text: widget.compra?.compra.quantidade.toString());
  late final _valor = TextEditingController(
      text: widget.compra == null
          ? ''
          : Money.formatSemSimbolo(widget.compra!.compra.valorUnitarioCentavos));
  late final _sequencia =
      TextEditingController(text: widget.compra?.compra.sequencia?.toString());
  ErrosCampos _erros = const {};

  @override
  void initState() {
    super.initState();
    _c = CompraFormController(
      AppScope.read(context).db,
      original: widget.compra,
      cliente: widget.cliente,
    );
  }

  @override
  void dispose() {
    _c.dispose();
    _quantidade.dispose();
    _valor.dispose();
    _sequencia.dispose();
    super.dispose();
  }

  int? get _totalCentavos {
    final q = int.tryParse(_quantidade.text);
    final v = Money.parse(_valor.text);
    return q == null || v == null ? null : q * v;
  }

  Future<void> _salvar() async {
    final erros = await _c.salvar(
      quantidade: int.tryParse(_quantidade.text),
      valorUnitarioCentavos: Money.parse(_valor.text),
      sequencia: _sequencia.text.isEmpty ? null : int.tryParse(_sequencia.text),
    );
    if (!mounted) return;
    if (erros.isNotEmpty) return setState(() => _erros = erros);
    Navigator.of(context).pop('Compra salva');
  }

  Future<void> _escolherData() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _c.data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) _c.definirData(d);
  }

  static String _exibirCliente(Cliente c) =>
      c.cnpj == null ? c.fantasia : '${c.fantasia} (${Cnpj.formatar(c.cnpj!)})';

  static String _exibirProduto(Produto p) => '${p.reduzido} - ${p.descricao}';

  @override
  Widget build(BuildContext context) => LayoutFormulario(
        titulo: _c.novo ? 'Nova compra' : 'Editar compra',
        controller: _c,
        aoSalvar: _salvar,
        aoExcluir: _c.novo
            ? null
            : () => excluirComConfirmacao(
                  context,
                  descricao: 'esta compra',
                  excluir: () async {
                    await _c.excluir();
                    return null;
                  },
                  mensagemSucesso: 'Compra excluída',
                ),
        children: [
          ListenableBuilder(
            listenable: _c,
            builder: (context, _) => Column(
              children: [
                LinhaCampos(children: [
                  CampoBusca<Cliente>(
                    key: const ValueKey('cliente'),
                    rotulo: 'Cliente *',
                    valor: _c.cliente,
                    exibir: _exibirCliente,
                    buscar: _c.buscarClientes,
                    aoSelecionar: _c.selecionarCliente,
                    aoLimpar: () => _c.selecionarCliente(null),
                    erro: _erros['cliente'],
                    autofocus: _c.novo && _c.cliente == null,
                  ),
                ]),
                LinhaCampos(flex: const [3, 1], children: [
                  CampoBusca<Produto>(
                    key: const ValueKey('produto'),
                    rotulo: 'Produto *',
                    valor: _c.produto,
                    exibir: _exibirProduto,
                    buscar: _c.buscarProdutos,
                    aoSelecionar: (p) {
                      final preco = _c.selecionarProduto(p);
                      if (preco != null) _valor.text = Money.formatSemSimbolo(preco);
                    },
                    aoLimpar: () => _c.selecionarProduto(null),
                    erro: _erros['produto'],
                  ),
                  InkWell(
                    key: const ValueKey('data'),
                    onTap: _escolherData,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                          labelText: 'Data *', suffixIcon: Icon(Icons.calendar_today)),
                      child: Text(formatarData(_c.data)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          LinhaCampos(children: [
            TextField(
              key: const ValueKey('quantidade'),
              controller: _quantidade,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _c.marcarAlterado(),
              decoration: InputDecoration(
                  labelText: 'Quantidade (unidades) *', errorText: _erros['quantidade']),
            ),
            TextField(
              key: const ValueKey('valorUnitario'),
              controller: _valor,
              keyboardType: TextInputType.number,
              inputFormatters: const [MoedaFormatter()],
              onChanged: (_) => _c.marcarAlterado(),
              decoration: InputDecoration(
                labelText: 'Valor unitário *',
                prefixText: 'R\$ ',
                errorText: _erros['valorUnitario'],
                helperText: _c.produto == null
                    ? null
                    : 'Preço padrão: ${Money.format(_c.produto!.precoPadraoCentavos)}',
              ),
            ),
            ListenableBuilder(
              listenable: Listenable.merge([_quantidade, _valor]),
              builder: (context, _) => InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Valor total',
                  filled: true,
                  enabled: false,
                ),
                child: Text(
                  _totalCentavos == null ? '—' : Money.format(_totalCentavos!),
                  key: const ValueKey('valorTotal'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ]),
          LinhaCampos(children: [
            TextField(
              key: const ValueKey('sequencia'),
              controller: _sequencia,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _c.marcarAlterado(),
              decoration: InputDecoration(
                  labelText: 'Sequência do pedido', errorText: _erros['sequencia']),
            ),
            const SizedBox.shrink(),
            const SizedBox.shrink(),
          ]),
        ],
      );
}
