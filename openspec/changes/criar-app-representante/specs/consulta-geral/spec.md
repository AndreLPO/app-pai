# Spec Delta

## Purpose

Oferece uma tabela única que reproduz a visão da planilha original, com cada compra junto dos dados do cliente e do produto, para o representante consultar tudo em um só lugar, como fazia no Excel.

## ADDED Requirements

### Requirement: Colunas no layout da planilha
A Consulta Geral MUST exibir uma linha por compra com as colunas, nesta ordem: Fantasia, DDD, Zap, Contato, Razão Social, CNPJ, Insc. Estadual, Sequência, CEP, Rua, Bairro, Cidade, Data, Reduzido, Qtde, Produto, Valor Unitário e Valor Total. A coluna Valor Total é a única que não existe na planilha original.

#### Scenario: Linha de compra
- **WHEN** existe uma compra do cliente "SOUSA" do produto 3068
- **THEN** a Consulta Geral mostra uma linha com os dados cadastrais atuais de "SOUSA", os dados da compra e a descrição atual do produto 3068

### Requirement: Filtros e ordenação da consulta
A Consulta Geral MUST oferecer busca, filtros por coluna, ordenação por qualquer coluna e paginação, conforme `tabelas-de-dados`. A ordenação padrão MUST ser por Data, decrescente. Os filtros rápidos Cidade, Produto, Cliente e Período MUST ficar sempre visíveis.

#### Scenario: Filtro por cidade e produto
- **WHEN** o usuário filtra Cidade = "CAMPINAS" e Produto = "CAFE TORRADO 500G"
- **THEN** a consulta mostra somente as compras de café de clientes de Campinas

### Requirement: Totais da consulta
A Consulta Geral MUST exibir no rodapé a soma de Qtde e de Valor Total das linhas que atendem aos filtros, considerando todas as páginas.

#### Scenario: Soma em várias páginas
- **WHEN** 120 linhas atendem aos filtros e a página mostra 50
- **THEN** o rodapé soma as 120 linhas

### Requirement: Rolagem de tabela larga
Como a consulta tem 18 colunas, a tabela MUST permitir rolagem horizontal com a coluna Fantasia fixa à esquerda e o cabeçalho fixo no topo, e MUST permitir ocultar e reexibir colunas.

#### Scenario: Ocultar coluna
- **WHEN** o usuário oculta as colunas Insc. Estadual e CEP
- **THEN** essas colunas deixam de aparecer e voltam ao serem reexibidas, dentro da mesma sessão

### Requirement: Somente leitura com atalho para edição
A Consulta Geral MUST NOT editar dados diretamente na tabela. Ao tocar em uma linha, o sistema MUST abrir o formulário da compra correspondente.

#### Scenario: Abrir compra pela consulta
- **WHEN** o usuário toca em uma linha da Consulta Geral
- **THEN** o sistema abre o formulário de edição daquela compra
