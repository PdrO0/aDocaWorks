```markdown
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

Se quiser, eu adapto o fluxo de checkout para usar Webhooks do MercadoPago e alterar o status do projeto/propostas automaticamente — quer que eu inclua também o endpoint de webhook já preparado?
```# aDocaWorks
# aDocaWorks
