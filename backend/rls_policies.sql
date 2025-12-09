alter table public.leads enable row level security;

-- current_setting('request.jwt.claims', true)::jsonb


-- SELECT POLICY

create policy "leads_select_policy"
on public.leads
for select
using (
  (
    -- Admins, they can read all leads of their tenant
    (current_setting('request.jwt.claims', true)::jsonb ->> 'role') = 'admin'
    AND tenant_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'tenant_id')::uuid
  )
  OR
  (
    -- Counselors, they can view leads assigned to them
    (current_setting('request.jwt.claims', true)::jsonb ->> 'role') = 'counselor'
    AND tenant_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'tenant_id')::uuid
    AND owner_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'user_id')::uuid
  )
  OR
  (
    -- Counselors, they can view leads assigned to their team
    (current_setting('request.jwt.claims', true)::jsonb ->> 'role') = 'counselor'
    AND tenant_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'tenant_id')::uuid
    AND EXISTS (
      SELECT 1
      FROM public.user_teams ut
      JOIN public.teams t ON t.id = ut.team_id
      WHERE ut.user_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'user_id')::uuid
        AND t.tenant_id = leads.tenant_id
    )
  )
);

-- INSERT POLICY

create policy "leads_insert_policy"
on public.leads
for insert
with check (
  (
    (current_setting('request.jwt.claims', true)::jsonb ->> 'role') IN ('admin', 'counselor')
  )
  AND
  (
    tenant_id = (current_setting('request.jwt.claims', true)::jsonb ->> 'tenant_id')::uuid
  )
);