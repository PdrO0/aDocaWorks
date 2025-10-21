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