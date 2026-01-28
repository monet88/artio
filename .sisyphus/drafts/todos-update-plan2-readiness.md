# Draft: TODOS.md Update - Plan 2 Readiness Assessment

**Created**: 2026-01-28 00:04
**Purpose**: Update TODOS.md với phân tích chi tiết về Plan 2 readiness

---

## Instructions

Copy các sections bên dưới để thay thế nội dung tương ứng trong `TODOS.md`.

---

## Section 1: Header Update

**Replace lines 3-4 with:**

```markdown
**Last Updated**: 2026-01-28 00:04
**Current**: Plan 1 Complete → Plan 2 Next (85% Ready)
```

---

## Section 2: Plan 2 Complete Replacement

**Replace entire Section "4. Plan 2" (lines 73-101) with:**

```markdown
### 4. 🔲 Plan 2: Credit, Premium & Rate Limit
**Path**: `plans/260125-1517-credit-premium-rate-limit/`
**Status**: Pending - 85% Ready
**Effort**: 6h (implementation) + 2h (prep recommended)
**Priority**: P1 - Execute NEXT
**Depends on**: Plan 1 complete ✓

**Readiness Assessment** (Updated 2026-01-28):

✅ **Ready (85%)**:
- [x] Phase 1-3 Bootstrap foundation complete (not placeholders)
- [x] 3-layer architecture in place (auth, template_engine)
- [x] Repositories ready: `generation_repository.dart`, `auth_repository.dart`
- [x] User model has credit fields: `credits`, `isPremium`, `premiumExpiresAt`
- [x] Constants extracted: `lib/core/constants/app_constants.dart`
- [x] RevenueCat SDK installed: `purchases_flutter: ^9.0.0`
- [x] Supabase Realtime enabled

⚠️ **Blockers (15%)**:
- [ ] 🔴 **Critical**: Supabase Edge Functions missing (`supabase/functions/generate-image/`)
- [ ] 🟡 **Medium**: RevenueCat not initialized (need `SubscriptionService`)
- [ ] 🟡 **Medium**: Credit deduction logic not implemented

**Execution Options**:

**Option A: Start Immediately** ⚡
- Execute plan, handle blockers during implementation
- Timeline: 6h
- Risk: May need refactoring

**Option B: Prep First (RECOMMENDED)** 🎯
- Fix blockers before execution (2h prep)
- Create Edge Function skeleton
- Setup RevenueCat service
- Verify database schema
- Timeline: 8h total (2h prep + 6h plan)
- Lower risk, cleaner implementation

**Option C: Consult Oracle** 🧠
- Get strategic guidance on monetization layer
- Timeline: 9-10h total
- Best for critical business logic validation

**Phases**:
- [ ] Phase 1: Database & Edge Function (1.5h)
  - Add `idx_generation_jobs_user_day` index
  - Edge Function enforces limits (server-side)
  - Handle 403 responses in client
- [ ] Phase 2: Credit Availability System (1.5h)
  - Calculated credits (not static balance)
  - Client-side credit UI
  - Real-time credit sync
- [ ] Phase 3: Rate Limiting & Cooldown (1h)
  - Defense-in-depth rate limiting
  - Button cooldown (prevent double-tap)
  - Daily limit: 5 for free users
- [ ] Phase 4: Premium Hybrid Sync (1.5h)
  - RevenueCat + Supabase hybrid sync
  - Premium unlock <1s perceived latency
  - Webhook configuration
- [ ] Phase 5: Input Validation (0.5h)
  - Security validation layer
  - Input length/format validation

**Success Criteria**:
- [ ] Zero credit desync errors
- [ ] Premium unlock <1s latency
- [ ] No duplicate generation requests
- [ ] Rate limit bypass blocked
- [ ] Server-side enforcement (not client-only)
```

---

## Section 3: Quick Commands Update

**Replace "Quick Commands" section (lines 141-149) with:**

```markdown
## Quick Commands

```bash
# Execute Plan 2 (Option A - Immediate)
/start-work plans/260125-1517-credit-premium-rate-limit/plan.md

# Execute Plan 2 (Option B - Prep First, RECOMMENDED)
# Step 1: Create prep plan for blockers
# Step 2: Execute credit plan after prep complete

# Execute Plan 2 (Option C - Consult Oracle)
# Consult Oracle first for architecture validation
# Then execute plan

# Resume Plan 0 (Phases 5-8)
/cook plans/260125-0120-artio-bootstrap/phase-05-gallery-feature.md
```
```

---

## Section 4: Progress Summary Update

**Replace "Progress Summary" section (lines 153-164) with:**

```markdown
## Progress Summary

| Plan | Status | Progress | Time |
|------|--------|----------|------|
| Plan 0 | Partial | 50% (Phase 1-4) | 22h / 40h |
| Plan 0.5 | ✅ Complete | 100% | 2h / 2h |
| Plan 1 | ✅ Complete | 100% | 8.5h / 10h |
| Plan 2 | 🔲 Ready 85% | 0% (blockers identified) | 0h / 8h (with prep) |
| Plan 0 (cont.) | Pending | 0% | 0h / 18h |
| Plan 3 | Deferred | 0% | 0h / 4h |

**Total Progress**: 32.5h / 82h (40%)

**Next Milestone**: Plan 2 execution (8h with prep, 6h direct)
```

---

## Summary of Changes

### What's New:
1. **Readiness percentage**: 85% ready (was: pending)
2. **Effort update**: 6h → 8h (includes 2h prep)
3. **Blockers identified**: 
   - Edge Functions missing (critical)
   - RevenueCat not initialized (medium)
   - Credit deduction logic missing (medium)
4. **Execution options**: 3 clear paths (A/B/C)
5. **Phase details expanded**: Server-side enforcement emphasis
6. **Progress tracking**: Updated total to 82h

### Why These Changes:
- Reflects actual codebase analysis (4 background agents, 4m 37s)
- Identifies concrete blockers before execution
- Provides decision framework for next steps
- Updates time estimates based on prep work needed

---

## Next Steps After Update

1. **Review updated TODOS.md**
2. **Choose execution path**:
   - Option A: Start immediately (`/start-work`)
   - Option B: Create prep plan first (recommended)
   - Option C: Consult Oracle for validation
3. **Execute chosen path**

---

**File Location**: `.sisyphus/drafts/todos-update-plan2-readiness.md`
**Action Required**: Copy sections above into `TODOS.md`
