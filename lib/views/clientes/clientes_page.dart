import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_scope.dart';
import '../../controllers/form_controllers.dart';
import '../../core/cnpj.dart';
import '../../core/datas.dart';
import '../../core/formatters.dart';
import '../../core/money.dart';
import '../../models/database/app_database.dart';
import '../compras/compras_page.dart';
import '../widgets/filtros.dart';
import '../widgets/formulario.dart';

class ClientesPage extends StatelessWidget {
  const ClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: TabelaCompleta<Cliente>(
        controller: scope.clientes,
        fixarPrimeiraColuna: true,
        aoTocarLinha: (c) => abrirFormulario(context, ClienteFormPage(cliente: c)),
        acoes: [
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
            onPressed: () => abrirFormulario(context, const ClienteFormPage()),
          ),
        ],
      ),
    );
  }
}

class ClienteFormPage extends StatefulWidget {
  const ClienteFormPage({super.key, this.cliente});

  final Cliente? cliente;

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _form = GlobalKey<FormState>();
  late final ClienteFormController _c;
  late final Map<String, TextEditingController> _campos;
  ErrosCampos _erros = const {};

  @override
  void initState() {
    super.initState();
    _c = ClienteFormController(AppScope.read(context).db, original: widget.cliente)
      ..carregarHistorico();
    final c = widget.cliente;
    _campos = {
      'fantasia': TextEditingController(text: c?.fantasia),
      'razaoSocial': TextEditingController(text: c?.razaoSocial),
      'cnpj': TextEditingController(text: c?.cnpj == null ? null : Cnpj.formatar(c!.cnpj!)),
      'inscEstadual': TextEditingController(text: c?.inscEstadual),
      'contato': TextEditingController(text: c?.contato),
      'ddd': TextEditingController(text: c?.ddd),
      'telefone': TextEditingController(text: c?.telefone),
      'cep': TextEditingController(text: c?.cep),
      'rua': TextEditingController(text: c?.rua),
      'bairro': TextEditingController(text: c?.bairro),
      'cidade': TextEditingController(text: c?.cidade),
    };
  }

  @override
  void dispose() {
    _c.dispose();
    for (final c in _campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _v(String id) => _campos[id]!.text;

  Future<void> _salvar() async {
    setState(() => _erros = const {});
    if (!_form.currentState!.validate()) return;
    final erros = await _c.salvar(DadosCliente(
      fantasia: _v('fantasia'),
      razaoSocial: _v('razaoSocial'),
      cnpj: _v('cnpj'),
      inscEstadual: _v('inscEstadual'),
      contato: _v('contato'),
      ddd: _v('ddd'),
      telefone: _v('telefone'),
      cep: _v('cep'),
      rua: _v('rua'),
      bairro: _v('bairro'),
      cidade: _v('cidade'),
    ));
    if (!mounted) return;
    if (erros.isNotEmpty) return setState(() => _erros = erros);
    Navigator.of(context).pop('Cliente salvo');
  }

  Future<void> _novaCompra() async {
    await abrirFormulario(context, CompraFormPage(cliente: _c.original));
    await _c.carregarHistorico();
  }

  Widget _texto(
    String id,
    String rotulo, {
    String? Function(String?)? validator,
    List<TextInputFormatter> formatters = const [MaiusculasFormatter()],
    TextInputType? teclado,
    bool autofocus = false,
  }) =>
      TextFormField(
        key: ValueKey(id),
        controller: _campos[id],
        autofocus: autofocus,
        keyboardType: teclado,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: formatters,
        validator: validator,
        decoration: InputDecoration(labelText: rotulo, errorText: _erros[id]),
      );

  @override
  Widget build(BuildContext context) {
    final existente = widget.cliente != null;
    return LayoutFormulario(
      titulo: existente ? 'Editar cliente' : 'Novo cliente',
      controller: _c,
      aoSalvar: _salvar,
      aoExcluir: existente
          ? () => excluirComConfirmacao(
                context,
                descricao: 'o cliente "${widget.cliente!.fantasia}"',
                excluir: _c.excluir,
                mensagemSucesso: 'Cliente excluído',
              )
          : null,
      children: [
        Form(
          key: _form,
          onChanged: _c.marcarAlterado,
          child: Column(
            children: [
              LinhaCampos(children: [
                _texto('fantasia', 'Nome Fantasia *',
                    autofocus: !existente,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Informe o Nome Fantasia' : null),
                _texto('razaoSocial', 'Razão Social'),
              ]),
              LinhaCampos(children: [
                _texto('cnpj', 'CNPJ',
                    teclado: TextInputType.number,
                    formatters: const [cnpjFormatter],
                    validator: (v) => ClienteFormController.validarCnpj(v ?? '')),
                _texto('inscEstadual', 'Inscrição Estadual'),
              ]),
              LinhaCampos(flex: const [3, 1, 2], children: [
                _texto('contato', 'Contato'),
                _texto('ddd', 'DDD',
                    teclado: TextInputType.number,
                    formatters: dddFormatters,
                    validator: (v) => (v ?? '').isEmpty || v!.length == 2
                        ? null
                        : 'DDD com 2 dígitos'),
                _texto('telefone', 'WhatsApp/Telefone',
                    teclado: TextInputType.phone,
                    formatters: const [TelefoneFormatter()]),
              ]),
              LinhaCampos(flex: const [1, 3], children: [
                _texto('cep', 'CEP',
                    teclado: TextInputType.number, formatters: const [cepFormatter]),
                _texto('rua', 'Rua e número'),
              ]),
              LinhaCampos(children: [
                _texto('bairro', 'Bairro'),
                _texto('cidade', 'Cidade'),
              ]),
            ],
          ),
        ),
        if (existente) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Compras', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Nova compra'),
                onPressed: _novaCompra,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListenableBuilder(
            listenable: _c,
            builder: (context, _) => _HistoricoCompras(_c.historico, _c.carregarHistorico),
          ),
        ],
      ],
    );
  }
}

class _HistoricoCompras extends StatelessWidget {
  const _HistoricoCompras(this.compras, this.aoAlterar);

  final List<({Compra compra, Produto produto})> compras;
  final Future<void> Function() aoAlterar;

  @override
  Widget build(BuildContext context) {
    if (compras.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Nenhuma compra registrada'),
      );
    }
    final negrito = Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold);
    return Card(
      child: Column(
        children: [
          ListTile(
            dense: true,
            title: Row(children: [
              Expanded(flex: 2, child: Text('Data', style: negrito)),
              Expanded(flex: 5, child: Text('Produto', style: negrito)),
              Expanded(flex: 2, child: Text('Qtde', textAlign: TextAlign.right, style: negrito)),
              Expanded(
                  flex: 3, child: Text('Valor Total', textAlign: TextAlign.right, style: negrito)),
            ]),
          ),
          const Divider(height: 1),
          for (final e in compras)
            ListTile(
              dense: true,
              onTap: () async {
                final completa = await AppScope.read(context).db.comprasDao.porId(e.compra.id);
                if (completa != null && context.mounted) {
                  await abrirFormulario(context, CompraFormPage(compra: completa));
                  await aoAlterar();
                }
              },
              title: Row(children: [
                Expanded(flex: 2, child: Text(formatarData(e.compra.data))),
                Expanded(flex: 5, child: Text('${e.produto.reduzido} - ${e.produto.descricao}')),
                Expanded(
                    flex: 2,
                    child: Text(formatInteiro(e.compra.quantidade), textAlign: TextAlign.right)),
                Expanded(
                    flex: 3,
                    child: Text(
                        Money.format(e.compra.quantidade * e.compra.valorUnitarioCentavos),
                        textAlign: TextAlign.right)),
              ]),
            ),
        ],
      ),
    );
  }
}
