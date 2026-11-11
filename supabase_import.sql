-- Holiday Study: botao "Import CSV" do painel (corra uma vez no Supabase > SQL Editor)
-- Só a equipa (is_team) pode usar. Nao apaga nada. Por defeito ignora session_id que ja existem.
create or replace function public.import_responses(p_rows jsonb, p_overwrite boolean default false)
returns integer language plpgsql security definer set search_path = public as $$
declare n integer := 0; r jsonb;
begin
  if not public.is_team() then raise exception 'not allowed'; end if;
  for r in select * from jsonb_array_elements(p_rows) loop
    if p_overwrite then
      insert into public.responses (session_id, created_at, destination, entry_point, payload)
      values ((r->>'session_id')::uuid, coalesce((r->>'created_at')::timestamptz, now()), r->>'destination', r->>'entry_point', r->'payload')
      on conflict (session_id) do update set destination = excluded.destination, entry_point = excluded.entry_point,
        payload = excluded.payload, updated_at = now();
    else
      insert into public.responses (session_id, created_at, destination, entry_point, payload)
      values ((r->>'session_id')::uuid, coalesce((r->>'created_at')::timestamptz, now()), r->>'destination', r->>'entry_point', r->'payload')
      on conflict (session_id) do nothing;
    end if;
    n := n + 1;
  end loop;
  return n;
end $$;
revoke all on function public.import_responses(jsonb, boolean) from public;
grant execute on function public.import_responses(jsonb, boolean) to authenticated;
