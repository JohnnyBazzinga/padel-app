# Release para App Store (iOS)

## 1) Estado atual do app para produção

Este projeto já está com:
- Backend apontado para Railway em produção
- Fluxo de roles e convites com guards no frontend
- Testes de regras de rota
- Testes de parsing para `User`, `RoleInvitation` e `AppRoles`

## 2) Comandos obrigatórios antes de gerar build para publicação

```bash
# Validação de qualidade
flutter clean
flutter pub get
flutter analyze
flutter test

# Build local sem assinatura (validação de compilação)
flutter build ios --release --no-codesign
```

## 3) Smoke test de fluxo crítico (UAT)

1. Conta ADMIN cria convite para um utilizador:
   - login com admin
   - `Home -> Admin -> Convidar organizador`
   - enviar email + nota
2. Utilizador convidado abre o link/rota:
   - consegue abrir `/roles/invitations?token=...`
   - consegue visualizar convite, aceitar/rejeitar
3. Após aceitar:
   - `/users/me` devolve `roles` com `ORGANIZER`
   - rota `/create-match` e `/tournaments/create` passam a ficar disponíveis
4. Utilizador sem permissão:
   - não consegue abrir `/admin/*`
   - é redirecionado para `/matches` ao tentar `/create-match`

## 4) Checklist de Codemagic (iOS)

### Variáveis de ambiente (exemplo)
- `KEYCHAIN_PATH` (gerido pelo Codemagic)
- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`
- `APP_IDENTIFIER` = `com.padelapp.app`
- `MATCH_GIT_BASIC_AUTHORIZATION`
- `MATCH_KEYCHAIN_PASSWORD`

### Workflow recomendado
- Flutter channel `stable`
- Steps:
  - `flutter pub get`
  - `flutter test`
  - `flutter analyze`
  - `flutter build ios --release --no-codesign`
  - `flutter build ipa`

## 5) Assinatura

- Confirmar signing manual/auto com:
  - bundle id: `com.padelapp.app`
  - certificado e perfil válidos no Apple Developer
- `version` no `pubspec.yaml` e build number alinhado com App Store Connect

## 6) Submissão Apple

- Abrir o build no App Store Connect
- Validar:
  - nome da app
  - privacy (se aplicável)
  - screenshots
  - metadata da app
- Submeter para review

