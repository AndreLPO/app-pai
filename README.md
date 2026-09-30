# App Pai

Apoio de vendas offline para representante comercial, pensado para tablet
Android. Substitui a planilha `DADOS.xlsx`: cadastros de clientes, produtos e
compras, consulta no layout da planilha, Home com indicadores e
importação/exportação `.xlsx`. Os dados ficam só no aparelho (SQLite via
Drift); não há servidor nem internet.

## Pré-requisitos

- Flutter stable 3.47 ou mais novo (`flutter --version`).
- Para gerar o APK: Android SDK configurado (`flutter doctor` sem erros em
  "Android toolchain").
- Para rodar no Windows (desenvolvimento): Visual Studio com a carga de
  trabalho "Desenvolvimento para desktop com C++".

## Rodar

```sh
flutter pub get
flutter run -d windows      # desenvolvimento no PC
flutter run                 # tablet ou emulador Android conectado
```

No primeiro acesso o app pede para criar um PIN de 4 a 6 dígitos.

## Gerar o código do Drift

As tabelas ficam em `lib/models/database/tables.dart` e os DAOs em
`lib/models/database/daos/`. Depois de alterá-los, gere os arquivos `*.g.dart`:

```sh
dart run build_runner build
```

Ao mudar o esquema, aumente `schemaVersion` em
`lib/models/database/app_database.dart` e escreva a migração em `onUpgrade`.

## Testes e análise

```sh
flutter analyze
flutter test
```

`test/fixtures/DADOS.xlsx` é a planilha de exemplo usada nos testes de
importação.

## Gerar o APK

```sh
flutter build apk --release
```

O arquivo sai em `build/app/outputs/flutter-apk/app-release.apk`. Copie para o
tablet e instale (é preciso permitir a instalação de fontes desconhecidas).
O APK de release está assinado com a chave de debug; para distribuir fora do
seu próprio tablet, configure uma chave de assinatura em
`android/app/build.gradle.kts`.

## Backup

Não há backup automático: se o tablet for perdido, reinstalado ou se o PIN
for esquecido, os dados se perdem. Faça backups pela exportação:

1. Abra **Importar/Exportar** e toque em **Exportar**.
2. Escolha **Compartilhar** (ex.: enviar para você mesmo pelo WhatsApp ou
   e-mail) ou **Salvar** em uma pasta. O arquivo se chama
   `dados_aaaa-mm-dd.xlsx`.

Para restaurar, instale o app, crie o PIN e importe esse arquivo em
**Importar/Exportar → Escolher arquivo**. A importação mescla com os dados
existentes sem duplicar, então pode ser repetida com segurança.

## Estrutura

```
lib/
  main.dart, app.dart, app_scope.dart   abertura do banco, tema, trava de PIN, injeção
  core/          dinheiro (centavos), CNPJ, datas, normalização de texto, máscaras
  models/        tabelas e DAOs do Drift, TableQuery, serviços (PIN, planilha)
  controllers/   ChangeNotifiers (auth, tabelas, formulários, Home, importação)
  views/         páginas e widgets (tabela genérica, filtros, gráfico)
test/            testes unitários, de DAO (SQLite em memória) e de widgets
```
