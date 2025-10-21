-- Schema mínimo para FreelaClone (execute no SQL editor do Supabase)

-- profiles: armazenar dados do usuário
create table if not exists profiles (
  id uuid primary key default auth.uid(),
  full_name text,
  avatar_url text,
  created_at timestamptz default now()
);

-- projects: projetos publicados
create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text,
  description text,
  budget numeric,
  deadline_days int,
  owner_id uuid references profiles(id) on delete set null,
  created_at timestamptz default now()
);

-- proposals: propostas enviadas para projetos
create table if not exists proposals (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  user_id uuid references profiles(id) on delete set null,
  message text,
  value numeric,
  created_at timestamptz default now()
);