# OAuth2 Webhook Management API

**Available Scopes:** `webhook:read`, `webhook:write`, `webhook:delete`

**List Webhooks:**
```
GET /api/v1/webhooks
```

**Get Details:**
```
GET /api/v1/webhooks/{id}
```

**Create:**
```
POST /api/v1/webhooks
{
  "bank_account_id": 123,
  "name": "My Webhook",
  "event_type": "All",
  "authen_type": "Api_Key",
  "webhook_url": "https://example.com/webhook",
  "is_verify_payment": true
}
```

**Update:**
```
PATCH /api/v1/webhooks/{id}
```

**Delete:**
```
DELETE /api/v1/webhooks/{id}
```
