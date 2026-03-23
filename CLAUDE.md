# CLAUDE.md — cobm_atendimento

## Visão Geral do Projeto

App mobile Flutter para gerenciamento de atendimento de uma **casa espírita**, onde consulentes escolhem a entidade que desejam consultar e entram em uma fila de atendimento cronometrado.

**Usuários:**
- **Gestor**: abre/encerra sessões, gerencia a fila, chama o próximo da fila
- **Cliente**: se cadastra, escolhe a entidade e entra na fila

**Plataformas:** Android e iOS

---

## Backend: Supabase

Usar **Supabase Cloud** (ou self-hosted para maior controle dos dados sensíveis).

### Pacote Flutter
```yaml
supabase_flutter: ^2.x
```

### Modelo de Dados (tabelas)

#### `profiles` — estende `auth.users`
| coluna | tipo | descrição |
|---|---|---|
| id | uuid (PK, FK auth.users) | |
| nome | text | |
| telefone | text | |
| role | enum: `gestor`, `cliente` | |
| created_at | timestamptz | |

#### `mediuns`
| coluna | tipo | descrição |
|---|---|---|
| id | uuid (PK) | |
| nome | text | Nome do médium |
| foto_url | text | URL da imagem |
| ativo | boolean | Se está ativo na casa |
| created_at | timestamptz | |

#### `entidades`
| coluna | tipo | descrição |
|---|---|---|
| id | uuid (PK) | |
| nome | text | Nome da entidade |
| descricao | text | |
| ativa | boolean | Se está disponível para atendimento |
| created_at | timestamptz | |

#### `medium_entidades` — M:N entre médiuns e entidades
| coluna | tipo | descrição |
|---|---|---|
| id | uuid (PK) | |
| medium_id | uuid (FK mediuns) | |
| entidade_id | uuid (FK entidades) | |

> Constraint: `UNIQUE (medium_id, entidade_id)`

#### `sessoes` — cada abertura da casa para atendimento
| coluna | tipo | descrição |
|---|---|---|
| id | uuid (PK) | |
| gestor_id | uuid (FK profiles) | Quem abriu a sessão |
| status | enum: `aberta`, `encerrada` | |
| aberta_em | timestamptz | |
| encerrada_em | timestamptz | |

#### `fila` — fila de atendimento
| coluna | tipo | descrição |
|---|---|---|
| id | uuid (PK) | |
| sessao_id | uuid (FK sessoes) | |
| cliente_id | uuid (FK profiles) | |
| medium_entidade_id | uuid (FK medium_entidades) | Médium + entidade escolhidos |
| posicao | integer | Ordem na fila |
| status | enum: `aguardando`, `em_atendimento`, `concluido`, `cancelado` | |
| criado_em | timestamptz | Quando entrou na fila |
| chamado_em | timestamptz | Quando foi chamado |
| iniciado_em | timestamptz | Quando o atendimento começou |
| encerrado_em | timestamptz | Quando terminou |
| duracao_segundos | integer | Calculado ao encerrar |

### Segurança (Row Level Security)
- `profiles`: usuário lê/edita apenas o próprio perfil; gestor lê todos
- `fila`: cliente vê apenas sua posição; gestor vê e gerencia tudo
- `sessoes`: apenas gestor cria/encerra
- `entidades`: leitura pública; escrita apenas gestor

### Realtime
Usar Supabase Realtime na tabela `fila` para atualização instantânea da fila para gestores e clientes.

---

## Arquitetura: Riverpod + Feature-first + Clean Architecture leve

### Estrutura de pastas

```
lib/
  main.dart
  app.dart                        # MaterialApp + ProviderScope
  core/
    config/
      supabase_config.dart        # inicialização do Supabase
    theme/
      app_theme.dart
    utils/
      formatters.dart
    widgets/                      # widgets compartilhados
  features/
    auth/
      data/
        auth_repository.dart
      domain/
        models/
          usuario.dart
      presentation/
        screens/
          login_screen.dart
          cadastro_screen.dart
        providers/
          auth_provider.dart
    entidades/
      data/
        entidades_repository.dart
      domain/
        models/
          entidade.dart
      presentation/
        screens/
          entidades_screen.dart
        providers/
          entidades_provider.dart
    sessao/
      data/
        sessao_repository.dart
      domain/
        models/
          sessao.dart
      presentation/
        screens/
          sessao_screen.dart        # gestor: abre/encerra sessão
        providers/
          sessao_provider.dart
    fila/
      data/
        fila_repository.dart
      domain/
        models/
          entrada_fila.dart
      presentation/
        screens/
          fila_screen.dart          # gestor: visão da fila
          entrada_fila_screen.dart  # cliente: entrar na fila
          atendimento_screen.dart   # cronômetro do atendimento
        providers/
          fila_provider.dart
```

### Convenções

- **State management**: Riverpod (`flutter_riverpod`, `riverpod_annotation`)
- **Models**: classes imutáveis com `freezed` (ou manual)
- **Repository pattern**: toda comunicação com Supabase fica nos `*_repository.dart`; a UI nunca chama o Supabase diretamente
- **Providers**: AsyncNotifier para operações assíncronas, StreamProvider para Realtime
- **Navegação**: `go_router`
- **Sem over-engineering**: Clean Architecture leve — não criar camadas `use_case` para operações simples

### Pacotes principais

```yaml
dependencies:
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  supabase_flutter: ^2.x
  go_router: ^14.x
  freezed_annotation: ^2.x

dev_dependencies:
  build_runner: ^2.x
  freezed: ^2.x
  riverpod_generator: ^2.x
  mocktail: ^1.x
```

---

## TDD (Test-Driven Development)

### Ciclo
**Red → Green → Refactor**: escrever o teste antes da implementação, sempre.

### Camadas e o que testar em cada uma

| Camada | Tipo de teste | Ferramenta |
|---|---|---|
| `domain/models` | Unit test | `flutter_test` |
| `data/repositories` | Unit test com mock do Supabase | `mocktail` |
| `presentation/providers` | Unit test com mock do repository | `mocktail` + `ProviderContainer` |
| `presentation/screens` | Widget test com mock do provider | `flutter_test` + `mocktail` |

### Estrutura de pastas dos testes

Espelha a estrutura de `lib/`:

```
test/
  features/
    auth/
      data/
        auth_repository_test.dart
      domain/
        models/
          usuario_test.dart
      presentation/
        providers/
          auth_provider_test.dart
        screens/
          login_screen_test.dart
    entidades/
      data/
        entidades_repository_test.dart
      domain/
        models/
          entidade_test.dart
      presentation/
        providers/
          entidades_provider_test.dart
    sessao/
      ...
    fila/
      data/
        fila_repository_test.dart
      domain/
        models/
          entrada_fila_test.dart
      presentation/
        providers/
          fila_provider_test.dart
        screens/
          fila_screen_test.dart
  core/
    helpers/
      test_helpers.dart   # fakes e factories compartilhados
```

### Convenções de teste

- **`mocktail`** para mocks — sem necessidade de codegen, sintaxe limpa
- Repositories são sempre **mockados** nos testes de providers e widgets
- Supabase é sempre **mockado** nos testes de repositories (nunca bate no banco real)
- Criar **factories** de modelos em `test/core/helpers/test_helpers.dart` para reutilizar nos testes
- Nome dos testes: `should [resultado esperado] when [condição]`
  - Ex: `should return lista de entidades when repositorio retorna com sucesso`
- Usar `ProviderContainer` para testar providers Riverpod isoladamente

### Exemplo de estrutura de um teste de provider

```dart
// test/features/entidades/presentation/providers/entidades_provider_test.dart

void main() {
  late MockEntidadesRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockEntidadesRepository();
    container = ProviderContainer(
      overrides: [
        entidadesRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('should retornar lista de entidades when repositorio retorna com sucesso', () async {
    // arrange
    when(() => mockRepository.listar()).thenAnswer((_) async => [entidadeFake]);
    // act
    final result = await container.read(entidadesProvider.future);
    // assert
    expect(result, [entidadeFake]);
  });
}
```

---

## Fluxo Principal

```
[Cliente]
  → Login/Cadastro
  → Vê entidades disponíveis na sessão aberta
  → Escolhe entidade → entra na fila
  → Acompanha posição na fila em tempo real
  → É chamado → atendimento cronometrado

[Gestor]
  → Login
  → Abre sessão
  → Vê fila em tempo real
  → Chama próximo → cronômetro inicia
  → Encerra atendimento → próximo é chamado
  → Encerra sessão
```

---

## Commits

**Frequência:** 1 commit por funcionalidade completa (incluindo testes passando).

**Padrão:** Conventional Commits

```
feat: adiciona listagem de entidades
fix: corrige ordenação da fila
test: adiciona testes do EntidadesRepository
refactor: extrai lógica de cronômetro
chore: adiciona pacote mocktail
docs: atualiza CLAUDE.md
```

**Tipos permitidos:** `feat`, `fix`, `test`, `refactor`, `chore`, `docs`

**Regra:** só commitar quando a feature estiver completa **e** todos os testes passando.

---

## Ambientes

**2 ambientes isolados:**

| | Dev | Prod |
|---|---|---|
| Supabase project | `cobm_atendimento_dev` | `cobm_atendimento_prod` |
| Flutter flavor | `dev` | `prod` |
| Dados | testes | consulentes reais |

### Execução
```bash
flutter run --flavor dev          # desenvolvimento
flutter build apk --flavor prod   # produção
```

### Variáveis de ambiente
Cada ambiente tem seu próprio arquivo (ambos no `.gitignore`):
```
.env.dev
.env.prod
```

Carregadas via `--dart-define`:
```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

**Regra:** nunca usar credenciais de prod em ambiente de dev e vice-versa.

---

## Decisões e Contexto

- Dados dos consulentes são **sensíveis** — avaliar Supabase self-hosted para produção
- Cronômetro de atendimento é controlado pelo **gestor**, com timestamps salvos no banco
- Cliente pode cancelar sua entrada na fila enquanto status = `aguardando`
- Cada sessão pode ter múltiplas entidades ativas simultaneamente (filas paralelas por entidade)
