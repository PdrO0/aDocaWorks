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

    // criar profile se não existir
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