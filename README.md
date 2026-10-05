# Alo Solar Energy V17 — Installer Account Update

This version keeps all V16 features and adds:

- Persistent dealer/installer login session using local secure app preferences for the session cookie.
- Back navigation no longer logs the account out. Logout happens only from the Logout button or if the server session expires.
- Dealer entry screen detects an existing valid session and offers Continue to dashboard.
- Installer verification is connected to `/api/portal/verify` and shows the verified installer details inside the app.
- Verification accepts either the 32-character installer code or a QR verification link containing `?code=`.
- Installer self-registration is available directly from the Installer Verification screen.
- Registration uses the existing Alo backend `/api/portal/register` and remains pending until admin approval.
- Kurdish, Arabic and English labels added for the new flows.

Only Maps, WhatsApp and phone calls are intended to open outside the app.
