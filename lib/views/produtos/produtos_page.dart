import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_scope.dart';
import '../../controllers/form_controllers.dart';
import '../../core/formatters.dart';
import '../../core/money.dart';
import '../../models/database/app_database.dart';
import '../widgets/filtros.dart';
import '../widgets/formulario.dart';

class ProdutosPage extends StatelessWidget {
  const ProdutosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos')),
      body: TabelaCompleta<Produto>(
        controller: scope.produtos,
        aoTocarLinha: (p) => abrirFormulario(context, ProdutoFormPage(produto: p)),
        acoes: [
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Adicionar'),
            onPressed: () => abrirFormulario(context, const ProdutoFormPage()),
          ),
        ],
      ),
    );
  }
}

class ProdutoFormPage extends StatefulWidget {
  const ProdutoFormPage({super.key, this.produto});

  final Produto? produto;

  @override
  State<ProdutoFormPage> createState() => _ProdutoFormPageState();
}

class _ProdutoFormPageState extends State<ProdutoFormPage> {
  final _form = GlobalKey<FormState>();
  late final ProdutoFormController _c;
  late final _reduzido = TextEditingController(text: widget.produto?.reduzido.toString());
  late final _descricao = TextEditingController(text: widget.produto?.descricao);
  late final _preco = TextEditingController(
      text: widget.produto == null
          ? ''
          : Money.formatSemSimbolo(widget.produto!.precoPadraoCentavos));
  ErrosCampos _erros = const {};

  @override
  void initState() {
    super.initState();
    _c = ProdutoFormController(AppScope.read(context).db, original: widget.produto);
  }

  @override
  void dispose() {
    _c.dispose();
    _reduzido.dispose();
    _descricao.dispose();
    _preco.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() => _erros = const {});
    if (!_form.currentState!.validate()) return;
    final erros = await _c.salvar(
      reduzido: int.parse(_reduzido.text),
      descricao: _descricao.text,
      precoCentavos: Money.parse(_preco.text)!,
    );
    if (!mounted) return;
    if (erros.isNotEmpty) return setState(() => _erros = erros);
    Navigator.of(context).pop('Produto salvo');
  }

  @override
  Widget build(BuildContext context) => LayoutFormulario(
        titulo: _c.novo ? 'Novo produto' : 'Editar produto',
        controller: _c,
        aoSalvar: _salvar,
        aoExcluir: _c.novo
            ? null
            : () => excluirComConfirmacao(
                  context,
                  descricao: 'o produto "${widget.produto!.descricao}"',
                  excluir: _c.excluir,
                  mensagemSucesso: 'Produto excluído',
                ),
        children: [
          Form(
            key: _form,
            onChanged: _c.marcarAlterado,
            child: Column(
              children: [
                LinhaCampos(
                  flex: const [1, 3],
                  children: [
                    TextFormField(
                      key: const ValueKey('reduzido'),
                      controller: _reduzido,
                      autofocus: _c.novo,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          labelText: 'Código reduzido *', errorText: _erros['reduzido']),
                      validator: (v) {
                        final n = int.tryParse(v ?? '');
                        return n == null || n <= 0 ? 'Informe um código maior que zero' : null;
                      },
                    ),
                    TextFormField(
                      key: const ValueKey('descricao'),
                      controller: _descricao,
                      inputFormatters: const [MaiusculasFormatter()],
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Descrição *'),
                      validator: (v) =>
                          (v ?? '').trim().isEmpty ? 'Informe a descrição' : null,
                    ),
                  ],
                ),
                LinhaCampos(
                  children: [
                    TextFormField(
                      key: const ValueKey('preco'),
                      controller: _preco,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [MoedaFormatter()],
                      decoration: const InputDecoration(
                          labelText: 'Preço padrão *', prefixText: 'R\$ '),
                      validator: (v) {
                        final c = Money.parse(v ?? '');
                        return c == null || c < 0 ? 'Informe o preço' : null;
                      },
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
}
