create extension if not exists "pgcrypto";

-- Leads table
create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  owner_id uuid not null,
  email text,
  phone text,
  full_name text,
  stage text not null default 'new',
  source text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);


-- Indexes for leads
create index if not exists idx_leads_tenant_id ON public.leads(tenant_id);
create index if not exists idx_leads_owner_id ON public.leads(owner_id);
create index if not exists idx_leads_stage ON public.leads(stage);
create index if not exists idx_leads_created_at ON public.leads(created_at);


-- Applications table
create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  lead_id uuid not null references public.leads(id) on delete cascade,
  program_id uuid,
  intake_id uuid,
  stage text not null default 'inquiry',
  status text not null default 'open',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Indexes for applications
create index if not exists idx_applications_tenant_id ON public.applications(tenant_id);
create index if not exists idx_applications_lead_id ON public.applications(lead_id);
create index if not exists idx_applications_stage ON public.applications(stage);


-- Tasks table
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  application_id uuid not null references public.applications(id) on delete cascade,
  title text,
  type text not null,
  status text not null default 'open',
  due_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint task_type_check check (type in ('call', 'email', 'review')),
  constraint due_at_check check (due_at >= created_at)
);

-- Indexes for tasks
create index if not exists idx_tasks_tenant_id ON public.tasks(tenant_id);
create index if not exists idx_tasks_due_at ON public.tasks(due_at);
create index if not exists idx_tasks_status ON public.tasks(status);
