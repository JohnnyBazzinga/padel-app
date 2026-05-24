# Fluxo de Roles e Convites (Admin -> Organizadores -> Jogos/Torneios)

## Objetivo
Controlar permissões reais no app para evitar que qualquer utilizador execute ações administrativas.

## Estado atual no app (frontend)
- `user.roles` é carregado de `/users/me`.
- `AppRoles` normaliza e resolve permissões:
  - `canInviteOrganizer` = `isAdmin` (APP_OWNER e PLATFORM_ADMIN entram aqui)
  - `canCreateMatches` = `isOrganizer`
  - `canCreateTournaments` = `isOrganizer`
- Regras de rota:
  - `/admin/*` protegido por `canAccessAdminArea` (= `isAdmin`).
  - `/create-match` protegido por `canCreateMatches`.
  - `/tournaments/create` protegido por `canCreateTournaments`.
  - `/roles/invitations` é pública para aceitar/rejeitar por token.
- Flow de convite implementado:
  - Admin cria convite (`POST /roles/invitations`) com `role=ORGANIZER`.
  - Convite pode ser processado pelo dono via token em `/roles/invitations?token=...`.
  - Ao aceitar, o app faz `refreshUser()` e atualiza permissões imediatamente.

## O que já foi aplicado no fluxo
- Guardas de rota para criação de jogos/torneios.
- Tela de convites (`AdminInvitesScreen`) com:
  - convites da conta,
  - convites pendentes (admin),
  - aceitar/rejeitar convite por token.
- `RolesProvider` com parsing resiliente de payload e refresh de listas.
- Redirecionamento para login pós-falha 401 em fluxo de token.
- Testes para:
  - normalização e herança de roles,
  - parse de `RoleInvitation`,
  - checks de produção e ausência de modo demo.

## O que falta no backend para ficar produção ready
- RBAC/guards robustos por rota:
  - `POST /roles/invitations`
  - `GET /roles/invitations/pending`
  - `GET /roles/invitations/me`
  - `POST /roles/invitations/{id}/accept|reject`
  - `POST /roles/invitations/{id}/cancel`
  - `POST /roles/invitations/token/{token}/accept|reject`
- Regras de dono do recurso:
  - só dono do convite pode aceitar/rejeitar `accept|reject` por id.
- Expiração e idempotência de convite:
  - retorno consistente de `409/410` e estado `EXPIRED`.
- Validação de quem pode convidar/editar convites por organização.
- Logs/audit trail para criação, aceite, rejeição e expiração.

## Contrato API mínimo esperado
1. `POST /roles/invitations` `{ email, role, note? }`
2. `GET /roles/invitations/pending`
3. `GET /roles/invitations/me`
4. `GET /roles/invitations/token/{token}`
5. `POST /roles/invitations/{id}/accept`
6. `POST /roles/invitations/{id}/reject`
7. `POST /roles/invitations/{id}/cancel`
8. `POST /roles/invitations/token/{token}/accept`
9. `POST /roles/invitations/token/{token}/reject`
