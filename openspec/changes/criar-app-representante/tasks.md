# Tasks

## 1. Setup do projeto

- [ ] 1.1 Criar o projeto Flutter na raiz (`flutter create --org br.com.apppai --platforms android,windows --project-name app_pai .`) com o Flutter stable mais recente e verificar que `flutter run -d windows` abre o app padrão
- [x] 1.2 Adicionar ao `pubspec.yaml` as dependências `drift`, `drift_flutter`, `path_provider`, `two_dimensional_scrollables`, `excel`, `file_picker`, `share_plus`, `crypto`, `intl` e, em dev, `drift_dev`, `build_runner` e `test`, com versões fixadas conferidas no pub.dev; verificar que `flutter pub get` conclui sem conflitos
- [x] 1.3 Criar a estrutura de pastas `lib/core`, `lib/models`, `lib/controllers`, `lib/views` e `test/fixtures` conforme o design, copiar `DADOS.xlsx` para `test/fixtures/`, configurar `analysis_options.yaml` (lints recomendados) e verificar que `flutter analyze` passa sem problemas
- [ ] 1.4 Configurar Android para tablet (orientação paisagem preferencial, nome do app, `minSdk` exigido pelos pacotes) e verificar que `flutter build apk --debug` conclui

## 2. Utilitários do core

- [x] 2.1 Implementar `core/money.dart` (centavos inteiros ↔ texto `R$ 1.234,56`, parse de entrada pt-BR, arredondamento de `double` para centavos) e verificar com testes unitários, incluindo `73.06999999999999 → 7307` e `93 × 7307 = R$ 6.795,51`
- [x] 2.2 Implementar `core/cnpj.dart` (limpar, validar dígitos verificadores, formatar `00.000.000/0000-00`) e verificar com testes de CNPJ válido, inválido e com máscara
- [x] 2.3 Implementar `core/text_normalize.dart` (maiúsculas, remoção de acentos, comparação normalizada) e verificar com testes (`"SÃO LUIZ"` corresponde a `"sao luiz"`)
- [x] 2.4 Implementar `core/formatters.dart` (TextInputFormatters de maiúsculas, CEP, telefone, DDD e moeda) e verificar com testes unitários de formatação

## 3. Banco de dados (Model)

- [x] 3.1 Definir em `models/database/tables.dart` as tabelas `clientes`, `produtos`, `compras` e `configuracoes` (FKs com RESTRICT, UNIQUE em cnpj e reduzido, índices do design) e gerar o código com `dart run build_runner build`, verificando que gera sem erros
- [x] 3.2 Implementar `AppDatabase` com `schemaVersion = 1`, `MigrationStrategy`, `PRAGMA foreign_keys = ON` e registro da função SQL `unaccent`; verificar com teste em `NativeDatabase.memory()` que `SELECT unaccent('SÃO')` retorna `sao` e que excluir um cliente com compra falha
- [x] 3.3 Implementar `models/table_query.dart` (`ColumnDef`, tipos de coluna, `Filtro`, `TableQuery` imutável) e um construtor de `WHERE`/`ORDER BY` reutilizável; verificar com testes unitários da combinação busca + filtros
- [x] 3.4 Implementar `ProdutosDao` (CRUD, busca por reduzido/descrição, página, contagem, contagem de compras vinculadas, quantidade vendida e última venda) e verificar com testes de DAO: reduzido duplicado, ordenação numérica, filtro por faixa de preço
- [x] 3.5 Implementar `ClientesDao` (CRUD, busca por fantasia/razão/CNPJ, página com última compra, filtro "sem compra há mais de 60 dias", contagem de compras vinculadas) e verificar com testes de DAO: CNPJ duplicado, busca sem acento, cliente sem compras por último na ordenação decrescente
- [x] 3.6 Implementar `ComprasDao` (CRUD, página com join de cliente e produto, total calculado, somas de quantidade e total filtrados, histórico por cliente) e verificar com testes de DAO: ordenação padrão por data decrescente e somas considerando todas as páginas
- [x] 3.7 Implementar `ConsultaDao` (join das 18 colunas da consulta geral, página, contagem e somas) e verificar com teste de DAO que filtra cidade + produto corretamente
- [x] 3.8 Implementar `AnaliticoDao` (indicadores por período, top 5 produtos e clientes, série dos últimos 12 meses com meses vazios zerados, contagem de clientes inativos) e verificar com teste de DAO usando o cenário da spec (R$ 100 + R$ 50 + R$ 30 → total R$ 180, 2 clientes, ticket R$ 90)

## 4. Estrutura do app, AppScope e navegação

- [ ] 4.1 Implementar `AppScope` (`InheritedWidget` com banco, DAOs, serviços, `AuthController` e controllers de tabela da sessão) e `main.dart` abrindo o banco via `drift_flutter`; verificar que o app inicia no Windows sem erros
- [x] 4.2 Implementar o tema Material 3 pt-BR (`intl` inicializado, `Locale('pt','BR')`) e o shell com `NavigationRail` (Home, Consulta Geral, Clientes, Produtos, Compras, Importar/Exportar, Trocar PIN); verificar com widget test que cada item navega para a página correspondente

## 5. Acesso por PIN

- [x] 5.1 Implementar `PinService` (salt de 16 bytes, SHA-256 iterado 10.000×, gravar e verificar em `configuracoes`, comparação em tempo constante) e verificar com testes que o PIN não aparece em texto puro no banco e que a verificação aceita só o PIN certo
- [x] 5.2 Implementar `AuthController` (estados sem PIN/bloqueado/desbloqueado, 5 erros → espera de 30 s, `AppLifecycleListener` com rebloqueio após 5 minutos em segundo plano) e verificar com testes unitários usando relógio injetável
- [x] 5.3 Implementar as telas Criar PIN (4–6 dígitos, confirmação), Login por PIN e Trocar PIN, com a trava em `MaterialApp.builder` que preserva a navegação abaixo; verificar com widget tests os cenários da spec `acesso-pin` (primeiro acesso, confirmação diferente, PIN incorreto, bloqueio após 5 erros, troca)

## 6. Componente de tabela genérico

- [x] 6.1 Implementar `TableController<T>` (`ChangeNotifier` com `TableQuery`, debounce de 300 ms na busca, carregamento, linhas, total, somas, `limparFiltros`) e verificar com testes unitários usando um DAO falso
- [x] 6.2 Implementar `DataTableView` sobre `TableView` (cabeçalho fixo, primeira coluna fixa opcional, toque no cabeçalho alterna crescente/decrescente com seta, toque na linha dispara callback), `FilterBar` (busca, filtros por tipo, chips removíveis, "Limpar filtros"), paginação de 50 e rodapé de totais; verificar com widget test a ordenação por toque, a remoção de chip e a paginação

## 7. Produtos

- [x] 7.1 Implementar `ProdutosController` e a página de tabela de Produtos (colunas e ordenação padrão da spec, botão "Adicionar") e verificar com widget test que a tabela lista os produtos do banco em memória
- [x] 7.2 Implementar o formulário de Produto (criar, editar, excluir com confirmação, bloqueio de exclusão com compras, reduzido único, preço em moeda, confirmação ao sair com alterações) e verificar com widget tests os cenários da spec `cadastro-produtos`

## 8. Clientes

- [x] 8.1 Implementar `ClientesController` e a página de tabela de Clientes (colunas, última compra, filtro de inativos acionável pela Home) e verificar com widget test a ordenação padrão por Fantasia
- [x] 8.2 Implementar o formulário de Cliente (maiúsculas, máscaras, validação e unicidade de CNPJ, exclusão bloqueada com compras, histórico de compras, botão "Nova compra") e verificar com widget tests os cenários da spec `cadastro-clientes`

## 9. Compras

- [x] 9.1 Implementar `ComprasController` e a página de tabela de Compras (colunas, ordenação padrão por data decrescente, rodapé com somas filtradas) e verificar com widget test o rodapé após filtrar por produto
- [x] 9.2 Implementar o formulário de Compra (busca de cliente e produto, data padrão hoje, preço sugerido pelo preço padrão e editável, substituição ao trocar de produto, total calculado ao vivo e não editável, cliente pré-selecionado quando aberto pelo cliente) e verificar com widget tests os cenários da spec `registro-compras`

## 10. Consulta Geral

- [x] 10.1 Implementar `ConsultaController` e a página Consulta Geral (18 colunas na ordem da spec, Fantasia fixa, filtros rápidos Cidade/Produto/Cliente/Período, ocultar e reexibir colunas, rodapé de totais, toque abre o formulário da compra) e verificar com widget tests os cenários da spec `consulta-geral`

## 11. Home analítica

- [x] 11.1 Implementar `HomeController` (período selecionado, carga dos agregados) e verificar com teste unitário que trocar o período recarrega os indicadores
- [x] 11.2 Implementar a página Home (seletor de período, cards de indicadores, top 5 produtos e clientes, gráfico de 12 barras próprio, card de clientes inativos que abre a tabela de Clientes filtrada, estado "sem dados no período") e verificar com widget tests os cenários da spec `home-analitica`

## 12. Importação e exportação de planilha

- [x] 12.1 Implementar a fase de análise do `PlanilhaImportService` (mapeamento por cabeçalho normalizado, regra DDD/ZAP, datas serial e `dd/mm/aaaa`, arredondamento de VALOR, linhas só de cliente, rejeições com motivo, avisos de CNPJ inválido, plano de criar e atualizar), rodando em `Isolate.run`; verificar com testes usando `test/fixtures/DADOS.xlsx` (linhas deslocadas do mock rejeitadas com motivo, `45911 → 11/09/2025`) e um arquivo sem a coluna PRODUTO
- [x] 12.2 Implementar a fase de aplicação (transação única; cliente por CNPJ ou fantasia + razão; produto por RED com preço da linha mais recente; compra duplicada ignorada) e verificar com teste de DAO que importar o mesmo arquivo duas vezes não cria registros na segunda
- [x] 12.3 Implementar o `PlanilhaExportService` (aba "CLIENTES", 17 cabeçalhos + TOTAL, datas como data do Excel, clientes sem compras em linha própria, nome `dados_aaaa-mm-dd.xlsx`) e verificar com teste que exportar e reimportar não cria duplicatas
- [x] 12.4 Implementar `ImportController` e a página Importar/Exportar (escolher arquivo, resumo com contagens, rejeitadas e avisos, confirmar ou cancelar, exportar com salvar ou compartilhar) e verificar com widget test que cancelar após o resumo não grava nada

## 13. Integração e entrega

- [x] 13.1 Rodar `flutter analyze` e `flutter test` completos e verificar que passam sem falhas
- [ ] 13.2 Teste manual em tablet Android ou emulador de tablet: criar PIN, importar uma planilha limpa, conferir a Home, filtrar e ordenar as 4 tabelas, cadastrar uma compra com preço negociado, exportar e compartilhar; verificar que todos os fluxos funcionam e anotar problemas
- [ ] 13.3 Escrever um `README.md` com como rodar, gerar código Drift, gerar o APK (`flutter build apk --release`) e fazer backup pela exportação, e verificar que os comandos documentados rodam como escritos
