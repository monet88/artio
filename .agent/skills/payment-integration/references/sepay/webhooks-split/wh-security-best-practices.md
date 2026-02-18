# Security Best Practices

1. **IP Whitelisting:** Restrict endpoint to SePay IPs
2. **API Key Verification:** Validate authorization header
3. **HTTPS Only:** Use SSL/TLS
4. **Duplicate Detection:** Prevent double processing
5. **Logging:** Maintain webhook logs
6. **Timeout Handling:** Respond quickly (<5s)
7. **Idempotency:** Same webhook multiple times = same result
