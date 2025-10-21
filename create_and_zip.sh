#!/usr/bin/env bash
set -euo pipefail

PROJECT="freelaclone-next-vercel"
OUTZIP="${PROJECT}.zip"

if [ -d "$PROJECT" ]; then
  echo "Diretório $PROJECT já existe. Remova ou mova antes de continuar."
  exit 1
fi

mkdir -p "$PROJECT"
cd "$PROJECT"

echo "Criando estrutura de diretórios..."
mkdir -p pages pages/project pages/api lib styles public

echo "Criando arquivos..."

cat > package.json <<'EOF'
{
  "name": "freelaclone-next-vercel",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start -p 3000",
    "lint": "next lint"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.27.0",
    "mercadopago": "^2.5.0",
    "next": "13.4.12",
    "react": "18.2.0",
    "react-dom": "18.2.0"
  }
}
EOF

cat > .env.local.example <<'EOF'
# Copie para .env.local e preencha com suas chaves

# Supabase (client)
NEXT_PUBLIC_SUPABASE_URL=https://your-supabase-url.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# Supabase (server) - opcional se você for usar server-side com permissões elevadas
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# MercadoPago (server access token)
MERCADOPAGO_ACCESS_TOKEN=YOUR_MERCADOPAGO_ACCESS_TOKEN

# (Opcional) Chave pública MercadoPago para uso client-side se desejar
NEXT_PUBLIC_MERCADOPAGO_PUBLIC_KEY=YOUR_PUBLIC_KEY
EOF

cat > README.md <<'EOF'
# FreelaClone — Next.js + Supabase + MercadoPago (Pronto para Vercel)

Este projeto é um template para um marketplace de freelas, pronto para deploy no Vercel, usando Supabase como backend (auth + banco) e MercadoPago para pagamentos. O código já está estruturado para você apenas inserir as chaves/variáveis de ambiente.

Principais pontos:
- Front-end: Next.js (páginas simples).
- Autenticação e persistência: Supabase (client-side).
- Pagamentos: endpoint server-side que cria preferência no MercadoPago (usa token SERVER).
- Deploy recomendado: Vercel.

Variáveis de ambiente (no Vercel):
- NEXT_PUBLIC_SUPABASE_URL
- NEXT_PUBLIC_SUPABASE_ANON_KEY
- SUPABASE_SERVICE_ROLE_KEY  (opcional, só se precisar de endpoints server-side com permissões elevadas)
- MERCADOPAGO_ACCESS_TOKEN   (obrigatório para o endpoint de pagamento)
- NEXT_PUBLIC_MERCADOPAGO_PUBLIC_KEY (opcional, para integração client-side se você usar)

Como rodar localmente:
1. Copie `.env.local.example` para `.env.local` e preencha com suas chaves.
2. Instale dependências:
   npm install
3. Rode em modo dev:
   npm run dev
4. Abra: http://localhost:3000

Supabase - criar tabelas
- Use o arquivo `supabase/schema.sql` no editor SQL do Supabase para criar as tabelas `profiles`, `projects`, `proposals`.

Deploy no Vercel
1. Conecte o repositório no Vercel.
2. Adicione as variáveis de ambiente (veja a lista acima).
3. Deploy — o Vercel detecta o Next.js automaticamente.

Observações de segurança
- Nunca coloque chaves secretas no client-side. Use as variáveis de ambiente do Vercel para chaves server-side (ex.: MERCADOPAGO_ACCESS_TOKEN).
- Para operações sensíveis no banco, prefira uma função serverless que use SUPABASE_SERVICE_ROLE_KEY.

Se quiser, eu também posso adicionar um endpoint de webhook do MercadoPago para atualizar status de pagamento automaticamente.
EOF

cat > supabase_schema.sql <<'EOF'
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
EOF

cat > next.config.js <<'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
};

module.exports = nextConfig;
EOF

cat > styles/globals.css <<'EOF'
:root{
  --primary:#2b6cb0;
  --bg:#f7fafc;
  --muted:#6b7280;
  --card:#fff;
  --max:1100px;
  font-family: Inter, system-ui, -apple-system, "Segoe UI", Roboto, Arial;
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:#102a43}
.container{max-width:var(--max);margin:0 auto;padding:1rem}
.header{background:#fff;border-bottom:1px solid #e6eef8}
.header .inner{display:flex;align-items:center;justify-content:space-between;padding:1rem}
.brand{font-weight:700;color:var(--primary);text-decoration:none}
.nav a{margin-left:1rem;color:inherit;text-decoration:none}
.hero{padding:2.5rem 0;text-align:center}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:1rem}
.card{background:var(--card);padding:1rem;border-radius:8px;box-shadow:0 6px 18px rgba(27,60,113,0.06)}
.btn{display:inline-block;padding:.5rem .75rem;border-radius:8px;text-decoration:none;border:1px solid transparent;background:transparent;color:var(--primary)}
.btn.primary{background:var(--primary);color:#fff}
.form label{display:block;margin-bottom:.6rem}
.form input,.form select,.form textarea{width:100%;padding:.6rem;border-radius:8px;border:1px solid #eef6ff;background:#fff}
.help{color:var(--muted);font-size:.95rem;margin-top:.5rem}
.footer{border-top:1px solid #e6eef8;background:#fff;margin-top:2rem;padding:1rem}
@media(max-width:700px){.header .inner{flex-direction:column;align-items:flex-start;gap:.5rem}}
EOF

cat > lib/supabaseClient.js <<'EOF'
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  if (process.env.NODE_ENV === 'development') {
    console.warn('NEXT_PUBLIC_SUPABASE_URL or NEXT_PUBLIC_SUPABASE_ANON_KEY is missing.');
  }
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
EOF

cat > lib/supabaseAdmin.js <<'EOF'
// Uso opcional em APIs server-side se você precisar do service role
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

export const supabaseAdmin =
  supabaseServiceRoleKey ? createClient(supabaseUrl, supabaseServiceRoleKey) : null;
EOF

cat > pages/_app.js <<'EOF'
import '../styles/globals.css';

export default function App({ Component, pageProps }) {
  return <Component {...pageProps} />;
}
EOF

cat > pages/index.js <<'EOF'
import { useEffect, useState } from 'react';
import Link from 'next/link';
import { supabase } from '../lib/supabaseClient';

export default function Home() {
  const [projects, setProjects] = useState([]);

  useEffect(() => {
    async function load() {
      const { data, error } = await supabase
        .from('projects')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(3);
      if (!error && data) setProjects(data);
    }
    load();
  }, []);

  return (
    <div>
      <header className="header">
        <div className="container inner">
          <a className="brand" href="/">FreelaClone</a>
          <nav className="nav">
            <Link href="/projects">Projetos</Link>
            <Link href="/post-project">Publicar</Link>
            <Link href="/dashboard">Minha Conta</Link>
          </nav>
        </div>
      </header>

      <main className="container">
        <section className="hero">
          <h1>Conecte-se com profissionais</h1>
          <p className="help">Publique projetos, receba propostas e contrate com segurança.</p>
          <div style={{ marginTop: '1rem' }}>
            <Link href="/post-project"><a className="btn primary">Publicar projeto</a></Link>
            <Link href="/projects"><a className="btn" style={{ marginLeft: '0.5rem' }}>Ver projetos</a></Link>
          </div>
        </section>

        <section style={{ marginTop: '1.5rem' }}>
          <h2>Projetos em destaque</h2>
          <div className="grid" style={{ marginTop: '1rem' }}>
            {projects.map(p => (
              <div key={p.id} className="card">
                <h3>{p.title}</h3>
                <div className="help">{p.category} • R$ {Number(p.budget).toLocaleString('pt-BR')}</div>
                <p className="help" style={{ marginTop: '.6rem' }}>{p.description?.slice(0, 140)}</p>
                <div style={{ marginTop: '.6rem' }}>
                  <Link href={`/project/${p.id}`}><a className="btn">Ver</a></Link>
                </div>
              </div>
            ))}
          </div>
        </section>
      </main>

      <footer className="footer">
        <div className="container">FreelaClone • Exemplo para deploy no Vercel</div>
      </footer>
    </div>
  );
}
EOF

cat > pages/projects.js <<'EOF'
import { useEffect, useState } from 'react';
import Link from 'next/link';
import { supabase } from '../lib/supabaseClient';
import { useRouter } from 'next/router';

export default function Projects() {
  const [projects, setProjects] = useState([]);
  const router = useRouter();
  const { q, category } = router.query;

  useEffect(() => {
    async function load() {
      let query = supabase.from('projects').select('*').order('created_at', { ascending: false });
      if (q) query = query.ilike('title', `%${q}%`).or(`description.ilike.%${q}%`);
      if (category) query = query.eq('category', category);
      const { data, error } = await query;
      if (!error && data) setProjects(data);
    }
    load();
  }, [q, category]);

  return (
    <div>
      <header className="header">
        <div className="container inner">
          <a className="brand" href="/">FreelaClone</a>
          <nav className="nav">
            <Link href="/post-project">Publicar</Link>
            <Link href="/dashboard">Minha Conta</Link>
          </nav>
        </div>
      </header>

      <main className="container">
        <h2>Projetos</h2>

        <form className="form" onSubmit={(e) => {
          e.preventDefault();
          const fd = new FormData(e.currentTarget);
          const qv = fd.get('q') || '';
          const cat = fd.get('category') || '';
          const params = new URLSearchParams();
          if (qv) params.set('q', qv);
          if (cat) params.set('category', cat);
          const qs = params.toString();
          router.push(`/projects${qs ? `?${qs}` : ''}`);
        }}>
          <input name="q" placeholder="Buscar..." defaultValue={q || ''} style={{ marginRight: '.5rem' }} />
          <select name="category" defaultValue={category || ''} style={{ marginRight: '.5rem' }}>
            <option value="">Todas categorias</option>
            <option>Desenvolvimento Web</option>
            <option>Design</option>
            <option>Mobile</option>
            <option>Marketing</option>
          </select>
          <button className="btn primary" type="submit">Filtrar</button>
        </form>

        <div className="grid" style={{ marginTop: '1rem' }}>
          {projects.map(p => (
            <div key={p.id} className="card">
              <h3>{p.title}</h3>
              <div className="help">{p.category} • R$ {Number(p.budget).toLocaleString('pt-BR')}</div>
              <p className="help" style={{ marginTop: '.6rem' }}>{p.description?.slice(0, 140)}</p>
              <div style={{ marginTop: '.6rem' }}>
                <Link href={`/project/${p.id}`}><a className="btn">Ver</a></Link>
              </div>
            </div>
          ))}
        </div>

      </main>
    </div>
  );
}
EOF

cat > pages/project/[id].js <<'EOF'
import { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import { supabase } from '../../lib/supabaseClient';

export default function ProjectPage() {
  const router = useRouter();
  const { id } = router.query;
  const [project, setProject] = useState(null);
  const [proposals, setProposals] = useState([]);
  const [msg, setMsg] = useState('');

  useEffect(() => {
    if (!id) return;
    async function load() {
      const { data: [p], error: e1 } = await supabase.from('projects').select('*').eq('id', id).limit(1);
      if (p) setProject(p);
      const { data: pr, error: e2 } = await supabase.from('proposals').select('*').eq('project_id', id).order('created_at', { ascending: false });
      if (pr) setProposals(pr);
    }
    load();
  }, [id]);

  async function sendProposal(e) {
    e.preventDefault();
    setMsg('');
    const message = e.target.message.value;
    const value = e.target.value.value;
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      setMsg('Você precisa entrar para enviar proposta.');
      return;
    }
    const { data: profile } = await supabase.from('profiles').select('id').eq('id', user.id).single();
    if (!profile) {
      await supabase.from('profiles').insert({ id: user.id, full_name: user.email });
    }
    const { error } = await supabase.from('proposals').insert([{
      project_id: id,
      user_id: user.id,
      message,
      value: Number(value)
    }]);
    if (error) setMsg('Erro ao enviar proposta: ' + error.message);
    else {
      setMsg('Proposta enviada!');
      e.target.reset();
      const { data: pr } = await supabase.from('proposals').select('*').eq('project_id', id).order('created_at', { ascending: false });
      setProposals(pr || []);
    }
  }

  async function pay(e) {
    e.preventDefault();
    const res = await fetch('/api/create-payment', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        title: project.title,
        description: project.description,
        amount: Number(project.budget),
        projectId: project.id
      })
    });
    const data = await res.json();
    if (data.error) {
      alert('Erro: ' + data.error);
      return;
    }
    window.location.href = data.init_point;
  }

  if (!project) return <div className="container">Carregando...</div>;

  return (
    <div>
      <header className="header">
        <div className="container inner">
          <a className="brand" href="/">FreelaClone</a>
        </div>
      </header>

      <main className="container">
        <div className="card">
          <h2>{project.title}</h2>
          <div className="help">{project.category} • R$ {Number(project.budget).toLocaleString('pt-BR')} • prazo {project.deadline_days} dias</div>
          <p style={{ marginTop: '.6rem' }}>{project.description}</p>

          <div style={{ marginTop: '.8rem' }}>
            <form onSubmit={pay}>
              <button className="btn primary" type="submit">Pagar / Contratar (MercadoPago)</button>
            </form>
          </div>
        </div>

        <div style={{ marginTop: '1rem' }}>
          <h3>Enviar proposta</h3>
          <form className="form" onSubmit={sendProposal}>
            <label>
              Mensagem
              <textarea name="message" required />
            </label>
            <label>
              Valor (R$)
              <input name="value" type="number" required />
            </label>
            <div style={{ marginTop: '.6rem' }}>
              <button className="btn primary" type="submit">Enviar proposta</button>
            </div>
            {msg && <div className="help" style={{ marginTop: '.6rem' }}>{msg}</div>}
          </form>
        </div>

        <div style={{ marginTop: '1rem' }}>
          <h3>Propostas</h3>
          <div className="grid">
            {proposals.length === 0 && <div className="help">Nenhuma proposta ainda.</div>}
            {proposals.map(pr => (
              <div key={pr.id} className="card">
                <div><strong>{pr.user_id}</strong></div>
                <div className="help">R$ {Number(pr.value).toLocaleString('pt-BR')} • {new Date(pr.created_at).toLocaleDateString()}</div>
                <p className="help">{pr.message}</p>
              </div>
            ))}
          </div>
        </div>
      </main>
    </div>
  );
}
EOF

cat > pages/post-project.js <<'EOF'
import { useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { useRouter } from 'next/router';

export default function PostProject() {
  const [msg, setMsg] = useState('');
  const router = useRouter();

  async function handleSubmit(e) {
    e.preventDefault();
    setMsg('');
    const fd = new FormData(e.currentTarget);
    const title = fd.get('title');
    const category = fd.get('category');
    const description = fd.get('description');
    const budget = Number(fd.get('budget'));
    const deadline_days = Number(fd.get('deadline_days'));

    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      setMsg('Você precisa entrar para publicar um projeto.');
      return;
    }

    const { data: profile } = await supabase.from('profiles').select('id').eq('id', user.id).single();
    if (!profile) {
      await supabase.from('profiles').insert({ id: user.id, full_name: user.email });
    }

    const { error } = await supabase.from('projects').insert([{
      title, category, description, budget, deadline_days, owner_id: user.id
    }]);
    if (error) setMsg('Erro: ' + error.message);
    else {
      setMsg('Projeto publicado!');
      setTimeout(() => router.push('/projects'), 800);
    }
  }

  return (
    <div>
      <header className="header">
        <div className="container inner">
          <a className="brand" href="/">FreelaClone</a>
        </div>
      </header>

      <main className="container">
        <h2>Publicar projeto</h2>
        <div className="card">
          <form className="form" onSubmit={handleSubmit}>
            <label>Título<input name="title" required /></label>
            <label>Categoria
              <select name="category" defaultValue="Desenvolvimento Web">
                <option>Desenvolvimento Web</option>
                <option>Design</option>
                <option>Mobile</option>
                <option>Marketing</option>
              </select>
            </label>
            <label>Descrição<textarea name="description" rows={6} required /></label>
            <label>Orçamento (R$)<input name="budget" type="number" min="0" required /></label>
            <label>Prazo (dias)<input name="deadline_days" type="number" min="1" required /></label>
            <div style={{ marginTop: '.6rem' }}>
              <button className="btn primary" type="submit">Publicar</button>
            </div>
            {msg && <div className="help" style={{ marginTop: '.6rem' }}>{msg}</div>}
          </form>
        </div>
      </main>
    </div>
  );
}
EOF

cat > pages/login.js <<'EOF'
import { useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { useRouter } from 'next/router';

export default function Login() {
  const [msg, setMsg] = useState('');
  const router = useRouter();

  async function handleLogin(e) {
    e.preventDefault();
    setMsg('');
    const fd = new FormData(e.currentTarget);
    const email = fd.get('email');
    const password = fd.get('password');

    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) setMsg('Erro: ' + error.message);
    else {
      setMsg('Logado! Redirecionando...');
      setTimeout(() => router.push('/dashboard'), 700);
    }
  }

  return (
    <div>
      <header className="header">
        <div className="container inner">
          <a className="brand" href="/">FreelaClone</a>
        </div>
      </header>

      <main className="container">
        <h2>Entrar</h2>
        <div className="card">
          <form className="form" onSubmit={handleLogin}>
            <label>E-mail<input name="email" type="email" required /></label>
            <label>Senha<input name="password" type="password" required /></label>
            <div style={{ marginTop: '.6rem' }}>
              <button className="btn primary" type="submit">Entrar</button>
            </div>
            {msg && <div className="help" style={{ marginTop: '.6rem' }}>{msg}</div>}
          </form>
          <div style={{ marginTop: '.6rem' }}>
            <a href="/register">Criar conta</a>
          </div>
        </div>
      </main>
    </div>
  );
}
EOF

cat > pages/register.js <<'EOF'
import { useState } from 'react';
import { supabase } from '../lib/supabaseClient';
import { useRouter } from 'next/router';

export default function Register() {
  const [msg, setMsg] = useState('');
  const router = useRouter();

  async function handleRegister(e) {
    e.preventDefault();
    setMsg('');
    const fd = new FormData(e.currentTarget);
    const email = fd.get('email');
    const password = fd.get('password');
    const name = fd.get('name');

    const { data, error } = await supabase.auth.signUp({ email, password }, { data: { full_name: name } });
    if (error) setMsg('Erro: ' + error.message);
    else {
      setMsg('Conta criada! Verifique seu e-mail (se aplicável). Redirecionando...');
      setTimeout(() => router.push('/dashboard'), 1000);
    }
  }

  return (
    <div>
      <header className="header">
        <div className="container inner">
          <a className="brand" href="/">FreelaClone</a>
        </div>
      </header>

      <main className="container">
        <h2>Cadastrar</h2>
        <div className="card">
          <form className="form" onSubmit={handleRegister}>
            <label>Nome<input name="name" required /></label>
            <label>E-mail<input name="email" type="email" required /></label>
            <label>Senha<input name="password" type="password" required /></label>
            <div style={{ marginTop: '.6rem' }}>
              <button className="btn primary" type="submit">Criar conta</button>
            </div>
            {msg && <div className="help" style={{ marginTop: '.6rem' }}>{msg}</div>}
          </form>
        </div>
      </main>
    </div>
  );
}
EOF

cat > pages/dashboard.js <<'EOF'
import { useEffect, useState } from 'react';
import Link from 'next/link';
import { supabase } from '../lib/supabaseClient';
import { useRouter } from 'next/router';

export default function Dashboard() {
  const [user, setUser] = useState(null);
  const [myProjects, setMyProjects] = useState([]);
  const [myProposals, setMyProposals] = useState([]);
  const router = useRouter();

  useEffect(() => {
    async function load() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) {
        router.push('/login');
        return;
      }
      setUser(user);
      const { data: projects } = await supabase.from('projects').select('*').eq('owner_id', user.id).order('created_at', { ascending: false });
      const { data: proposals } = await supabase.from('proposals').select('*').eq('user_id', user.id).order('created_at', { ascending: false });
      setMyProjects(projects || []);
      setMyProposals(proposals || []);
    }
    load();
  }, [router]);

  async function handleLogout() {
    await supabase.auth.signOut();
    router.push('/');
  }

  if (!user) return <div className="container">Carregando...</div>;

  return (
    <div>
      <header className="header">
        <div className="container inner">
          <a className="brand" href="/">FreelaClone</a>
          <nav className="nav">
            <a onClick={handleLogout} style={{ cursor: 'pointer' }}>Sair</a>
          </nav>
        </div>
      </header>

      <main className="container">
        <h2>Minha conta</h2>
        <div className="card">
          <h3>{user.email}</h3>
        </div>

        <div style={{ marginTop: '1rem' }} className="card">
          <h3>Meus projetos</h3>
          {myProjects.length === 0 && <div className="help">Você ainda não publicou projetos.</div>}
          {myProjects.map(p => (
            <div key={p.id} style={{ padding: '.5rem 0', borderBottom: '1px solid #eef6ff' }}>
              <strong>{p.title}</strong>
              <div className="help">R$ {Number(p.budget).toLocaleString('pt-BR')}</div>
              <div style={{ marginTop: '.4rem' }}><Link href={`/project/${p.id}`}><a className="btn">Ver</a></Link></div>
            </div>
          ))}
        </div>

        <div style={{ marginTop: '1rem' }} className="card">
          <h3>Minhas propostas</h3>
          {myProposals.length === 0 && <div className="help">Nenhuma proposta enviada.</div>}
          {myProposals.map(pr => (
            <div key={pr.id} style={{ padding: '.5rem 0', borderBottom: '1px solid #eef6ff' }}>
              <strong>Projeto: {pr.project_id}</strong>
              <div className="help">R$ {Number(pr.value).toLocaleString('pt-BR')}</div>
              <div className="help">{pr.message}</div>
            </div>
          ))}
        </div>
      </main>
    </div>
  );
}
EOF

cat > pages/api/create-payment.js <<'EOF'
import mercadopago from 'mercadopago';

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN;
  if (!accessToken) return res.status(500).json({ error: 'MERCADOPAGO_ACCESS_TOKEN not configured' });

  mercadopago.configure({ access_token: accessToken });

  try {
    const { title, description, amount, projectId } = req.body;
    if (!amount || !title) return res.status(400).json({ error: 'Missing fields' });

    const preference = {
      items: [
        {
          title,
          description: description || '',
          quantity: 1,
          unit_price: Number(amount)
        }
      ],
      external_reference: projectId || null,
      back_urls: {
        success: process.env.NEXT_PUBLIC_RETURN_URL || `${process.env.NEXT_PUBLIC_APP_URL || ''}/dashboard`,
        failure: process.env.NEXT_PUBLIC_APP_URL || '/',
        pending: process.env.NEXT_PUBLIC_APP_URL || '/'
      },
      auto_return: 'approved'
    };

    const response = await mercadopago.preferences.create(preference);
    return res.status(200).json({ init_point: response.body.init_point, id: response.body.id });
  } catch (err) {
    console.error('MP error', err);
    return res.status(500).json({ error: err.message || 'MercadoPago error' });
  }
}
EOF

cat > .gitignore <<'EOF'
node_modules
.next
.env.local
.DS_Store
EOF

echo "Todos os arquivos criados."

cd ..
echo "Criando ZIP: $OUTZIP"
# Excluir node_modules e .next caso existam
zip -r "$OUTZIP" "$PROJECT" -x "$PROJECT/node_modules/*" "$PROJECT/.next/*"
echo "ZIP criado: $(pwd)/$OUTZIP"

echo "Pronto. Extraia o arquivo e execute 'npm install' dentro da pasta $PROJECT antes de rodar o projeto."
EOF