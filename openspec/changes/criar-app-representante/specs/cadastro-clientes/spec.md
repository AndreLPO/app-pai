# Spec Delta

## Purpose

Mantém o cadastro dos clientes (supermercados) atendidos pelo representante, com dados fiscais, de contato e de endereço equivalentes às colunas A a L da planilha.

## ADDED Requirements

### Requirement: Dados do cliente
O cliente MUST ter os campos: Nome Fantasia (obrigatório), Razão Social, CNPJ, Inscrição Estadual, Contato, DDD, WhatsApp/Telefone, CEP, Rua (com número), Bairro e Cidade. Os textos MUST ser salvos em letras maiúsculas, como na planilha.

#### Scenario: Cadastro mínimo
- **WHEN** o usuário salva um cliente preenchendo só o Nome Fantasia
- **THEN** o cliente é salvo e aparece na tabela

#### Scenario: Nome Fantasia vazio
- **WHEN** o usuário tenta salvar um cliente sem Nome Fantasia
- **THEN** o sistema bloqueia o salvamento e destaca o campo obrigatório

### Requirement: Validação de CNPJ
Quando informado, o CNPJ MUST ter 14 dígitos com dígitos verificadores válidos e MUST ser único entre os clientes. O sistema MUST exibir o CNPJ no formato `00.000.000/0000-00`.

#### Scenario: CNPJ inválido
- **WHEN** o usuário informa um CNPJ com dígito verificador incorreto
- **THEN** o sistema bloqueia o salvamento e informa "CNPJ inválido"

#### Scenario: CNPJ duplicado
- **WHEN** o usuário informa um CNPJ que já pertence a outro cliente
- **THEN** o sistema bloqueia o salvamento e indica qual cliente já usa esse CNPJ

### Requirement: Máscaras de contato e endereço
O formulário MUST aplicar máscara ao CEP (`00000-000`) e ao telefone (`0 0000-0000` ou `0000-0000`), e o DDD MUST aceitar só 2 dígitos.

#### Scenario: Digitação de CEP
- **WHEN** o usuário digita "11071486" no CEP
- **THEN** o campo exibe "11071-486"

### Requirement: Tabela de clientes
A tabela de Clientes MUST exibir as colunas Fantasia, Razão Social, CNPJ, Contato, Telefone (DDD + número), Cidade, Bairro e Data da Última Compra, com os filtros e a ordenação definidos em `tabelas-de-dados`. A ordenação padrão MUST ser por Fantasia, crescente.

#### Scenario: Cliente sem compras
- **WHEN** um cliente não tem compras registradas
- **THEN** a coluna Data da Última Compra aparece vazia para ele e esse cliente fica por último ao ordenar essa coluna de forma decrescente

### Requirement: Exclusão de cliente com compras
O sistema MUST NOT excluir um cliente que possui compras registradas enquanto essas compras existirem, e MUST informar quantas compras impedem a exclusão.

#### Scenario: Tentativa de excluir cliente com compras
- **WHEN** o usuário tenta excluir um cliente com 3 compras
- **THEN** o sistema recusa a exclusão e informa que existem 3 compras vinculadas

### Requirement: Histórico de compras no cliente
O formulário de um cliente existente MUST exibir a lista das compras desse cliente (data, produto, quantidade e valor total), da mais recente para a mais antiga, e MUST ter um atalho para registrar uma nova compra já com esse cliente preenchido.

#### Scenario: Nova compra a partir do cliente
- **WHEN** o usuário toca em "Nova compra" no formulário do cliente
- **THEN** o sistema abre o formulário de compra com o cliente já selecionado
