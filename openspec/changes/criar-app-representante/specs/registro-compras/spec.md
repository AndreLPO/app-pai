# Spec Delta

## Purpose

Registra cada compra de um produto por um cliente (data, quantidade em unidades, valor unitário, valor total e sequência do pedido), equivalente a uma linha da planilha, e aplica a regra de preço baseada no preço padrão do produto.

## ADDED Requirements

### Requirement: Dados da compra
A compra MUST ter os campos Cliente (obrigatório), Produto (obrigatório), Data (obrigatória, padrão = data de hoje), Quantidade em unidades (obrigatória, inteiro maior que zero), Valor Unitário (obrigatório, maior ou igual a zero) e Sequência do Pedido (opcional, inteiro positivo). Várias compras MAY compartilhar a mesma Sequência do Pedido.

#### Scenario: Compra válida
- **WHEN** o usuário seleciona cliente, produto, quantidade 93 e mantém a data de hoje
- **THEN** a compra é salva com a data atual

#### Scenario: Quantidade inválida
- **WHEN** o usuário informa quantidade 0 ou negativa
- **THEN** o sistema bloqueia o salvamento e informa que a quantidade deve ser maior que zero

#### Scenario: Mesma sequência em várias linhas
- **WHEN** o usuário registra duas compras de produtos diferentes com Sequência do Pedido 3345336
- **THEN** as duas compras são salvas

### Requirement: Seleção de cliente e produto com busca
Os campos Cliente e Produto MUST permitir busca digitada: o cliente por Fantasia, Razão Social ou CNPJ, e o produto por Reduzido ou Descrição.

#### Scenario: Busca de produto por reduzido
- **WHEN** o usuário digita "3068" no campo Produto
- **THEN** o sistema sugere o produto de código reduzido 3068

### Requirement: Preço sugerido pelo produto
Ao selecionar ou trocar o produto, o sistema MUST preencher o Valor Unitário com o Preço Padrão do produto. O usuário MUST poder alterar o Valor Unitário depois disso, e o valor alterado é o que MUST ser salvo.

#### Scenario: Preço padrão preenchido
- **WHEN** o usuário seleciona um produto com preço padrão R$ 7,99
- **THEN** o campo Valor Unitário é preenchido com R$ 7,99

#### Scenario: Preço negociado
- **WHEN** o usuário altera o Valor Unitário para R$ 7,50 e salva
- **THEN** a compra é salva com valor unitário R$ 7,50 e o preço padrão do produto continua R$ 7,99

#### Scenario: Troca de produto depois de editar o preço
- **WHEN** o usuário já editou o Valor Unitário e troca o produto
- **THEN** o Valor Unitário é substituído pelo preço padrão do novo produto

### Requirement: Valor total da linha
O sistema MUST calcular o Valor Total como Quantidade × Valor Unitário, com precisão de centavos, e MUST exibi-lo no formulário (atualizado a cada alteração) e nas tabelas. O Valor Total MUST NOT ser editável.

#### Scenario: Cálculo do total
- **WHEN** a quantidade é 93 e o valor unitário é R$ 73,07
- **THEN** o Valor Total exibido é R$ 6.795,51

### Requirement: Tabela de compras
A tabela de Compras MUST exibir as colunas Data, Sequência, Cliente (Fantasia), Reduzido, Produto, Quantidade, Valor Unitário e Valor Total, com os filtros e a ordenação definidos em `tabelas-de-dados`. A ordenação padrão MUST ser por Data, decrescente. O rodapé MUST mostrar a soma de Quantidade e de Valor Total das linhas filtradas.

#### Scenario: Totais filtrados
- **WHEN** o usuário filtra as compras pelo produto "LEITE INTEGRAL 1L"
- **THEN** o rodapé mostra a soma de quantidade e de valor total só dessas compras
