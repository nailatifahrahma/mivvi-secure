# MIVVI SECURE — API Integration

## Purpose

The API provides account registration/login and distributes a versioned detector configuration to Android clients. The mobile app still performs all message parsing, URL checks, keyword matching, weighted scoring, and classification locally.

**No message body, sender identifier, phone number, notification payload, or analysis history is uploaded.** Account registration sends the user's name, email, and password to this API; passwords are stored as scrypt hashes.

## Endpoints

### `GET /api/v1/health`

Response:

```json
{
  "status": "ok",
  "service": "mivvi-secure-rules-api",
  "version": "1.0.0"
}
```

### `GET /api/v1/rules`

Returns `server/config/rules.json`:

```json
{
  "version": "1.0.0",
  "weights": {
    "suspicious_keyword": 2,
    "url_outside_whitelist": 3,
    "shortlink": 2,
    "unknown_sender": 2,
    "urgency": 1,
    "sensitive_data": 3
  },
  "thresholds": {
    "suspicious_from": 3,
    "phishing_from": 6
  },
  "keywords": ["menang", "hadiah", "verifikasi akun"],
  "urgency_patterns": ["segera", "24 jam"],
  "sensitive_patterns": ["otp", "pin", "password"],
  "official_domains": ["bca.co.id", "pajak.go.id"],
  "shortlink_domains": ["bit.ly", "tinyurl.com"]
}
```

The actual response includes the full default pattern lists. The Android client caches the JSON in `SharedPreferences` and falls back to built-in rules if the API cannot be reached.

## Weight keys

| Key | Meaning | Default |
|---|---|---:|
| `suspicious_keyword` | One or more suspicious keyword patterns detected | 2 |
| `url_outside_whitelist` | At least one extracted URL host is outside configured whitelist | 3 |
| `shortlink` | At least one URL host matches configured shortlink domains | 2 |
| `unknown_sender` | Non-empty sender is not in user's local trusted-sender list | 2 |
| `urgency` | One or more urgency patterns detected | 1 |
| `sensitive_data` | One or more sensitive-data request patterns detected | 3 |

## Account authentication

Android authentication uses the same API base URL configured under **Pengaturan → Integrasi Data (Rules API)**. The default for the Android emulator is `http://10.0.2.2:8000`. On a physical phone, use the computer's LAN IP address and bind the server to `0.0.0.0`.

### `POST /api/v1/auth/register`

Create a pending account. The name must contain at least 2 characters, the email must be valid, and the password must contain 8–128 characters. The API sends a six-digit code by email; the code expires after 10 minutes. Registration does not create a session until the code is verified. SMTP must be configured with `MIVVI_SMTP_HOST`, `MIVVI_SMTP_PORT`, `MIVVI_SMTP_USER`, `MIVVI_SMTP_PASSWORD`, and optionally `MIVVI_SMTP_FROM`.

```json
{
  "name": "Nama Pengguna",
  "email": "pengguna@example.com",
  "password": "contoh-kata-sandi"
}
```

### `POST /api/v1/auth/verify-email`

Submit the address and six-digit code received by email. A successful response creates the first session.

```json
{
  "email": "pengguna@example.com",
  "code": "123456"
}
```

### `POST /api/v1/auth/resend-verification`

Submit `{"email":"pengguna@example.com"}` to resend a pending code. Requests are limited to one per minute per account.

### `POST /api/v1/auth/password-reset/request`

Submit `{"email":"pengguna@example.com"}`. If the email belongs to a verified account, the API sends a six-digit reset code. The response is intentionally generic so it does not reveal whether the account exists. Codes expire after 10 minutes; requests are limited to one per minute per account. SMTP must be configured as for registration OTP.

### `POST /api/v1/auth/password-reset/confirm`

Submit the email, six-digit code, and a new password (8–128 characters):

```json
{
  "email": "pengguna@example.com",
  "code": "123456",
  "new_password": "kata-sandi-baru"
}
```

The code allows at most five attempts. On success the password is stored as a scrypt hash, the reset code is removed, and all existing sessions are revoked. The user must log in again.

### `POST /api/v1/auth/login`

```json
{
  "email": "pengguna@example.com",
  "password": "contoh-kata-sandi"
}
```

Email verification and login return an `access_token`, `token_type: "bearer"`, `expires_in` (30 days), and the account's `id`, `name`, and `email`. The Android app stores the token encrypted with an Android Keystore key. The server stores only a SHA-256 hash of the session token. Unverified accounts cannot log in.

### `GET /api/v1/auth/me`

Send `Authorization: Bearer <access_token>` to retrieve the current account.

### `POST /api/v1/auth/logout`

Send the same bearer header to revoke the current session. If the device is offline, the app clears its local token, but the server-side session remains valid until it expires.

Accounts, verification codes, reset codes, and sessions are stored in `server/data/auth.sqlite3` by default. Set `MIVVI_AUTH_DB` to choose another database path. Login rate limiting is not implemented. The Android web simulator login remains a UI demo; these endpoints are used by the native Android app.

Each feature contributes its weight at most once per message. Multiple matches are shown in the explanation but do not multiply that feature's score.

## Update configuration

Edit `server/config/rules.json` and restart/reload FastAPI. Validate JSON before deploying. For public deployment, require HTTPS, add login rate limiting and email verification/recovery, and review account-data retention. The current API is intended for local development and is not hardened for public exposure.

## Android configuration

In the app, enter the API base URL only, such as `http://192.168.1.10:8000` for a debug build. The client appends its API paths. Release builds reject non-HTTPS API URLs and disable cleartext traffic. Set the production HTTPS URL with Gradle property `MIVVI_RELEASE_API_BASE_URL`; release builds also require a dedicated signing key in the ignored `keystore.properties` file. A real HTTPS backend and trusted TLS certificate must exist before distribution.
