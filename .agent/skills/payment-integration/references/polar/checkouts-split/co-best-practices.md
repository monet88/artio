# Best Practices

1. **Success URL:**
   - Must be absolute URL: `https://example.com/success`
   - Use `{CHECKOUT_ID}` placeholder to retrieve checkout details
   - Verify payment via webhook, not just success redirect

2. **External Customer ID:**
   - Set on first checkout
   - Never change once set
   - Use for all customer operations
   - Enables customer lookup without storing Polar IDs

3. **Pre-filling Data:**
   - Pre-fill customer info when available
   - Reduces friction in checkout
   - Improves conversion rates

4. **Embedded Checkout:**
   - Provide seamless experience
   - Match your site's theme
   - Handle errors gracefully
   - Show loading states

5. **Metadata:**
   - Store tracking info (source, campaign, etc.)
   - Link to your internal systems
   - Use for analytics and reporting

6. **Error Handling:**
   - Handle expired sessions
   - Provide clear error messages
   - Offer to create new session
   - Log failures for debugging

7. **Mobile Optimization:**
   - Test on mobile devices
   - Ensure responsive design
   - Consider mobile payment methods
   - Test embedded checkout on mobile
