import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../database/daos/config_dao.dart';

/// Criação, verificação e troca do PIN de acesso.
///
/// O PIN nunca é gravado: só um hash SHA-256 iterado sobre `salt + pin`,
/// com salt aleatório de 16 bytes.
class PinService {
  PinService(this._config, {Random? random}) : _random = random ?? Random.secure();

  final ConfigDao _config;
  final Random _random;

  static const chaveHash = 'pin_hash';
  static const chaveSalt = 'pin_salt';
  static const iteracoes = 10000;
  static const tamanhoMinimo = 4;
  static const tamanhoMaximo = 6;

  /// PIN numérico de 4 a 6 dígitos.
  static bool formatoValido(String pin) => RegExp(r'^\d{4,6}$').hasMatch(pin);

  Future<bool> temPin() async => await _config.ler(chaveHash) != null;

  /// Grava um novo PIN (substitui o anterior).
  Future<void> definir(String pin) async {
    if (!formatoValido(pin)) {
      throw ArgumentError.value(pin, 'pin', 'PIN deve ter de 4 a 6 dígitos');
    }
    final salt = List<int>.generate(16, (_) => _random.nextInt(256));
    await _config.gravarVarios({
      chaveSalt: base64Encode(salt),
      chaveHash: base64Encode(_hash(salt, pin)),
    });
  }

  Future<bool> verificar(String pin) async {
    final hash = await _config.ler(chaveHash);
    final salt = await _config.ler(chaveSalt);
    if (hash == null || salt == null) return false;
    return _iguais(_hash(base64Decode(salt), pin), base64Decode(hash));
  }

  /// Troca o PIN se [atual] estiver correto. Retorna se trocou.
  Future<bool> trocar(String atual, String novo) async {
    if (!await verificar(atual)) return false;
    await definir(novo);
    return true;
  }

  static List<int> _hash(List<int> salt, String pin) {
    final entrada = [...salt, ...utf8.encode(pin)];
    var h = sha256.convert(entrada).bytes;
    for (var i = 1; i < iteracoes; i++) {
      h = sha256.convert([...h, ...entrada]).bytes;
    }
    return h;
  }

  /// Comparação em tempo constante.
  static bool _iguais(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
