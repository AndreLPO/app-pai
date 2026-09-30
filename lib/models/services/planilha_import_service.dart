import 'dart:convert';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart';

import '../../core/cnpj.dart';
import '../../core/datas.dart';
import '../../core/money.dart';
import '../../core/text_normalize.dart';
import '../database/app_database.dart';
import 'planilha_layout.dart';

/// Dados de cliente lidos de uma linha.
class ClienteImportado {
  const ClienteImportado({
    required this.fantasia,
    this.razaoSocial,
    this.cnpj,
    this.inscEstadual,
    this.contato,
    this.ddd,
    this.telefone,
    this.cep,
    this.rua,
    this.bairro,
    this.cidade,
  });

  final String fantasia;
  final String? razaoSocial;

  /// Só dígitos.
  final String? cnpj;
  final String? inscEstadual;
  final String? contato;
  final String? ddd;
  final String? telefone;
  final String? cep;
  final String? rua;
  final String? bairro;
  final String? cidade;

  /// Identidade do cliente: CNPJ ou, sem CNPJ, Fantasia + Razão Social.
  String get chave => cnpj != null ? 'CNPJ:$cnpj' : 'NOME:$fantasia|${razaoSocial ?? ''}';

  /// Junta com uma linha posterior do mesmo cliente: valores preenchidos
  /// da linha nova prevalecem.
  ClienteImportado mesclar(ClienteImportado o) => ClienteImportado(
        fantasia: o.fantasia,
        razaoSocial: o.razaoSocial ?? razaoSocial,
        cnpj: o.cnpj ?? cnpj,
        inscEstadual: o.inscEstadual ?? inscEstadual,
        contato: o.contato ?? contato,
        ddd: o.ddd ?? ddd,
        telefone: o.telefone ?? telefone,
        cep: o.cep ?? cep,
        rua: o.rua ?? rua,
        bairro: o.bairro ?? bairro,
        cidade: o.cidade ?? cidade,
      );
}

/// Dados de compra lidos de uma linha.
class CompraImportada {
  const CompraImportada({
    required this.reduzido,
    required this.descricao,
    required this.data,
    required this.quantidade,
    required this.valorCentavos,
    this.sequencia,
  });

  final int reduzido;
  final String descricao;
  final DateTime data;
  final int quantidade;
  final int valorCentavos;
  final int? sequencia;
}

class LinhaImportada {
  const LinhaImportada(this.linha, this.cliente, this.compra);

  /// Número da linha no arquivo (1 = cabeçalho).
  final int linha;
  final ClienteImportado cliente;

  /// `null` para linha só de cliente.
  final CompraImportada? compra;
}

class Ocorrencia {
  const Ocorrencia(this.linha, this.mensagem);

  final int linha;
  final String mensagem;

  @override
  String toString() => 'Linha $linha: $mensagem';
}

/// Resultado da leitura do arquivo (sem acesso ao banco).
class LeituraPlanilha {
  const LeituraPlanilha({
    this.linhas = const [],
    this.rejeitadas = const [],
    this.avisos = const [],
    this.colunasAusentes = const [],
    this.erro,
  });

  final List<LinhaImportada> linhas;
  final List<Ocorrencia> rejeitadas;
  final List<Ocorrencia> avisos;
  final List<String> colunasAusentes;

  /// Erro que impede a importação (arquivo inválido, colunas ausentes).
  final String? erro;
}

/// O que a importação vai fazer, calculado antes de gravar.
class PlanoImportacao {
  const PlanoImportacao({
    required this.leitura,
    this.clientesNovos = 0,
    this.clientesAtualizados = 0,
    this.produtosNovos = 0,
    this.produtosAtualizados = 0,
    this.comprasNovas = 0,
    this.comprasDuplicadas = 0,
  });

  final LeituraPlanilha leitura;
  final int clientesNovos;
  final int clientesAtualizados;
  final int produtosNovos;
  final int produtosAtualizados;
  final int comprasNovas;
  final int comprasDuplicadas;

  String? get erro => leitura.erro;
  List<Ocorrencia> get rejeitadas => leitura.rejeitadas;
  List<Ocorrencia> get avisos => leitura.avisos;

  bool get podeAplicar => erro == null && leitura.linhas.isNotEmpty;
}

/// Importação de planilha `.xlsx` no layout de `DADOS.xlsx`, em duas fases:
/// [analisar] (lê, valida e planeja, sem gravar) e [aplicar] (grava tudo em
/// uma transação).
class PlanilhaImportService {
  PlanilhaImportService(this._db);

  final AppDatabase _db;

  Future<PlanoImportacao> analisar(List<int> bytes) async {
    final leitura = await Isolate.run(() => lerPlanilha(bytes));
    if (leitura.erro != null) return PlanoImportacao(leitura: leitura);
    return _planejar(leitura);
  }

  /// Simula a importação para contar o que será criado e atualizado.
  Future<PlanoImportacao> _planejar(LeituraPlanilha leitura) async {
    var clientesNovos = 0, clientesAtualizados = 0;
    var produtosNovos = 0, produtosAtualizados = 0;
    var comprasNovas = 0, comprasDuplicadas = 0;

    final clientes = _clientesPorChave(leitura);
    final idsClientes = <String, int?>{};
    for (final e in clientes.entries) {
      final existente = await _clienteExistente(e.value);
      idsClientes[e.key] = existente?.id;
      if (existente == null) {
        clientesNovos++;
      } else if (_clienteAtualizado(existente, e.value) != existente) {
        clientesAtualizados++;
      }
    }

    final produtos = _produtosPorReduzido(leitura);
    final idsProdutos = <int, int?>{};
    for (final p in produtos.values) {
      final existente = await _db.produtosDao.porReduzido(p.reduzido);
      idsProdutos[p.reduzido] = existente?.id;
      if (existente == null) {
        produtosNovos++;
      } else if (existente.descricao != p.descricao) {
        produtosAtualizados++;
      }
    }

    final vistas = <String>{};
    for (final l in leitura.linhas) {
      final c = l.compra;
      if (c == null) continue;
      final clienteId = idsClientes[l.cliente.chave];
      final produtoId = idsProdutos[c.reduzido];
      final chave = '${l.cliente.chave}|${c.reduzido}|${formatarDataIso(c.data)}|'
          '${c.sequencia}|${c.quantidade}';
      final duplicada = !vistas.add(chave) ||
          (clienteId != null &&
              produtoId != null &&
              await _db.comprasDao.existeDuplicata(
                clienteId: clienteId,
                produtoId: produtoId,
                data: c.data,
                sequencia: c.sequencia,
                quantidade: c.quantidade,
              ));
      duplicada ? comprasDuplicadas++ : comprasNovas++;
    }

    return PlanoImportacao(
      leitura: leitura,
      clientesNovos: clientesNovos,
      clientesAtualizados: clientesAtualizados,
      produtosNovos: produtosNovos,
      produtosAtualizados: produtosAtualizados,
      comprasNovas: comprasNovas,
      comprasDuplicadas: comprasDuplicadas,
    );
  }

  /// Grava o plano em uma única transação: se algo falhar, nada é gravado.
  Future<void> aplicar(PlanoImportacao plano) async {
    if (!plano.podeAplicar) return;
    final leitura = plano.leitura;
    await _db.transaction(() async {
      final idsClientes = <String, int>{};
      for (final e in _clientesPorChave(leitura).entries) {
        final existente = await _clienteExistente(e.value);
        if (existente == null) {
          idsClientes[e.key] = await _db.clientesDao.inserir(_novoCliente(e.value));
        } else {
          final atualizado = _clienteAtualizado(existente, e.value);
          if (atualizado != existente) await _db.clientesDao.atualizar(atualizado);
          idsClientes[e.key] = existente.id;
        }
      }

      final idsProdutos = <int, int>{};
      for (final p in _produtosPorReduzido(leitura).values) {
        final existente = await _db.produtosDao.porReduzido(p.reduzido);
        if (existente == null) {
          idsProdutos[p.reduzido] = await _db.produtosDao.inserir(
            ProdutosCompanion.insert(
              reduzido: p.reduzido,
              descricao: p.descricao,
              precoPadraoCentavos: p.valorCentavos,
            ),
          );
        } else {
          // Preço padrão existente é mantido.
          if (existente.descricao != p.descricao) {
            await _db.produtosDao.atualizar(existente.copyWith(descricao: p.descricao));
          }
          idsProdutos[p.reduzido] = existente.id;
        }
      }

      for (final l in leitura.linhas) {
        final c = l.compra;
        if (c == null) continue;
        final clienteId = idsClientes[l.cliente.chave]!;
        final produtoId = idsProdutos[c.reduzido]!;
        final duplicada = await _db.comprasDao.existeDuplicata(
          clienteId: clienteId,
          produtoId: produtoId,
          data: c.data,
          sequencia: c.sequencia,
          quantidade: c.quantidade,
        );
        if (duplicada) continue;
        await _db.comprasDao.inserir(ComprasCompanion.insert(
          clienteId: clienteId,
          produtoId: produtoId,
          data: c.data,
          quantidade: c.quantidade,
          valorUnitarioCentavos: c.valorCentavos,
          sequencia: Value(c.sequencia),
        ));
      }
    });
  }

  static Map<String, ClienteImportado> _clientesPorChave(LeituraPlanilha leitura) {
    final mapa = <String, ClienteImportado>{};
    for (final l in leitura.linhas) {
      final atual = mapa[l.cliente.chave];
      mapa[l.cliente.chave] = atual == null ? l.cliente : atual.mesclar(l.cliente);
    }
    return mapa;
  }

  /// Um produto por RED, com a descrição e o valor da linha mais recente.
  static Map<int, CompraImportada> _produtosPorReduzido(LeituraPlanilha leitura) {
    final mapa = <int, CompraImportada>{};
    for (final l in leitura.linhas) {
      final c = l.compra;
      if (c == null) continue;
      final atual = mapa[c.reduzido];
      if (atual == null || !c.data.isBefore(atual.data)) mapa[c.reduzido] = c;
    }
    return mapa;
  }

  Future<Cliente?> _clienteExistente(ClienteImportado c) async {
    if (c.cnpj != null) return _db.clientesDao.porCnpj(c.cnpj!);
    final q = _db.select(_db.clientes)
      ..where((t) => t.fantasia.equals(c.fantasia))
      ..where((t) => c.razaoSocial == null
          ? t.razaoSocial.isNull()
          : t.razaoSocial.equals(c.razaoSocial!))
      ..orderBy([(t) => OrderingTerm.asc(t.id)])
      ..limit(1);
    return q.getSingleOrNull();
  }

  static ClientesCompanion _novoCliente(ClienteImportado c) => ClientesCompanion.insert(
        fantasia: c.fantasia,
        razaoSocial: Value(c.razaoSocial),
        cnpj: Value(c.cnpj),
        inscEstadual: Value(c.inscEstadual),
        contato: Value(c.contato),
        ddd: Value(c.ddd),
        telefone: Value(c.telefone),
        cep: Value(c.cep),
        rua: Value(c.rua),
        bairro: Value(c.bairro),
        cidade: Value(c.cidade),
      );

  /// Cliente existente com os campos preenchidos no arquivo.
  static Cliente _clienteAtualizado(Cliente e, ClienteImportado c) => e.copyWith(
        fantasia: c.fantasia,
        razaoSocial: Value(c.razaoSocial ?? e.razaoSocial),
        cnpj: Value(c.cnpj ?? e.cnpj),
        inscEstadual: Value(c.inscEstadual ?? e.inscEstadual),
        contato: Value(c.contato ?? e.contato),
        ddd: Value(c.ddd ?? e.ddd),
        telefone: Value(c.telefone ?? e.telefone),
        cep: Value(c.cep ?? e.cep),
        rua: Value(c.rua ?? e.rua),
        bairro: Value(c.bairro ?? e.bairro),
        cidade: Value(c.cidade ?? e.cidade),
      );
}

/// Lê e valida a primeira aba do arquivo. Função pura (roda em isolate).
LeituraPlanilha lerPlanilha(List<int> bytes) {
  final Excel excel;
  try {
    excel = Excel.decodeBytes(corrigirCaminhosAbsolutos(bytes));
  } catch (_) {
    return const LeituraPlanilha(erro: 'Arquivo inválido: use uma planilha .xlsx');
  }
  final tabelas = excel.tables;
  if (tabelas.isEmpty) return const LeituraPlanilha(erro: 'A planilha está vazia');
  final nomeAba = excel.getDefaultSheet() ?? tabelas.keys.first;
  final rows = (tabelas[nomeAba] ?? tabelas.values.first).rows;
  if (rows.isEmpty) return const LeituraPlanilha(erro: 'A planilha está vazia');

  // Localiza as colunas pelo cabeçalho normalizado.
  final indices = <ColunaPlanilha, int>{};
  final cabecalho = rows.first;
  for (var i = 0; i < cabecalho.length; i++) {
    final texto = _texto(cabecalho[i]?.value);
    if (texto == null) continue;
    final chave = ColunaPlanilha.normalizarCabecalho(texto);
    for (final c in ColunaPlanilha.values) {
      if (c.chave == chave) indices.putIfAbsent(c, () => i);
    }
  }
  final ausentes = [
    for (final c in ColunaPlanilha.values)
      if (!indices.containsKey(c)) c.cabecalho,
  ];
  if (ausentes.isNotEmpty) {
    return LeituraPlanilha(
      colunasAusentes: ausentes,
      erro: 'Colunas ausentes: ${ausentes.join(', ')}',
    );
  }

  final linhas = <LinhaImportada>[];
  final rejeitadas = <Ocorrencia>[];
  final avisos = <Ocorrencia>[];

  for (var r = 1; r < rows.length; r++) {
    final row = rows[r];
    final numero = r + 1;
    CellValue? cel(ColunaPlanilha c) {
      final i = indices[c]!;
      return i < row.length ? row[i]?.value : null;
    }

    String? txt(ColunaPlanilha c) => maiusculasOuNulo(_texto(cel(c)));

    if (ColunaPlanilha.values.every((c) => txt(c) == null)) continue;

    final motivos = <String>[];
    final fantasia = txt(ColunaPlanilha.fantasia);
    if (fantasia == null) motivos.add('FANTASIA ausente');

    // CNPJ: guardado só com dígitos; inválido gera aviso, não rejeição.
    String? cnpj;
    final cnpjTexto = txt(ColunaPlanilha.cnpj);
    if (cnpjTexto != null) {
      cnpj = Cnpj.limpar(cnpjTexto);
      if (cnpj.isEmpty) {
        cnpj = null;
        avisos.add(Ocorrencia(numero, 'CNPJ "$cnpjTexto" ignorado'));
      } else if (!Cnpj.isValido(cnpj)) {
        avisos.add(Ocorrencia(numero, 'CNPJ inválido (${Cnpj.formatar(cnpj)})'));
      }
    }

    // DDD e ZAP: se DDD tem mais de 2 dígitos e ZAP está vazio, o valor
    // é o telefone.
    var ddd = txt(ColunaPlanilha.ddd);
    var telefone = txt(ColunaPlanilha.zap);
    if (ddd != null && telefone == null && Cnpj.limpar(ddd).length > 2) {
      telefone = ddd;
      ddd = null;
    }

    // Compra: linha só de cliente quando PRODUTO, RED, QTDE e VALOR vazios.
    CompraImportada? compra;
    final temCompra = [
      ColunaPlanilha.produto,
      ColunaPlanilha.red,
      ColunaPlanilha.qtde,
      ColunaPlanilha.valor,
    ].any((c) => txt(c) != null);
    if (temCompra) {
      final descricao = txt(ColunaPlanilha.produto);
      final reduzido = _inteiro(cel(ColunaPlanilha.red));
      final quantidade = _inteiro(cel(ColunaPlanilha.qtde));
      final valor = _numero(cel(ColunaPlanilha.valor));
      final data = _data(cel(ColunaPlanilha.data));
      final seqTexto = txt(ColunaPlanilha.sequencia);
      final sequencia = _inteiro(cel(ColunaPlanilha.sequencia));

      if (txt(ColunaPlanilha.red) == null) {
        motivos.add('RED ausente');
      } else if (reduzido == null || reduzido <= 0) {
        motivos.add('RED inválido');
      }
      if (descricao == null) motivos.add('PRODUTO ausente');
      if (quantidade == null || quantidade <= 0) motivos.add('QTDE inválida');
      if (data == null) motivos.add('DATA inválida');
      if (valor == null || valor < 0) motivos.add('VALOR inválido');
      if (seqTexto != null && (sequencia == null || sequencia <= 0)) {
        motivos.add('SEQUÊNC inválida');
      }

      if (motivos.isEmpty) {
        compra = CompraImportada(
          reduzido: reduzido!,
          descricao: descricao!,
          data: data!,
          quantidade: quantidade!,
          valorCentavos: Money.fromDouble(valor!.toDouble()),
          sequencia: sequencia,
        );
      }
    }

    if (motivos.isNotEmpty) {
      rejeitadas.add(Ocorrencia(numero, motivos.join(', ')));
      continue;
    }

    linhas.add(LinhaImportada(
      numero,
      ClienteImportado(
        fantasia: fantasia!,
        razaoSocial: txt(ColunaPlanilha.razaoSocial),
        cnpj: cnpj,
        inscEstadual: txt(ColunaPlanilha.inscEstadual),
        contato: txt(ColunaPlanilha.contato),
        ddd: ddd,
        telefone: telefone,
        cep: txt(ColunaPlanilha.cep),
        rua: txt(ColunaPlanilha.rua),
        bairro: txt(ColunaPlanilha.bairro),
        cidade: txt(ColunaPlanilha.cidade),
      ),
      compra,
    ));
  }

  return LeituraPlanilha(linhas: linhas, rejeitadas: rejeitadas, avisos: avisos);
}

/// Alguns geradores de `.xlsx` (como o de `DADOS.xlsx`) gravam os caminhos
/// das abas como absolutos (`/xl/worksheets/sheet1.xml`), o que o pacote
/// `excel` não resolve. Reescreve-os como relativos antes da leitura.
List<int> corrigirCaminhosAbsolutos(List<int> bytes) {
  final Archive arquivo;
  try {
    arquivo = ZipDecoder().decodeBytes(bytes);
  } catch (_) {
    return bytes;
  }
  const nomeRels = 'xl/_rels/workbook.xml.rels';
  final rels = arquivo.findFile(nomeRels);
  if (rels == null) return bytes;
  final texto = utf8.decode(rels.content as List<int>);
  if (!texto.contains('Target="/xl/')) return bytes;

  final corrigido = utf8.encode(texto.replaceAll('Target="/xl/', 'Target="'));
  final saida = Archive();
  for (final f in arquivo.files) {
    saida.addFile(f.name == nomeRels
        ? ArchiveFile(nomeRels, corrigido.length, corrigido)
        : ArchiveFile(f.name, f.size, f.content));
  }
  return ZipEncoder().encode(saida) ?? bytes;
}

String? _texto(CellValue? v) {
  final t = switch (v) {
    null => null,
    TextCellValue() => v.value.toString(),
    IntCellValue() => '${v.value}',
    DoubleCellValue() =>
      v.value == v.value.roundToDouble() ? '${v.value.toInt()}' : '${v.value}',
    DateCellValue() => formatarData(DateTime(v.year, v.month, v.day)),
    DateTimeCellValue() => formatarData(DateTime(v.year, v.month, v.day)),
    FormulaCellValue() => null,
    _ => v.toString(),
  };
  final s = t?.trim();
  return s == null || s.isEmpty ? null : s;
}

num? _numero(CellValue? v) => switch (v) {
      IntCellValue() => v.value,
      DoubleCellValue() => v.value,
      TextCellValue() => _numeroDeTexto(_texto(v)),
      _ => null,
    };

num? _numeroDeTexto(String? t) {
  if (t == null) return null;
  final centavos = Money.parse(t);
  return centavos == null ? null : centavos / 100;
}

int? _inteiro(CellValue? v) {
  final n = switch (v) {
    IntCellValue() => v.value,
    DoubleCellValue() => v.value,
    TextCellValue() => int.tryParse((_texto(v) ?? '').replaceAll('.', '')),
    _ => null,
  };
  if (n == null || n != n.roundToDouble()) return null;
  return n.toInt();
}

DateTime? _data(CellValue? v) => switch (v) {
      DateCellValue() => DateTime(v.year, v.month, v.day),
      DateTimeCellValue() => DateTime(v.year, v.month, v.day),
      IntCellValue() => v.value > 0 ? dataDeSerialExcel(v.value) : null,
      DoubleCellValue() => v.value > 0 ? dataDeSerialExcel(v.value) : null,
      TextCellValue() => parseData(_texto(v) ?? ''),
      _ => null,
    };
