# Important Constraints

1. **Cannot change after creation:**
   - Billing cycle (one-time, monthly, yearly)
   - Pricing type (fixed, pay-what-you-want, free)

2. **Price changes don't affect existing subscribers:**
   - Current subscribers keep their original price
   - New subscribers get new price
   - Use separate products for significant changes

3. **Products cannot be deleted:**
   - Archive instead
   - Maintains order history integrity
   - Archived products not shown to new customers

4. **Metadata vs Custom Fields:**
   - Metadata: For internal use, not shown to customers
   - Custom Fields: Collected from customers at checkout
