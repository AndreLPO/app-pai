// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientesTable extends Clientes with TableInfo<$ClientesTable, Cliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fantasiaMeta = const VerificationMeta(
    'fantasia',
  );
  @override
  late final GeneratedColumn<String> fantasia = GeneratedColumn<String>(
    'fantasia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _razaoSocialMeta = const VerificationMeta(
    'razaoSocial',
  );
  @override
  late final GeneratedColumn<String> razaoSocial = GeneratedColumn<String>(
    'razao_social',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cnpjMeta = const VerificationMeta('cnpj');
  @override
  late final GeneratedColumn<String> cnpj = GeneratedColumn<String>(
    'cnpj',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _inscEstadualMeta = const VerificationMeta(
    'inscEstadual',
  );
  @override
  late final GeneratedColumn<String> inscEstadual = GeneratedColumn<String>(
    'insc_estadual',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contatoMeta = const VerificationMeta(
    'contato',
  );
  @override
  late final GeneratedColumn<String> contato = GeneratedColumn<String>(
    'contato',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dddMeta = const VerificationMeta('ddd');
  @override
  late final GeneratedColumn<String> ddd = GeneratedColumn<String>(
    'ddd',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _telefoneMeta = const VerificationMeta(
    'telefone',
  );
  @override
  late final GeneratedColumn<String> telefone = GeneratedColumn<String>(
    'telefone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cepMeta = const VerificationMeta('cep');
  @override
  late final GeneratedColumn<String> cep = GeneratedColumn<String>(
    'cep',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ruaMeta = const VerificationMeta('rua');
  @override
  late final GeneratedColumn<String> rua = GeneratedColumn<String>(
    'rua',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bairroMeta = const VerificationMeta('bairro');
  @override
  late final GeneratedColumn<String> bairro = GeneratedColumn<String>(
    'bairro',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cidadeMeta = const VerificationMeta('cidade');
  @override
  late final GeneratedColumn<String> cidade = GeneratedColumn<String>(
    'cidade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fantasia,
    razaoSocial,
    cnpj,
    inscEstadual,
    contato,
    ddd,
    telefone,
    cep,
    rua,
    bairro,
    cidade,
    criadoEm,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cliente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('fantasia')) {
      context.handle(
        _fantasiaMeta,
        fantasia.isAcceptableOrUnknown(data['fantasia']!, _fantasiaMeta),
      );
    } else if (isInserting) {
      context.missing(_fantasiaMeta);
    }
    if (data.containsKey('razao_social')) {
      context.handle(
        _razaoSocialMeta,
        razaoSocial.isAcceptableOrUnknown(
          data['razao_social']!,
          _razaoSocialMeta,
        ),
      );
    }
    if (data.containsKey('cnpj')) {
      context.handle(
        _cnpjMeta,
        cnpj.isAcceptableOrUnknown(data['cnpj']!, _cnpjMeta),
      );
    }
    if (data.containsKey('insc_estadual')) {
      context.handle(
        _inscEstadualMeta,
        inscEstadual.isAcceptableOrUnknown(
          data['insc_estadual']!,
          _inscEstadualMeta,
        ),
      );
    }
    if (data.containsKey('contato')) {
      context.handle(
        _contatoMeta,
        contato.isAcceptableOrUnknown(data['contato']!, _contatoMeta),
      );
    }
    if (data.containsKey('ddd')) {
      context.handle(
        _dddMeta,
        ddd.isAcceptableOrUnknown(data['ddd']!, _dddMeta),
      );
    }
    if (data.containsKey('telefone')) {
      context.handle(
        _telefoneMeta,
        telefone.isAcceptableOrUnknown(data['telefone']!, _telefoneMeta),
      );
    }
    if (data.containsKey('cep')) {
      context.handle(
        _cepMeta,
        cep.isAcceptableOrUnknown(data['cep']!, _cepMeta),
      );
    }
    if (data.containsKey('rua')) {
      context.handle(
        _ruaMeta,
        rua.isAcceptableOrUnknown(data['rua']!, _ruaMeta),
      );
    }
    if (data.containsKey('bairro')) {
      context.handle(
        _bairroMeta,
        bairro.isAcceptableOrUnknown(data['bairro']!, _bairroMeta),
      );
    }
    if (data.containsKey('cidade')) {
      context.handle(
        _cidadeMeta,
        cidade.isAcceptableOrUnknown(data['cidade']!, _cidadeMeta),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cliente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fantasia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fantasia'],
      )!,
      razaoSocial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}razao_social'],
      ),
      cnpj: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cnpj'],
      ),
      inscEstadual: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insc_estadual'],
      ),
      contato: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contato'],
      ),
      ddd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ddd'],
      ),
      telefone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefone'],
      ),
      cep: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cep'],
      ),
      rua: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rua'],
      ),
      bairro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bairro'],
      ),
      cidade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cidade'],
      ),
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class Cliente extends DataClass implements Insertable<Cliente> {
  final int id;
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
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  const Cliente({
    required this.id,
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
    required this.criadoEm,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['fantasia'] = Variable<String>(fantasia);
    if (!nullToAbsent || razaoSocial != null) {
      map['razao_social'] = Variable<String>(razaoSocial);
    }
    if (!nullToAbsent || cnpj != null) {
      map['cnpj'] = Variable<String>(cnpj);
    }
    if (!nullToAbsent || inscEstadual != null) {
      map['insc_estadual'] = Variable<String>(inscEstadual);
    }
    if (!nullToAbsent || contato != null) {
      map['contato'] = Variable<String>(contato);
    }
    if (!nullToAbsent || ddd != null) {
      map['ddd'] = Variable<String>(ddd);
    }
    if (!nullToAbsent || telefone != null) {
      map['telefone'] = Variable<String>(telefone);
    }
    if (!nullToAbsent || cep != null) {
      map['cep'] = Variable<String>(cep);
    }
    if (!nullToAbsent || rua != null) {
      map['rua'] = Variable<String>(rua);
    }
    if (!nullToAbsent || bairro != null) {
      map['bairro'] = Variable<String>(bairro);
    }
    if (!nullToAbsent || cidade != null) {
      map['cidade'] = Variable<String>(cidade);
    }
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      fantasia: Value(fantasia),
      razaoSocial: razaoSocial == null && nullToAbsent
          ? const Value.absent()
          : Value(razaoSocial),
      cnpj: cnpj == null && nullToAbsent ? const Value.absent() : Value(cnpj),
      inscEstadual: inscEstadual == null && nullToAbsent
          ? const Value.absent()
          : Value(inscEstadual),
      contato: contato == null && nullToAbsent
          ? const Value.absent()
          : Value(contato),
      ddd: ddd == null && nullToAbsent ? const Value.absent() : Value(ddd),
      telefone: telefone == null && nullToAbsent
          ? const Value.absent()
          : Value(telefone),
      cep: cep == null && nullToAbsent ? const Value.absent() : Value(cep),
      rua: rua == null && nullToAbsent ? const Value.absent() : Value(rua),
      bairro: bairro == null && nullToAbsent
          ? const Value.absent()
          : Value(bairro),
      cidade: cidade == null && nullToAbsent
          ? const Value.absent()
          : Value(cidade),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory Cliente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cliente(
      id: serializer.fromJson<int>(json['id']),
      fantasia: serializer.fromJson<String>(json['fantasia']),
      razaoSocial: serializer.fromJson<String?>(json['razaoSocial']),
      cnpj: serializer.fromJson<String?>(json['cnpj']),
      inscEstadual: serializer.fromJson<String?>(json['inscEstadual']),
      contato: serializer.fromJson<String?>(json['contato']),
      ddd: serializer.fromJson<String?>(json['ddd']),
      telefone: serializer.fromJson<String?>(json['telefone']),
      cep: serializer.fromJson<String?>(json['cep']),
      rua: serializer.fromJson<String?>(json['rua']),
      bairro: serializer.fromJson<String?>(json['bairro']),
      cidade: serializer.fromJson<String?>(json['cidade']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fantasia': serializer.toJson<String>(fantasia),
      'razaoSocial': serializer.toJson<String?>(razaoSocial),
      'cnpj': serializer.toJson<String?>(cnpj),
      'inscEstadual': serializer.toJson<String?>(inscEstadual),
      'contato': serializer.toJson<String?>(contato),
      'ddd': serializer.toJson<String?>(ddd),
      'telefone': serializer.toJson<String?>(telefone),
      'cep': serializer.toJson<String?>(cep),
      'rua': serializer.toJson<String?>(rua),
      'bairro': serializer.toJson<String?>(bairro),
      'cidade': serializer.toJson<String?>(cidade),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  Cliente copyWith({
    int? id,
    String? fantasia,
    Value<String?> razaoSocial = const Value.absent(),
    Value<String?> cnpj = const Value.absent(),
    Value<String?> inscEstadual = const Value.absent(),
    Value<String?> contato = const Value.absent(),
    Value<String?> ddd = const Value.absent(),
    Value<String?> telefone = const Value.absent(),
    Value<String?> cep = const Value.absent(),
    Value<String?> rua = const Value.absent(),
    Value<String?> bairro = const Value.absent(),
    Value<String?> cidade = const Value.absent(),
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) => Cliente(
    id: id ?? this.id,
    fantasia: fantasia ?? this.fantasia,
    razaoSocial: razaoSocial.present ? razaoSocial.value : this.razaoSocial,
    cnpj: cnpj.present ? cnpj.value : this.cnpj,
    inscEstadual: inscEstadual.present ? inscEstadual.value : this.inscEstadual,
    contato: contato.present ? contato.value : this.contato,
    ddd: ddd.present ? ddd.value : this.ddd,
    telefone: telefone.present ? telefone.value : this.telefone,
    cep: cep.present ? cep.value : this.cep,
    rua: rua.present ? rua.value : this.rua,
    bairro: bairro.present ? bairro.value : this.bairro,
    cidade: cidade.present ? cidade.value : this.cidade,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  Cliente copyWithCompanion(ClientesCompanion data) {
    return Cliente(
      id: data.id.present ? data.id.value : this.id,
      fantasia: data.fantasia.present ? data.fantasia.value : this.fantasia,
      razaoSocial: data.razaoSocial.present
          ? data.razaoSocial.value
          : this.razaoSocial,
      cnpj: data.cnpj.present ? data.cnpj.value : this.cnpj,
      inscEstadual: data.inscEstadual.present
          ? data.inscEstadual.value
          : this.inscEstadual,
      contato: data.contato.present ? data.contato.value : this.contato,
      ddd: data.ddd.present ? data.ddd.value : this.ddd,
      telefone: data.telefone.present ? data.telefone.value : this.telefone,
      cep: data.cep.present ? data.cep.value : this.cep,
      rua: data.rua.present ? data.rua.value : this.rua,
      bairro: data.bairro.present ? data.bairro.value : this.bairro,
      cidade: data.cidade.present ? data.cidade.value : this.cidade,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cliente(')
          ..write('id: $id, ')
          ..write('fantasia: $fantasia, ')
          ..write('razaoSocial: $razaoSocial, ')
          ..write('cnpj: $cnpj, ')
          ..write('inscEstadual: $inscEstadual, ')
          ..write('contato: $contato, ')
          ..write('ddd: $ddd, ')
          ..write('telefone: $telefone, ')
          ..write('cep: $cep, ')
          ..write('rua: $rua, ')
          ..write('bairro: $bairro, ')
          ..write('cidade: $cidade, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fantasia,
    razaoSocial,
    cnpj,
    inscEstadual,
    contato,
    ddd,
    telefone,
    cep,
    rua,
    bairro,
    cidade,
    criadoEm,
    atualizadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cliente &&
          other.id == this.id &&
          other.fantasia == this.fantasia &&
          other.razaoSocial == this.razaoSocial &&
          other.cnpj == this.cnpj &&
          other.inscEstadual == this.inscEstadual &&
          other.contato == this.contato &&
          other.ddd == this.ddd &&
          other.telefone == this.telefone &&
          other.cep == this.cep &&
          other.rua == this.rua &&
          other.bairro == this.bairro &&
          other.cidade == this.cidade &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm);
}

class ClientesCompanion extends UpdateCompanion<Cliente> {
  final Value<int> id;
  final Value<String> fantasia;
  final Value<String?> razaoSocial;
  final Value<String?> cnpj;
  final Value<String?> inscEstadual;
  final Value<String?> contato;
  final Value<String?> ddd;
  final Value<String?> telefone;
  final Value<String?> cep;
  final Value<String?> rua;
  final Value<String?> bairro;
  final Value<String?> cidade;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.fantasia = const Value.absent(),
    this.razaoSocial = const Value.absent(),
    this.cnpj = const Value.absent(),
    this.inscEstadual = const Value.absent(),
    this.contato = const Value.absent(),
    this.ddd = const Value.absent(),
    this.telefone = const Value.absent(),
    this.cep = const Value.absent(),
    this.rua = const Value.absent(),
    this.bairro = const Value.absent(),
    this.cidade = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String fantasia,
    this.razaoSocial = const Value.absent(),
    this.cnpj = const Value.absent(),
    this.inscEstadual = const Value.absent(),
    this.contato = const Value.absent(),
    this.ddd = const Value.absent(),
    this.telefone = const Value.absent(),
    this.cep = const Value.absent(),
    this.rua = const Value.absent(),
    this.bairro = const Value.absent(),
    this.cidade = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  }) : fantasia = Value(fantasia);
  static Insertable<Cliente> custom({
    Expression<int>? id,
    Expression<String>? fantasia,
    Expression<String>? razaoSocial,
    Expression<String>? cnpj,
    Expression<String>? inscEstadual,
    Expression<String>? contato,
    Expression<String>? ddd,
    Expression<String>? telefone,
    Expression<String>? cep,
    Expression<String>? rua,
    Expression<String>? bairro,
    Expression<String>? cidade,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fantasia != null) 'fantasia': fantasia,
      if (razaoSocial != null) 'razao_social': razaoSocial,
      if (cnpj != null) 'cnpj': cnpj,
      if (inscEstadual != null) 'insc_estadual': inscEstadual,
      if (contato != null) 'contato': contato,
      if (ddd != null) 'ddd': ddd,
      if (telefone != null) 'telefone': telefone,
      if (cep != null) 'cep': cep,
      if (rua != null) 'rua': rua,
      if (bairro != null) 'bairro': bairro,
      if (cidade != null) 'cidade': cidade,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
    });
  }

  ClientesCompanion copyWith({
    Value<int>? id,
    Value<String>? fantasia,
    Value<String?>? razaoSocial,
    Value<String?>? cnpj,
    Value<String?>? inscEstadual,
    Value<String?>? contato,
    Value<String?>? ddd,
    Value<String?>? telefone,
    Value<String?>? cep,
    Value<String?>? rua,
    Value<String?>? bairro,
    Value<String?>? cidade,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
  }) {
    return ClientesCompanion(
      id: id ?? this.id,
      fantasia: fantasia ?? this.fantasia,
      razaoSocial: razaoSocial ?? this.razaoSocial,
      cnpj: cnpj ?? this.cnpj,
      inscEstadual: inscEstadual ?? this.inscEstadual,
      contato: contato ?? this.contato,
      ddd: ddd ?? this.ddd,
      telefone: telefone ?? this.telefone,
      cep: cep ?? this.cep,
      rua: rua ?? this.rua,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fantasia.present) {
      map['fantasia'] = Variable<String>(fantasia.value);
    }
    if (razaoSocial.present) {
      map['razao_social'] = Variable<String>(razaoSocial.value);
    }
    if (cnpj.present) {
      map['cnpj'] = Variable<String>(cnpj.value);
    }
    if (inscEstadual.present) {
      map['insc_estadual'] = Variable<String>(inscEstadual.value);
    }
    if (contato.present) {
      map['contato'] = Variable<String>(contato.value);
    }
    if (ddd.present) {
      map['ddd'] = Variable<String>(ddd.value);
    }
    if (telefone.present) {
      map['telefone'] = Variable<String>(telefone.value);
    }
    if (cep.present) {
      map['cep'] = Variable<String>(cep.value);
    }
    if (rua.present) {
      map['rua'] = Variable<String>(rua.value);
    }
    if (bairro.present) {
      map['bairro'] = Variable<String>(bairro.value);
    }
    if (cidade.present) {
      map['cidade'] = Variable<String>(cidade.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('fantasia: $fantasia, ')
          ..write('razaoSocial: $razaoSocial, ')
          ..write('cnpj: $cnpj, ')
          ..write('inscEstadual: $inscEstadual, ')
          ..write('contato: $contato, ')
          ..write('ddd: $ddd, ')
          ..write('telefone: $telefone, ')
          ..write('cep: $cep, ')
          ..write('rua: $rua, ')
          ..write('bairro: $bairro, ')
          ..write('cidade: $cidade, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }
}

class $ProdutosTable extends Produtos with TableInfo<$ProdutosTable, Produto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProdutosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _reduzidoMeta = const VerificationMeta(
    'reduzido',
  );
  @override
  late final GeneratedColumn<int> reduzido = GeneratedColumn<int>(
    'reduzido',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precoPadraoCentavosMeta =
      const VerificationMeta('precoPadraoCentavos');
  @override
  late final GeneratedColumn<int> precoPadraoCentavos = GeneratedColumn<int>(
    'preco_padrao_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reduzido,
    descricao,
    precoPadraoCentavos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produtos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Produto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('reduzido')) {
      context.handle(
        _reduzidoMeta,
        reduzido.isAcceptableOrUnknown(data['reduzido']!, _reduzidoMeta),
      );
    } else if (isInserting) {
      context.missing(_reduzidoMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('preco_padrao_centavos')) {
      context.handle(
        _precoPadraoCentavosMeta,
        precoPadraoCentavos.isAcceptableOrUnknown(
          data['preco_padrao_centavos']!,
          _precoPadraoCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precoPadraoCentavosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Produto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Produto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      reduzido: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reduzido'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      precoPadraoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preco_padrao_centavos'],
      )!,
    );
  }

  @override
  $ProdutosTable createAlias(String alias) {
    return $ProdutosTable(attachedDatabase, alias);
  }
}

class Produto extends DataClass implements Insertable<Produto> {
  final int id;
  final int reduzido;
  final String descricao;
  final int precoPadraoCentavos;
  const Produto({
    required this.id,
    required this.reduzido,
    required this.descricao,
    required this.precoPadraoCentavos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['reduzido'] = Variable<int>(reduzido);
    map['descricao'] = Variable<String>(descricao);
    map['preco_padrao_centavos'] = Variable<int>(precoPadraoCentavos);
    return map;
  }

  ProdutosCompanion toCompanion(bool nullToAbsent) {
    return ProdutosCompanion(
      id: Value(id),
      reduzido: Value(reduzido),
      descricao: Value(descricao),
      precoPadraoCentavos: Value(precoPadraoCentavos),
    );
  }

  factory Produto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Produto(
      id: serializer.fromJson<int>(json['id']),
      reduzido: serializer.fromJson<int>(json['reduzido']),
      descricao: serializer.fromJson<String>(json['descricao']),
      precoPadraoCentavos: serializer.fromJson<int>(
        json['precoPadraoCentavos'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'reduzido': serializer.toJson<int>(reduzido),
      'descricao': serializer.toJson<String>(descricao),
      'precoPadraoCentavos': serializer.toJson<int>(precoPadraoCentavos),
    };
  }

  Produto copyWith({
    int? id,
    int? reduzido,
    String? descricao,
    int? precoPadraoCentavos,
  }) => Produto(
    id: id ?? this.id,
    reduzido: reduzido ?? this.reduzido,
    descricao: descricao ?? this.descricao,
    precoPadraoCentavos: precoPadraoCentavos ?? this.precoPadraoCentavos,
  );
  Produto copyWithCompanion(ProdutosCompanion data) {
    return Produto(
      id: data.id.present ? data.id.value : this.id,
      reduzido: data.reduzido.present ? data.reduzido.value : this.reduzido,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      precoPadraoCentavos: data.precoPadraoCentavos.present
          ? data.precoPadraoCentavos.value
          : this.precoPadraoCentavos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Produto(')
          ..write('id: $id, ')
          ..write('reduzido: $reduzido, ')
          ..write('descricao: $descricao, ')
          ..write('precoPadraoCentavos: $precoPadraoCentavos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, reduzido, descricao, precoPadraoCentavos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Produto &&
          other.id == this.id &&
          other.reduzido == this.reduzido &&
          other.descricao == this.descricao &&
          other.precoPadraoCentavos == this.precoPadraoCentavos);
}

class ProdutosCompanion extends UpdateCompanion<Produto> {
  final Value<int> id;
  final Value<int> reduzido;
  final Value<String> descricao;
  final Value<int> precoPadraoCentavos;
  const ProdutosCompanion({
    this.id = const Value.absent(),
    this.reduzido = const Value.absent(),
    this.descricao = const Value.absent(),
    this.precoPadraoCentavos = const Value.absent(),
  });
  ProdutosCompanion.insert({
    this.id = const Value.absent(),
    required int reduzido,
    required String descricao,
    required int precoPadraoCentavos,
  }) : reduzido = Value(reduzido),
       descricao = Value(descricao),
       precoPadraoCentavos = Value(precoPadraoCentavos);
  static Insertable<Produto> custom({
    Expression<int>? id,
    Expression<int>? reduzido,
    Expression<String>? descricao,
    Expression<int>? precoPadraoCentavos,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reduzido != null) 'reduzido': reduzido,
      if (descricao != null) 'descricao': descricao,
      if (precoPadraoCentavos != null)
        'preco_padrao_centavos': precoPadraoCentavos,
    });
  }

  ProdutosCompanion copyWith({
    Value<int>? id,
    Value<int>? reduzido,
    Value<String>? descricao,
    Value<int>? precoPadraoCentavos,
  }) {
    return ProdutosCompanion(
      id: id ?? this.id,
      reduzido: reduzido ?? this.reduzido,
      descricao: descricao ?? this.descricao,
      precoPadraoCentavos: precoPadraoCentavos ?? this.precoPadraoCentavos,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (reduzido.present) {
      map['reduzido'] = Variable<int>(reduzido.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (precoPadraoCentavos.present) {
      map['preco_padrao_centavos'] = Variable<int>(precoPadraoCentavos.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProdutosCompanion(')
          ..write('id: $id, ')
          ..write('reduzido: $reduzido, ')
          ..write('descricao: $descricao, ')
          ..write('precoPadraoCentavos: $precoPadraoCentavos')
          ..write(')'))
        .toString();
  }
}

class $ComprasTable extends Compras with TableInfo<$ComprasTable, Compra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComprasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _produtoIdMeta = const VerificationMeta(
    'produtoId',
  );
  @override
  late final GeneratedColumn<int> produtoId = GeneratedColumn<int>(
    'produto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produtos (id) ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> data =
      GeneratedColumn<int>(
        'data',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ComprasTable.$converterdata);
  static const VerificationMeta _quantidadeMeta = const VerificationMeta(
    'quantidade',
  );
  @override
  late final GeneratedColumn<int> quantidade = GeneratedColumn<int>(
    'quantidade',
    aliasedName,
    false,
    check: () => ComparableExpr(quantidade).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorUnitarioCentavosMeta =
      const VerificationMeta('valorUnitarioCentavos');
  @override
  late final GeneratedColumn<int> valorUnitarioCentavos = GeneratedColumn<int>(
    'valor_unitario_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenciaMeta = const VerificationMeta(
    'sequencia',
  );
  @override
  late final GeneratedColumn<int> sequencia = GeneratedColumn<int>(
    'sequencia',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    produtoId,
    data,
    quantidade,
    valorUnitarioCentavos,
    sequencia,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compras';
  @override
  VerificationContext validateIntegrity(
    Insertable<Compra> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('produto_id')) {
      context.handle(
        _produtoIdMeta,
        produtoId.isAcceptableOrUnknown(data['produto_id']!, _produtoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produtoIdMeta);
    }
    if (data.containsKey('quantidade')) {
      context.handle(
        _quantidadeMeta,
        quantidade.isAcceptableOrUnknown(data['quantidade']!, _quantidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_quantidadeMeta);
    }
    if (data.containsKey('valor_unitario_centavos')) {
      context.handle(
        _valorUnitarioCentavosMeta,
        valorUnitarioCentavos.isAcceptableOrUnknown(
          data['valor_unitario_centavos']!,
          _valorUnitarioCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorUnitarioCentavosMeta);
    }
    if (data.containsKey('sequencia')) {
      context.handle(
        _sequenciaMeta,
        sequencia.isAcceptableOrUnknown(data['sequencia']!, _sequenciaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Compra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Compra(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      produtoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produto_id'],
      )!,
      data: $ComprasTable.$converterdata.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}data'],
        )!,
      ),
      quantidade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantidade'],
      )!,
      valorUnitarioCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_unitario_centavos'],
      )!,
      sequencia: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequencia'],
      ),
    );
  }

  @override
  $ComprasTable createAlias(String alias) {
    return $ComprasTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterdata = const DiaConverter();
}

class Compra extends DataClass implements Insertable<Compra> {
  final int id;
  final int clienteId;
  final int produtoId;
  final DateTime data;
  final int quantidade;
  final int valorUnitarioCentavos;
  final int? sequencia;
  const Compra({
    required this.id,
    required this.clienteId,
    required this.produtoId,
    required this.data,
    required this.quantidade,
    required this.valorUnitarioCentavos,
    this.sequencia,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['produto_id'] = Variable<int>(produtoId);
    {
      map['data'] = Variable<int>($ComprasTable.$converterdata.toSql(data));
    }
    map['quantidade'] = Variable<int>(quantidade);
    map['valor_unitario_centavos'] = Variable<int>(valorUnitarioCentavos);
    if (!nullToAbsent || sequencia != null) {
      map['sequencia'] = Variable<int>(sequencia);
    }
    return map;
  }

  ComprasCompanion toCompanion(bool nullToAbsent) {
    return ComprasCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      produtoId: Value(produtoId),
      data: Value(data),
      quantidade: Value(quantidade),
      valorUnitarioCentavos: Value(valorUnitarioCentavos),
      sequencia: sequencia == null && nullToAbsent
          ? const Value.absent()
          : Value(sequencia),
    );
  }

  factory Compra.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Compra(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      produtoId: serializer.fromJson<int>(json['produtoId']),
      data: serializer.fromJson<DateTime>(json['data']),
      quantidade: serializer.fromJson<int>(json['quantidade']),
      valorUnitarioCentavos: serializer.fromJson<int>(
        json['valorUnitarioCentavos'],
      ),
      sequencia: serializer.fromJson<int?>(json['sequencia']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'produtoId': serializer.toJson<int>(produtoId),
      'data': serializer.toJson<DateTime>(data),
      'quantidade': serializer.toJson<int>(quantidade),
      'valorUnitarioCentavos': serializer.toJson<int>(valorUnitarioCentavos),
      'sequencia': serializer.toJson<int?>(sequencia),
    };
  }

  Compra copyWith({
    int? id,
    int? clienteId,
    int? produtoId,
    DateTime? data,
    int? quantidade,
    int? valorUnitarioCentavos,
    Value<int?> sequencia = const Value.absent(),
  }) => Compra(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    produtoId: produtoId ?? this.produtoId,
    data: data ?? this.data,
    quantidade: quantidade ?? this.quantidade,
    valorUnitarioCentavos: valorUnitarioCentavos ?? this.valorUnitarioCentavos,
    sequencia: sequencia.present ? sequencia.value : this.sequencia,
  );
  Compra copyWithCompanion(ComprasCompanion data) {
    return Compra(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      produtoId: data.produtoId.present ? data.produtoId.value : this.produtoId,
      data: data.data.present ? data.data.value : this.data,
      quantidade: data.quantidade.present
          ? data.quantidade.value
          : this.quantidade,
      valorUnitarioCentavos: data.valorUnitarioCentavos.present
          ? data.valorUnitarioCentavos.value
          : this.valorUnitarioCentavos,
      sequencia: data.sequencia.present ? data.sequencia.value : this.sequencia,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Compra(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('produtoId: $produtoId, ')
          ..write('data: $data, ')
          ..write('quantidade: $quantidade, ')
          ..write('valorUnitarioCentavos: $valorUnitarioCentavos, ')
          ..write('sequencia: $sequencia')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    produtoId,
    data,
    quantidade,
    valorUnitarioCentavos,
    sequencia,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Compra &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.produtoId == this.produtoId &&
          other.data == this.data &&
          other.quantidade == this.quantidade &&
          other.valorUnitarioCentavos == this.valorUnitarioCentavos &&
          other.sequencia == this.sequencia);
}

class ComprasCompanion extends UpdateCompanion<Compra> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<int> produtoId;
  final Value<DateTime> data;
  final Value<int> quantidade;
  final Value<int> valorUnitarioCentavos;
  final Value<int?> sequencia;
  const ComprasCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.produtoId = const Value.absent(),
    this.data = const Value.absent(),
    this.quantidade = const Value.absent(),
    this.valorUnitarioCentavos = const Value.absent(),
    this.sequencia = const Value.absent(),
  });
  ComprasCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required int produtoId,
    required DateTime data,
    required int quantidade,
    required int valorUnitarioCentavos,
    this.sequencia = const Value.absent(),
  }) : clienteId = Value(clienteId),
       produtoId = Value(produtoId),
       data = Value(data),
       quantidade = Value(quantidade),
       valorUnitarioCentavos = Value(valorUnitarioCentavos);
  static Insertable<Compra> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<int>? produtoId,
    Expression<int>? data,
    Expression<int>? quantidade,
    Expression<int>? valorUnitarioCentavos,
    Expression<int>? sequencia,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (produtoId != null) 'produto_id': produtoId,
      if (data != null) 'data': data,
      if (quantidade != null) 'quantidade': quantidade,
      if (valorUnitarioCentavos != null)
        'valor_unitario_centavos': valorUnitarioCentavos,
      if (sequencia != null) 'sequencia': sequencia,
    });
  }

  ComprasCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<int>? produtoId,
    Value<DateTime>? data,
    Value<int>? quantidade,
    Value<int>? valorUnitarioCentavos,
    Value<int?>? sequencia,
  }) {
    return ComprasCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      produtoId: produtoId ?? this.produtoId,
      data: data ?? this.data,
      quantidade: quantidade ?? this.quantidade,
      valorUnitarioCentavos:
          valorUnitarioCentavos ?? this.valorUnitarioCentavos,
      sequencia: sequencia ?? this.sequencia,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (produtoId.present) {
      map['produto_id'] = Variable<int>(produtoId.value);
    }
    if (data.present) {
      map['data'] = Variable<int>(
        $ComprasTable.$converterdata.toSql(data.value),
      );
    }
    if (quantidade.present) {
      map['quantidade'] = Variable<int>(quantidade.value);
    }
    if (valorUnitarioCentavos.present) {
      map['valor_unitario_centavos'] = Variable<int>(
        valorUnitarioCentavos.value,
      );
    }
    if (sequencia.present) {
      map['sequencia'] = Variable<int>(sequencia.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComprasCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('produtoId: $produtoId, ')
          ..write('data: $data, ')
          ..write('quantidade: $quantidade, ')
          ..write('valorUnitarioCentavos: $valorUnitarioCentavos, ')
          ..write('sequencia: $sequencia')
          ..write(')'))
        .toString();
  }
}

class $ConfiguracoesTable extends Configuracoes
    with TableInfo<$ConfiguracoesTable, Configuracao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfiguracoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [chave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuracoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Configuracao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  Configuracao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Configuracao(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  $ConfiguracoesTable createAlias(String alias) {
    return $ConfiguracoesTable(attachedDatabase, alias);
  }
}

class Configuracao extends DataClass implements Insertable<Configuracao> {
  final String chave;
  final String valor;
  const Configuracao({required this.chave, required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    map['valor'] = Variable<String>(valor);
    return map;
  }

  ConfiguracoesCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracoesCompanion(chave: Value(chave), valor: Value(valor));
  }

  factory Configuracao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Configuracao(
      chave: serializer.fromJson<String>(json['chave']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'valor': serializer.toJson<String>(valor),
    };
  }

  Configuracao copyWith({String? chave, String? valor}) =>
      Configuracao(chave: chave ?? this.chave, valor: valor ?? this.valor);
  Configuracao copyWithCompanion(ConfiguracoesCompanion data) {
    return Configuracao(
      chave: data.chave.present ? data.chave.value : this.chave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Configuracao(')
          ..write('chave: $chave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Configuracao &&
          other.chave == this.chave &&
          other.valor == this.valor);
}

class ConfiguracoesCompanion extends UpdateCompanion<Configuracao> {
  final Value<String> chave;
  final Value<String> valor;
  final Value<int> rowid;
  const ConfiguracoesCompanion({
    this.chave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfiguracoesCompanion.insert({
    required String chave,
    required String valor,
    this.rowid = const Value.absent(),
  }) : chave = Value(chave),
       valor = Value(valor);
  static Insertable<Configuracao> custom({
    Expression<String>? chave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfiguracoesCompanion copyWith({
    Value<String>? chave,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return ConfiguracoesCompanion(
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracoesCompanion(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $ProdutosTable produtos = $ProdutosTable(this);
  late final $ComprasTable compras = $ComprasTable(this);
  late final $ConfiguracoesTable configuracoes = $ConfiguracoesTable(this);
  late final Index idxClientesFantasia = Index(
    'idx_clientes_fantasia',
    'CREATE INDEX idx_clientes_fantasia ON clientes (fantasia)',
  );
  late final Index idxComprasData = Index(
    'idx_compras_data',
    'CREATE INDEX idx_compras_data ON compras (data)',
  );
  late final Index idxComprasCliente = Index(
    'idx_compras_cliente',
    'CREATE INDEX idx_compras_cliente ON compras (cliente_id)',
  );
  late final Index idxComprasProduto = Index(
    'idx_compras_produto',
    'CREATE INDEX idx_compras_produto ON compras (produto_id)',
  );
  late final Index idxComprasDuplicata = Index(
    'idx_compras_duplicata',
    'CREATE INDEX idx_compras_duplicata ON compras (cliente_id, produto_id, data, sequencia, quantidade)',
  );
  late final ClientesDao clientesDao = ClientesDao(this as AppDatabase);
  late final ProdutosDao produtosDao = ProdutosDao(this as AppDatabase);
  late final ComprasDao comprasDao = ComprasDao(this as AppDatabase);
  late final ConsultaDao consultaDao = ConsultaDao(this as AppDatabase);
  late final AnaliticoDao analiticoDao = AnaliticoDao(this as AppDatabase);
  late final ConfigDao configDao = ConfigDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clientes,
    produtos,
    compras,
    configuracoes,
    idxClientesFantasia,
    idxComprasData,
    idxComprasCliente,
    idxComprasProduto,
    idxComprasDuplicata,
  ];
}

typedef $$ClientesTableCreateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  required String fantasia,
  Value<String?> razaoSocial,
  Value<String?> cnpj,
  Value<String?> inscEstadual,
  Value<String?> contato,
  Value<String?> ddd,
  Value<String?> telefone,
  Value<String?> cep,
  Value<String?> rua,
  Value<String?> bairro,
  Value<String?> cidade,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
});
typedef $$ClientesTableUpdateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  Value<String> fantasia,
  Value<String?> razaoSocial,
  Value<String?> cnpj,
  Value<String?> inscEstadual,
  Value<String?> contato,
  Value<String?> ddd,
  Value<String?> telefone,
  Value<String?> cep,
  Value<String?> rua,
  Value<String?> bairro,
  Value<String?> cidade,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
});

final class $$ClientesTableReferences
    extends BaseReferences<_$AppDatabase, $ClientesTable, Cliente> {
  $$ClientesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ComprasTable, List<Compra>> _comprasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.compras,
    aliasName: 'clientes__id__compras__cliente_id',
  );

  $$ComprasTableProcessedTableManager get comprasRefs {
    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_comprasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fantasia => $composableBuilder(
    column: $table.fantasia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get razaoSocial => $composableBuilder(
    column: $table.razaoSocial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cnpj => $composableBuilder(
    column: $table.cnpj,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inscEstadual => $composableBuilder(
    column: $table.inscEstadual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contato => $composableBuilder(
    column: $table.contato,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ddd => $composableBuilder(
    column: $table.ddd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefone => $composableBuilder(
    column: $table.telefone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cep => $composableBuilder(
    column: $table.cep,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rua => $composableBuilder(
    column: $table.rua,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bairro => $composableBuilder(
    column: $table.bairro,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cidade => $composableBuilder(
    column: $table.cidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> comprasRefs(
    Expression<bool> Function($$ComprasTableFilterComposer f) f,
  ) {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fantasia => $composableBuilder(
    column: $table.fantasia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get razaoSocial => $composableBuilder(
    column: $table.razaoSocial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cnpj => $composableBuilder(
    column: $table.cnpj,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inscEstadual => $composableBuilder(
    column: $table.inscEstadual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contato => $composableBuilder(
    column: $table.contato,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ddd => $composableBuilder(
    column: $table.ddd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefone => $composableBuilder(
    column: $table.telefone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cep => $composableBuilder(
    column: $table.cep,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rua => $composableBuilder(
    column: $table.rua,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bairro => $composableBuilder(
    column: $table.bairro,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cidade => $composableBuilder(
    column: $table.cidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fantasia =>
      $composableBuilder(column: $table.fantasia, builder: (column) => column);

  GeneratedColumn<String> get razaoSocial => $composableBuilder(
    column: $table.razaoSocial,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cnpj =>
      $composableBuilder(column: $table.cnpj, builder: (column) => column);

  GeneratedColumn<String> get inscEstadual => $composableBuilder(
    column: $table.inscEstadual,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contato =>
      $composableBuilder(column: $table.contato, builder: (column) => column);

  GeneratedColumn<String> get ddd =>
      $composableBuilder(column: $table.ddd, builder: (column) => column);

  GeneratedColumn<String> get telefone =>
      $composableBuilder(column: $table.telefone, builder: (column) => column);

  GeneratedColumn<String> get cep =>
      $composableBuilder(column: $table.cep, builder: (column) => column);

  GeneratedColumn<String> get rua =>
      $composableBuilder(column: $table.rua, builder: (column) => column);

  GeneratedColumn<String> get bairro =>
      $composableBuilder(column: $table.bairro, builder: (column) => column);

  GeneratedColumn<String> get cidade =>
      $composableBuilder(column: $table.cidade, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  Expression<T> comprasRefs<T extends Object>(
    Expression<T> Function($$ComprasTableAnnotationComposer a) f,
  ) {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesTable,
          Cliente,
          $$ClientesTableFilterComposer,
          $$ClientesTableOrderingComposer,
          $$ClientesTableAnnotationComposer,
          $$ClientesTableCreateCompanionBuilder,
          $$ClientesTableUpdateCompanionBuilder,
          (Cliente, $$ClientesTableReferences),
          Cliente,
          PrefetchHooks Function({bool comprasRefs})
        > {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fantasia = const Value.absent(),
                Value<String?> razaoSocial = const Value.absent(),
                Value<String?> cnpj = const Value.absent(),
                Value<String?> inscEstadual = const Value.absent(),
                Value<String?> contato = const Value.absent(),
                Value<String?> ddd = const Value.absent(),
                Value<String?> telefone = const Value.absent(),
                Value<String?> cep = const Value.absent(),
                Value<String?> rua = const Value.absent(),
                Value<String?> bairro = const Value.absent(),
                Value<String?> cidade = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => ClientesCompanion(
                id: id,
                fantasia: fantasia,
                razaoSocial: razaoSocial,
                cnpj: cnpj,
                inscEstadual: inscEstadual,
                contato: contato,
                ddd: ddd,
                telefone: telefone,
                cep: cep,
                rua: rua,
                bairro: bairro,
                cidade: cidade,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fantasia,
                Value<String?> razaoSocial = const Value.absent(),
                Value<String?> cnpj = const Value.absent(),
                Value<String?> inscEstadual = const Value.absent(),
                Value<String?> contato = const Value.absent(),
                Value<String?> ddd = const Value.absent(),
                Value<String?> telefone = const Value.absent(),
                Value<String?> cep = const Value.absent(),
                Value<String?> rua = const Value.absent(),
                Value<String?> bairro = const Value.absent(),
                Value<String?> cidade = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => ClientesCompanion.insert(
                id: id,
                fantasia: fantasia,
                razaoSocial: razaoSocial,
                cnpj: cnpj,
                inscEstadual: inscEstadual,
                contato: contato,
                ddd: ddd,
                telefone: telefone,
                cep: cep,
                rua: rua,
                bairro: bairro,
                cidade: cidade,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientesTable, Cliente>(table),
                  $$ClientesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({comprasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (comprasRefs) db.compras],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (comprasRefs)
                    await $_getPrefetchedData<Cliente, $ClientesTable, Compra>(
                      currentTable: table,
                      referencedTable: $$ClientesTableReferences
                          ._comprasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ClientesTableReferences(db, table, p0).comprasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.clienteId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesTable,
      Cliente,
      $$ClientesTableFilterComposer,
      $$ClientesTableOrderingComposer,
      $$ClientesTableAnnotationComposer,
      $$ClientesTableCreateCompanionBuilder,
      $$ClientesTableUpdateCompanionBuilder,
      (Cliente, $$ClientesTableReferences),
      Cliente,
      PrefetchHooks Function({bool comprasRefs})
    >;
typedef $$ProdutosTableCreateCompanionBuilder = ProdutosCompanion Function({
  Value<int> id,
  required int reduzido,
  required String descricao,
  required int precoPadraoCentavos,
});
typedef $$ProdutosTableUpdateCompanionBuilder = ProdutosCompanion Function({
  Value<int> id,
  Value<int> reduzido,
  Value<String> descricao,
  Value<int> precoPadraoCentavos,
});

final class $$ProdutosTableReferences
    extends BaseReferences<_$AppDatabase, $ProdutosTable, Produto> {
  $$ProdutosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ComprasTable, List<Compra>> _comprasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.compras,
    aliasName: 'produtos__id__compras__produto_id',
  );

  $$ComprasTableProcessedTableManager get comprasRefs {
    final manager = $$ComprasTableTableManager(
      $_db,
      $_db.compras,
    ).filter((f) => f.produtoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_comprasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProdutosTableFilterComposer
    extends Composer<_$AppDatabase, $ProdutosTable> {
  $$ProdutosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reduzido => $composableBuilder(
    column: $table.reduzido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precoPadraoCentavos => $composableBuilder(
    column: $table.precoPadraoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> comprasRefs(
    Expression<bool> Function($$ComprasTableFilterComposer f) f,
  ) {
    final $$ComprasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.produtoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableFilterComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProdutosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProdutosTable> {
  $$ProdutosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reduzido => $composableBuilder(
    column: $table.reduzido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precoPadraoCentavos => $composableBuilder(
    column: $table.precoPadraoCentavos,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProdutosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProdutosTable> {
  $$ProdutosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get reduzido =>
      $composableBuilder(column: $table.reduzido, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<int> get precoPadraoCentavos => $composableBuilder(
    column: $table.precoPadraoCentavos,
    builder: (column) => column,
  );

  Expression<T> comprasRefs<T extends Object>(
    Expression<T> Function($$ComprasTableAnnotationComposer a) f,
  ) {
    final $$ComprasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.compras,
      getReferencedColumn: (t) => t.produtoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComprasTableAnnotationComposer(
            $db: $db,
            $table: $db.compras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProdutosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProdutosTable,
          Produto,
          $$ProdutosTableFilterComposer,
          $$ProdutosTableOrderingComposer,
          $$ProdutosTableAnnotationComposer,
          $$ProdutosTableCreateCompanionBuilder,
          $$ProdutosTableUpdateCompanionBuilder,
          (Produto, $$ProdutosTableReferences),
          Produto,
          PrefetchHooks Function({bool comprasRefs})
        > {
  $$ProdutosTableTableManager(_$AppDatabase db, $ProdutosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProdutosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProdutosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProdutosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> reduzido = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<int> precoPadraoCentavos = const Value.absent(),
              }) => ProdutosCompanion(
                id: id,
                reduzido: reduzido,
                descricao: descricao,
                precoPadraoCentavos: precoPadraoCentavos,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int reduzido,
                required String descricao,
                required int precoPadraoCentavos,
              }) => ProdutosCompanion.insert(
                id: id,
                reduzido: reduzido,
                descricao: descricao,
                precoPadraoCentavos: precoPadraoCentavos,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProdutosTable, Produto>(table),
                  $$ProdutosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({comprasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (comprasRefs) db.compras],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (comprasRefs)
                    await $_getPrefetchedData<Produto, $ProdutosTable, Compra>(
                      currentTable: table,
                      referencedTable: $$ProdutosTableReferences
                          ._comprasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProdutosTableReferences(db, table, p0).comprasRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.produtoId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProdutosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProdutosTable,
      Produto,
      $$ProdutosTableFilterComposer,
      $$ProdutosTableOrderingComposer,
      $$ProdutosTableAnnotationComposer,
      $$ProdutosTableCreateCompanionBuilder,
      $$ProdutosTableUpdateCompanionBuilder,
      (Produto, $$ProdutosTableReferences),
      Produto,
      PrefetchHooks Function({bool comprasRefs})
    >;
typedef $$ComprasTableCreateCompanionBuilder = ComprasCompanion Function({
  Value<int> id,
  required int clienteId,
  required int produtoId,
  required DateTime data,
  required int quantidade,
  required int valorUnitarioCentavos,
  Value<int?> sequencia,
});
typedef $$ComprasTableUpdateCompanionBuilder = ComprasCompanion Function({
  Value<int> id,
  Value<int> clienteId,
  Value<int> produtoId,
  Value<DateTime> data,
  Value<int> quantidade,
  Value<int> valorUnitarioCentavos,
  Value<int?> sequencia,
});

final class $$ComprasTableReferences
    extends BaseReferences<_$AppDatabase, $ComprasTable, Compra> {
  $$ComprasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('compras__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProdutosTable _produtoIdTable(_$AppDatabase db) =>
      db.produtos.createAlias('compras__produto_id__produtos__id');

  $$ProdutosTableProcessedTableManager get produtoId {
    final $_column = $_itemColumn<int>('produto_id')!;

    final manager = $$ProdutosTableTableManager(
      $_db,
      $_db.produtos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produtoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ComprasTableFilterComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get data =>
      $composableBuilder(
        column: $table.data,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorUnitarioCentavos => $composableBuilder(
    column: $table.valorUnitarioCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequencia => $composableBuilder(
    column: $table.sequencia,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProdutosTableFilterComposer get produtoId {
    final $$ProdutosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produtoId,
      referencedTable: $db.produtos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProdutosTableFilterComposer(
            $db: $db,
            $table: $db.produtos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprasTableOrderingComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorUnitarioCentavos => $composableBuilder(
    column: $table.valorUnitarioCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequencia => $composableBuilder(
    column: $table.sequencia,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProdutosTableOrderingComposer get produtoId {
    final $$ProdutosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produtoId,
      referencedTable: $db.produtos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProdutosTableOrderingComposer(
            $db: $db,
            $table: $db.produtos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComprasTable> {
  $$ComprasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valorUnitarioCentavos => $composableBuilder(
    column: $table.valorUnitarioCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequencia =>
      $composableBuilder(column: $table.sequencia, builder: (column) => column);

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProdutosTableAnnotationComposer get produtoId {
    final $$ProdutosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produtoId,
      referencedTable: $db.produtos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProdutosTableAnnotationComposer(
            $db: $db,
            $table: $db.produtos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComprasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComprasTable,
          Compra,
          $$ComprasTableFilterComposer,
          $$ComprasTableOrderingComposer,
          $$ComprasTableAnnotationComposer,
          $$ComprasTableCreateCompanionBuilder,
          $$ComprasTableUpdateCompanionBuilder,
          (Compra, $$ComprasTableReferences),
          Compra,
          PrefetchHooks Function({bool clienteId, bool produtoId})
        > {
  $$ComprasTableTableManager(_$AppDatabase db, $ComprasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComprasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComprasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComprasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<int> produtoId = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> quantidade = const Value.absent(),
                Value<int> valorUnitarioCentavos = const Value.absent(),
                Value<int?> sequencia = const Value.absent(),
              }) => ComprasCompanion(
                id: id,
                clienteId: clienteId,
                produtoId: produtoId,
                data: data,
                quantidade: quantidade,
                valorUnitarioCentavos: valorUnitarioCentavos,
                sequencia: sequencia,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                required int produtoId,
                required DateTime data,
                required int quantidade,
                required int valorUnitarioCentavos,
                Value<int?> sequencia = const Value.absent(),
              }) => ComprasCompanion.insert(
                id: id,
                clienteId: clienteId,
                produtoId: produtoId,
                data: data,
                quantidade: quantidade,
                valorUnitarioCentavos: valorUnitarioCentavos,
                sequencia: sequencia,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ComprasTable, Compra>(table),
                  $$ComprasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({clienteId = false, produtoId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (clienteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.clienteId,
                        referencedTable: $$ComprasTableReferences
                            ._clienteIdTable(db),
                        referencedColumn: $$ComprasTableReferences
                            ._clienteIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (produtoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.produtoId,
                        referencedTable: $$ComprasTableReferences
                            ._produtoIdTable(db),
                        referencedColumn: $$ComprasTableReferences
                            ._produtoIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ComprasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComprasTable,
      Compra,
      $$ComprasTableFilterComposer,
      $$ComprasTableOrderingComposer,
      $$ComprasTableAnnotationComposer,
      $$ComprasTableCreateCompanionBuilder,
      $$ComprasTableUpdateCompanionBuilder,
      (Compra, $$ComprasTableReferences),
      Compra,
      PrefetchHooks Function({bool clienteId, bool produtoId})
    >;
typedef $$ConfiguracoesTableCreateCompanionBuilder =
    ConfiguracoesCompanion Function({
      required String chave,
      required String valor,
      Value<int> rowid,
    });
typedef $$ConfiguracoesTableUpdateCompanionBuilder =
    ConfiguracoesCompanion Function({
      Value<String> chave,
      Value<String> valor,
      Value<int> rowid,
    });

class $$ConfiguracoesTableFilterComposer
    extends Composer<_$AppDatabase, $ConfiguracoesTable> {
  $$ConfiguracoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfiguracoesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfiguracoesTable> {
  $$ConfiguracoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfiguracoesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfiguracoesTable> {
  $$ConfiguracoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$ConfiguracoesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfiguracoesTable,
          Configuracao,
          $$ConfiguracoesTableFilterComposer,
          $$ConfiguracoesTableOrderingComposer,
          $$ConfiguracoesTableAnnotationComposer,
          $$ConfiguracoesTableCreateCompanionBuilder,
          $$ConfiguracoesTableUpdateCompanionBuilder,
          (
            Configuracao,
            BaseReferences<_$AppDatabase, $ConfiguracoesTable, Configuracao>,
          ),
          Configuracao,
          PrefetchHooks Function()
        > {
  $$ConfiguracoesTableTableManager(_$AppDatabase db, $ConfiguracoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfiguracoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfiguracoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfiguracoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chave = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracoesCompanion(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chave,
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracoesCompanion.insert(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfiguracoesTable, Configuracao>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConfiguracoesTable,
                    Configuracao
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfiguracoesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfiguracoesTable,
      Configuracao,
      $$ConfiguracoesTableFilterComposer,
      $$ConfiguracoesTableOrderingComposer,
      $$ConfiguracoesTableAnnotationComposer,
      $$ConfiguracoesTableCreateCompanionBuilder,
      $$ConfiguracoesTableUpdateCompanionBuilder,
      (
        Configuracao,
        BaseReferences<_$AppDatabase, $ConfiguracoesTable, Configuracao>,
      ),
      Configuracao,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$ProdutosTableTableManager get produtos =>
      $$ProdutosTableTableManager(_db, _db.produtos);
  $$ComprasTableTableManager get compras =>
      $$ComprasTableTableManager(_db, _db.compras);
  $$ConfiguracoesTableTableManager get configuracoes =>
      $$ConfiguracoesTableTableManager(_db, _db.configuracoes);
}
