# Testing

### Manual Testing
```bash
# Use Polar dashboard to send test webhooks
# Or use webhook testing tools

curl -X POST https://your-domain.com/webhook/polar \
  -H "Content-Type: application/json" \
  -H "webhook-id: msg_test" \
  -H "webhook-timestamp: $(date +%s)" \
  -H "webhook-signature: v1,test_signature" \
  -d '{"type":"order.paid","data":{...}}'
```

### Local Testing with ngrok
```bash
# Expose local server
ngrok http 3000

# Use ngrok URL in Polar webhook settings
https://abc123.ngrok.io/webhook/polar
```
