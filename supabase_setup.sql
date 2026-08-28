-- SUPABASE SETUP - Programação Eleitoral 2026
-- Execute este arquivo UMA VEZ no SQL Editor do seu projeto Supabase.
-- Depois crie apenas os dois usuários autorizados em Authentication > Users.

create table if not exists public.programacao_checks (
  line_id integer primary key check (line_id between 0 and 3919),
  checked_at timestamptz not null default now(),
  checked_by text not null
);

alter table public.programacao_checks enable row level security;

-- Princípio de menor privilégio: visitantes anônimos não acessam a tabela.
revoke all on table public.programacao_checks from anon, authenticated;
grant select, insert, update, delete on table public.programacao_checks to authenticated;

-- Recria as políticas para permitir que SOMENTE usuários autenticados
-- vejam e alterem as marcações compartilhadas.
drop policy if exists "programacao_checks_select" on public.programacao_checks;
drop policy if exists "programacao_checks_insert" on public.programacao_checks;
drop policy if exists "programacao_checks_update" on public.programacao_checks;
drop policy if exists "programacao_checks_delete" on public.programacao_checks;

create policy "programacao_checks_select"
on public.programacao_checks for select
to authenticated
using (true);

create policy "programacao_checks_insert"
on public.programacao_checks for insert
to authenticated
with check (true);

create policy "programacao_checks_update"
on public.programacao_checks for update
to authenticated
using (true)
with check (true);

create policy "programacao_checks_delete"
on public.programacao_checks for delete
to authenticated
using (true);

-- Habilita Postgres Changes para que as alterações apareçam em tempo real.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'programacao_checks'
  ) then
    alter publication supabase_realtime add table public.programacao_checks;
  end if;
end $$;
