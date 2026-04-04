-- =============================================================================
-- COBM ATENDIMENTO — Schema Consolidado
-- Executar no SQL Editor do Supabase (projeto dev ou prod)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. EXTENSÕES
-- -----------------------------------------------------------------------------
create extension if not exists "pgcrypto";


-- -----------------------------------------------------------------------------
-- 2. TIPOS ENUMERADOS
-- -----------------------------------------------------------------------------
do $$ begin
  create type role_tipo as enum ('gestor', 'cliente');
exception when duplicate_object then null; end $$;

do $$ begin
  create type status_sessao as enum ('aberta', 'encerrada');
exception when duplicate_object then null; end $$;

do $$ begin
  create type status_fila as enum ('aguardando', 'em_atendimento', 'concluido', 'cancelado');
exception when duplicate_object then null; end $$;


-- -----------------------------------------------------------------------------
-- 3. TABELAS
-- -----------------------------------------------------------------------------

-- profiles — espelha auth.users com dados adicionais
create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  nome        text        not null,
  telefone    text        not null,
  role        role_tipo   not null default 'cliente',
  created_at  timestamptz not null default now()
);

-- mediuns
create table if not exists public.mediuns (
  id          uuid        primary key default gen_random_uuid(),
  nome        text        not null,
  foto_url    text,
  ativo       boolean     not null default true,
  created_at  timestamptz not null default now()
);

-- entidades
create table if not exists public.entidades (
  id          uuid        primary key default gen_random_uuid(),
  nome        text        not null,
  descricao   text        not null default '',
  ativa       boolean     not null default true,
  created_at  timestamptz not null default now()
);

-- medium_entidades — M:N entre médiuns e entidades
create table if not exists public.medium_entidades (
  id           uuid primary key default gen_random_uuid(),
  medium_id    uuid not null references public.mediuns(id)   on delete cascade,
  entidade_id  uuid not null references public.entidades(id) on delete cascade,
  unique (medium_id, entidade_id)
);

-- sessoes — cada abertura da casa para atendimento
create table if not exists public.sessoes (
  id           uuid         primary key default gen_random_uuid(),
  gestor_id    uuid         not null references public.profiles(id),
  status       status_sessao not null default 'aberta',
  aberta_em    timestamptz  not null default now(),
  encerrada_em timestamptz
);

-- sessao_medium_entidades — quais médiuns/entidades estão ativos em cada sessão
create table if not exists public.sessao_medium_entidades (
  id                  uuid primary key default gen_random_uuid(),
  sessao_id           uuid not null references public.sessoes(id)          on delete cascade,
  medium_entidade_id  uuid not null references public.medium_entidades(id) on delete cascade,
  unique (sessao_id, medium_entidade_id)
);

-- fila — fila de atendimento
create table if not exists public.fila (
  id                  uuid         primary key default gen_random_uuid(),
  sessao_id           uuid         not null references public.sessoes(id)          on delete cascade,
  medium_entidade_id  uuid         not null references public.medium_entidades(id),
  cliente_nome        text         not null,
  posicao             integer      not null,
  status              status_fila  not null default 'aguardando',
  criado_em           timestamptz  not null default now(),
  chamado_em          timestamptz,
  iniciado_em         timestamptz,
  encerrado_em        timestamptz,
  duracao_segundos    integer
);


-- -----------------------------------------------------------------------------
-- 4. ÍNDICES
-- -----------------------------------------------------------------------------
create index if not exists idx_fila_sessao_id          on public.fila(sessao_id);
create index if not exists idx_fila_medium_entidade_id on public.fila(medium_entidade_id);
create index if not exists idx_fila_status             on public.fila(status);
create index if not exists idx_sessoes_status          on public.sessoes(status);
create index if not exists idx_sme_sessao_id           on public.sessao_medium_entidades(sessao_id);


-- -----------------------------------------------------------------------------
-- 5. FUNÇÃO AUXILIAR (evita recursão infinita no RLS de profiles)
-- -----------------------------------------------------------------------------
create or replace function public.is_gestor()
returns boolean
language sql
security definer
stable
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and role = 'gestor'
  );
$$;


-- -----------------------------------------------------------------------------
-- 6. ROW LEVEL SECURITY
-- -----------------------------------------------------------------------------

alter table public.profiles             enable row level security;
alter table public.mediuns              enable row level security;
alter table public.entidades            enable row level security;
alter table public.medium_entidades     enable row level security;
alter table public.sessoes              enable row level security;
alter table public.sessao_medium_entidades enable row level security;
alter table public.fila                 enable row level security;


-- profiles
drop policy if exists "profiles: select proprio ou gestor" on public.profiles;
create policy "profiles: select proprio ou gestor"
  on public.profiles for select
  using (id = auth.uid() or public.is_gestor());

drop policy if exists "profiles: insert proprio" on public.profiles;
create policy "profiles: insert proprio"
  on public.profiles for insert
  with check (id = auth.uid());

drop policy if exists "profiles: update proprio" on public.profiles;
create policy "profiles: update proprio"
  on public.profiles for update
  using (id = auth.uid());


-- mediuns
drop policy if exists "mediuns: leitura autenticado" on public.mediuns;
create policy "mediuns: leitura autenticado"
  on public.mediuns for select
  using (auth.role() = 'authenticated');

drop policy if exists "mediuns: escrita gestor" on public.mediuns;
create policy "mediuns: escrita gestor"
  on public.mediuns for all
  using (public.is_gestor())
  with check (public.is_gestor());


-- entidades
drop policy if exists "entidades: leitura autenticado" on public.entidades;
create policy "entidades: leitura autenticado"
  on public.entidades for select
  using (auth.role() = 'authenticated');

drop policy if exists "entidades: escrita gestor" on public.entidades;
create policy "entidades: escrita gestor"
  on public.entidades for all
  using (public.is_gestor())
  with check (public.is_gestor());


-- medium_entidades
drop policy if exists "medium_entidades: leitura autenticado" on public.medium_entidades;
create policy "medium_entidades: leitura autenticado"
  on public.medium_entidades for select
  using (auth.role() = 'authenticated');

drop policy if exists "medium_entidades: escrita gestor" on public.medium_entidades;
create policy "medium_entidades: escrita gestor"
  on public.medium_entidades for all
  using (public.is_gestor())
  with check (public.is_gestor());


-- sessoes
drop policy if exists "sessoes: leitura autenticado" on public.sessoes;
create policy "sessoes: leitura autenticado"
  on public.sessoes for select
  using (auth.role() = 'authenticated');

drop policy if exists "sessoes: escrita gestor" on public.sessoes;
create policy "sessoes: escrita gestor"
  on public.sessoes for all
  using (public.is_gestor())
  with check (public.is_gestor());


-- sessao_medium_entidades
drop policy if exists "sme: leitura autenticado" on public.sessao_medium_entidades;
create policy "sme: leitura autenticado"
  on public.sessao_medium_entidades for select
  using (auth.role() = 'authenticated');

drop policy if exists "sme: escrita gestor" on public.sessao_medium_entidades;
create policy "sme: escrita gestor"
  on public.sessao_medium_entidades for all
  using (public.is_gestor())
  with check (public.is_gestor());


-- fila
drop policy if exists "fila: leitura autenticado" on public.fila;
create policy "fila: leitura autenticado"
  on public.fila for select
  using (auth.role() = 'authenticated');

drop policy if exists "fila: escrita gestor" on public.fila;
create policy "fila: escrita gestor"
  on public.fila for all
  using (public.is_gestor())
  with check (public.is_gestor());


-- -----------------------------------------------------------------------------
-- 7. REALTIME
-- -----------------------------------------------------------------------------
-- Habilitar publicação realtime na tabela fila
-- (executar separadamente se der erro de permissão)
alter publication supabase_realtime add table public.fila;


-- -----------------------------------------------------------------------------
-- 8. TRIGGER — removido intencionalmente
-- -----------------------------------------------------------------------------
-- O app Flutter gerencia o insert em profiles via salvarPerfil() logo após
-- o signUp(). Um trigger automático causaria violação de NOT NULL em nome/telefone
-- pois esses campos não são enviados pelo Supabase Auth no momento do signup.
--
-- Para criar o gestor inicial, insira manualmente via painel do Supabase:
--   insert into public.profiles (id, nome, telefone, role)
--   values ('<uuid do auth.users>', 'Nome', '(11) 99999-9999', 'gestor');

drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.handle_new_user();
