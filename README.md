# Plano de Metas — Polo Anhanguera Campo Grande/RJ

App web completo (PWA) com banco de dados real no Supabase.

## Arquivos

- `index.html` — o app inteiro (interface + lógica). Conecta direto no Supabase.
- `manifest.json` — configuração de instalação como app no celular.
- `service-worker.js` — permite abrir rápido e funcionar parcialmente offline.
- `icon-192.png` / `icon-512.png` — ícones do app na tela inicial.
- `schema.sql` — script que cria as tabelas no Supabase (já foi executado).

## Passo 1 — Confirmar o schema no Supabase

1. Entre no projeto **App Anhanguera CG** em supabase.com
2. Vá em **SQL Editor → New query**
3. Cole o conteúdo de `schema.sql` e clique em **Run**
   - (Se já rodou antes, pode rodar de novo sem problema — os comandos usam `if not exists` / `on conflict do nothing`.)

## Passo 2 — Configurar o e-mail de redefinição de senha (recomendado)

1. No painel do Supabase, vá em **Authentication → URL Configuration**
2. Em **Site URL**, coloque a URL do seu site depois que ele estiver publicado (ex: `https://plano-metas-anhanguera.vercel.app`)
   - Antes de publicar, pode deixar como está; depois do deploy, volte aqui e atualize.

## Passo 3 — Publicar o site (Vercel)

1. Acesse **vercel.com** e crie uma conta (pode usar GitHub ou e-mail)
2. Clique em **Add New → Project**
3. Se pedir um repositório Git: a opção mais simples é arrastar a pasta inteira
   (`index.html`, `manifest.json`, `service-worker.js`, `icon-192.png`, `icon-512.png`)
   na aba de **deploy manual / drag and drop** do Vercel
4. Clique em **Deploy**
5. Em poucos segundos, o Vercel te dá uma URL fixa, tipo:
   `https://plano-metas-anhanguera.vercel.app`

## Passo 4 — Criar a primeira conta de uso

1. Abra a URL publicada
2. Clique em **"Criar conta"**, preencha nome, papel (ex: Gestor), e-mail e senha
3. Pronto — já está logado e os dados começam a ser salvos no Supabase

## Passo 5 — Instalar no celular

- **Android (Chrome):** abra a URL → menu (⋮) → "Adicionar à tela inicial" / "Instalar app"
- **iPhone (Safari):** abra a URL → botão de compartilhar (□↑) → "Adicionar à Tela de Início"

## Adicionar mais pessoas da equipe

Cada pessoa nova só precisa abrir a URL do site e clicar em **"Criar conta"** com o
próprio e-mail. Não existe um passo de "convite" — qualquer pessoa de confiança
pode criar a própria conta. Se quiser restringir isso depois, é possível desativar
o cadastro aberto no Supabase (Authentication → Providers → Email) e criar os
usuários manualmente pelo painel — me avise se quiser isso.
