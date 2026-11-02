-- Holiday Study: base de dados (v1.0)
-- Cole tudo no Supabase > SQL Editor e carregue em Run. Pode correr mais do que uma vez.
-- Use um projeto numa região da UE (RGPD).

-- 1) Respostas -------------------------------------------------------------
create table if not exists public.responses (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  session_id uuid not null unique,
  destination text,
  entry_point text,
  payload jsonb not null check (pg_column_size(payload) < 30000)
);
alter table public.responses enable row level security;

-- 2) Equipa autorizada ---------------------------------------------------------
-- Só os emails desta tabela veem o painel. Edite no passo 6 abaixo.
create table if not exists public.team (email text primary key);
alter table public.team enable row level security;

create or replace function public.is_team() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.team where lower(email) = lower(coalesce(auth.jwt() ->> 'email', '')));
$$;
revoke all on function public.is_team() from public;
grant execute on function public.is_team() to authenticated;

-- 3) Quem responde só consegue ENVIAR (nunca ler) ------------------------------
create or replace function public.upsert_response(p_session uuid, p_destination text, p_entry text, p_payload jsonb)
returns void language sql security definer set search_path = public as $$
  insert into public.responses (session_id, destination, entry_point, payload)
  values (p_session, p_destination, p_entry, p_payload)
  on conflict (session_id) do update
    set destination = excluded.destination, entry_point = excluded.entry_point,
        payload = excluded.payload, updated_at = now();
$$;
revoke all on function public.upsert_response(uuid, text, text, jsonb) from public;
grant execute on function public.upsert_response(uuid, text, text, jsonb) to anon;

-- 4) A equipa le e apaga respostas (ex.: apagar testes) ------------------------
drop policy if exists "team read responses" on public.responses;
create policy "team read responses" on public.responses for select to authenticated using (public.is_team());
drop policy if exists "team delete responses" on public.responses;
create policy "team delete responses" on public.responses for delete to authenticated using (public.is_team());
grant select, delete on public.responses to authenticated;

-- 5) Textos editaveis (pequenas correcoes de linguagem) ------------------------
create table if not exists public.text_overrides (
  lang text not null check (lang in ('en','pt')),
  key text not null,                       -- texto original em ingles
  value text not null check (length(value) < 2000),
  updated_at timestamptz not null default now(),
  updated_by text,
  primary key (lang, key)
);
alter table public.text_overrides enable row level security;
drop policy if exists "anyone reads texts" on public.text_overrides;
create policy "anyone reads texts" on public.text_overrides for select to anon, authenticated using (true);
drop policy if exists "team writes texts" on public.text_overrides;
create policy "team writes texts" on public.text_overrides for all to authenticated using (public.is_team()) with check (public.is_team());
grant select on public.text_overrides to anon;
grant select, insert, update, delete on public.text_overrides to authenticated;

-- 6) A SUA EQUIPA: troque pelos 6 emails reais (os mesmos que criar em Authentication > Users)
insert into public.team (email) values
  ('email1@exemplo.com'),
  ('email2@exemplo.com'),
  ('email3@exemplo.com'),
  ('email4@exemplo.com'),
  ('email5@exemplo.com'),
  ('email6@exemplo.com')
on conflict do nothing;
