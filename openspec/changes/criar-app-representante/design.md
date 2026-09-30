# Design

## Context

Projeto novo: hoje o repositório tem só `DADOS.xlsx` (mock) e o OpenSpec. O Flutter instalado é o 3.47.x stable (Dart 3.13). A motivação e o escopo estão em `proposal.md`, e o comportamento está em `specs/`.

Restrições que moldam o desenho:
- Um único usuário, um único tablet (Android é o alvo principal; Windows serve para desenvolvimento e depuração), totalmente offline.
- Estado só com recursos nativos do Flutter. Nada de Provider, Riverpod, Bloc, GetX etc.
- Persistência com Drift (SQLite).
- Os dados reais podem ter milhares de compras. Filtros e ordenação não podem depender de carregar tudo na memória.

## Goals / Non-Goals

**Goals:**
- MVC legível, sem camadas extras que não se pagam: Model (Drift + serviços), Controller (`ChangeNotifier`) e View (widgets).
- Um único componente de tabela, reutilizado nas 4 telas de tabela.
- Filtro, ordenação, paginação e totais calculados no SQLite.
- Valores monetários exatos (centavos inteiros).

**Non-Goals:**
- Multiusuário, sincronização, backup em nuvem, integração com ERP ou API.
- Suporte a telefone (layout pensado para tablet; em telas pequenas funciona, mas não é otimizado).
- Recuperação de PIN esquecido (veja Open Questions).
- Internacionalização além de pt-BR.

## Decisions

### 1. Estrutura MVC

```
lib/
  main.dart                 # abre o banco, cria o AppScope e roda o App
  app.dart                  # MaterialApp, tema, rotas, trava de PIN
  core/                     # utilitários puros (sem Flutter/Drift)
    money.dart              # centavos <-> texto pt-BR
    cnpj.dart               # validação e formatação
    text_normalize.dart     # maiúsculas, remoção de acentos
    formatters.dart         # TextInputFormatters (CEP, telefone, moeda, maiúsculas)
  models/
    database/
      app_database.dart     # @DriftDatabase, migrações, função SQL unaccent
      tables.dart           # Clientes, Produtos, Compras, Configuracoes
      daos/                 # ClientesDao, ProdutosDao, ComprasDao, ConsultaDao, AnaliticoDao, ConfigDao
    table_query.dart        # TableQuery, ColumnDef, Filter (descrição da consulta de tabela)
    services/
      pin_service.dart
      planilha_import_service.dart
      planilha_export_service.dart
  controllers/
    auth_controller.dart
    home_controller.dart
    table_controller.dart   # base genérica: query + página + resultado
    clientes_controller.dart / produtos_controller.dart / compras_controller.dart / consulta_controller.dart
    form controllers        # cliente_form_controller.dart etc.
    import_controller.dart
  views/
    shell/                  # NavigationRail + páginas
    pin/  home/  clientes/  produtos/  compras/  consulta/  importacao/
    widgets/data_table_view.dart, filter_bar.dart, bar_chart.dart ...
```

- **Model** = tabelas Drift, DAOs com as consultas e serviços sem UI (PIN, planilha).
- **Controller** = `ChangeNotifier` por tela (ou por formulário). Recebe DAOs e serviços pelo construtor, expõe estado imutável e métodos de ação.
- **View** = widgets que só leem o controller (`ListenableBuilder` / `ValueListenableBuilder`) e chamam ações.
- *Alternativa descartada:* uma camada Repository sobre os DAOs. Os DAOs do Drift já cumprem esse papel, e um repositório só repassaria chamadas.

### 2. Injeção de dependências com `InheritedWidget`

Um `AppScope extends InheritedWidget` guarda `AppDatabase`, os DAOs, os serviços e o `AuthController`, que é global. Os controllers de tela são criados no `State` da página (`initState`) e descartados no `dispose`. Assim, cada tela tem seu estado próprio.

**Exceção:** os controllers das 4 tabelas vivem no `AppScope`, durante toda a sessão, para atender o requisito "Estado de filtros por tela" (voltar do formulário mantém filtros e página).

*Alternativa:* `get_it`. Foi descartada para manter "somente nativo".

### 3. Drift: esquema

| Tabela | Colunas principais |
|---|---|
| `clientes` | id PK, fantasia (NOT NULL), razao_social, cnpj (UNIQUE, só dígitos, nullable), insc_estadual, contato, ddd, telefone, cep, rua, bairro, cidade, criado_em, atualizado_em |
| `produtos` | id PK, reduzido (INT UNIQUE NOT NULL), descricao (NOT NULL), preco_padrao_centavos (INT NOT NULL) |
| `compras` | id PK, cliente_id FK → clientes (RESTRICT), produto_id FK → produtos (RESTRICT), data (DATE), quantidade (INT > 0), valor_unitario_centavos (INT), sequencia (INT nullable) |
| `configuracoes` | chave PK, valor (TEXT): hash e salt do PIN |

- O **Valor Total não é gravado**. Ele é calculado como `quantidade * valor_unitario_centavos` nas consultas. Isso evita inconsistência, e a regra "total não editável" sai de graça.
- `PRAGMA foreign_keys = ON` + `ON DELETE RESTRICT` garantem no banco a regra "não excluir cliente ou produto com compras". O DAO conta as compras antes, para mostrar a mensagem.
- Índices: `compras(data)`, `compras(cliente_id)`, `compras(produto_id)`, `compras(cliente_id, produto_id, data, sequencia, quantidade)` (checagem de duplicata na importação).
- `schemaVersion = 1` com `MigrationStrategy` já configurada, para as próximas versões.
- *Alternativa:* guardar reais como `REAL`. Foi descartada porque o ruído de ponto flutuante já aparece na planilha (`73.0699999`).

### 4. Busca e ordenação sem acento: função SQL `unaccent`

Na abertura do banco (`NativeDatabase.createInBackground(..., setup: ...)`), é registrada a função determinística `unaccent(text)`, que remove acentos e converte para minúsculas. Busca, filtros "contém" e ordenação de texto usam `unaccent(coluna)`.

*Alternativa:* colunas-sombra normalizadas em cada tabela. Funciona, mas duplica dados e exige manutenção em toda escrita. Com poucos milhares de linhas, a função custa pouco.

### 5. Tabelas genéricas: `TableQuery` + `ColumnDef` + DAO por tela

- `ColumnDef` descreve cada coluna: id, rótulo, tipo (`texto`, `categoria`, `inteiro`, `moeda`, `data`), a expressão Drift correspondente, se é ordenável e se é filtrável.
- `TableQuery` é um valor imutável: `busca`, `List<Filtro>`, `ordenarPor`, `crescente`, `pagina`, `tamanhoPagina`.
- Cada DAO de tabela expõe `buscarPagina(TableQuery)`, `contar(TableQuery)` e, quando há rodapé, `somar(TableQuery)`. Todos usam o mesmo `WHERE` montado a partir das `ColumnDef`s.
- `TableController<T>` (`ChangeNotifier`) guarda a query, dispara a consulta a cada mudança, com debounce de 300 ms na busca, e expõe `carregando`, `linhas`, `total` e `somas`.
- A Consulta Geral usa um join `compras ⋈ clientes ⋈ produtos` no `ConsultaDao`, com o mesmo mecanismo.

### 6. Widget de tabela: `TableView` do pacote `two_dimensional_scrollables`

O pacote é mantido pelo time do Flutter e oferece rolagem nos dois eixos com linha e coluna fixas, que a Consulta Geral (18 colunas, Fantasia fixa) exige. Um único `DataTableView` envolve esse widget: cabeçalho clicável com seta de ordenação, chips de filtro, paginação e rodapé de totais. Ele é usado nas 4 telas.

*Alternativa:* `DataTable` / `PaginatedDataTable` do Material. Não fixam a primeira coluna e montam todas as células de uma vez.

### 7. Navegação e trava de PIN

- `MaterialApp` com `Navigator` imperativo (`push` para formulários). Não há deep links, então `go_router` seria excesso.
- Shell com `NavigationRail` (Home, Consulta Geral, Clientes, Produtos, Compras, Importar/Exportar, Configurações/Trocar PIN).
- `MaterialApp.builder` envolve o app em um `Stack`: quando `AuthController.bloqueado` é verdadeiro, a tela de PIN cobre tudo e o conteúdo abaixo fica `Offstage`. Assim, o estado de navegação é preservado depois do desbloqueio.
- Um `AppLifecycleListener` registra o horário de `paused`/`hidden`. No `resumed`, se passaram 5 minutos ou mais, o app chama `bloquear()`.
- O contador de tentativas e o bloqueio de 30 s ficam em memória, no `AuthController`.

### 8. PIN

Salt aleatório de 16 bytes (`Random.secure`). O hash é `sha256` iterado 10.000 vezes sobre `salt + pin` (pacote `crypto`), e os dois são guardados em `configuracoes`. A comparação é em tempo constante. Não há dependência de keystore do sistema.

*Alternativa:* `flutter_secure_storage`. Foi descartada: não resolve o caso real (um PIN de 4 dígitos é quebrável offline de qualquer forma se o banco for extraído) e adiciona dependência nativa. A proteção pretendida é contra uso casual do tablet.

### 9. Importação e exportação

- Leitura e escrita com o pacote `excel`. A escolha do arquivo usa `file_picker`. O arquivo exportado é salvo em diretório temporário e oferecido por `share_plus` (compartilhar) e `FilePicker.saveFile` (salvar em uma pasta).
- A importação acontece em duas fases: `analisar(bytes)` roda em `Isolate.run`, faz o parse e a validação e devolve um `PlanoImportacao` (criar e atualizar, rejeitadas, avisos). Depois, `aplicar(plano)` grava tudo em uma única `transaction` do Drift.
- Mapeamento de colunas pelo cabeçalho normalizado (sem acento, maiúsculas, `trim`): `CID ` → `CID`, `SEQUÊNC` → `SEQUENC`.
- DDD e ZAP: a planilha usa as duas colunas de forma inconsistente (em geral, DDD contém o número completo). Regra: se DDD tem mais de 2 dígitos e ZAP está vazio, o valor vai para telefone e o DDD fica vazio. Caso contrário, cada coluna vai para seu campo.
- Datas: numéricas são tratadas como serial do Excel (base 1899-12-30). Texto é lido como `dd/mm/aaaa`.
- A exportação gera 17 colunas + TOTAL, na ordem do layout, e isso fecha o ciclo de reimportação sem duplicatas.

### 10. Home analítica

`AnaliticoDao` com consultas agregadas (`SUM`, `COUNT DISTINCT`, `GROUP BY strftime('%Y-%m', data)`) parametrizadas pelo período. O gráfico de barras é um widget próprio (`CustomPaint` ou `Row` de barras), sem biblioteca de gráficos. É só um gráfico de 12 barras.

*Alternativa:* `fl_chart`. É mais completo, mas é uma dependência a mais para um único gráfico simples.

### 11. Formulários

`Form` + `TextFormField` com validadores do `core/`, e um controller de formulário (`ChangeNotifier`) por tela, que guarda o registro, o flag `sujo` (usado no `PopScope` para confirmar o descarte) e as ações `salvar`/`excluir`. Cliente e Produto na compra usam `Autocomplete`/`SearchAnchor` alimentados por consultas do DAO. O Valor Total é um `ValueListenableBuilder` sobre quantidade e valor unitário.

### 12. Testes

- Unitários (`package:test`): `core/` (dinheiro, CNPJ, normalização), parse da importação (incluindo linhas deslocadas do mock como rejeitadas) e PIN.
- DAOs com `NativeDatabase.memory()`: filtros, ordenação, paginação, somas, restrição de exclusão e duplicatas.
- Widgets: criação e desbloqueio de PIN, adicionar pela tabela, regra de preço no formulário de compra.
- `DADOS.xlsx` é copiado para `test/fixtures/` como fixture de layout.

## Risks / Trade-offs

- [PIN esquecido: sem recuperação, só reinstalando o app, o que apaga os dados] → Orientar que a exportação serve de backup. Veja Open Questions.
- [Perda ou quebra do tablet apaga os dados, já que não há nuvem] → A exportação `.xlsx` com compartilhamento facilita backup manual (ex.: enviar para si mesmo pelo WhatsApp ou e-mail).
- [Pacote `excel` lento ou com muita memória em planilhas grandes] → O parse roda em isolate. Com dezenas de milhares de linhas, avaliar um parser por streaming depois.
- [Planilha real com layout diferente do mock (colunas deslocadas)] → Mapeamento por cabeçalho, relatório de linhas rejeitadas e confirmação antes de gravar.
- [`unaccent` customizado não usa índice na busca] → Aceitável para o volume esperado. Se ficar lento, migrar para colunas-sombra indexadas.
- [SHA-256 iterado não é KDF de verdade] → Aceito, dado o modelo de ameaça (uso casual) e o espaço de 4 a 6 dígitos.
- [Versões dos pacotes em 2026 podem ter mudado de API (ex.: `drift_flutter`, `file_picker`)] → Fixar versões no `pubspec.yaml` na criação e conferir no pub.dev.

## Migration Plan

Não há migração de dados: o app começa vazio e recebe os dados reais pela importação. Drift `schemaVersion = 1`. Futuras mudanças de esquema usam `onUpgrade` com testes de migração (`drift_dev schema dump`). Distribuição: APK de release instalado direto no tablet (sem loja).

## Open Questions

- Recuperação de PIN esquecido: manter sem recuperação, ou oferecer uma "frase de recuperação" definida junto com o PIN? Pode ser adicionado depois sem mudar o esquema (é só mais uma chave em `configuracoes`).
- O alvo é mesmo só Android, ou também iPad? O desenho não muda, mas afeta a configuração de plataforma e o teste de `file_picker`/`share_plus`.
