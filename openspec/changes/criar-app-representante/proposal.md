# Proposal

## Why

O representante de vendas (usuário único) acompanha as compras de cada cliente de supermercado em uma planilha Excel (`DADOS.xlsx`), o que é difícil de consultar, filtrar e manter no tablet durante as visitas. Um aplicativo Flutter offline, com banco local, substitui a planilha como ferramenta de apoio às vendas sem depender de API, ERP ou internet.

## What Changes

- Novo aplicativo Flutter (versão estável mais recente), voltado a tablet, 100% offline.
- Arquitetura MVC simples usando somente gerenciamento de estado nativo do Flutter (`ChangeNotifier`, `ValueNotifier`, `StatefulWidget`, `InheritedWidget`), sem pacotes de estado de terceiros.
- Persistência local com Drift (SQLite), em vez do Hive discutido anteriormente.
- Tela de acesso protegida por PIN numérico, definido no primeiro acesso.
- Home com dados analíticos básicos das compras (totais, rankings e evolução mensal).
- Três cadastros (Clientes, Produtos e Compras), cada um com tabela filtrável e ordenável por coluna, e botão "Adicionar" que abre uma tela de formulário. A mesma tela de formulário também edita e exclui registros.
- Tela "Consulta Geral": tabela única no layout da planilha (cliente + compra + produto), com filtros e ordenação.
- Importação de planilha `.xlsx` com o mesmo layout de 17 colunas de `DADOS.xlsx`, e exportação dos dados nesse mesmo layout.
- Regra de preço: cada compra guarda o valor unitário, que vem do preço padrão do produto e pode ser alterado, e mostra o valor total da linha (quantidade × valor unitário).

## Capabilities

### New Capabilities
- `acesso-pin`: criação do PIN no primeiro acesso, desbloqueio do app pelo PIN e troca de PIN.
- `home-analitica`: indicadores e rankings calculados a partir das compras registradas.
- `tabelas-de-dados`: comportamento comum a todas as telas de tabela (filtros, ordenação por coluna, paginação, ação de adicionar e abertura de registro).
- `cadastro-clientes`: modelo de Cliente, sua tabela e seu formulário.
- `cadastro-produtos`: modelo de Produto (código reduzido, descrição, preço padrão), sua tabela e seu formulário.
- `registro-compras`: modelo de Compra (cliente × produto × data × quantidade × valores × sequência do pedido), sua tabela e seu formulário com a regra de preço.
- `consulta-geral`: visão consolidada no formato da planilha, com filtros e ordenação.
- `planilha-importacao-exportacao`: carga de planilha `.xlsx` no layout de `DADOS.xlsx` e exportação no mesmo layout.

### Modified Capabilities
- (nenhuma: projeto novo, sem specs existentes)

## Impact

- Novo projeto Flutter na raiz do repositório (`pubspec.yaml`, `lib/`, `test/`, `android/`).
- Dependências novas: `drift`, `drift_flutter`, `sqlite3_flutter_libs` (conforme a versão), `path_provider`, `drift_dev` + `build_runner` (dev), `excel` (leitura e escrita `.xlsx`), `file_picker` (escolha de arquivo), `share_plus` (envio do arquivo exportado), `crypto` (hash do PIN) e `intl` (datas e moeda pt-BR).
- `DADOS.xlsx` atual é mock: serve de referência de layout e fixture de teste, e não é carregado no app.
- Sem integração externa: nenhuma API, ERP ou serviço de rede.
