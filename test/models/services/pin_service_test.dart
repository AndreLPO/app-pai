import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/services/pin_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../database/helpers.dart';

void main() {
  late AppDatabase db;
  late PinService pin;

  setUp(() {
    db = bancoDeTeste();
    pin = PinService(db.configDao);
  });
  tearDown(() => db.close());

  test('formato: 4 a 6 dígitos numéricos', () {
    expect(PinService.formatoValido('1234'), isTrue);
    expect(PinService.formatoValido('123456'), isTrue);
    expect(PinService.formatoValido('123'), isFalse);
    expect(PinService.formatoValido('1234567'), isFalse);
    expect(PinService.formatoValido('12a4'), isFalse);
  });

  test('sem PIN cadastrado no início', () async {
    expect(await pin.temPin(), isFalse);
    expect(await pin.verificar('1234'), isFalse);
  });

  test('verificação aceita só o PIN certo', () async {
    await pin.definir('1234');
    expect(await pin.temPin(), isTrue);
    expect(await pin.verificar('1234'), isTrue);
    expect(await pin.verificar('1235'), isFalse);
    expect(await pin.verificar('12345'), isFalse);
  });

  test('o PIN não aparece em texto puro no banco', () async {
    await pin.definir('1234');
    final linhas = await db.select(db.configuracoes).get();
    expect(linhas, isNotEmpty);
    for (final l in linhas) {
      expect(l.chave.contains('1234'), isFalse);
      expect(l.valor.contains('1234'), isFalse);
    }
  });

  test('salt diferente a cada definição', () async {
    await pin.definir('1234');
    final hash1 = await db.configDao.ler(PinService.chaveHash);
    await pin.definir('1234');
    expect(await db.configDao.ler(PinService.chaveHash), isNot(hash1));
    expect(await pin.verificar('1234'), isTrue);
  });

  test('troca exige o PIN atual correto', () async {
    await pin.definir('1234');
    expect(await pin.trocar('0000', '5678'), isFalse);
    expect(await pin.verificar('1234'), isTrue);

    expect(await pin.trocar('1234', '5678'), isTrue);
    expect(await pin.verificar('5678'), isTrue);
    expect(await pin.verificar('1234'), isFalse);
  });

  test('recusa PIN com tamanho inválido', () {
    expect(() => pin.definir('12'), throwsArgumentError);
  });
}
