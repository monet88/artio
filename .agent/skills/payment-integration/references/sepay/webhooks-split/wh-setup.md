# Setup

1. Access WebHooks menu in dashboard
2. Click "+ Add webhooks"
3. Configure:
   - **Name:** Descriptive identifier
   - **Event Selection:** `All`, `In_only`, `Out_only`
   - **Conditions:** Bank accounts, VA filtering, payment code requirements
   - **Webhook URL:** Your callback endpoint (must be publicly accessible)
   - **Is Verify Payment:** Flag for validation
   - **Authentication:** `No_Authen`, `OAuth2.0`, or `Api_Key`
4. Click "Add" to finalize
