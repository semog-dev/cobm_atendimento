# Cobm Atendimento

App mobile Flutter para gerenciamento de atendimento de uma **casa espírita**, onde consulentes escolhem a entidade que desejam consultar e entram em uma fila de atendimento cronometrado.

## Funcionalidades

- Fila de atendimento em tempo real por médium/entidade
- Cronômetro de atendimento controlado pelo gestor
- Escolha de entidade pelo consulente
- Gestão de sessões de atendimento

## Usuários

- **Gestor**: abre/encerra sessões, gerencia a fila, chama o próximo
- **Cliente**: se cadastra, escolhe a entidade e acompanha sua posição na fila

## Stack

- **Flutter** — Android e iOS
- **Supabase** — banco de dados, autenticação e realtime
- **Riverpod** — gerenciamento de estado
- **go_router** — navegação

## Ambientes

| | Dev | Prod |
|---|---|---|
| Flutter flavor | `dev` | `prod` |
| Supabase project | `cobm_atendimento_dev` | `cobm_atendimento_prod` |

```bash
# Desenvolvimento
flutter run --flavor dev

# Build produção
flutter build apk --flavor prod
```

## Configuração

Crie os arquivos de variáveis de ambiente (não versionados):

```
.env.dev
.env.prod
```

Cada arquivo deve conter:
```
SUPABASE_URL=sua_url
SUPABASE_ANON_KEY=sua_chave
```

## Arquitetura

Feature-first com Clean Architecture leve:

```
lib/
  core/           # configurações, tema, utilitários
  features/
    auth/         # autenticação
    entidades/    # entidades espirituais
    mediuns/      # médiuns
    sessao/       # sessões de atendimento
    fila/         # fila e cronômetro
```

Cada feature segue a estrutura: `data/` → `domain/` → `presentation/`.

## Testes

TDD com ciclo Red → Green → Refactor. A estrutura de testes espelha `lib/`:

```bash
flutter test
```
