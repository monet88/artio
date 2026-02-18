# Monitoring

### Dashboard Features
- View webhook attempts
- Check response status
- Review retry history
- Manual retry option
- Filter by event type
- Search by customer

### Application Monitoring
```typescript
const metrics = {
  webhooks_received: counter('polar_webhooks_received_total'),
  webhooks_processed: counter('polar_webhooks_processed_total'),
  webhooks_failed: counter('polar_webhooks_failed_total'),
  processing_time: histogram('polar_webhook_processing_seconds')
};

app.post('/webhook/polar', async (req, res) => {
  metrics.webhooks_received.inc({ type: req.body.type });

  const timer = metrics.processing_time.startTimer();

  try {
    await handleEvent(req.body);
    metrics.webhooks_processed.inc({ type: req.body.type });
  } catch (error) {
    metrics.webhooks_failed.inc({ type: req.body.type });
  } finally {
    timer();
  }

  res.json({ received: true });
});
```
