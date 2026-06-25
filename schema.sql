-- =====================================================================
-- SCHEMA: Plano de Metas — Polo Anhanguera Campo Grande/RJ
-- Cole este arquivo inteiro no Supabase em: SQL Editor > New query > Run
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) PERFIS (substitui a antiga tabela "usuarios" com login/senha manual)
--    Cada linha aqui representa uma pessoa que tem conta no Supabase Auth.
--    O "papel" (Gestor, Sócio, Diretora Acadêmica, Outro) é só informativo.
-- ---------------------------------------------------------------------
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  papel text not null default 'Outro',
  created_at timestamptz default now()
);

-- Quando alguém se cadastra (Supabase Auth cria o usuário), criamos
-- automaticamente uma linha em profiles com nome/papel vindos do cadastro.
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, nome, papel)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nome', new.email),
    coalesce(new.raw_user_meta_data->>'papel', 'Outro')
  );
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------------------------------------------------------------------
-- 2) COLABORADORES
-- ---------------------------------------------------------------------
create table if not exists employees (
  id text primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- 3) DADOS POR CICLO / PERÍODO
--    Guardamos como "tabela de documentos" (chave + json) para espelhar
--    exatamente a estrutura que o app já usa (periodCrescimento[cicloId] etc),
--    evitando reescrever toda a lógica de cálculo do front-end.
-- ---------------------------------------------------------------------
create table if not exists period_crescimento (
  ciclo_id text primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);

create table if not exists period_admin (
  mes_id text primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);

create table if not exists period_financeiro (
  bim_id text primary key,
  data jsonb not null,
  updated_at timestamptz default now()
);

-- ---------------------------------------------------------------------
-- 4) CONFIGURAÇÕES GERAIS (feriados, última seleção de aba/ciclo etc.)
--    Uma única linha (id fixo = 'app') guarda o objeto config inteiro.
-- ---------------------------------------------------------------------
create table if not exists app_config (
  id text primary key default 'app',
  data jsonb not null default '{"holidays":[],"lastSelected":{}}',
  updated_at timestamptz default now()
);

insert into app_config (id, data)
values ('app', '{"holidays":[],"lastSelected":{}}')
on conflict (id) do nothing;

-- =====================================================================
-- ROW LEVEL SECURITY (RLS)
-- Regra do Polo: qualquer pessoa LOGADA (autenticada) pode ler e editar
-- os dados — é uma equipe pequena e de confiança (gestão do Polo).
-- Quem não estiver logado não acessa nada.
-- =====================================================================

alter table profiles enable row level security;
alter table employees enable row level security;
alter table period_crescimento enable row level security;
alter table period_admin enable row level security;
alter table period_financeiro enable row level security;
alter table app_config enable row level security;

-- profiles: todo autenticado pode ver a lista (para a aba "Usuários"),
-- mas cada um só edita o próprio perfil.
create policy "profiles_select_authenticated" on profiles
  for select using (auth.role() = 'authenticated');
create policy "profiles_update_own" on profiles
  for update using (auth.uid() = id);

-- Dados do Polo: leitura e escrita liberadas para qualquer autenticado.
create policy "employees_all_authenticated" on employees
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "crescimento_all_authenticated" on period_crescimento
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "admin_all_authenticated" on period_admin
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "financeiro_all_authenticated" on period_financeiro
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "config_all_authenticated" on app_config
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
