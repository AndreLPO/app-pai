import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_scope.dart';
import '../../controllers/auth_controller.dart';
import '../../models/services/pin_service.dart';
import '../widgets/dialogos.dart';

/// Campo de PIN numérico, oculto.
class CampoPin extends StatelessWidget {
  const CampoPin({
    super.key,
    required this.controller,
    required this.rotulo,
    this.autofocus = false,
    this.focusNode,
    this.onSubmitted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String rotulo;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: enabled,
        obscureText: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, letterSpacing: 8),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(PinService.tamanhoMaximo),
        ],
        decoration: InputDecoration(
          labelText: rotulo,
          border: const OutlineInputBorder(),
          counterText: '',
        ),
        onSubmitted: onSubmitted,
      );
}

class _CartaoPin extends StatelessWidget {
  const _CartaoPin({required this.titulo, required this.children, this.subtitulo});

  final String titulo;
  final String? subtitulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.lock_outline,
                        size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(titulo,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 8),
                      Text(subtitulo!, textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 24),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class _Erro extends StatelessWidget {
  const _Erro(this.texto);

  final String? texto;

  @override
  Widget build(BuildContext context) => texto == null
      ? const SizedBox(height: 16)
      : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            texto!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        );
}

/// Primeiro acesso: define o PIN.
class CriarPinPage extends StatefulWidget {
  const CriarPinPage({super.key, required this.auth});

  final AuthController auth;

  @override
  State<CriarPinPage> createState() => _CriarPinPageState();
}

class _CriarPinPageState extends State<CriarPinPage> {
  final _pin = TextEditingController();
  final _confirmacao = TextEditingController();
  final _focoPin = FocusNode();
  String? _erro;
  bool _salvando = false;

  @override
  void dispose() {
    _pin.dispose();
    _confirmacao.dispose();
    _focoPin.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    setState(() => _salvando = true);
    final erro = await widget.auth.criarPin(_pin.text, _confirmacao.text);
    if (!mounted) return;
    setState(() {
      _salvando = false;
      _erro = erro;
    });
    if (erro != null) {
      _pin.clear();
      _confirmacao.clear();
      _focoPin.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) => _CartaoPin(
        titulo: 'Criar PIN',
        subtitulo: 'Defina um PIN de ${PinService.tamanhoMinimo} a '
            '${PinService.tamanhoMaximo} dígitos para proteger o acesso.',
        children: [
          CampoPin(
              key: const ValueKey('pin'),
              controller: _pin,
              rotulo: 'PIN',
              autofocus: true,
              focusNode: _focoPin),
          const SizedBox(height: 16),
          CampoPin(
            key: const ValueKey('confirmacao'),
            controller: _confirmacao,
            rotulo: 'Confirmar PIN',
            onSubmitted: (_) => _salvar(),
          ),
          _Erro(_erro),
          FilledButton(
            onPressed: _salvando ? null : _salvar,
            child: const Text('Salvar'),
          ),
        ],
      );
}

/// Desbloqueio do app.
class LoginPinPage extends StatefulWidget {
  const LoginPinPage({super.key, required this.auth});

  final AuthController auth;

  @override
  State<LoginPinPage> createState() => _LoginPinPageState();
}

class _LoginPinPageState extends State<LoginPinPage> {
  final _pin = TextEditingController();
  final _foco = FocusNode();
  String? _erro;
  Timer? _contagem;

  @override
  void initState() {
    super.initState();
    _iniciarContagemSeNecessario();
  }

  @override
  void dispose() {
    _contagem?.cancel();
    _pin.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _iniciarContagemSeNecessario() {
    if (widget.auth.esperaRestante == Duration.zero) return;
    _contagem?.cancel();
    _contagem = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {});
      if (widget.auth.esperaRestante == Duration.zero) {
        t.cancel();
        _foco.requestFocus();
      }
    });
  }

  Future<void> _entrar() async {
    final r = await widget.auth.entrar(_pin.text);
    if (!mounted || r == ResultadoLogin.sucesso) return;
    _pin.clear();
    setState(() => _erro = r == ResultadoLogin.incorreto ? 'PIN incorreto' : null);
    _iniciarContagemSeNecessario();
    _foco.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final espera = widget.auth.esperaRestante;
    final aguardando = espera > Duration.zero;
    final segundos = (espera.inMilliseconds / 1000).ceil();
    return _CartaoPin(
      titulo: 'Digite seu PIN',
      children: [
        CampoPin(
          key: const ValueKey('pin'),
          controller: _pin,
          rotulo: 'PIN',
          autofocus: true,
          focusNode: _foco,
          enabled: !aguardando,
          onSubmitted: (_) => _entrar(),
        ),
        _Erro(aguardando
            ? 'Muitas tentativas incorretas. Aguarde $segundos s para tentar de novo.'
            : _erro),
        FilledButton(
          onPressed: aguardando ? null : _entrar,
          child: const Text('Entrar'),
        ),
      ],
    );
  }
}

/// Troca do PIN, dentro do app desbloqueado.
class TrocarPinPage extends StatefulWidget {
  const TrocarPinPage({super.key});

  @override
  State<TrocarPinPage> createState() => _TrocarPinPageState();
}

class _TrocarPinPageState extends State<TrocarPinPage> {
  final _atual = TextEditingController();
  final _novo = TextEditingController();
  final _confirmacao = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _atual.dispose();
    _novo.dispose();
    _confirmacao.dispose();
    super.dispose();
  }

  Future<void> _trocar() async {
    final auth = AppScope.of(context).auth;
    final erro = await auth.trocarPin(_atual.text, _novo.text, _confirmacao.text);
    if (!mounted) return;
    setState(() => _erro = erro);
    if (erro == null) {
      _atual.clear();
      _novo.clear();
      _confirmacao.clear();
      mostrarMensagem(context, 'PIN alterado');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Trocar PIN')),
        body: _CartaoPin(
          titulo: 'Trocar PIN',
          children: [
            CampoPin(key: const ValueKey('atual'), controller: _atual, rotulo: 'PIN atual'),
            const SizedBox(height: 16),
            CampoPin(key: const ValueKey('novo'), controller: _novo, rotulo: 'Novo PIN'),
            const SizedBox(height: 16),
            CampoPin(
              key: const ValueKey('confirmacao'),
              controller: _confirmacao,
              rotulo: 'Confirmar novo PIN',
              onSubmitted: (_) => _trocar(),
            ),
            _Erro(_erro),
            FilledButton(onPressed: _trocar, child: const Text('Trocar PIN')),
          ],
        ),
      );
}

/// Cobre o app enquanto ele estiver bloqueado. O conteúdo abaixo continua
/// montado (fora de cena), preservando a navegação.
class TravaPin extends StatefulWidget {
  const TravaPin({super.key, required this.auth, required this.child});

  final AuthController auth;
  final Widget child;

  @override
  State<TravaPin> createState() => _TravaPinState();
}

class _TravaPinState extends State<TravaPin> {
  final _chaveApp = GlobalKey();
  bool _jaDesbloqueou = false;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: widget.auth,
        builder: (context, _) {
          final auth = widget.auth;
          final bloqueado = auth.bloqueado;
          if (!bloqueado) _jaDesbloqueou = true;
          return Stack(
            children: [
              // Nada é montado antes do primeiro desbloqueio.
              if (_jaDesbloqueou)
                KeyedSubtree(
                  key: _chaveApp,
                  child: Offstage(
                    offstage: bloqueado,
                    child: TickerMode(
                      enabled: !bloqueado,
                      child: ExcludeFocus(excluding: bloqueado, child: widget.child),
                    ),
                  ),
                ),
              if (bloqueado)
                Positioned.fill(
                  child: _TelaTrava(key: const ValueKey('trava'), auth: auth),
                ),
            ],
          );
        },
      );
}

class _TelaTrava extends StatelessWidget {
  const _TelaTrava({super.key, required this.auth});

  final AuthController auth;

  @override
  Widget build(BuildContext context) => HeroControllerScope.none(
        // Navigator próprio: dá Overlay aos campos, acima do app travado.
        child: Navigator(
          onGenerateRoute: (_) => MaterialPageRoute<void>(
            builder: (context) => Scaffold(
              body: ListenableBuilder(
                listenable: auth,
                builder: (context, _) => switch (auth.estado) {
                  EstadoAuth.carregando => const Center(child: CircularProgressIndicator()),
                  EstadoAuth.semPin => CriarPinPage(auth: auth),
                  _ => LoginPinPage(auth: auth),
                },
              ),
            ),
          ),
        ),
      );
}
