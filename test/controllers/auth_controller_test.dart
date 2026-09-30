import 'package:app_pai/controllers/auth_controller.dart';
import 'package:app_pai/models/database/app_database.dart';
import 'package:app_pai/models/services/pin_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../models/database/helpers.dart';

void main() {
  late AppDatabase db;
  late PinService pin;
  late DateTime agora;
  late AuthController auth;

  setUp(() {
    db = bancoDeTeste();
    pin = PinService(db.configDao);
    agora = DateTime(2026, 6, 1, 10);
    auth = AuthController(pin, relogio: () => agora);
  });
  tearDown(() async {
    auth.dispose();
    await db.close();
  });

  test('sem PIN no primeiro acesso', () async {
    expect(auth.estado, EstadoAuth.carregando);
    await auth.iniciar();
    expect(auth.estado, EstadoAuth.semPin);
    expect(auth.bloqueado, isTrue);
  });

  test('criar PIN: tamanho, confirmação e sucesso', () async {
    await auth.iniciar();
    expect(await auth.criarPin('123', '123'), contains('4 a 6'));
    expect(await auth.criarPin('1234', '1235'), 'Os PINs não conferem');
    expect(await pin.temPin(), isFalse);

    expect(await auth.criarPin('1234', '1234'), isNull);
    expect(auth.estado, EstadoAuth.desbloqueado);
  });

  test('com PIN cadastrado inicia bloqueado', () async {
    await pin.definir('1234');
    await auth.iniciar();
    expect(auth.estado, EstadoAuth.bloqueado);
    expect(await auth.entrar('1111'), ResultadoLogin.incorreto);
    expect(auth.estado, EstadoAuth.bloqueado);
    expect(await auth.entrar('1234'), ResultadoLogin.sucesso);
    expect(auth.estado, EstadoAuth.desbloqueado);
  });

  test('5 erros seguidos: espera de 30 s', () async {
    await pin.definir('1234');
    await auth.iniciar();
    for (var i = 0; i < 4; i++) {
      expect(await auth.entrar('0000'), ResultadoLogin.incorreto);
      expect(auth.esperaRestante, Duration.zero);
    }
    expect(await auth.entrar('0000'), ResultadoLogin.incorreto);
    expect(auth.esperaRestante, const Duration(seconds: 30));

    // Nem o PIN certo entra durante a espera.
    agora = agora.add(const Duration(seconds: 10));
    expect(auth.esperaRestante, const Duration(seconds: 20));
    expect(await auth.entrar('1234'), ResultadoLogin.aguardando);
    expect(auth.bloqueado, isTrue);

    agora = agora.add(const Duration(seconds: 20));
    expect(auth.esperaRestante, Duration.zero);
    expect(await auth.entrar('1234'), ResultadoLogin.sucesso);
  });

  test('acerto zera a contagem de erros', () async {
    await pin.definir('1234');
    await auth.iniciar();
    for (var i = 0; i < 4; i++) {
      await auth.entrar('0000');
    }
    await auth.entrar('1234');
    auth.bloquear();
    await auth.entrar('0000');
    expect(auth.esperaRestante, Duration.zero);
  });

  test('rebloqueia só após 5 minutos em segundo plano', () async {
    await auth.iniciar();
    await auth.criarPin('1234', '1234');

    auth.aoIrParaSegundoPlano();
    agora = agora.add(const Duration(minutes: 4, seconds: 59));
    auth.aoRetomar();
    expect(auth.estado, EstadoAuth.desbloqueado);

    auth.aoIrParaSegundoPlano();
    agora = agora.add(const Duration(minutes: 5));
    auth.aoRetomar();
    expect(auth.estado, EstadoAuth.bloqueado);
  });

  test('onHide seguido de onPause conta desde o primeiro evento', () async {
    await auth.iniciar();
    await auth.criarPin('1234', '1234');
    auth.aoIrParaSegundoPlano();
    agora = agora.add(const Duration(minutes: 3));
    auth.aoIrParaSegundoPlano();
    agora = agora.add(const Duration(minutes: 2));
    auth.aoRetomar();
    expect(auth.estado, EstadoAuth.bloqueado);
  });

  test('trocar PIN', () async {
    await auth.iniciar();
    await auth.criarPin('1234', '1234');
    expect(await auth.trocarPin('0000', '5678', '5678'), 'PIN atual incorreto');
    expect(await auth.trocarPin('1234', '5678', '5679'), 'Os PINs não conferem');
    expect(await pin.verificar('1234'), isTrue);
    expect(await auth.trocarPin('1234', '5678', '5678'), isNull);
    expect(await pin.verificar('5678'), isTrue);
  });
}
