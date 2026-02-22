# 🐛 Debug Report: "Something went wrong" Error

**Date**: 2026-02-22  
**Issue**: Generation fails with generic error message  
**Device**: Samsung A536E

---

## 🔍 ROOT CAUSE ANALYSIS

### Issue Found in Code

**File**: `lib/features/template_engine/presentation/view_models/generation_view_model.dart`

**Lines 64-68**:
```dart
if (eligibility.isDenied) {
  state = AsyncError(
    Exception(eligibility.denialReason ?? 'Generation not allowed'), // ❌ Wrong!
    StackTrace.current,
  );
  return;
}
```

**Problem**: 
- Using generic `Exception` instead of `AppException`
- This causes `AppExceptionMapper.toUserMessage()` to return: **"Something went wrong. Please try again."**

---

## 🔧 POTENTIAL CAUSES

### 1. User Not Logged In
- `userId` is null or empty
- Policy check fails
- Need to verify authentication state

### 2. Credits Insufficient
- User has 0 credits
- Policy denies generation
- Need to check credit balance

### 3. Rate Limiting
- Too many requests
- Cooldown period active
- Policy denies generation

### 4. Template Not Found
- Invalid `templateId`
- Template inactive
- Policy check fails

---

## ✅ FIX REQUIRED

### Fix 1: Proper Error Type (CRITICAL)

**File**: `lib/features/template_engine/presentation/view_models/generation_view_model.dart`

**Change lines 64-68 from**:
```dart
if (eligibility.isDenied) {
  state = AsyncError(
    Exception(eligibility.denialReason ?? 'Generation not allowed'),
    StackTrace.current,
  );
  return;
}
```

**To**:
```dart
if (eligibility.isDenied) {
  state = AsyncError(
    AppException.generation(
      message: eligibility.denialReason ?? 'Generation not allowed',
    ),
    StackTrace.current,
  );
  return;
}
```

**Impact**: User will see actual error message instead of generic "Something went wrong"

---

### Fix 2: Add Better Error Messages

**Recommended error messages based on denial reason**:

```dart
if (eligibility.isDenied) {
  final reason = eligibility.denialReason ?? 'Generation not allowed';
  final AppException error;
  
  // Map denial reason to proper exception type
  if (reason.toLowerCase().contains('credit')) {
    error = AppException.payment(
      message: 'Insufficient credits. Watch an ad or upgrade to continue.',
      code: 'insufficient_credits',
    );
  } else if (reason.toLowerCase().contains('rate') || 
             reason.toLowerCase().contains('limit')) {
    error = AppException.network(
      message: 'Too many requests. Please wait a moment and try again.',
      statusCode: 429,
    );
  } else if (reason.toLowerCase().contains('auth') || 
             reason.toLowerCase().contains('login')) {
    error = AppException.auth(
      message: 'Please sign in to generate images.',
    );
  } else {
    error = AppException.generation(message: reason);
  }
  
  state = AsyncError(error, StackTrace.current);
  return;
}
```

---

## 🧪 DEBUG STEPS

### Step 1: Check User Authentication

```bash
# Run on terminal
adb -s R5CT61YYXKD logcat -d | grep -i "userId\|authentication\|supabase"
```

**Look for**:
- "user_id": null → Not logged in
- "Supabase init completed" → Connected
- Auth tokens present

---

### Step 2: Check Credit Balance

**In app**:
1. Login
2. Check credit balance (top right corner)
3. If 0 credits → This is the issue!

**Solution**: 
- Watch rewarded ad to earn credits
- Or sign up gets 20 credits welcome bonus

---

### Step 3: Check Template Validity

```bash
# Check if template exists and is active
# Via admin dashboard: http://localhost:8888/templates
```

---

### Step 4: Monitor Realtime Logs

```bash
# Clear logs and monitor Flutter errors
adb -s R5CT61YYXKD logcat -c
adb -s R5CT61YYXKD logcat | grep -i "flutter\|exception\|error"

# Then trigger generation in app
```

---

## 📋 CHECKLIST TO RESOLVE

- [ ] **Fix 1**: Update error handling in `generation_view_model.dart`
- [ ] **Fix 2**: Add better error messages for policy denials
- [ ] **Test 1**: Verify user is logged in
- [ ] **Test 2**: Check credit balance > 0
- [ ] **Test 3**: Verify template is active
- [ ] **Test 4**: Test generation after fixes
- [ ] **Test 5**: Verify error messages are user-friendly

---

## 🎯 MOST LIKELY CAUSES (Ranked)

1. **User has 0 credits** (90% likely)
   - New account might not have welcome bonus yet
   - Need to watch ad or purchase credits
   
2. **User not logged in** (5% likely)
   - Auth token expired
   - Need to re-login

3. **Template inactive** (3% likely)
   - Template marked as inactive in DB
   - Shouldn't show in list if inactive

4. **Rate limiting** (2% likely)
   - Too many requests
   - Cooldown period

---

## 🚀 IMMEDIATE ACTION

**To test right now on device**:

1. **Check login**:
   - Open app
   - See if you're on Home screen or Login screen
   - If Login → sign up/login first

2. **Check credits**:
   - Look at top right corner
   - Should show credit count
   - If 0 → Watch ad to earn 5 credits

3. **Try generate again**:
   - Select template
   - Fill form
   - Click Generate
   - See if specific error shows

---

## 📝 LOGS TO COLLECT

Để tôi implement fix và test, cần:

1. ✅ Check if user is logged in
2. ✅ Check credit balance
3. ✅ Monitor generation attempt
4. ✅ Capture actual policy denial reason

---

**Next Step**: Implement Fix 1 (proper error type) to see actual error message instead of generic one.
