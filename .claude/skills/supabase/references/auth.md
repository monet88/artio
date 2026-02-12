# Supabase Auth

## Client Init

```javascript
// Client-side (respects RLS)
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// Server-side admin (bypasses RLS — NEVER expose client-side)
const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { autoRefreshToken: false, persistSession: false }
})
```

## Authentication Methods

### Email/Password
```javascript
// Sign up (with optional metadata)
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com', password: 'pass123',
  options: { data: { full_name: 'John Doe' } }
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com', password: 'pass123'
})

// Sign out
await supabase.auth.signOut()
```

### OAuth
```javascript
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google', // or 'github', 'discord', etc.
  options: { redirectTo: 'https://yourapp.com/auth/callback' }
})
```

### Magic Link
```javascript
const { data, error } = await supabase.auth.signInWithOtp({
  email: 'user@example.com',
  options: { emailRedirectTo: 'https://yourapp.com/welcome' }
})
```

### Anonymous Auth
```javascript
const { data, error } = await supabase.auth.signInAnonymously()
```

## Session Management

```javascript
// Local session (fast, NOT secure for authorization)
const { data: { session } } = await supabase.auth.getSession()

// Server-validated user (secure, use for authorization)
const { data: { user } } = await supabase.auth.getUser()

// Listen for auth changes
const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
  // Events: SIGNED_IN, SIGNED_OUT, TOKEN_REFRESHED, USER_UPDATED
})
subscription.unsubscribe() // cleanup
```

## Password Recovery

```javascript
// Request reset email
await supabase.auth.resetPasswordForEmail('user@example.com', {
  redirectTo: 'https://yourapp.com/update-password'
})

// Update password (after redirect)
await supabase.auth.updateUser({ password: 'new_password' })
```

## Admin Operations (Server-Side Only)

```javascript
// Create user (bypasses email confirmation)
await admin.auth.admin.createUser({
  email: 'user@example.com', password: 'pass',
  email_confirm: true, app_metadata: { role: 'admin' }
})

// List users
const { data } = await admin.auth.admin.listUsers()

// Update user role
await admin.auth.admin.updateUserById(userId, {
  app_metadata: { role: 'moderator' }
})

// Delete user
await admin.auth.admin.deleteUser(userId)
```

## Security Rules

1. **Never expose `SERVICE_ROLE_KEY`** — bypasses RLS
2. **Use `getUser()` on server** — `getSession()` reads local storage only, not validated
3. **Use `app_metadata` for roles** — `user_metadata` is user-editable
4. **Enable RLS on all tables** — without it, anon key grants full access
5. **Normalize emails** — `trim().toLowerCase()` before auth operations
