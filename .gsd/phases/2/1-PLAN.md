---
phase: 2
plan: 1
wave: 1
depends_on: []
files_modified:
  - supabase/migrations/20260218000000_create_credit_system.sql
autonomous: true
user_setup: []

must_haves:
  truths:
    - "user_credits table exists with columns: user_id (PK, FK→auth.users), balance (int, default 0), updated_at"
    - "credit_transactions table exists with columns: id, user_id (FK), amount (int), type (enum), description, reference_id, created_at"
    - "ad_views table exists with columns: user_id (FK), view_date (date), view_count (int), unique constraint on user_id+view_date"
    - "All three tables have RLS enabled with user-owns-own-data policies"
    - "deduct_credits(uuid, int, text, text) Postgres function exists and atomically deducts + logs transaction"
    - "refund_credits(uuid, int, text, text) Postgres function exists and atomically refunds + logs transaction"
    - "New user signup inserts a user_credits row with balance=20 and a welcome_bonus transaction"
  artifacts:
    - "supabase/migrations/20260218000000_create_credit_system.sql exists and is valid SQL"
---

# Plan 2.1: Credit System Database Schema

<objective>
Create the database foundation for the credit-based economy: tables for credit balances, transaction history, and ad view tracking. Include atomic helper functions for credit operations and a welcome bonus for new users.

Purpose: All subsequent credit work (Edge Function enforcement, client credit display, ad rewards) depends on these tables existing.
Output: A single Supabase migration file containing all DDL.
</objective>

<context>
Load for context:
- .gsd/SPEC.md — Credit economy requirements (welcome bonus: 20, ad reward: 5, max 10 ads/day)
- .gsd/ARCHITECTURE.md — Existing DB schema (profiles, templates, generation_jobs)
- supabase/migrations/20260128000000_create_profiles_table.sql — handle_new_user() trigger to modify
- supabase/migrations/20260128115551_add_deleted_at_and_storage_bucket.sql — generation_jobs schema
</context>

<tasks>

<task type="auto">
  <name>Create credit tables, indexes, RLS, and helper functions</name>
  <files>supabase/migrations/20260218000000_create_credit_system.sql</files>
  <action>
    Create a single migration file with 3 sections:

    **Section 1: user_credits table**
    - user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE
    - balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0)
    - updated_at TIMESTAMPTZ DEFAULT NOW()
    - Index on user_id (implicit via PK)
    - RLS: users SELECT own row, no direct UPDATE (use functions only)
    - Add updated_at trigger (same pattern as templates)

    **Section 2: credit_transactions table**
    - id UUID PRIMARY KEY DEFAULT gen_random_uuid()
    - user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
    - amount INTEGER NOT NULL (positive = credit, negative = debit)
    - type TEXT NOT NULL CHECK (type IN ('welcome_bonus', 'ad_reward', 'generation', 'refund', 'subscription', 'manual'))
    - description TEXT
    - reference_id TEXT (nullable — links to generation_jobs.id or ad session)
    - created_at TIMESTAMPTZ DEFAULT NOW()
    - Indexes: user_id, created_at DESC, (user_id, type)
    - RLS: users SELECT own rows, no direct INSERT (use functions only)

    **Section 3: ad_views table**
    - user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
    - view_date DATE NOT NULL DEFAULT CURRENT_DATE
    - view_count INTEGER NOT NULL DEFAULT 1 CHECK (view_count >= 0 AND view_count <= 10)
    - PRIMARY KEY (user_id, view_date)
    - RLS: users SELECT own rows

    **Section 4: Helper functions (SECURITY DEFINER)**

    `deduct_credits(p_user_id UUID, p_amount INT, p_description TEXT, p_reference_id TEXT DEFAULT NULL)`
    - Returns BOOLEAN
    - In a single statement: UPDATE user_credits SET balance = balance - p_amount WHERE user_id = p_user_id AND balance >= p_amount
    - If no row updated → RETURN FALSE (insufficient credits)
    - If updated → INSERT credit_transaction with type='generation', amount=-p_amount → RETURN TRUE

    `refund_credits(p_user_id UUID, p_amount INT, p_description TEXT, p_reference_id TEXT DEFAULT NULL)`
    - Returns VOID
    - UPDATE user_credits SET balance = balance + p_amount WHERE user_id = p_user_id
    - INSERT credit_transaction with type='refund', amount=+p_amount

    AVOID: Making balance column allow negative values — the CHECK constraint prevents overdrafts.
    AVOID: Using RLS policies that allow direct INSERT/UPDATE on user_credits — all mutations go through SECURITY DEFINER functions to maintain atomicity.
    AVOID: Granting EXECUTE on helper functions to anon role — only authenticated and service_role should call them.
  </action>
  <verify>
    Apply migration via Supabase MCP `apply_migration` tool.
    Then run:
    ```sql
    SELECT table_name FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name IN ('user_credits', 'credit_transactions', 'ad_views');
    ```
    Expect 3 rows returned.

    Verify functions:
    ```sql
    SELECT routine_name FROM information_schema.routines
    WHERE routine_schema = 'public'
    AND routine_name IN ('deduct_credits', 'refund_credits');
    ```
    Expect 2 rows.

    Verify RLS:
    ```sql
    SELECT tablename, policyname FROM pg_policies
    WHERE schemaname = 'public'
    AND tablename IN ('user_credits', 'credit_transactions', 'ad_views');
    ```
    Expect policies for all 3 tables.
  </verify>
  <done>
    - 3 tables exist with correct columns and constraints
    - RLS enabled and policies applied to all 3 tables
    - deduct_credits and refund_credits functions exist
    - balance CHECK (>= 0) prevents overdrafts
  </done>
</task>

<task type="auto">
  <name>Add welcome bonus to new user signup trigger</name>
  <files>supabase/migrations/20260218000000_create_credit_system.sql</files>
  <action>
    In the SAME migration file (appended after Section 4), add Section 5:

    **Section 5: Welcome bonus trigger**

    CREATE OR REPLACE the `handle_new_user()` function to ALSO:
    1. INSERT INTO user_credits (user_id, balance) VALUES (NEW.id, 20)
    2. INSERT INTO credit_transactions (user_id, amount, type, description) VALUES (NEW.id, 20, 'welcome_bonus', 'Welcome bonus — 20 free credits')

    The function already creates a profiles row — add the credit rows AFTER the profile insert.
    Keep the existing profile insert logic unchanged.
    Function must remain SECURITY DEFINER.

    AVOID: Creating a separate trigger — reuse the existing on_auth_user_created trigger since it fires the same function.
    AVOID: Removing or changing the existing profile insert logic.
  </action>
  <verify>
    Verify the updated function body:
    ```sql
    SELECT prosrc FROM pg_proc WHERE proname = 'handle_new_user';
    ```
    Expect the function body to contain 'user_credits' and 'credit_transactions' and 'welcome_bonus'.
  </verify>
  <done>
    - handle_new_user() function updated to include credit initialization
    - New user signup creates: profile row + user_credits row (balance=20) + credit_transaction (welcome_bonus)
    - Existing profile creation logic unchanged
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] user_credits, credit_transactions, ad_views tables exist with correct schemas
- [ ] RLS policies exist for all 3 tables
- [ ] deduct_credits() and refund_credits() functions exist
- [ ] handle_new_user() includes welcome bonus logic
- [ ] balance CHECK constraint prevents negative balance
</verification>

<success_criteria>
- [ ] Migration file is valid SQL and applies without errors
- [ ] All 3 tables created with proper columns, constraints, and indexes
- [ ] RLS enabled on all tables with correct policies
- [ ] Helper functions are SECURITY DEFINER and handle atomicity
- [ ] Welcome bonus integrated into existing signup trigger
</success_criteria>
