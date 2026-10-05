ALO SOLAR V18.10 — ADMIN REDIRECT FIX

- Admin POST/GET requests now follow 301/302/303/307/308 manually.
- POST method and JSON body are preserved across redirects.
- Authorization Bearer token is preserved on redirected Admin requests.
- No unrelated UI/features were changed.

Test:
flutter pub get
flutter analyze
flutter run
