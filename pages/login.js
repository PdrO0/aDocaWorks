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