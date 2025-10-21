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