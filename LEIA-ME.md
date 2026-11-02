# Customer Survey: como pôr online

Esta pasta é o site completo. Tem duas páginas:

- **index.html**: o questionário público (o link que partilham com toda a gente).
- **admin.html**: a área privada da equipa (dashboard, respostas, editor de textos). Só entra quem tiver login.

Demora cerca de 30 minutos a pôr tudo a funcionar. Faça os passos pela ordem.

## 1. Base de dados (Supabase)

1. Em supabase.com crie um projeto novo. Escolha uma região da **UE** (por exemplo Frankfurt ou Paris), por causa do RGPD.
2. Abra o ficheiro **supabase_setup.sql** num editor de texto. No fim do ficheiro (passo 6) troque os 6 emails de exemplo pelos emails reais da equipa e guarde.
3. No Supabase, vá a **SQL Editor**, cole o conteúdo do ficheiro e carregue em **Run**. Deve aparecer "Success".
4. Vá a **Authentication > Sign In / Providers > Email** e **desligue** "Allow new users to sign up" (assim ninguém de fora cria conta).
5. Vá a **Authentication > Users > Add user** e crie os 6 utilizadores, com os mesmos emails do passo 2, uma palavra-passe cada e a opção "Auto Confirm User" ligada.
6. Vá a **Project Settings > API** e copie dois valores: **Project URL** e a chave **anon public**. A chave "service_role" nunca deve ser colada em lado nenhum.

## 2. Configuração

Abra o ficheiro **config.js** e preencha:

- `SUPABASE_URL`: o Project URL.
- `SUPABASE_ANON_KEY`: a chave anon public (pode ser pública, é protegida pelas regras da base de dados).
- `SITE_URL`: o endereço do site no GitHub, com a barra no fim (ver passo 3).

## 3. GitHub Pages (com um endereço sem o seu nome pessoal)

O endereço do GitHub Pages inclui sempre o nome da conta ou da organização. Para não aparecer o seu nome de utilizador, crie uma **organização gratuita** e use-a para alojar o site.

1. No GitHub: clique no seu avatar, **Your organizations > New organization > Free**. Escolha um nome neutro, por exemplo `holiday-study-nova` (evite "novasbe" sozinho, que parece uma conta oficial, e evite "details" ou "loyalty").
2. Dentro da organização crie um repositório **público** chamado `customer-survey` e carregue **todos os ficheiros e pastas** desta pasta (index.html, admin.html, config.js, texts.json, og.png, vendor, supabase_setup.sql).
3. No repositório: **Settings > Pages > Build and deployment**, escolha "Deploy from a branch", branch **main**, pasta **/ (root)** e Save.
4. Ao fim de um ou dois minutos o site fica em `https://holiday-study-nova.github.io/customer-survey/` (com o nome da sua organização). Esse é o `SITE_URL`.
5. Pode convidar os colegas para a organização (**People > Invite member**) para todos poderem editar os ficheiros.

Atenção: o nome do repositório fica no endereço e não deve ser mudado depois de partilharem o link.

Alternativa sem GitHub: no netlify.com arraste a pasta para "Deploy manually" e obtém um endereço como `customer-survey.netlify.app`, também gratuito e sem nenhum nome pessoal. Para atualizar é preciso voltar a arrastar a pasta.

## 4. Pré-visualização bonita ao partilhar (WhatsApp, etc.)

No ficheiro **index.html** há 3 sítios com o texto `__SITE_URL__`. Substitua-os todos pelo seu endereço do passo 3 (com a barra no fim). No GitHub: abra o index.html, clique no lápis, use Ctrl+F para encontrar `__SITE_URL__` e troque. Se preferir, envie o endereço à Claude e ela devolve o ficheiro já pronto.

Depois, ao enviar o link no WhatsApp, aparece o cartão com o logótipo da Nova SBE, o título e os ícones. O WhatsApp guarda a pré-visualização durante algum tempo, por isso a primeira vez pode demorar a atualizar.

## 5. Links

- **Questionário (público):** o endereço do passo 3.
- **Área da equipa (privado):** o mesmo endereço seguido de `admin.html`. Entram com email e palavra-passe (ou pedem um link por email).
- Dentro do painel há sempre os botões **Copiar link do questionário** e **Partilhar** (abre o WhatsApp ou a partilha do telemóvel).
- No fim do questionário cada pessoa vê os botões **Partilhar**, **WhatsApp** e **Copiar link**.

## 6. Antes de lançar: testar

1. Responda ao questionário uma vez no telemóvel.
2. Abra o painel: a resposta deve aparecer em **Visão geral** e em **Respostas**.
3. Apague as respostas de teste: **Respostas > abrir a resposta > Apagar esta resposta**.

## 7. O que há no painel

- **Visão geral:** número de respostas, progresso por destino (meta de 30), e gráficos de demografia (género, idade, residência), férias, rankings de mecanismos e benefícios, bundles escolhidos, preços e orçamento. O filtro permite ver todos, um destino ou "outros locais".
- **Respostas:** lista de todas as respostas, abre cada uma, exporta CSV (abre bem no Excel) e permite apagar.
- **Textos:** pesquisa qualquer texto do questionário e corrige a versão em inglês e em português. Só serve para pequenas correções de linguagem. As respostas guardadas não mudam, porque guardam sempre o nome original de cada opção. A alteração aparece no questionário ao fim de poucos segundos.

## Notas

- O questionário não pede nome nem email e a aplicação não guarda o endereço IP das pessoas. Confirmem com a coordenadora se o texto de consentimento chega para o curso.
- Se mudarem a língua ou o texto de uma opção no editor, a análise continua a usar o nome original da opção, por isso os gráficos não se partem.
- Se algo falhar, abram a consola do browser (F12) e enviem a mensagem de erro à Claude.
