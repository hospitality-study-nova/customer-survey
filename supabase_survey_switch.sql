-- Interruptor para abrir/fechar o questionario (corra uma vez no Supabase > SQL Editor > Run).
-- Fechado: quem abre o link ve uma pagina de "encerrado" e novas respostas sao recusadas.
-- Quem ja comecou (a sessao ja existe na base) pode continuar a atualizar a sua resposta.

create table if not exists public.survey_settings (
  id int primary key default 1 check (id = 1),
  is_open boolean not null default true,
  updated_at timestamptz not null default now(),
  updated_by text
);
insert into public.survey_settings (id, is_open) values (1, true) on conflict do nothing;
alter table public.survey_settings enable row level security;

drop policy if exists "anyone reads survey settings" on public.survey_settings;
create policy "anyone reads survey settings" on public.survey_settings for select to anon, authenticated using (true);
drop policy if exists "team updates survey settings" on public.survey_settings;
create policy "team updates survey settings" on public.survey_settings for update to authenticated using (public.is_team()) with check (public.is_team());
grant select on public.survey_settings to anon;
grant select, update on public.survey_settings to authenticated;

-- Recusa NOVAS respostas quando o questionario esta fechado
create or replace function public.upsert_response(p_session uuid, p_destination text, p_entry text, p_payload jsonb)
returns void language plpgsql security definer set search_path = public as $$
begin
  if not (select is_open from public.survey_settings where id = 1)
     and not exists (select 1 from public.responses where session_id = p_session) then
    raise exception 'survey_closed' using errcode = 'P0001';
  end if;
  insert into public.responses (session_id, destination, entry_point, payload)
  values (p_session, p_destination, p_entry, p_payload)
  on conflict (session_id) do update
    set destination = excluded.destination, entry_point = excluded.entry_point,
        payload = excluded.payload, updated_at = now();
end;
$$;
revoke all on function public.upsert_response(uuid, text, text, jsonb) from public;
grant execute on function public.upsert_response(uuid, text, text, jsonb) to anon;
