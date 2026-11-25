from __future__ import annotations

import json
import base64
import hashlib
import hmac
import html
import logging
import os
import re
import secrets
import smtplib
import sqlite3
import time
from contextlib import contextmanager
from email.message import EmailMessage
from email.headerregistry import Address
from pathlib import Path
from typing import Any, Generator

from fastapi import FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field, field_validator

APP_DIR = Path(__file__).resolve().parent
DEFAULT_CONFIG = APP_DIR.parent / "config" / "rules.json"
CONFIG_PATH = Path(os.getenv("MIVVI_RULES_FILE", str(DEFAULT_CONFIG)))
STATIC_INDEX = APP_DIR / "static" / "index.html"
AUTH_DB_PATH = Path(os.getenv("MIVVI_AUTH_DB", str(APP_DIR.parent / "data" / "auth.sqlite3")))
SESSION_TTL_SECONDS = 30 * 24 * 60 * 60
SCRYPT_N = 2**14

app = FastAPI(
    title="MIVVI SECURE API",
    version="1.0.0",
    description=(
        "API autentikasi akun dan konfigurasi aturan Rule-Based Risk Scoring. "
        "Isi pesan pengguna tidak dikirim ke layanan ini."
    ),
)
logger = logging.getLogger(__name__)

# The Android app is a native client. CORS is enabled to support optional local admin tools.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type"],
)


class RegisterRequest(BaseModel):
    name: str = Field(min_length=2, max_length=80)
    email: str = Field(min_length=3, max_length=254)
    password: str = Field(min_length=8, max_length=128)

    @field_validator("name")
    @classmethod
    def clean_name(cls, value: str) -> str:
        value = " ".join(value.strip().split())
        if len(value) < 2:
            raise ValueError("Nama minimal 2 karakter")
        return value

    @field_validator("email")
    @classmethod
    def clean_email(cls, value: str) -> str:
        value = value.strip().casefold()
        if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", value):
            raise ValueError("Format email tidak valid")
        return value


class LoginRequest(BaseModel):
    email: str = Field(min_length=3, max_length=254)
    password: str = Field(min_length=1, max_length=128)

    @field_validator("email")
    @classmethod
    def clean_email(cls, value: str) -> str:
        value = value.strip().casefold()
        if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", value):
            raise ValueError("Format email tidak valid")
        return value


class EmailRequest(BaseModel):
    email: str = Field(min_length=3, max_length=254)

    @field_validator("email")
    @classmethod
    def clean_email(cls, value: str) -> str:
        value = value.strip().casefold()
        if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", value):
            raise ValueError("Format email tidak valid")
        return value


class VerifyEmailRequest(EmailRequest):
    code: str = Field(pattern=r"^\d{6}$")


class ResetPasswordRequest(EmailRequest):
    code: str = Field(pattern=r"^\d{6}$")
    new_password: str = Field(min_length=8, max_length=128)


@contextmanager
def auth_db() -> Generator[sqlite3.Connection, None, None]:
    AUTH_DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    connection = sqlite3.connect(AUTH_DB_PATH, timeout=10)
    connection.row_factory = sqlite3.Row
    connection.execute("PRAGMA foreign_keys = ON")
    connection.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE COLLATE NOCASE,
            password_hash TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            email_verified INTEGER NOT NULL DEFAULT 0
        )
    """)
    user_columns = {row["name"] for row in connection.execute("PRAGMA table_info(users)").fetchall()}
    if "email_verified" not in user_columns:
        # Existing accounts were created before OTP existed; keep them usable.
        connection.execute("ALTER TABLE users ADD COLUMN email_verified INTEGER NOT NULL DEFAULT 1")
    connection.execute("""
        CREATE TABLE IF NOT EXISTS auth_sessions (
            token_hash TEXT PRIMARY KEY,
            user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
            expires_at INTEGER NOT NULL
        )
    """)
    connection.execute("""
        CREATE TABLE IF NOT EXISTS email_verification_codes (
            user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
            code_salt TEXT NOT NULL,
            code_hash TEXT NOT NULL,
            expires_at INTEGER NOT NULL,
            last_sent_at INTEGER NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0
        )
    """)
    connection.execute("""
        CREATE TABLE IF NOT EXISTS password_reset_codes (
            user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
            code_salt TEXT NOT NULL,
            code_hash TEXT NOT NULL,
            expires_at INTEGER NOT NULL,
            last_sent_at INTEGER NOT NULL,
            attempts INTEGER NOT NULL DEFAULT 0
        )
    """)
    try:
        yield connection
        connection.commit()
    finally:
        connection.close()


def hash_password(password: str) -> str:
    salt = secrets.token_bytes(16)
    digest = hashlib.scrypt(password.encode("utf-8"), salt=salt, n=SCRYPT_N, r=8, p=1, dklen=32)
    return "scrypt${}${}${}".format(
        SCRYPT_N,
        base64.urlsafe_b64encode(salt).decode("ascii"),
        base64.urlsafe_b64encode(digest).decode("ascii"),
    )


def verify_password(password: str, stored: str) -> bool:
    try:
        algorithm, n_value, salt_text, digest_text = stored.split("$")
        if algorithm != "scrypt":
            return False
        salt = base64.urlsafe_b64decode(salt_text.encode("ascii"))
        expected = base64.urlsafe_b64decode(digest_text.encode("ascii"))
        actual = hashlib.scrypt(password.encode("utf-8"), salt=salt, n=int(n_value), r=8, p=1, dklen=len(expected))
        return hmac.compare_digest(actual, expected)
    except (ValueError, TypeError):
        return False


def user_payload(user: sqlite3.Row) -> dict[str, Any]:
    return {"id": user["id"], "name": user["name"], "email": user["email"]}


def issue_session(connection: sqlite3.Connection, user: sqlite3.Row) -> dict[str, Any]:
    token = secrets.token_urlsafe(32)
    expires_at = int(time.time()) + SESSION_TTL_SECONDS
    connection.execute("DELETE FROM auth_sessions WHERE expires_at <= ?", (int(time.time()),))
    connection.execute(
        "INSERT INTO auth_sessions(token_hash, user_id, expires_at) VALUES (?, ?, ?)",
        (hashlib.sha256(token.encode("ascii")).hexdigest(), user["id"], expires_at),
    )
    return {
        "access_token": token,
        "token_type": "bearer",
        "expires_in": SESSION_TTL_SECONDS,
        "user": user_payload(user),
    }


OTP_TTL_SECONDS = 10 * 60
OTP_RESEND_DELAY_SECONDS = 60
OTP_MAX_ATTEMPTS = 5


def smtp_settings() -> tuple[str, int, str, str, str]:
    host = os.getenv("MIVVI_SMTP_HOST", "").strip()
    username = os.getenv("MIVVI_SMTP_USER", "").strip()
    password = os.getenv("MIVVI_SMTP_PASSWORD", "")
    if host.casefold() in {"smtp.gmail.com", "smtp.googlemail.com"}:
        # Google displays App Passwords in groups; whitespace is not part of the credential.
        password = "".join(password.split())
    sender = os.getenv("MIVVI_SMTP_FROM", username).strip()
    try:
        port = int(os.getenv("MIVVI_SMTP_PORT", "587"))
    except ValueError as exc:
        raise HTTPException(status_code=503, detail="MIVVI_SMTP_PORT harus berupa angka") from exc
    if not host or not username or not password or not sender:
        raise HTTPException(
            status_code=503,
            detail="Email OTP belum dikonfigurasi. Atur MIVVI_SMTP_HOST, MIVVI_SMTP_USER, dan MIVVI_SMTP_PASSWORD di server.",
        )
    return host, port, username, password, sender


def authenticate_smtp(server: smtplib.SMTP, host: str, username: str, password: str) -> None:
    if host.casefold() in {"smtp.gmail.com", "smtp.googlemail.com"}:
        # Gmail advertises LOGIN and closes the session during smtplib.login()'s PLAIN attempt
        # in some environments. Use the advertised LOGIN challenge-response explicitly.
        auth_methods = server.esmtp_features.get("auth", "").upper().split()
        if "LOGIN" not in auth_methods:
            raise smtplib.SMTPNotSupportedError("Gmail SMTP LOGIN is not available")
        server.user = username
        server.password = password
        server.auth("LOGIN", server.auth_login, initial_response_ok=False)
        return
    server.login(username, password)


def otp_email_html(
    heading: str,
    introduction: str,
    code: str,
    security_note: str,
) -> str:
    safe_heading = html.escape(heading)
    safe_introduction = html.escape(introduction)
    safe_code = html.escape(code)
    safe_security_note = html.escape(security_note)
    return f"""<!doctype html>
<html lang="id">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="light">
    <title>{safe_heading}</title>
  </head>
  <body style="margin:0;padding:0;background:#eef2f8;font-family:Arial,Helvetica,sans-serif;color:#172033;">
    <div style="display:none;max-height:0;overflow:hidden;opacity:0;">Kode OTP MIVVI SECURE berlaku 10 menit.</div>
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background:#eef2f8;padding:32px 12px;">
      <tr><td align="center">
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="max-width:560px;background:#ffffff;border-radius:18px;overflow:hidden;">
          <tr><td style="height:6px;background:#4bd4df;font-size:0;line-height:0;">&nbsp;</td></tr>
          <tr><td style="padding:28px 32px 10px;">
            <table role="presentation" cellspacing="0" cellpadding="0" border="0"><tr>
              <td style="width:34px;height:34px;border-radius:10px;background:#0d1730;color:#63dde8;text-align:center;vertical-align:middle;font-size:17px;font-weight:bold;">M</td>
              <td style="padding-left:10px;color:#13203a;font-size:14px;font-weight:700;letter-spacing:1.2px;">MIVVI SECURE</td>
            </tr></table>
          </td></tr>
          <tr><td style="padding:20px 32px 0;">
            <p style="margin:0 0 10px;color:#078996;font-size:11px;font-weight:700;letter-spacing:1.5px;">KODE KEAMANAN</p>
            <h1 style="margin:0;color:#111a2c;font-size:25px;line-height:1.3;">{safe_heading}</h1>
            <p style="margin:14px 0 0;color:#536078;font-size:15px;line-height:1.65;">{safe_introduction}</p>
          </td></tr>
          <tr><td style="padding:24px 32px 0;">
            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background:#f1fbfc;border:1px solid #b9edf0;border-radius:14px;">
              <tr><td align="center" style="padding:20px 12px 8px;color:#607184;font-size:11px;font-weight:700;letter-spacing:1.2px;">KODE OTP ANDA</td></tr>
              <tr><td align="center" style="padding:0 12px 20px;color:#10213b;font-family:Arial,Helvetica,sans-serif;font-size:34px;font-weight:700;letter-spacing:9px;">{safe_code}</td></tr>
            </table>
          </td></tr>
          <tr><td style="padding:18px 32px 0;color:#536078;font-size:13px;line-height:1.6;">
            Kode ini berlaku selama <strong style="color:#18243a;">10 menit</strong>. Masukkan kode langsung di aplikasi MIVVI SECURE.
          </td></tr>
          <tr><td style="padding:18px 32px 26px;">
            <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="background:#f7f8fb;border-radius:10px;">
              <tr><td style="padding:13px 15px;color:#657187;font-size:12px;line-height:1.55;">{safe_security_note}</td></tr>
            </table>
          </td></tr>
          <tr><td style="padding:18px 32px;background:#101a31;color:#aeb9cc;font-size:11px;line-height:1.6;">
            Email otomatis dari MIVVI SECURE. Jangan membagikan kode OTP kepada siapa pun.
          </td></tr>
        </table>
        <p style="margin:16px 0 0;color:#8792a5;font-size:11px;">© MIVVI SECURE · Keamanan pesan, tetap di perangkatmu.</p>
      </td></tr>
    </table>
  </body>
</html>"""


def send_account_email(email: str, subject: str, body: str, html_body: str | None = None) -> None:
    host, port, username, password, sender = smtp_settings()
    message = EmailMessage()
    message["Subject"] = subject
    message["From"] = Address(display_name="MIVVI SECURE", addr_spec=sender)
    message["To"] = email
    message.set_content(body)
    if html_body:
        message.add_alternative(html_body, subtype="html")
    try:
        if port == 465:
            with smtplib.SMTP_SSL(host, port, timeout=15) as server:
                server.ehlo()
                authenticate_smtp(server, host, username, password)
                server.send_message(message)
        else:
            with smtplib.SMTP(host, port, timeout=15) as server:
                server.ehlo()
                server.starttls()
                server.ehlo()
                authenticate_smtp(server, host, username, password)
                server.send_message(message)
    except smtplib.SMTPAuthenticationError as exc:
        raise HTTPException(
            status_code=503,
            detail="SMTP menolak login. Periksa alamat akun dan App Password; gunakan App Password tanpa spasi untuk Gmail.",
        ) from exc
    except smtplib.SMTPServerDisconnected as exc:
        raise HTTPException(
            status_code=503,
            detail="SMTP memutus koneksi saat login atau mengirim email. Periksa App Password dan kebijakan akses SMTP akun.",
        ) from exc
    except (OSError, smtplib.SMTPException) as exc:
        raise HTTPException(status_code=503, detail="Email OTP gagal dikirim. Periksa konfigurasi dan koneksi SMTP server.") from exc


def send_verification_email(email: str, code: str) -> None:
    body = (
        f"Kode verifikasi akun MIVVI SECURE Anda: {code}\n\n"
        "Kode berlaku selama 10 menit. Jika Anda tidak meminta kode ini, abaikan email ini."
    )
    send_account_email(
        email,
        "Kode verifikasi MIVVI SECURE",
        body,
        otp_email_html(
            "Verifikasi emailmu",
            "Gunakan kode sekali pakai ini untuk menyelesaikan pembuatan akun MIVVI SECURE.",
            code,
            "Jika kamu tidak membuat akun ini, abaikan email ini. Tidak ada tindakan lain yang diperlukan.",
        ),
    )


def store_and_send_verification(connection: sqlite3.Connection, user: sqlite3.Row) -> None:
    code = f"{secrets.randbelow(1_000_000):06d}"
    salt = secrets.token_bytes(16)
    code_hash = hashlib.pbkdf2_hmac("sha256", code.encode("ascii"), salt, 200_000).hex()
    now = int(time.time())
    connection.execute(
        "INSERT INTO email_verification_codes(user_id, code_salt, code_hash, expires_at, last_sent_at, attempts) "
        "VALUES (?, ?, ?, ?, ?, 0) ON CONFLICT(user_id) DO UPDATE SET "
        "code_salt=excluded.code_salt, code_hash=excluded.code_hash, expires_at=excluded.expires_at, "
        "last_sent_at=excluded.last_sent_at, attempts=0",
        (user["id"], salt.hex(), code_hash, now + OTP_TTL_SECONDS, now),
    )
    send_verification_email(user["email"], code)


PASSWORD_RESET_TTL_SECONDS = 10 * 60
PASSWORD_RESET_RESEND_DELAY_SECONDS = 60
PASSWORD_RESET_MAX_ATTEMPTS = 5
PASSWORD_RESET_GENERIC_RESPONSE = {
    "status": "accepted",
    "message": "Jika email terdaftar dan terverifikasi, kode reset akan dikirim.",
    "expires_in": PASSWORD_RESET_TTL_SECONDS,
}


def store_and_send_password_reset(connection: sqlite3.Connection, user: sqlite3.Row) -> None:
    code = f"{secrets.randbelow(1_000_000):06d}"
    salt = secrets.token_bytes(16)
    code_hash = hashlib.pbkdf2_hmac("sha256", code.encode("ascii"), salt, 200_000).hex()
    now = int(time.time())
    connection.execute(
        "INSERT INTO password_reset_codes(user_id, code_salt, code_hash, expires_at, last_sent_at, attempts) "
        "VALUES (?, ?, ?, ?, ?, 0) ON CONFLICT(user_id) DO UPDATE SET "
        "code_salt=excluded.code_salt, code_hash=excluded.code_hash, expires_at=excluded.expires_at, "
        "last_sent_at=excluded.last_sent_at, attempts=0",
        (user["id"], salt.hex(), code_hash, now + PASSWORD_RESET_TTL_SECONDS, now),
    )
    send_account_email(
        user["email"],
        "Kode reset kata sandi MIVVI SECURE",
        f"Kode reset kata sandi MIVVI SECURE Anda: {code}\n\n"
        "Kode berlaku selama 10 menit. Jika Anda tidak meminta reset, abaikan email ini.",
        otp_email_html(
            "Atur ulang kata sandi",
            "Masukkan kode berikut di aplikasi untuk membuat kata sandi baru.",
            code,
            "Jika kamu tidak meminta reset kata sandi, abaikan email ini. Kata sandimu tidak akan berubah.",
        ),
    )


def require_user(authorization: str | None) -> tuple[str, sqlite3.Row]:
    scheme, _, token = (authorization or "").partition(" ")
    if scheme.casefold() != "bearer" or not token:
        raise HTTPException(status_code=401, detail="Sesi tidak valid atau sudah berakhir")
    token_hash = hashlib.sha256(token.encode("ascii", errors="ignore")).hexdigest()
    with auth_db() as connection:
        row = connection.execute(
            "SELECT s.token_hash, u.* FROM auth_sessions s JOIN users u ON u.id=s.user_id "
            "WHERE s.token_hash=? AND s.expires_at>?",
            (token_hash, int(time.time())),
        ).fetchone()
    if row is None:
        raise HTTPException(status_code=401, detail="Sesi tidak valid atau sudah berakhir")
    return token_hash, row


def load_config() -> dict[str, Any]:
    try:
        with CONFIG_PATH.open("r", encoding="utf-8") as file:
            data = json.load(file)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=500, detail="Rules configuration file was not found") from exc
    except json.JSONDecodeError as exc:
        raise HTTPException(status_code=500, detail="Rules configuration contains invalid JSON") from exc

    required = {"version", "weights", "thresholds", "keywords", "urgency_patterns", "sensitive_patterns", "official_domains", "shortlink_domains"}
    missing = required.difference(data)
    if missing:
        raise HTTPException(status_code=500, detail=f"Rules configuration missing keys: {sorted(missing)}")
    return data


@app.get("/", response_class=FileResponse, tags=["web"])
def root() -> FileResponse:
    """Serve the interactive web prototype simulator for MIVVI SECURE."""
    if not STATIC_INDEX.exists():
        raise HTTPException(status_code=404, detail="Simulator web page was not found")
    return FileResponse(STATIC_INDEX)


@app.get("/api/v1/health", tags=["system"])
def health() -> dict[str, str]:
    return {"status": "ok", "service": "mivvi-secure-rules-api", "version": "1.0.0"}


@app.get("/api/v1/rules", tags=["rules"])
def get_rules() -> dict[str, Any]:
    """Return the active scoring rules so Android can cache them locally."""
    return load_config()


@app.post("/api/v1/auth/register", tags=["auth"])
def register_account(request: RegisterRequest) -> dict[str, Any]:
    """Create an unverified account and send an email verification code."""
    with auth_db() as connection:
        try:
            connection.execute(
                "INSERT INTO users(name, email, password_hash, created_at, email_verified) VALUES (?, ?, ?, ?, 0)",
                (request.name, request.email, hash_password(request.password), int(time.time())),
            )
        except sqlite3.IntegrityError as exc:
            raise HTTPException(status_code=409, detail="Email sudah terdaftar") from exc
        user = connection.execute("SELECT * FROM users WHERE email=?", (request.email,)).fetchone()
        store_and_send_verification(connection, user)
        return {"status": "verification_required", "email": user["email"], "expires_in": OTP_TTL_SECONDS}


@app.post("/api/v1/auth/verify-email", tags=["auth"])
def verify_email(request: VerifyEmailRequest) -> dict[str, Any]:
    """Verify the email code and create the first signed-in session."""
    now = int(time.time())
    with auth_db() as connection:
        user = connection.execute("SELECT * FROM users WHERE email=?", (request.email,)).fetchone()
        if user is None:
            raise HTTPException(status_code=400, detail="Kode verifikasi tidak valid atau kedaluwarsa")
        if user["email_verified"]:
            raise HTTPException(status_code=409, detail="Email sudah diverifikasi. Silakan masuk.")
        verification = connection.execute(
            "SELECT * FROM email_verification_codes WHERE user_id=?", (user["id"],)
        ).fetchone()
        if verification is None or verification["expires_at"] <= now:
            if verification is not None:
                connection.execute("DELETE FROM email_verification_codes WHERE user_id=?", (user["id"],))
                connection.commit()
            raise HTTPException(status_code=400, detail="Kode verifikasi tidak valid atau kedaluwarsa")
        if verification["attempts"] >= OTP_MAX_ATTEMPTS:
            connection.execute("DELETE FROM email_verification_codes WHERE user_id=?", (user["id"],))
            connection.commit()
            raise HTTPException(status_code=429, detail="Batas percobaan kode tercapai. Minta kode baru.")

        salt = bytes.fromhex(verification["code_salt"])
        supplied_hash = hashlib.pbkdf2_hmac("sha256", request.code.encode("ascii"), salt, 200_000).hex()
        if not hmac.compare_digest(supplied_hash, verification["code_hash"]):
            attempts = verification["attempts"] + 1
            if attempts >= OTP_MAX_ATTEMPTS:
                connection.execute("DELETE FROM email_verification_codes WHERE user_id=?", (user["id"],))
                connection.commit()
                raise HTTPException(status_code=429, detail="Batas percobaan kode tercapai. Minta kode baru.")
            connection.execute(
                "UPDATE email_verification_codes SET attempts=? WHERE user_id=?", (attempts, user["id"])
            )
            connection.commit()
            raise HTTPException(status_code=400, detail="Kode verifikasi salah")

        connection.execute("UPDATE users SET email_verified=1 WHERE id=?", (user["id"],))
        connection.execute("DELETE FROM email_verification_codes WHERE user_id=?", (user["id"],))
        verified_user = connection.execute("SELECT * FROM users WHERE id=?", (user["id"],)).fetchone()
        return issue_session(connection, verified_user)


@app.post("/api/v1/auth/resend-verification", tags=["auth"])
def resend_verification(request: EmailRequest) -> dict[str, Any]:
    """Resend a pending email code no more than once per minute."""
    now = int(time.time())
    with auth_db() as connection:
        user = connection.execute("SELECT * FROM users WHERE email=?", (request.email,)).fetchone()
        if user is None or user["email_verified"]:
            raise HTTPException(status_code=404, detail="Akun menunggu verifikasi tidak ditemukan")
        previous = connection.execute(
            "SELECT last_sent_at FROM email_verification_codes WHERE user_id=?", (user["id"],)
        ).fetchone()
        if previous is not None and now - previous["last_sent_at"] < OTP_RESEND_DELAY_SECONDS:
            raise HTTPException(status_code=429, detail="Tunggu sebentar sebelum meminta kode baru")
        store_and_send_verification(connection, user)
        return {"status": "sent", "expires_in": OTP_TTL_SECONDS}


@app.post("/api/v1/auth/password-reset/request", tags=["auth"])
def request_password_reset(request: EmailRequest) -> dict[str, Any]:
    """Send a short-lived reset code without revealing whether the account exists."""
    now = int(time.time())
    with auth_db() as connection:
        user = connection.execute(
            "SELECT * FROM users WHERE email=? AND email_verified=1", (request.email,)
        ).fetchone()
        if user is None:
            return PASSWORD_RESET_GENERIC_RESPONSE

        previous = connection.execute(
            "SELECT last_sent_at FROM password_reset_codes WHERE user_id=?", (user["id"],)
        ).fetchone()
        if previous is not None and now - previous["last_sent_at"] < PASSWORD_RESET_RESEND_DELAY_SECONDS:
            return PASSWORD_RESET_GENERIC_RESPONSE

        try:
            store_and_send_password_reset(connection, user)
        except HTTPException as exc:
            # Keep the endpoint response indistinguishable for known and unknown addresses.
            connection.execute("DELETE FROM password_reset_codes WHERE user_id=?", (user["id"],))
            logger.warning("Password reset email could not be sent (HTTP %s)", exc.status_code)
        return PASSWORD_RESET_GENERIC_RESPONSE


@app.post("/api/v1/auth/password-reset/confirm", tags=["auth"])
def confirm_password_reset(request: ResetPasswordRequest) -> dict[str, str]:
    """Change the password using a valid reset code and revoke existing sessions."""
    now = int(time.time())
    with auth_db() as connection:
        user = connection.execute(
            "SELECT * FROM users WHERE email=? AND email_verified=1", (request.email,)
        ).fetchone()
        if user is None:
            raise HTTPException(status_code=400, detail="Kode reset tidak valid atau kedaluwarsa")

        reset = connection.execute(
            "SELECT * FROM password_reset_codes WHERE user_id=?", (user["id"],)
        ).fetchone()
        if reset is None or reset["expires_at"] <= now:
            if reset is not None:
                connection.execute("DELETE FROM password_reset_codes WHERE user_id=?", (user["id"],))
                connection.commit()
            raise HTTPException(status_code=400, detail="Kode reset tidak valid atau kedaluwarsa")
        if reset["attempts"] >= PASSWORD_RESET_MAX_ATTEMPTS:
            connection.execute("DELETE FROM password_reset_codes WHERE user_id=?", (user["id"],))
            connection.commit()
            raise HTTPException(status_code=429, detail="Batas percobaan kode tercapai. Minta kode reset baru.")

        salt = bytes.fromhex(reset["code_salt"])
        supplied_hash = hashlib.pbkdf2_hmac("sha256", request.code.encode("ascii"), salt, 200_000).hex()
        if not hmac.compare_digest(supplied_hash, reset["code_hash"]):
            attempts = reset["attempts"] + 1
            if attempts >= PASSWORD_RESET_MAX_ATTEMPTS:
                connection.execute("DELETE FROM password_reset_codes WHERE user_id=?", (user["id"],))
                connection.commit()
                raise HTTPException(status_code=429, detail="Batas percobaan kode tercapai. Minta kode reset baru.")
            connection.execute(
                "UPDATE password_reset_codes SET attempts=? WHERE user_id=?", (attempts, user["id"])
            )
            connection.commit()
            raise HTTPException(status_code=400, detail="Kode reset salah")

        connection.execute(
            "UPDATE users SET password_hash=? WHERE id=?",
            (hash_password(request.new_password), user["id"]),
        )
        connection.execute("DELETE FROM password_reset_codes WHERE user_id=?", (user["id"],))
        connection.execute("DELETE FROM auth_sessions WHERE user_id=?", (user["id"],))
        return {"status": "password_reset", "message": "Kata sandi berhasil diubah. Silakan masuk kembali."}


@app.post("/api/v1/auth/login", tags=["auth"])
def login(request: LoginRequest) -> dict[str, Any]:
    """Verify an account password and create a revocable bearer session."""
    with auth_db() as connection:
        user = connection.execute("SELECT * FROM users WHERE email=?", (request.email,)).fetchone()
        if user is None or not verify_password(request.password, user["password_hash"]):
            raise HTTPException(status_code=401, detail="Email atau kata sandi salah")
        if not user["email_verified"]:
            raise HTTPException(status_code=403, detail="Verifikasi email sebelum masuk")
        return issue_session(connection, user)


@app.get("/api/v1/auth/me", tags=["auth"])
def current_account(authorization: str | None = Header(default=None)) -> dict[str, Any]:
    """Return the account associated with a valid bearer session."""
    _, user = require_user(authorization)
    return {"user": user_payload(user)}


@app.post("/api/v1/auth/logout", tags=["auth"])
def logout(authorization: str | None = Header(default=None)) -> dict[str, str]:
    """Revoke the current bearer session."""
    token_hash, _ = require_user(authorization)
    with auth_db() as connection:
        connection.execute("DELETE FROM auth_sessions WHERE token_hash=?", (token_hash,))
    return {"status": "signed_out"}
