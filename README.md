# Curevoo Admin Dashboard

Flutter Web admin dashboard for Curevoo backend admin workflows.

## Implemented Modules

- Authentication (`/api/auth/*`)
- Knowledge Articles CRUD (`/api/admin/knowledge-articles`)
- Notifications (`/api/registration/notifications`)
- AI Workflows:
  - Cancer Diagnosis (`/api/ai/cancer-diagnosis/*`)
  - Cancer Resistance (`/api/ai/cancer-resistance/*`)

## Project Structure

- `lib/cubits`: Feature cubits and states (`auth`, `articles`, `notifications`, `ai`)
- `lib/repos`: API client and repositories (`auth_repo`, `knowledge_articles_repo`, `notifications_repo`, `ai_repo`)
- `lib/models`: DTOs and domain models
- `lib/screens`: UI screens and dashboard shell
- `lib/theme`: App theme configuration
- `lib/constants`: API base URL and endpoint constants

## API Base URL

Configured in `lib/constants/api_constants.dart`:

- Default: `http://localhost:5432`

Update this value when switching to staging/production.

## Run Locally

1. Install dependencies:

```bash
flutter pub get
```

2. Run app (web):

```bash
flutter run -d chrome
```

3. Quality checks:

```bash
flutter analyze
flutter test
```

## Auth and Token Behavior

- Login stores `accessToken` and `refreshToken` in shared preferences.
- API client attaches `Authorization: Bearer <accessToken>` automatically.
- On `401`, client tries `/api/auth/refresh` once and retries the original request.
- If refresh fails, local session is cleared and user is forced back to login.

## Endpoint Mapping

- `POST /api/auth/login` -> Login screen submit
- `GET /api/auth/validate-token` -> session restore validation on app start
- `POST /api/auth/refresh` -> automatic token refresh on unauthorized response
- `POST /api/auth/logout` -> top-bar logout action
- `POST /api/admin/knowledge-articles` -> create article dialog
- `PUT /api/admin/knowledge-articles/:id` -> edit article and publish toggle
- `DELETE /api/admin/knowledge-articles/:id` -> delete article confirmation
- `GET /api/registration/notifications` -> Notifications tab
- `POST /api/ai/cancer-diagnosis/start` -> AI Workflows / Diagnosis / Start
- `POST /api/ai/cancer-diagnosis/message` -> AI Workflows / Diagnosis / Send
- `POST /api/ai/cancer-resistance/start` -> AI Workflows / Resistance / Start
- `POST /api/ai/cancer-resistance/message` -> AI Workflows / Resistance / Send

## Manual QA Checklist

### Authentication

- Open app with no saved session: login screen appears.
- Login with valid admin credentials: dashboard opens.
- Login with invalid credentials: error snackbar appears.
- Click logout: session clears and returns to login.

### Articles

- Open Articles tab: list loads (or empty state shown).
- Create article with required fields: new item appears in list.
- Edit article fields: changes are reflected.
- Toggle publish switch: publication state updates.
- Delete article and confirm: item removed from list.

### Notifications

- Open Notifications tab: notifications are fetched.
- Click Refresh: list updates without crashing.
- Backend error case: error snackbar is displayed.

### AI Workflows

- Set session ID and click Apply Session.
- Diagnosis: click Start, then send a message, verify bot reply appears.
- Resistance: click Start, then send a message, verify bot reply appears.
- Response rendering supports string, object, and list payload shapes.

## Notes

- Pagination is intentionally not implemented because backend does not support it.
- If articles list endpoint is absent/limited server-side, create/update/delete flows remain available.
