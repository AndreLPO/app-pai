import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../core/cnpj.dart';
import '../core/datas.dart';
import '../core/text_normalize.dart';
import '../models/database/app_database.dart';
import '../models/database/daos/compras_dao.dart';

/// Base dos formulários: flag de alterações não salvas e de gravação.
abstract class FormController extends ChangeNotifier {
  bool _sujo = false;
  bool get sujo => _sujo;

  bool _salvando = false;
  bool get salvando => _salvando;

  void marcarAlterado() {
    if (_sujo) return;
    _sujo = true;
    notifyListeners();
  }

  /// Executa uma gravação marcando [salvando]; limpa [sujo] se der certo.
  @protected
  Future<R> gravando<R>(Future<R> Function() acao, {bool Function(R)? sucesso}) async {
    _salvando = true;
    notifyListeners();
    try {
      final r = await acao();
      if (sucesso?.call(r) ?? true) _sujo = false;
      return r;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }

  String mensagemCompras(int n) => n == 1
      ? 'Não é possível excluir: existe 1 compra vinculada'
      : 'Não é possível excluir: existem $n compras vinculadas';
}

/// Erros de validação por campo (vazio = salvo).
typedef ErrosCampos = Map<String, String>;

class ProdutoFormController extends FormController {
  ProdutoFormController(this._db, {this.original});

  final AppDatabase _db;
  final Produto? original;

  bool get novo => original == null;

  Future<ErrosCampos> salvar({
    required int reduzido,
    required String descricao,
    required int precoCentavos,
  }) =>
      gravando(() async {
        final dao = _db.produtosDao;
        final outro = await dao.porReduzido(reduzido, excetoId: original?.id);
        if (outro != null) {
          return {'reduzido': 'Código já usado por "${outro.descricao}"'};
        }
        final desc = descricao.trim().toUpperCase();
        if (original == null) {
          await dao.inserir(ProdutosCompanion.insert(
            reduzido: reduzido,
            descricao: desc,
            precoPadraoCentavos: precoCentavos,
          ));
        } else {
          await dao.atualizar(original!.copyWith(
            reduzido: reduzido,
            descricao: desc,
            precoPadraoCentavos: precoCentavos,
          ));
        }
        return <String, String>{};
      }, sucesso: (e) => e.isEmpty);

  /// Exclui o produto. Retorna a mensagem de erro, se não puder.
  Future<String?> excluir() => gravando(() async {
        final n = await _db.produtosDao.contarCompras(original!.id);
        if (n > 0) return mensagemCompras(n);
        await _db.produtosDao.excluir(original!.id);
        return null;
      }, sucesso: (e) => e == null);
}

/// Campos editáveis do cliente, como digitados.
class DadosCliente {
  const DadosCliente({
    required this.fantasia,
    this.razaoSocial = '',
    this.cnpj = '',
    this.inscEstadual = '',
    this.contato = '',
    this.ddd = '',
    this.telefone = '',
    this.cep = '',
    this.rua = '',
    this.bairro = '',
    this.cidade = '',
  });

  final String fantasia;
  final String razaoSocial;
  final String cnpj;
  final String inscEstadual;
  final String contato;
  final String ddd;
  final String telefone;
  final String cep;
  final String rua;
  final String bairro;
  final String cidade;
}

class ClienteFormController extends FormController {
  ClienteFormController(this._db, {this.original});

  final AppDatabase _db;
  Cliente? original;

  bool get novo => original == null;

  List<({Compra compra, Produto produto})> _historico = const [];
  List<({Compra compra, Produto produto})> get historico => _historico;

  Future<void> carregarHistorico() async {
    if (original == null) return;
    _historico = await _db.clientesDao.historico(original!.id);
    notifyListeners();
  }

  static String? validarCnpj(String texto) {
    if (Cnpj.limpar(texto).isEmpty) return null;
    return Cnpj.isValido(texto) ? null : 'CNPJ inválido';
  }

  Future<ErrosCampos> salvar(DadosCliente d) => gravando(() async {
        final dao = _db.clientesDao;
        final fantasia = maiusculasOuNulo(d.fantasia);
        if (fantasia == null) return {'fantasia': 'Informe o Nome Fantasia'};
        final cnpj = Cnpj.limpar(d.cnpj);
        if (cnpj.isNotEmpty) {
          final erro = validarCnpj(cnpj);
          if (erro != null) return {'cnpj': erro};
          final outro = await dao.porCnpj(cnpj, excetoId: original?.id);
          if (outro != null) return {'cnpj': 'CNPJ já usado por "${outro.fantasia}"'};
        }
        String? t(String v) => maiusculasOuNulo(v);
        final companion = ClientesCompanion(
          fantasia: Value(fantasia),
          razaoSocial: Value(t(d.razaoSocial)),
          cnpj: Value(cnpj.isEmpty ? null : cnpj),
          inscEstadual: Value(t(d.inscEstadual)),
          contato: Value(t(d.contato)),
          ddd: Value(t(d.ddd)),
          telefone: Value(t(d.telefone)),
          cep: Value(t(d.cep)),
          rua: Value(t(d.rua)),
          bairro: Value(t(d.bairro)),
          cidade: Value(t(d.cidade)),
        );
        if (original == null) {
          final id = await dao.inserir(companion);
          original = await dao.porId(id);
        } else {
          await dao.atualizar(original!.copyWithCompanion(companion));
          original = await dao.porId(original!.id);
        }
        return <String, String>{};
      }, sucesso: (e) => e.isEmpty);

  Future<String?> excluir() => gravando(() async {
        final n = await _db.clientesDao.contarCompras(original!.id);
        if (n > 0) return mensagemCompras(n);
        await _db.clientesDao.excluir(original!.id);
        return null;
      }, sucesso: (e) => e == null);
}

class CompraFormController extends FormController {
  CompraFormController(this._db, {CompraCompleta? original, Cliente? cliente})
      : _original = original,
        _cliente = original?.cliente ?? cliente,
        _produto = original?.produto,
        _data = original?.compra.data ?? soData(_db.relogio());

  final AppDatabase _db;
  final CompraCompleta? _original;

  bool get novo => _original == null;

  Cliente? _cliente;
  Cliente? get cliente => _cliente;

  Produto? _produto;
  Produto? get produto => _produto;

  DateTime _data;
  DateTime get data => _data;

  Future<List<Cliente>> buscarClientes(String texto) => _db.clientesDao.sugestoes(texto);

  Future<List<Produto>> buscarProdutos(String texto) => _db.produtosDao.sugestoes(texto);

  void selecionarCliente(Cliente? c) {
    if (c?.id == _cliente?.id) return;
    _cliente = c;
    marcarAlterado();
    notifyListeners();
  }

  /// Seleciona o produto e devolve o preço sugerido (o preço padrão dele),
  /// que substitui o Valor Unitário digitado.
  int? selecionarProduto(Produto? p) {
    _produto = p;
    marcarAlterado();
    notifyListeners();
    return p?.precoPadraoCentavos;
  }

  void definirData(DateTime d) {
    _data = soData(d);
    marcarAlterado();
    notifyListeners();
  }

  Future<ErrosCampos> salvar({
    required int? quantidade,
    required int? valorUnitarioCentavos,
    required int? sequencia,
  }) =>
      gravando(() async {
        final erros = <String, String>{
          if (_cliente == null) 'cliente': 'Selecione o cliente',
          if (_produto == null) 'produto': 'Selecione o produto',
          if (quantidade == null || quantidade <= 0)
            'quantidade': 'A quantidade deve ser maior que zero',
          if (valorUnitarioCentavos == null || valorUnitarioCentavos < 0)
            'valorUnitario': 'Informe o valor unitário',
          if (sequencia != null && sequencia <= 0)
            'sequencia': 'A sequência deve ser um número positivo',
        };
        if (erros.isNotEmpty) return erros;
        final dao = _db.comprasDao;
        if (_original == null) {
          await dao.inserir(ComprasCompanion.insert(
            clienteId: _cliente!.id,
            produtoId: _produto!.id,
            data: _data,
            quantidade: quantidade!,
            valorUnitarioCentavos: valorUnitarioCentavos!,
            sequencia: Value(sequencia),
          ));
        } else {
          await dao.atualizar(_original.compra.copyWith(
            clienteId: _cliente!.id,
            produtoId: _produto!.id,
            data: _data,
            quantidade: quantidade!,
            valorUnitarioCentavos: valorUnitarioCentavos!,
            sequencia: Value(sequencia),
          ));
        }
        return erros;
      }, sucesso: (e) => e.isEmpty);

  Future<void> excluir() => gravando(() => _db.comprasDao.excluir(_original!.compra.id));
}
