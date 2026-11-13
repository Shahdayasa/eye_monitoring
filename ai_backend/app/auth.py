"""Firebase ID token verification for the inference API."""

from __future__ import annotations

import os
from typing import Optional

try:
    import firebase_admin
    from firebase_admin import auth as fb_auth
    from firebase_admin import credentials
except Exception:  # pragma: no cover
    firebase_admin = None
    fb_auth = None
    credentials = None


class AuthConfigurationError(RuntimeError):
    pass


def _init_firebase() -> None:
    if firebase_admin is None:
        raise AuthConfigurationError("firebase-admin is not installed")
    if firebase_admin._apps:
        return

    cred_path = os.getenv("FIREBASE_CREDENTIALS") or os.getenv(
        "GOOGLE_APPLICATION_CREDENTIALS"
    )
    if cred_path:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
    else:
        # Supports default credentials / emulator in configured environments.
        firebase_admin.initialize_app()


def verify_bearer_token(authorization: Optional[str]) -> str:
    """Verify Authorization header and return Firebase uid.

    Raises ValueError on invalid/missing token so callers can map to 401.
    """
    if not authorization:
        raise ValueError("Missing Authorization header")
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != "bearer" or not parts[1].strip():
        raise ValueError("Invalid Authorization header format")
    token = parts[1].strip()

    try:
        _init_firebase()
    except Exception as e:
        raise ValueError(f"Auth not configured: {e}") from e

    try:
        decoded = fb_auth.verify_id_token(token)
        uid = decoded.get("uid")
        if not uid:
            raise ValueError("Token missing uid")
        return uid
    except Exception as e:
        raise ValueError(f"Invalid or expired token: {e}") from e


def auth_required() -> bool:
    """Auth is required by default; can be disabled explicitly for local dev."""
    flag = os.getenv("REQUIRE_AUTH", "true").strip().lower()
    return flag not in ("0", "false", "no", "off")
