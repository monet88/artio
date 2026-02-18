# Plan 2.1 Summary: Credit System Database Schema

## Status: ✅ COMPLETE

## What Was Done

### Task 1: Credit tables, indexes, RLS, and helper functions
- Created `user_credits` table (user_id PK, balance with CHECK >= 0, updated_at)
- Created `ad_views` table (user_id + view_date composite PK, view_count 0-10)
- Altered `credit_transactions` — expanded type CHECK to include `welcome_bonus`, `ad_reward`, `subscription`, `manual`; added `reference_id` column + indexes
- Created `deduct_credits()` SECURITY DEFINER function — atomic deduct + transaction log
- Created `refund_credits()` SECURITY DEFINER function — atomic refund + transaction log
- RLS enabled on all 3 tables with user-owns-own-data policies
- GRANT EXECUTE to `authenticated` role on helper functions

### Task 2: Welcome bonus trigger
- Updated `handle_new_user()` to also:
  - INSERT `user_credits` row with balance=20
  - INSERT `credit_transactions` row with type='welcome_bonus'
- Existing profile creation logic preserved

## Verification Evidence
- Tables confirmed: `ad_views`, `credit_transactions`, `user_credits` all exist
- Functions confirmed: `deduct_credits`, `refund_credits` both exist
- RLS policies confirmed: 4 policies across 3 tables
- handle_new_user() body confirmed: contains user_credits + welcome_bonus logic

## Commit
- `8a2ad6e` — feat(phase-2): create credit system database schema
