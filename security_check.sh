#!/bin/bash
# Find functions declared with SECURITY DEFINER
funcs=(
"handle_new_user"
"deduct_credits"
"refund_credits"
"update_subscription_status"
)

for fn in "${funcs[@]}"; do
    echo "Checking $fn:"
    grep -E "REVOKE.*ON FUNCTION.*$fn.*FROM PUBLIC" supabase/migrations/*.sql
    echo ""
done
