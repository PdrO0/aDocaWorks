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
      // opcional: criar profile no supabase (após confirmação)
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