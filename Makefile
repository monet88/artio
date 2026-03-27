# =============================================================================
# Artio — Build & Release Makefile
# =============================================================================
# Usage:
#   make build-android   → Safe production AAB (strips dev/staging env files)
#   make build-ios       → Safe production IPA
#   make check-secrets   → Scan for accidentally leaked secrets before push

.PHONY: build-android build-ios check-secrets restore-env clean

# Env files that must NOT be bundled in production builds
DEV_ENV_FILES := .env.development .env.staging

# Backup dir (temp, gitignored)
BACKUP_DIR := .env-backup

# ---------------------------------------------------------------------------
# build-android: Build release AAB safely — strips dev env files first
# ---------------------------------------------------------------------------
build-android: check-secrets _strip-dev-env
	@echo "▶ Building Android release AAB..."
	flutter build appbundle --release --dart-define=ENV=production
	@$(MAKE) _restore-env
	@echo "✅ AAB built: build/app/outputs/bundle/release/app-release.aab"

# ---------------------------------------------------------------------------
# build-ios: Build release IPA safely
# ---------------------------------------------------------------------------
build-ios: check-secrets _strip-dev-env
	@echo "▶ Building iOS release..."
	flutter build ipa --release --dart-define=ENV=production
	@$(MAKE) _restore-env
	@echo "✅ IPA built: build/ios/ipa/"

# ---------------------------------------------------------------------------
# check-secrets: Scan tracked files for accidentally committed secrets
# ---------------------------------------------------------------------------
check-secrets:
	@echo "🔍 Scanning for leaked secrets in tracked files..."
	@FOUND=0; \
	for pattern in \
		"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+" \
		"AIza[0-9A-Za-z_-]{35}" \
		"ghp_[a-zA-Z0-9]{36}" \
		"sbp_[a-zA-Z0-9]+" \
		"artio2026secure"; \
	do \
		MATCHES=$$(git ls-files | xargs grep -rlE "$$pattern" 2>/dev/null | grep -v "\.gitignore\|Makefile"); \
		if [ -n "$$MATCHES" ]; then \
			echo "❌ POTENTIAL SECRET FOUND (pattern: $$pattern):"; \
			echo "$$MATCHES"; \
			FOUND=1; \
		fi; \
	done; \
	if [ $$FOUND -eq 0 ]; then echo "✅ No leaked secrets found in tracked files."; fi; \
	exit $$FOUND

# ---------------------------------------------------------------------------
# Internal: strip dev env files before production build
# ---------------------------------------------------------------------------
_strip-dev-env:
	@echo "🔒 Temporarily removing dev/staging env files from build..."
	@mkdir -p $(BACKUP_DIR)
	@for f in $(DEV_ENV_FILES); do \
		if [ -f "$$f" ]; then \
			mv "$$f" "$(BACKUP_DIR)/$$f.bak" && echo "  ↳ Moved $$f to backup"; \
		fi; \
	done

# ---------------------------------------------------------------------------
# Internal: restore dev env files after build
# ---------------------------------------------------------------------------
_restore-env:
	@echo "↩ Restoring dev/staging env files..."
	@for f in $(DEV_ENV_FILES); do \
		if [ -f "$(BACKUP_DIR)/$$f.bak" ]; then \
			mv "$(BACKUP_DIR)/$$f.bak" "$$f" && echo "  ↳ Restored $$f"; \
		fi; \
	done
	@rm -rf $(BACKUP_DIR)

# Emergency restore (if build crashed mid-way)
restore-env: _restore-env

# Clean build artifacts
clean:
	flutter clean
	rm -rf build/
