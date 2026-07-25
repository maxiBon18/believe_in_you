# Examples

1. feat(registration): add email verification page

Implemented the email verification flow with OTP input and resend functionality.
Uses Firebase Auth email verification under the hood.

Refs: #42

2. fix(auth): handle token expiration on app resume

The token was not refreshed when the app returned from background,
causing 401 errors on subsequent API calls.