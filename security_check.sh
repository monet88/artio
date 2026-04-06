#!/bin/bash
set -euo pipefail

funcs=(
  "handle_new_user"
  "deduct_credits"
  "refund_credits"
  "update_subscription_status"
)

missing_revoke=0

for fn in "${funcs[@]}"; do
  echo "Checking $fn:"
  if grep -Eq "REVOKE[[:space:]]+EXECUTE[[:space:]]+ON FUNCTION.*${fn}.*FROM PUBLIC" supabase/migrations/*.sql; then
    echo "  OK"
  else
    echo "  Missing REVOKE EXECUTE ... FROM PUBLIC for ${fn}"
    missing_revoke=1
  fi
  echo ""
done

exit "${missing_revoke}"
