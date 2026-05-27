Projecto Padel FY

Objetivo v5: app social + gestão de jogos de padel com foco em descoberta local e confiança.

## Como vamos usar este documento

- ✅ Implementado
- 🟨 Parcial (funciona, mas com limitações técnicas a fechar)
- ⛔ Não implementado

## Funcionalidades funcionais do documento

1. Comunidade + feed tipo Instagram

- ✅ `Feed social com cards de publicações`
- ✅ `Like` e `comentário` no post
- ✅ `scroll` com paginação no feed
- ✅ `Filtro por cidade` e estado (status)
- 🟨 `Publicação de media` (até 3 imagens)  
  - Implementado via URLs de imagem, ainda sem upload/file picker oficial
- ✅ `Estado/Stories` (A jogar, A procurar parceiro, Offline)  
  - Implementado com estado de utilizador persistente (`availabilityStatus`) e compatibilidade com aliases de API (`status`, `availability`, `state`)
- ðŸŸ¨ `follow` entre utilizadores (UI e toggle implementados no feed; contrato backend final ainda a fechar)
- 🟨 `Perfil do autor` ao tocar no post  
  - abre `/profile` atual do utilizador, sem navegação por perfil público ainda

2. Matchmaking e “Need 1 player now”

- ✅ `Endpoint suggest`
  - `/match-making/suggest` consumido em `MatchesProvider.fetchMatchSuggestions`
- ✅ `Fluxo automático fill`
  - `/match-making/create-fill` consumido em `MatchesProvider.createAutoFill`
- ✅ `Cidades iniciais`  
  - Lisboa, Madrid, São Paulo, Barcelona, Dubai
- ✅ `Filtro inicial por cidade e nível/slots`
- 🟨 `match confiante por critérios avançados`  
  - confiança já exibida (campo `confidence`) mas sem motor de ranking/heurística avançado documentado
- 🟨 `Prioridade premium`
  - existe parâmetro `premium`, ainda sem feature flag/tiers no produto

3. Ranking + reputação

- ✅ `Ranking global` (`/rankings`)
- ✅ `Ranking ELO` (`/rankings/elo`)
- ✅ Exibição de reputação no ranking e match card
- ✅ `Mini feedback pós-jogo` (pontualidade, fair play, social)
  - popup obrigatório após score quando ainda não enviado
- 🟨 `Cálculo de ELO/reputação`
  - consumo de campos da API e UI pronto, sem confirmação de regra final de backend no app

4. Perfil / confiança social

- ✅ `Indicador de reputação` no perfil
- ✅ `badges` e contagem de votos (`votos`) no perfil
- ✅ `Badges` de reputação também em ranking e detalhe de partida

5. UI / navegação estilo Instagram

- ✅ `Bottom nav` com 5 abas: Feed, Buscar, Partidas, Notificações, Perfil
- ✅ `Estado de navegação` central via `MainScreen`
- ✅ Navegação consolidada em rotas Shell (`/home`, `/search`, `/matches`, `/notifications`, `/profile`)
- 🟨 `Tema sólido` aplicado, mas ainda com pequenos defaults de espaçamento a revisar por consistência

6. Motor de negócio / mercado

- ⛔ `Anúncios (clubes/marcas)`
- ⛔ `Venda/compra de material usado`
- ⛔ `Aulas de treinador`
- ⛔ `Promoções / happy hours`

7. Funcionalidades de base

- ✅ Registo/login, autenticação e perfil
- ✅ Clubes/campos + booking
- ✅ Chat
- ✅ Amizades básicas (funcionalidade ativa no projeto)
- ✅ Torneios
- ✅ Histórico de partidas

## Decisão de simplificação (fase atual)

- Remover de momento:
  - implementação de follow de rede social completa
  - upload de ficheiros de imagem sofisticado (mantemos URL até fechar infraestrutura backend)
  - gamificação avançada fora do scope inicial
- Preservar para fase 2:
  - ads, material usado, coaches e promoções

## Próximo passo (próxima sprint)

- Fechar a camada técnica de `Reputação`:
  - padronizar contrato backend de feedback e atualizar agregados (skill signal, confiança, trust score)
- Ativar feed de media com upload real (múltiplo até 3)
- Definir se `match fill` mantém prioridade premium ou passa para ranking único
- Documentar contratos `POST`/`GET` faltantes no backend (ads, gear, coaches, promotions)

## Referência rápida (implementado no código)

- `features/home/screens/social_feed_screen.dart`
- `shared/providers/social_feed_provider.dart`
- `shared/models/social_post.dart`
- `features/need_one/screens/need_one_screen.dart`
- `shared/providers/matches_provider.dart`
- `features/matches/screens/match_detail_screen.dart`
- `features/rankings/screens/rankings_screen.dart`
- `shared/providers/rankings_provider.dart`
- `shared/models/user_model.dart`
- `features/profile/screens/profile_screen.dart`
- `features/home/screens/main_screen.dart`
- `core/navigation/app_router.dart`
- `main.dart`

## Documento técnico complementar

- Ver: `docs/estado_implementacao.md`



## Atualização de registo
- Perfil do autor no feed: Social Feed -> Profile agora abre /profile/{id} com vista pública do autor quando disponível.


## 2. Comunity and social network backend alignment (27/05/2026)
- Follow backend now fully implemented:
  - Endpoints /users/{id}/follow, /users/{id}/unfollow, /users/{id}/follow-toggle.
  - Post social endpoints /posts, /posts/feed, /posts/{id}/like, /posts/{id}/comment.
  - Prisma entities added: Post, PostMedia, PostLike, PostComment, UserFollow.
- Next item status changed:
  - Follow can now persist and toggle in backend, not only UI.
