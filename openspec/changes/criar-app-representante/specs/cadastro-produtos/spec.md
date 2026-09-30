# Spec Delta

## Purpose

Mantém o catálogo de produtos identificados pelo código reduzido (RED), com descrição e preço padrão, que serve de base para o preço sugerido nas compras.

## ADDED Requirements

### Requirement: Dados do produto
O produto MUST ter os campos Código Reduzido (obrigatório, inteiro positivo, único), Descrição (obrigatória, salva em maiúsculas) e Preço Padrão (obrigatório, maior ou igual a zero, em reais com 2 casas decimais).

#### Scenario: Cadastro válido
- **WHEN** o usuário salva o produto reduzido 3068, "REFRIGERANTE 2L", preço 7,99
- **THEN** o produto é salvo e aparece na tabela

#### Scenario: Reduzido duplicado
- **WHEN** o usuário tenta salvar um produto com um código reduzido que já existe
- **THEN** o sistema bloqueia o salvamento e informa qual produto já usa esse código

### Requirement: Preço em reais sem erro de arredondamento
Os valores monetários MUST ser guardados e calculados sem erro de ponto flutuante, com precisão de centavos, e exibidos no formato brasileiro (`R$ 1.234,56`).

#### Scenario: Valor com centavos
- **WHEN** o usuário informa o preço 73,07
- **THEN** o sistema exibe exatamente "R$ 73,07" em todas as telas

### Requirement: Alteração do preço padrão
A alteração do preço padrão de um produto MUST valer só para as compras registradas depois dela. As compras já registradas MUST manter o valor unitário gravado nelas.

#### Scenario: Reajuste de preço
- **WHEN** o preço padrão de um produto muda de 7,99 para 8,49
- **THEN** as compras antigas desse produto continuam com 7,99 e uma nova compra sugere 8,49

### Requirement: Tabela de produtos
A tabela de Produtos MUST exibir as colunas Reduzido, Descrição, Preço Padrão, Quantidade Total Vendida e Data da Última Venda, com os filtros e a ordenação definidos em `tabelas-de-dados`. A ordenação padrão MUST ser por Descrição, crescente.

#### Scenario: Filtro por faixa de preço
- **WHEN** o usuário filtra o Preço Padrão entre 5,00 e 10,00
- **THEN** a tabela mostra só os produtos com preço padrão nessa faixa

### Requirement: Exclusão de produto com compras
O sistema MUST NOT excluir um produto que possui compras registradas, e MUST informar quantas compras impedem a exclusão.

#### Scenario: Tentativa de excluir produto vendido
- **WHEN** o usuário tenta excluir um produto que aparece em 10 compras
- **THEN** o sistema recusa a exclusão e informa que existem 10 compras vinculadas
