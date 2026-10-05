ALO SOLAR V18.9 — Admin bearer-session fix

- Admin login now receives an explicit sessionToken from the mobile admin backend.
- The app stores that token and sends it as Authorization: Bearer on all admin requests.
- Admin /me, installer applications, approve/reject/disable/unban, and logout all use the same mobile-admin backend and same token.
- Back navigation does not log the admin out.
- A 401 clears the invalid saved session and returns to login on the next auth check.
- No unrelated app features were intentionally changed.

Test:
flutter pub get
flutter analyze
flutter run
