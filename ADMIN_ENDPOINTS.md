# Admin-Requestable Endpoints

This file includes the endpoints you listed from `ENDPOINTS.md`:
- All `ADMIN` endpoints
- All `PUBLIC` endpoints

## 1. ADMIN Endpoints

### `GET /api/admin/knowledge-articles`
- Auth: `ADMIN`
- Purpose: List all knowledge articles (published and unpublished).
- Query params: `category=cancer|wellbeing|curevoo`, `language=en|ar`
- Example: `GET /api/admin/knowledge-articles?category=cancer` with `Authorization: Bearer {{adminAccessToken}}`

### `GET /api/admin/knowledge-articles/:id`
- Auth: `ADMIN`
- Purpose: Return full knowledge article details by id (includes content).
- Example: `GET /api/admin/knowledge-articles/{{articleId}}` with `Authorization: Bearer {{adminAccessToken}}`

### `GET /api/admin/knowledge-articles/:id/metadata`
- Auth: `ADMIN`
- Purpose: Return article metadata by id (excludes `content` body).
- Example: `GET /api/admin/knowledge-articles/{{articleId}}/metadata` with `Authorization: Bearer {{adminAccessToken}}`

### `POST /api/admin/knowledge-articles`
- Auth: `ADMIN`
- Purpose: Create a knowledge article entry for psychological-support education pages.
- Example:
```json
{
  "title": "What is NSCLC?",
  "category": "cancer",
  "summary": "Simple explanation for patients.",
  "content": "NSCLC is ...",
  "sources": [
    {
      "title": "National Cancer Institute",
      "url": "https://www.cancer.gov/"
    }
  ],
  "language": "en",
  "is_published": true
}
```

### `PUT /api/admin/knowledge-articles/:id`
- Auth: `ADMIN`
- Purpose: Update an existing knowledge article.
- Example:
```json
{
  "summary": "Updated summary text"
}
```

### `DELETE /api/admin/knowledge-articles/:id`
- Auth: `ADMIN`
- Purpose: Delete one knowledge article by id.
- Example: `DELETE /api/admin/knowledge-articles/{{articleId}}` with `Authorization: Bearer {{adminAccessToken}}`

### `GET /api/admin/users/doctors`
- Auth: `ADMIN`
- Purpose: List doctor accounts for admin management.
- Example: `GET /api/admin/users/doctors` with `Authorization: Bearer {{adminAccessToken}}`

### `POST /api/admin/users/doctors`
- Auth: `ADMIN`
- Purpose: Create a doctor account as admin.
- Example:
```json
{
  "email": "doctor.admin.created@example.com",
  "password": "Pass1234!",
  "fullName": "Dr. Admin Created",
  "phoneNumber": "+963944000100",
  "age": 42,
  "specialization": "Oncology",
  "workingAt": "City Hospital",
  "experience": 12,
  "location": "Damascus",
  "languages": ["ar", "en"]
}
```

### `PUT /api/admin/users/doctors/:userId`
- Auth: `ADMIN`
- Purpose: Update a doctor account as admin.
- Example:
```json
{
  "fullName": "Dr. Updated Name",
  "specialization": "Radiation Oncology",
  "isActive": true
}
```

### `DELETE /api/admin/users/doctors/:userId`
- Auth: `ADMIN`
- Purpose: Delete a doctor account as admin.
- Example: `DELETE /api/admin/users/doctors/{{doctorUserId}}` with `Authorization: Bearer {{adminAccessToken}}`

### `GET /api/admin/users/patients`
- Auth: `ADMIN`
- Purpose: List patient accounts for admin management.
- Example: `GET /api/admin/users/patients` with `Authorization: Bearer {{adminAccessToken}}`

### `POST /api/admin/users/patients`
- Auth: `ADMIN`
- Purpose: Create a patient account as admin.
- Example:
```json
{
  "email": "patient.admin.created@example.com",
  "password": "Pass1234!",
  "fullName": "Patient Admin Created",
  "phoneNumber": "+963944000200",
  "age": 35,
  "sex": "FEMALE",
  "location": "Damascus"
}
```

### `PUT /api/admin/users/patients/:userId`
- Auth: `ADMIN`
- Purpose: Update a patient account as admin.
- Example:
```json
{
  "fullName": "Updated Patient Name",
  "age": 36,
  "medicalHistory": "Updated notes"
}
```

### `DELETE /api/admin/users/patients/:userId`
- Auth: `ADMIN`
- Purpose: Delete a patient account as admin.
- Example: `DELETE /api/admin/users/patients/{{patientUserId}}` with `Authorization: Bearer {{adminAccessToken}}`

### `POST /api/registration/create-account`
- Auth: `ADMIN` (for admin creation path)
- Purpose: Create account when creating `role=ADMIN`.
- Example:
```json
{
  "email": "newadmin@example.com",
  "password": "Pass1234!",
  "fullName": "New Admin",
  "role": "ADMIN"
}
```

## 2. PUBLIC Endpoints

### `GET /health`
- Auth: Public
- Purpose: Health check endpoint.
- Example: `GET http://localhost:5432/health`

### `GET /uploads/<path>`
- Auth: Public
- Purpose: Serves uploaded static files such as doctor photos and medical-record images.
- Example: `GET http://localhost:5432/uploads/doctors/sample.jpg`

### `POST /api/auth/register`
- Auth: Public
- Purpose: Register a patient through the auth module.
- Example:
```json
{
  "email": "patient1@example.com",
  "password": "Pass1234!",
  "fullName": "Patient One"
}
```

### `POST /api/auth/register-doctor`
- Auth: Public
- Purpose: Register a doctor through the auth module.
- Example: `multipart/form-data` with `name=Dr. Samer`, `email=doctor@example.com`, `password=Pass1234!`, `phoneNumber=+963944000000`, `age=40`, `specialization=Oncology`, `workplace=City Hospital`, `experience=10`, `location=Damascus`, `languages=["ar","en"]`

### `POST /api/auth/login`
- Auth: Public
- Purpose: Login through the auth module.
- Example:
```json
{
  "email": "patient1@example.com",
  "password": "Pass1234!"
}
```

### `POST /api/auth/refresh`
- Auth: Public
- Purpose: Refresh access token.
- Example:
```json
{
  "refreshToken": "{{refreshToken}}"
}
```

### `POST /api/auth/logout`
- Auth: Public
- Purpose: Clear refresh token cookie.
- Example: `POST /api/auth/logout`

### `POST /api/registration/create-account`
- Auth: Public (for `role=PATIENT` or `role=DOCTOR`)
- Purpose: Unified account creation endpoint.
- Example:
```json
{
  "email": "newpatient@example.com",
  "password": "Pass1234!",
  "fullName": "New Patient",
  "role": "PATIENT"
}
```

### `POST /api/registration/verify-email/send-otp`
- Auth: Public
- Purpose: Send email verification OTP.
- Example:
```json
{
  "email": "newpatient@example.com"
}
```

### `POST /api/registration/verify-email/confirm`
- Auth: Public
- Purpose: Confirm email verification OTP.
- Example:
```json
{
  "email": "newpatient@example.com",
  "otp": "123456"
}
```

### `POST /api/registration/login`
- Auth: Public
- Purpose: Login alias under registration.
- Example:
```json
{
  "email": "doctor@example.com",
  "password": "Pass1234!"
}
```

### `POST /api/registration/refresh`
- Auth: Public
- Purpose: Refresh token alias under registration.
- Example:
```json
{
  "refreshToken": "{{refreshToken}}"
}
```

### `POST /api/registration/forgot-password/send-otp`
- Auth: Public
- Purpose: Send password reset OTP.
- Example:
```json
{
  "email": "doctor@example.com"
}
```

### `POST /api/registration/forgot-password/reset`
- Auth: Public
- Purpose: Reset password with OTP.
- Example:
```json
{
  "email": "doctor@example.com",
  "otp": "123456",
  "newPassword": "NewPass1234!"
}
```

### `POST /api/patients/register`
- Auth: Public
- Purpose: Register a patient through the patient module.
- Example:
```json
{
  "email": "patient2@example.com",
  "password": "Pass1234!",
  "fullName": "Patient Two"
}
```

### `POST /api/patients/login`
- Auth: Public
- Purpose: Login through the patient module.
- Example:
```json
{
  "email": "patient2@example.com",
  "password": "Pass1234!"
}
```

### `POST /api/patients/refresh`
- Auth: Public
- Purpose: Refresh token through the patient module.
- Example:
```json
{
  "refreshToken": "{{refreshToken}}"
}
```

### `POST /api/patients/forgot-password/send-otp`
- Auth: Public
- Purpose: Send patient password reset OTP.
- Example:
```json
{
  "email": "patient2@example.com"
}
```

### `POST /api/patients/forgot-password/reset`
- Auth: Public
- Purpose: Reset patient password with OTP.
- Example:
```json
{
  "email": "patient2@example.com",
  "otp": "123456",
  "newPassword": "NewPass1234!"
}
```

## Summary

- Total endpoints in this file: `34`
- Admin endpoints: `15`
- Public endpoints: `19`
