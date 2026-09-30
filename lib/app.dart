import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'views/pin/pin_pages.dart';
import 'views/shell/shell_page.dart';

ThemeData temaApp() => ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E9E)),
      visualDensity: VisualDensity.standard,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _iniciado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;
    AppScope.of(context).auth
      ..monitorarCicloDeVida()
      ..iniciar();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    return MaterialApp(
      title: 'App Pai',
      debugShowCheckedModeBanner: false,
      theme: temaApp(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => TravaPin(auth: auth, child: child!),
      home: const ShellPage(),
    );
  }
}
