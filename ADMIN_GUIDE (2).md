# Curevoo Admin Guide

## What Admin Does

In this backend, `ADMIN` is focused on platform-level content management and privileged account bootstrap.

### Current Admin Capabilities

1. Manage psychological knowledge articles:
- `POST /api/admin/knowledge-articles`
- `PUT /api/admin/knowledge-articles/:id`
- `DELETE /api/admin/knowledge-articles/:id`

2. Manage doctor accounts:
- `POST /api/admin/users/doctors`
- `PUT /api/admin/users/doctors/:userId`
- `DELETE /api/admin/users/doctors/:userId`

3. Manage patient accounts:
- `POST /api/admin/users/patients`
- `PUT /api/admin/users/patients/:userId`
- `DELETE /api/admin/users/patients/:userId`

4. Create other admin accounts through unified registration:
- `POST /api/registration/create-account` with `"role": "ADMIN"`
- This is only allowed when the caller is already authenticated as `ADMIN`.

### Current Admin Restrictions

1. Admin cannot use doctor-only endpoints (`requireRole("DOCTOR")`) as doctor actions.
2. Admin cannot use patient-only endpoints (`requireRole("PATIENT")`) as patient actions.
3. Admin does not automatically get doctor profile or patient profile records.

## Bootstrap Admin Creation

Because the API requires an existing admin to create another admin, the first admin must be bootstrapped directly in DB.

Use:

```bash
node scripts/create-admin.js
```

Optional arguments:

```bash
node scripts/create-admin.js --email admin@curevoo.local --password "StrongPass123!" --name "Platform Admin"
```

If an admin already exists, creation is blocked by default. To allow creation anyway:

```bash
node scripts/create-admin.js --force
```

## Security Notes

1. Change bootstrap credentials immediately after first login.
2. Keep admin count minimal.
3. Never expose printed bootstrap passwords in shared logs.
