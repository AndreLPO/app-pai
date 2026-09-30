# Spec Delta

## Purpose

Oferece na tela inicial uma visão rápida do desempenho de vendas (totais, rankings e evolução mensal), calculada a partir das compras registradas, para o representante se orientar antes e durante as visitas.

## ADDED Requirements

### Requirement: Filtro de período da Home
A Home MUST ter um seletor de período com as opções "Mês atual", "Últimos 3 meses", "Últimos 12 meses", "Ano atual" e "Tudo", com "Mês atual" como padrão. Todos os indicadores e rankings MUST respeitar o período selecionado, exceto o gráfico mensal, que mostra sempre os últimos 12 meses.

#### Scenario: Troca de período
- **WHEN** o usuário seleciona "Últimos 12 meses"
- **THEN** os indicadores e rankings são recalculados considerando só as compras com data dentro desse período

### Requirement: Indicadores principais
A Home MUST exibir, para o período selecionado: o valor total vendido (soma dos totais de linha), a quantidade total de unidades, o número de registros de compra, o número de clientes distintos que compraram e o ticket médio por cliente (valor total dividido pelos clientes distintos).

#### Scenario: Cálculo dos indicadores
- **WHEN** o período contém 2 compras do cliente A (R$ 100,00 e R$ 50,00) e 1 compra do cliente B (R$ 30,00)
- **THEN** a Home mostra valor total R$ 180,00, 3 registros, 2 clientes e ticket médio R$ 90,00

#### Scenario: Período sem compras
- **WHEN** não há compras no período selecionado
- **THEN** os indicadores mostram zero e a Home informa que não há dados no período, sem erro

### Requirement: Rankings de produtos e clientes
A Home MUST exibir os 5 produtos com maior valor vendido e os 5 clientes com maior valor comprado no período, cada um com seu valor total, em ordem decrescente.

#### Scenario: Ranking de produtos
- **WHEN** o período tem compras de 8 produtos diferentes
- **THEN** a Home lista os 5 de maior valor total, do maior para o menor

### Requirement: Evolução mensal
A Home MUST exibir um gráfico de barras com o valor total vendido por mês nos últimos 12 meses, incluindo os meses sem vendas com valor zero.

#### Scenario: Mês sem vendas
- **WHEN** um dos últimos 12 meses não tem compras
- **THEN** o gráfico mostra esse mês com barra de valor zero

### Requirement: Clientes sem compra recente
A Home MUST exibir a quantidade de clientes cadastrados cuja última compra tem mais de 60 dias, ou que nunca compraram, com atalho para a lista desses clientes na tela de Clientes.

#### Scenario: Atalho para clientes inativos
- **WHEN** o usuário toca no indicador de clientes sem compra recente
- **THEN** o sistema abre a tabela de Clientes filtrada por esses clientes
