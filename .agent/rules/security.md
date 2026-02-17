# Security Guidelines

## Pre-Commit Security Checks

Before ANY commit:
- [ ] No hardcoded secrets (API keys, passwords, tokens)
- [ ] All user inputs validated
- [ ] Authentication/authorization verified
- [ ] Error messages don't leak sensitive data
- [ ] `.env*` files are in `.gitignore`

## Secret Management

- NEVER hardcode secrets in source code
- ALWAYS use `.env.*` files + `flutter_dotenv` for client secrets
- Use Supabase Secrets for Edge Function keys (`SUPABASE_SERVICE_ROLE_KEY`, `KIE_API_KEY`, `GEMINI_API_KEY`)
- Validate required secrets at startup (`EnvConfig`)
- Rotate any secrets that may have been exposed

## Security Response

If security issue found:
1. STOP immediately
2. Assess severity and blast radius
3. Fix CRITICAL issues before continuing
4. Rotate any exposed secrets
5. Review codebase for similar issues
