import 'package:drift/drift.dart';

/// Guarda datas sem horário como inteiro `aaaammdd` (ex.: `20250911`).
///
/// Mantém ordenação e filtros por intervalo simples no SQL e agrupa por mês
/// com `data ~/ 100`, sem depender de fuso horário.
class DiaConverter extends TypeConverter<DateTime, int> {
  const DiaConverter();

  static int paraInt(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  static DateTime deInt(int v) => DateTime(v ~/ 10000, (v ~/ 100) % 100, v % 100);

  @override
  DateTime fromSql(int fromDb) => deInt(fromDb);

  @override
  int toSql(DateTime value) => paraInt(value);
}

@DataClassName('Cliente')
@TableIndex(name: 'idx_clientes_fantasia', columns: {#fantasia})
class Clientes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fantasia => text()();
  TextColumn get razaoSocial => text().nullable()();

  /// Só dígitos.
  TextColumn get cnpj => text().nullable().unique()();
  TextColumn get inscEstadual => text().nullable()();
  TextColumn get contato => text().nullable()();
  TextColumn get ddd => text().nullable()();
  TextColumn get telefone => text().nullable()();
  TextColumn get cep => text().nullable()();
  TextColumn get rua => text().nullable()();
  TextColumn get bairro => text().nullable()();
  TextColumn get cidade => text().nullable()();
  DateTimeColumn get criadoEm => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get atualizadoEm => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('Produto')
class Produtos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get reduzido => integer().unique()();
  TextColumn get descricao => text()();
  IntColumn get precoPadraoCentavos => integer()();
}

@DataClassName('Compra')
@TableIndex(name: 'idx_compras_data', columns: {#data})
@TableIndex(name: 'idx_compras_cliente', columns: {#clienteId})
@TableIndex(name: 'idx_compras_produto', columns: {#produtoId})
@TableIndex(
  name: 'idx_compras_duplicata',
  columns: {#clienteId, #produtoId, #data, #sequencia, #quantidade},
)
class Compras extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get clienteId =>
      integer().references(Clientes, #id, onDelete: KeyAction.restrict)();
  IntColumn get produtoId =>
      integer().references(Produtos, #id, onDelete: KeyAction.restrict)();
  IntColumn get data => integer().map(const DiaConverter())();
  IntColumn get quantidade =>
      // ignore: recursive_getters
      integer().check(quantidade.isBiggerThanValue(0))();
  IntColumn get valorUnitarioCentavos => integer()();
  IntColumn get sequencia => integer().nullable()();
}

@DataClassName('Configuracao')
class Configuracoes extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {chave};
}
