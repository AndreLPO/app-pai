# Spec Delta

## Purpose

Permite carregar no app os dados reais a partir de uma planilha `.xlsx` no mesmo layout de `DADOS.xlsx`, e exportar os dados do app nesse mesmo layout, para servir de backup e para compartilhar.

## ADDED Requirements

### Requirement: Layout aceito na importação
O sistema MUST aceitar arquivos `.xlsx` cuja primeira aba tenha, na linha 1, os cabeçalhos FANTASIA, DDD, ZAP, CONTATO, RAZÃO SOCIAL, CNPJ, INSC. ESTADUAL, SEQUÊNC, CEP, RUA, BAIRRO, CID, DATA, RED, QTDE, PRODUTO e VALOR. As colunas MUST ser localizadas pelo nome do cabeçalho, ignorando maiúsculas, acentos e espaços nas pontas. Uma coluna extra "TOTAL" MUST ser ignorada. As linhas totalmente vazias MUST ser ignoradas.

#### Scenario: Cabeçalho com espaço sobrando
- **WHEN** o arquivo tem o cabeçalho "CID " (com espaço no fim)
- **THEN** a coluna é reconhecida como Cidade

#### Scenario: Cabeçalho obrigatório ausente
- **WHEN** falta a coluna PRODUTO no arquivo
- **THEN** o sistema recusa a importação sem gravar nada e informa as colunas ausentes

### Requirement: Conversão dos valores importados
Na importação, o sistema MUST: interpretar DATA tanto como data serial do Excel quanto como texto `dd/mm/aaaa`; interpretar VALOR como valor unitário, arredondado a 2 casas; interpretar QTDE como quantidade inteira de unidades; e interpretar RED como código reduzido do produto.

#### Scenario: Valor com ruído de ponto flutuante
- **WHEN** a célula VALOR contém 73.06999999999999
- **THEN** a compra é importada com valor unitário R$ 73,07

#### Scenario: Data serial
- **WHEN** a célula DATA contém o número 45911
- **THEN** a compra é importada com a data 11/09/2025

### Requirement: Mesclagem sem duplicar
A importação MUST mesclar com os dados existentes, sem apagá-los. Cada cliente MUST ser identificado pelo CNPJ ou, sem CNPJ, pelo par Fantasia + Razão Social: se já existe, é atualizado; se não, é criado. Cada produto MUST ser identificado pelo RED: se não existe, é criado com o preço padrão igual ao VALOR da linha mais recente daquele RED no arquivo; se existe, a descrição é atualizada e o preço padrão é mantido. Uma compra MUST ser considerada duplicada, e então ignorada, quando já existe uma compra com o mesmo cliente, produto, data, sequência e quantidade.

#### Scenario: Reimportar o mesmo arquivo
- **WHEN** o usuário importa o mesmo arquivo duas vezes
- **THEN** a segunda importação não cria nenhum cliente, produto ou compra novos

#### Scenario: Produto novo na planilha
- **WHEN** o arquivo tem o RED 3068 em duas linhas, com valores 7,50 (01/02/2026) e 7,99 (01/03/2026), e esse RED não existe no app
- **THEN** o produto 3068 é criado com preço padrão R$ 7,99

### Requirement: Validação e relatório da importação
Antes de gravar, o sistema MUST validar todas as linhas e mostrar um resumo com a quantidade de clientes, produtos e compras a criar ou atualizar, e com as linhas rejeitadas e o motivo (ex.: sem FANTASIA, sem RED, sem PRODUTO, QTDE inválida, DATA inválida). O usuário MUST confirmar para gravar. A gravação MUST ser atômica: se falhar, nada é gravado.

#### Scenario: Linha rejeitada
- **WHEN** a linha 15 do arquivo não tem RED
- **THEN** o resumo lista "Linha 15: RED ausente" e essa linha não é importada, mas as demais são

#### Scenario: CNPJ com dígito verificador inválido
- **WHEN** uma linha tem um CNPJ com 14 dígitos mas dígito verificador inválido
- **THEN** o cliente é importado com esse CNPJ e o resumo lista um aviso para a linha, sem rejeitá-la

#### Scenario: Cancelar após o resumo
- **WHEN** o usuário vê o resumo e cancela
- **THEN** nenhum dado é gravado

### Requirement: Exportação no mesmo layout
O sistema MUST exportar todas as compras para um arquivo `.xlsx` com uma aba "CLIENTES", os 17 cabeçalhos do layout de importação na mesma ordem e uma coluna TOTAL no fim. As datas MUST ser gravadas como data do Excel. O arquivo exportado MUST poder ser reimportado sem criar duplicatas. Clientes sem nenhuma compra MUST ser exportados em uma linha só com as colunas do cliente preenchidas.

#### Scenario: Exportar e reimportar
- **WHEN** o usuário exporta os dados e importa o arquivo gerado no mesmo app
- **THEN** a importação não cria nenhum registro novo

#### Scenario: Compartilhar exportação
- **WHEN** a exportação termina
- **THEN** o sistema oferece salvar o arquivo ou compartilhá-lo por outro app do tablet (ex.: WhatsApp, e-mail), com nome no padrão `dados_aaaa-mm-dd.xlsx`

### Requirement: Clientes sem compras na importação
Uma linha com dados do cliente e sem PRODUTO, RED, QTDE e VALOR MUST ser importada só como cliente, sem gerar compra e sem ser rejeitada.

#### Scenario: Linha só de cliente
- **WHEN** uma linha tem FANTASIA e CNPJ preenchidos e as colunas da compra vazias
- **THEN** o cliente é criado ou atualizado e nenhuma compra é criada
