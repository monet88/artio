# Testing Patterns

### Unit Tests for UUID Parsing
```typescript
// __tests__/lib/sepay.test.ts
describe('parseOrderIdFromContent', () => {
  it('parses standard format', () => {
    expect(parseOrderIdFromContent('CLAUDEKIT 4e4635f4-0478-4080-a5c5-48da91f97f1e'))
      .toBe('4e4635f4-0478-4080-a5c5-48da91f97f1e');
  });

  it('handles bank dash-stripping', () => {
    expect(parseOrderIdFromContent('CLAUDEKIT 4e4635f404784080a5c548da91f97f1e'))
      .toBe('4e4635f4-0478-4080-a5c5-48da91f97f1e');
  });

  it('handles real-world Vietnamese bank memo', () => {
    expect(parseOrderIdFromContent('BankAPINotify 4e4635f404784080a5c548da91f97f1e-CHUYEN TIEN'))
      .toBe('4e4635f4-0478-4080-a5c5-48da91f97f1e');
  });

  it('returns null for invalid content', () => {
    expect(parseOrderIdFromContent('CLAUDEKIT')).toBeNull();
    expect(parseOrderIdFromContent('4e4635f4-0478')).toBeNull();
    expect(parseOrderIdFromContent('104588021672-CLAUDEKIT')).toBeNull();
  });
});
```

### Webhook Integration Test Script
```bash
#!/bin/bash
# scripts/test-sepay-webhook.sh

BASE_URL="http://localhost:3000/api/webhooks/sepay"
API_KEY="your-test-key"

# Test 1: Valid Bearer token
echo "Test 1: Bearer token auth"
curl -X POST "$BASE_URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"id":12345,"content":"CLAUDEKIT test-uuid","transferAmount":2450000,"transferType":"in"}'

# Test 2: Valid Apikey format
echo "Test 2: Apikey auth"
curl -X POST "$BASE_URL" \
  -H "Authorization: Apikey $API_KEY" \
  -d '{"id":12346,"content":"CLAUDEKIT test-uuid","transferAmount":2450000,"transferType":"in"}'

# Test 3: Missing auth (should return 401)
echo "Test 3: No auth (expect 401)"
curl -X POST "$BASE_URL" \
  -d '{"id":12347,"content":"test","transferAmount":100000,"transferType":"in"}'

# Test 4: Invalid key (should return 401)
echo "Test 4: Invalid key (expect 401)"
curl -X POST "$BASE_URL" \
  -H "Authorization: Bearer wrong-key" \
  -d '{"id":12348,"content":"test","transferAmount":100000,"transferType":"in"}'
```
