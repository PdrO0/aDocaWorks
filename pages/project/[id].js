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
    // pegar usuário atual
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) {
      setMsg('Você precisa entrar para enviar proposta.');
      return;
    }
    // garantir profile
    const { data: profile } = await supabase.from('profiles').select('id').eq('id', user.id).single();
    if (!profile) {
      // criar profile automático
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
      // reload proposals
      const { data: pr } = await supabase.from('proposals').select('*').eq('project_id', id).order('created_at', { ascending: false });
      setProposals(pr || []);
    }
  }

  async function pay(e) {
    e.preventDefault();
    // criar preferência no servidor (server-side uses MERCADOPAGO_ACCESS_TOKEN)
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
    // redireciona para o ponto de pagamento (init_point)
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