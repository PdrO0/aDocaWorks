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