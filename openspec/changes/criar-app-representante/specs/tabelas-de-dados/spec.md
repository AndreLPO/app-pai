# Spec Delta

## Purpose

Define o comportamento comum de todas as telas de tabela do app (Clientes, Produtos, Compras e Consulta Geral): filtros, ordenação por coluna, paginação e abertura de registros, para que o uso seja igual em todas elas.

## ADDED Requirements

### Requirement: Ordenação por coluna
Toda tabela MUST permitir ordenar por qualquer coluna visível tocando no seu cabeçalho. O primeiro toque MUST ordenar de forma crescente, o segundo de forma decrescente, e a coluna ativa MUST mostrar um indicador de direção. Textos MUST ser ordenados sem diferenciar maiúsculas de minúsculas e ignorando acentos. Números, valores e datas MUST ser ordenados pelo valor, não pelo texto exibido.

#### Scenario: Ordenar crescente e depois decrescente
- **WHEN** o usuário toca uma vez no cabeçalho "Valor Unitário" e depois toca de novo
- **THEN** a tabela fica ordenada do menor para o maior valor e depois do maior para o menor, com o indicador de direção atualizado

#### Scenario: Ordenação numérica
- **WHEN** a coluna numérica contém 9, 10 e 100 e é ordenada de forma crescente
- **THEN** a ordem exibida é 9, 10, 100

### Requirement: Busca geral
Toda tabela MUST ter um campo de busca que filtra as linhas contendo o texto digitado em qualquer coluna de texto, sem diferenciar maiúsculas de minúsculas nem acentos.

#### Scenario: Busca sem acento
- **WHEN** o usuário digita "sao luiz" na busca
- **THEN** a tabela mostra as linhas que contêm "SÃO LUIZ"

### Requirement: Filtros por coluna
Toda tabela MUST oferecer filtros por coluna de acordo com o tipo: "contém" para texto, "igual a" em lista de valores para colunas categóricas (ex.: cidade, produto), intervalo mínimo e máximo para números e valores, e intervalo de datas para datas. Os filtros ativos MUST aparecer como chips removíveis. Os filtros MUST ser combinados com E, e junto com a busca geral.

#### Scenario: Combinação de filtros
- **WHEN** o usuário filtra cidade = "LIMEIRA" e data entre 01/01/2026 e 31/03/2026
- **THEN** a tabela mostra somente as linhas que atendem às duas condições

#### Scenario: Remover filtro
- **WHEN** o usuário remove o chip de um filtro ativo
- **THEN** a tabela é recalculada sem aquele filtro

#### Scenario: Limpar tudo
- **WHEN** o usuário aciona "Limpar filtros"
- **THEN** todos os filtros e a busca são removidos e a ordenação volta ao padrão da tabela

### Requirement: Paginação e contagem
Toda tabela MUST paginar os resultados, com 50 linhas por página como padrão, e MUST exibir o total de registros que atendem aos filtros.

#### Scenario: Muitos registros
- **WHEN** existem 1.200 registros que atendem aos filtros
- **THEN** a tabela mostra 50 por página, indica "1.200 registros" e permite navegar entre as páginas

### Requirement: Adicionar registro
As tabelas de Clientes, Produtos e Compras MUST ter uma ação "Adicionar" que abre uma nova tela de formulário vazio. Ao salvar, o sistema MUST voltar à tabela, que passa a mostrar o novo registro.

#### Scenario: Adicionar e voltar
- **WHEN** o usuário toca em "Adicionar", preenche um formulário válido e salva
- **THEN** o sistema volta à tabela, confirma o salvamento e a tabela já inclui o novo registro

#### Scenario: Cancelar com alterações
- **WHEN** o usuário tenta sair do formulário com dados alterados e não salvos
- **THEN** o sistema pede confirmação antes de descartar as alterações

### Requirement: Abrir, editar e excluir registro
Ao tocar em uma linha das tabelas de Clientes, Produtos ou Compras, o sistema MUST abrir o mesmo formulário preenchido, permitindo editar e salvar. O formulário de um registro existente MUST oferecer a ação "Excluir", com confirmação.

#### Scenario: Edição
- **WHEN** o usuário toca em uma linha, altera um campo e salva
- **THEN** a tabela mostra o registro com o valor alterado

#### Scenario: Exclusão confirmada
- **WHEN** o usuário aciona "Excluir" e confirma
- **THEN** o registro é removido e deixa de aparecer na tabela

### Requirement: Estado de filtros por tela
Cada tabela MUST manter a busca, os filtros, a ordenação e a página enquanto o usuário navega para um formulário e volta, dentro da mesma sessão.

#### Scenario: Voltar do formulário
- **WHEN** o usuário filtra a tabela, abre um registro e volta sem salvar
- **THEN** a tabela continua com os mesmos filtros, ordenação e página
