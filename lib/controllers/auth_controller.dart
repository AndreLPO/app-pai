import 'package:flutter/widgets.dart';

import '../models/services/pin_service.dart';

enum EstadoAuth { carregando, semPin, bloqueado, desbloqueado }

enum ResultadoLogin { sucesso, incorreto, aguardando }

/// Estado de acesso do app: criação do PIN, login, espera após erros e
/// rebloqueio ao voltar do segundo plano.
class AuthController extends ChangeNotifier {
  AuthController(this._pin, {DateTime Function()? relogio})
      : _agora = relogio ?? DateTime.now;

  final PinService _pin;
  final DateTime Function() _agora;

  static const maxTentativas = 5;
  static const espera = Duration(seconds: 30);
  static const tempoRebloqueio = Duration(minutes: 5);

  EstadoAuth _estado = EstadoAuth.carregando;
  EstadoAuth get estado => _estado;

  bool get bloqueado => _estado != EstadoAuth.desbloqueado;

  int _erros = 0;
  DateTime? _aguardarAte;
  DateTime? _foiParaSegundoPlano;
  AppLifecycleListener? _ciclo;

  /// Tempo restante de espera após [maxTentativas] erros (zero = liberado).
  Duration get esperaRestante {
    final ate = _aguardarAte;
    if (ate == null) return Duration.zero;
    final resto = ate.difference(_agora());
    return resto.isNegative ? Duration.zero : resto;
  }

  /// Lê se já existe PIN (só na primeira chamada).
  Future<void> iniciar() async {
    if (_estado != EstadoAuth.carregando) return;
    _estado = await _pin.temPin() ? EstadoAuth.bloqueado : EstadoAuth.semPin;
    notifyListeners();
  }

  /// Valida e grava o primeiro PIN. Retorna a mensagem de erro, se houver.
  Future<String?> criarPin(String pin, String confirmacao) async {
    final erro = validarNovoPin(pin, confirmacao);
    if (erro != null) return erro;
    await _pin.definir(pin);
    _estado = EstadoAuth.desbloqueado;
    notifyListeners();
    return null;
  }

  Future<ResultadoLogin> entrar(String pin) async {
    if (esperaRestante > Duration.zero) return ResultadoLogin.aguardando;
    if (await _pin.verificar(pin)) {
      _erros = 0;
      _aguardarAte = null;
      _estado = EstadoAuth.desbloqueado;
      notifyListeners();
      return ResultadoLogin.sucesso;
    }
    _erros++;
    if (_erros >= maxTentativas) {
      _erros = 0;
      _aguardarAte = _agora().add(espera);
    }
    notifyListeners();
    return ResultadoLogin.incorreto;
  }

  /// Troca o PIN. Retorna a mensagem de erro, se houver.
  Future<String?> trocarPin(String atual, String novo, String confirmacao) async {
    final erro = validarNovoPin(novo, confirmacao);
    if (erro != null) return erro;
    if (!await _pin.trocar(atual, novo)) return 'PIN atual incorreto';
    return null;
  }

  static String? validarNovoPin(String pin, String confirmacao) {
    if (!PinService.formatoValido(pin)) {
      return 'O PIN deve ter de ${PinService.tamanhoMinimo} a '
          '${PinService.tamanhoMaximo} dígitos';
    }
    if (pin != confirmacao) return 'Os PINs não conferem';
    return null;
  }

  void bloquear() {
    if (_estado != EstadoAuth.desbloqueado) return;
    _estado = EstadoAuth.bloqueado;
    notifyListeners();
  }

  void aoIrParaSegundoPlano() => _foiParaSegundoPlano ??= _agora();

  void aoRetomar() {
    final desde = _foiParaSegundoPlano;
    _foiParaSegundoPlano = null;
    if (desde != null && _agora().difference(desde) >= tempoRebloqueio) {
      bloquear();
    }
  }

  /// Liga o rebloqueio ao ciclo de vida do app (chamado uma vez no app).
  void monitorarCicloDeVida() {
    _ciclo ??= AppLifecycleListener(
      onHide: aoIrParaSegundoPlano,
      onPause: aoIrParaSegundoPlano,
      onResume: aoRetomar,
    );
  }

  @override
  void dispose() {
    _ciclo?.dispose();
    super.dispose();
  }
}
