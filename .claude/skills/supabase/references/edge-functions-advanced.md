# Edge Function Advanced Patterns

## REST API Routing

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status, headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  })
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  const url = new URL(req.url)
  const path = url.pathname.replace('/functions/v1/api', '')
  const client = createClient(
    Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )

  try {
    if (path === '/users' && req.method === 'GET') {
      const { data, error } = await client.from('users').select('*')
      if (error) throw error
      return jsonResponse({ data })
    }
    if (path === '/users' && req.method === 'POST') {
      const body = await req.json()
      const { data, error } = await client.from('users').insert(body).select().single()
      if (error) throw error
      return jsonResponse({ data }, 201)
    }
    return jsonResponse({ error: 'Not found' }, 404)
  } catch (error) { return jsonResponse({ error: error.message }, 400) }
})
```

## Streaming Response (SSE)

```typescript
import OpenAI from 'npm:openai@4'
const openai = new OpenAI({ apiKey: Deno.env.get('OPENAI_API_KEY') })

Deno.serve(async (req) => {
  const { prompt } = await req.json()
  const stream = await openai.chat.completions.create({
    model: 'gpt-4', messages: [{ role: 'user', content: prompt }], stream: true
  })
  const encoder = new TextEncoder()
  const readable = new ReadableStream({
    async start(controller) {
      for await (const chunk of stream) {
        controller.enqueue(encoder.encode(chunk.choices[0]?.delta?.content || ''))
      }
      controller.close()
    }
  })
  return new Response(readable, { headers: { 'Content-Type': 'text/event-stream' } })
})
```

## Rate Limiting

```typescript
Deno.serve(async (req) => {
  const client = createClient(/* user context */)
  const admin = createClient(/* service role */)
  const { data: { user } } = await client.auth.getUser()
  if (!user) return new Response('Unauthorized', { status: 401 })

  const { count } = await admin.from('rate_limits').select('*', { count: 'exact' })
    .eq('user_id', user.id).gte('created_at', new Date(Date.now() - 60000).toISOString())

  if (count && count >= 10) return new Response(JSON.stringify({ error: 'Rate limit' }), { status: 429 })
  await admin.from('rate_limits').insert({ user_id: user.id })
  // ... process request
})
```

## Custom Error Class

```typescript
class AppError extends Error {
  constructor(message: string, public statusCode = 400, public code = 'APP_ERROR') { super(message) }
}

Deno.serve(async (req) => {
  try {
    const { action } = await req.json()
    if (!action) throw new AppError('Action required', 400, 'MISSING_ACTION')
    return jsonResponse({ success: true })
  } catch (error) {
    const status = error instanceof AppError ? error.statusCode : 500
    const code = error instanceof AppError ? error.code : 'INTERNAL_ERROR'
    console.error('Function error:', error)
    return jsonResponse({ error: error.message, code }, status)
  }
})
```

## Direct Database Connection

```typescript
import postgres from 'npm:postgres@3'

Deno.serve(async (req) => {
  const sql = postgres(Deno.env.get('SUPABASE_DB_URL')!, { prepare: false })
  try {
    const users = await sql`SELECT id, name FROM users WHERE status = 'active' LIMIT 10`
    return new Response(JSON.stringify({ data: users }))
  } finally { await sql.end() }
})
```

Key: `prepare: false` for serverless, always close connection in `finally`.

## Image Processing (Storage)

```typescript
Deno.serve(async (req) => {
  const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)
  const { path } = await req.json()
  const { data: file } = await admin.storage.from('uploads').download(path)
  const processed = await processImage(file) // your logic
  const { data } = await admin.storage.from('processed').upload(`out_${path}`, processed)
  return new Response(JSON.stringify({ path: data.path }))
})
```
