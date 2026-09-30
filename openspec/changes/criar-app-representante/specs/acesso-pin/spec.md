# Spec Delta

## Purpose

Protege o acesso ao aplicativo com um PIN numérico, definido pelo próprio usuário no primeiro acesso, para que os dados de clientes e compras não fiquem expostos se o tablet for usado por terceiros.

## ADDED Requirements

### Requirement: Definição do PIN no primeiro acesso
Quando nenhum PIN estiver cadastrado, o sistema MUST exibir a tela de criação de PIN antes de qualquer outra tela. O PIN MUST ter de 4 a 6 dígitos numéricos e MUST ser digitado duas vezes, com as duas entradas iguais, para ser salvo.

#### Scenario: Primeiro acesso ao app
- **WHEN** o app é aberto e não existe PIN cadastrado
- **THEN** o sistema exibe a tela "Criar PIN" e não permite navegar para outras telas

#### Scenario: Confirmação igual
- **WHEN** o usuário digita "1234" e confirma com "1234"
- **THEN** o sistema salva o PIN e abre a Home

#### Scenario: Confirmação diferente
- **WHEN** o usuário digita "1234" e confirma com "1235"
- **THEN** o sistema informa que os PINs não conferem, não salva nada e pede o PIN novamente

#### Scenario: PIN com tamanho inválido
- **WHEN** o usuário tenta salvar um PIN com menos de 4 ou mais de 6 dígitos
- **THEN** o sistema recusa o PIN e informa o tamanho permitido

### Requirement: Desbloqueio por PIN
Quando existir PIN cadastrado, o sistema MUST exigir o PIN a cada abertura do app, antes de mostrar qualquer dado.

#### Scenario: PIN correto
- **WHEN** o usuário informa o PIN cadastrado na tela de login
- **THEN** o sistema abre a Home

#### Scenario: PIN incorreto
- **WHEN** o usuário informa um PIN diferente do cadastrado
- **THEN** o sistema exibe "PIN incorreto", limpa o campo e continua na tela de login

#### Scenario: Tentativas seguidas incorretas
- **WHEN** o usuário erra o PIN 5 vezes seguidas
- **THEN** o sistema bloqueia novas tentativas por 30 segundos e mostra o tempo restante

### Requirement: Armazenamento seguro do PIN
O sistema MUST NOT guardar o PIN em texto puro. Somente um hash com salt MUST ser guardado localmente.

#### Scenario: Inspeção do armazenamento
- **WHEN** o banco local é inspecionado depois da criação do PIN "1234"
- **THEN** o valor "1234" não aparece em texto puro em nenhum registro

### Requirement: Troca de PIN
O sistema MUST permitir trocar o PIN a partir do app desbloqueado, pedindo o PIN atual e o novo PIN com confirmação.

#### Scenario: Troca bem-sucedida
- **WHEN** o usuário informa o PIN atual correto e um novo PIN válido confirmado
- **THEN** o sistema passa a aceitar somente o novo PIN

#### Scenario: PIN atual incorreto na troca
- **WHEN** o usuário informa um PIN atual incorreto
- **THEN** o sistema recusa a troca e mantém o PIN anterior

### Requirement: Bloqueio ao sair do app
O sistema MUST exigir o PIN novamente quando o app voltar ao primeiro plano depois de ficar 5 minutos ou mais em segundo plano.

#### Scenario: Retorno depois de 5 minutos
- **WHEN** o app fica 5 minutos ou mais em segundo plano e é retomado
- **THEN** o sistema exibe a tela de login antes de mostrar qualquer dado

#### Scenario: Retorno rápido
- **WHEN** o app fica menos de 5 minutos em segundo plano e é retomado
- **THEN** o sistema volta à tela em que o usuário estava
