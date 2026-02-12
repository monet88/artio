# Auth MFA & Sessions

## MFA (Multi-Factor Authentication)

### Assurance Levels
- **AAL1**: Basic auth (email/password, OAuth)
- **AAL2**: MFA verified (TOTP or phone code)

### TOTP Enrollment

```javascript
// 1. Enroll factor
const { data, error } = await supabase.auth.mfa.enroll({
  factorType: 'totp', friendlyName: 'My Authenticator'
})
// data.totp.qr_code — display to user to scan
// data.totp.secret — for manual entry
// data.id — factor ID for verification

// 2. Verify enrollment
const { data: challenge } = await supabase.auth.mfa.challenge({ factorId: data.id })
const { error: verifyError } = await supabase.auth.mfa.verify({
  factorId: data.id, challengeId: challenge.id, code: '123456'
})
```

### Sign-In with MFA

```javascript
const { data: signIn } = await supabase.auth.signInWithPassword({ email, password })
const { data: factors } = await supabase.auth.mfa.listFactors()

if (factors.totp.length > 0) {
  const { data: challenge } = await supabase.auth.mfa.challenge({ factorId: factors.totp[0].id })
  // Prompt user for code
  const { data: verify, error } = await supabase.auth.mfa.verify({
    factorId: factors.totp[0].id, challengeId: challenge.id, code: userCode
  })
  // Session promoted to AAL2
}
```

### Shortcut: challengeAndVerify

```javascript
const { data, error } = await supabase.auth.mfa.challengeAndVerify({
  factorId: 'factor-id', code: '123456'
})
```

### Admin: Delete factor (lost device recovery)

```javascript
await supabaseAdmin.auth.admin.mfa.deleteFactor({ id: 'factor-id', userId: 'user-id' })
```

### RLS: Require MFA

```sql
CREATE POLICY "MFA required" ON sensitive_data FOR UPDATE TO authenticated
USING ((auth.jwt()->>'aal') = 'aal2');
```

## Session Details

### Structure
- **Access Token (JWT)**: short-lived (default 1h), contains user claims
- **Refresh Token**: single-use, auto-rotates, 10s reuse window

### Auth Events

| Event | When |
|-------|------|
| `INITIAL_SESSION` | Initial load |
| `SIGNED_IN` | User signed in |
| `SIGNED_OUT` | User signed out |
| `TOKEN_REFRESHED` | Access token refreshed |
| `USER_UPDATED` | Metadata updated |
| `PASSWORD_RECOVERY` | Reset initiated |

### JWT Claims

```javascript
const { data: { session } } = await supabase.auth.getSession()
const payload = JSON.parse(atob(session.access_token.split('.')[1]))
// payload.sub — user ID
// payload.email — email
// payload.role — authenticated/anon
// payload.aal — aal1/aal2
// payload.exp — expiration timestamp
```

## Identity Linking

```javascript
// Link additional OAuth provider
const { data } = await supabase.auth.linkIdentity({ provider: 'google' })

// Unlink identity
await supabase.auth.unlinkIdentity({ identity_id: 'identity-uuid' })

// List identities
const { data: { identities } } = await supabase.auth.getUserIdentities()
```

## Anonymous → Permanent Conversion

```javascript
await supabase.auth.signInAnonymously()
// Later: convert to permanent
await supabase.auth.updateUser({ email: 'user@example.com' })
// After email verification:
await supabase.auth.updateUser({ password: 'password123' })
// Or link OAuth:
await supabase.auth.linkIdentity({ provider: 'google' })
```

## Sign Out Scopes

```javascript
await supabase.auth.signOut()                    // all sessions (default)
await supabase.auth.signOut({ scope: 'local' })  // current only
await supabase.auth.signOut({ scope: 'others' }) // all except current
```

## Session Termination Triggers

1. Explicit sign out
2. Password change
3. Inactivity timeout (Pro)
4. Max lifetime expiration (Pro)
5. Single-session enforcement (Pro)
