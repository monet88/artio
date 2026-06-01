```markdown
# artio Development Patterns

> Auto-generated skill from repository analysis

## Overview

This skill covers the core development patterns and workflows for the `artio` TypeScript codebase. It documents the project's coding conventions, file organization, and key maintenance workflows—especially around documentation and knowledge graph artifact management. Whether you're contributing code, updating documentation, or maintaining analysis outputs, this guide provides step-by-step instructions and code examples to ensure consistency and quality.

## Coding Conventions

### File Naming

- **Style:** kebab-case
- **Example:**  
  ```
  user-profile.ts
  data-loader.test.ts
  ```

### Import Style

- **Style:** Relative imports
- **Example:**
  ```typescript
  import { fetchData } from './data-loader';
  import { UserProfile } from '../models/user-profile';
  ```

### Export Style

- **Style:** Named exports
- **Example:**
  ```typescript
  // user-profile.ts
  export interface UserProfile {
    id: string;
    name: string;
  }

  export function getUserProfile(id: string): UserProfile { ... }
  ```

### Commit Patterns

- **Type:** Conventional commits
- **Prefixes used:** `docs`, `chore`
- **Example:**
  ```
  docs: update architecture diagram in README
  chore: remove obsolete scripts from scripts/
  ```

## Workflows

### Project Documentation Restructure

**Trigger:** When you want to set up, restructure, or significantly update project documentation and supporting scripts.  
**Command:** `/restructure-docs`

1. Create or update markdown documentation files under `docs/` (e.g., `ARCHITECTURE.md`, `README.md`, decision logs, templates).
2. Add or update scripts in `scripts/` to support documentation validation or search.
3. Remove obsolete documentation or script files.
4. Update `.gitignore` if new documentation/script artifacts are generated.

**Example:**
```bash
# Add a new architecture doc
echo "# Architecture" > docs/ARCHITECTURE.md

# Remove an obsolete script
rm scripts/old-docs-helper.sh

# Update .gitignore
echo "docs/generated/" >> .gitignore
```

**Files Involved:**
- `docs/ARCHITECTURE.md`
- `docs/README.md`
- `docs/decisions/README.md`
- `docs/templates/*.md`
- `docs/project-changelog.md`
- `docs/project-roadmap.md`
- `scripts/*.sh`
- `scripts/*.ps1`

---

### Understand Anything Graph Artifact Update

**Trigger:** When you want to persist or refresh the latest analyzed architecture/graph outputs for the dashboard or analysis pipeline.  
**Command:** `/update-ua-graph`

1. Add or update `.understand-anything/intermediate/*.json` files (batches, graphs, reviews, etc.).
2. Update `.understand-anything/knowledge-graph.json` and `meta.json`.
3. Update `.understand-anything/.understandignore` to ignore new or obsolete artifacts.

**Example:**
```bash
# Update knowledge graph artifact
cp output/graph.json .understand-anything/knowledge-graph.json

# Add a new intermediate analysis batch
cp output/batch-42.json .understand-anything/intermediate/batch-42.json

# Ignore obsolete artifact
echo ".understand-anything/intermediate/old-batch.json" >> .understand-anything/.understandignore
```

**Files Involved:**
- `.understand-anything/intermediate/*.json`
- `.understand-anything/knowledge-graph.json`
- `.understand-anything/meta.json`
- `.understand-anything/.understandignore`

## Testing Patterns

- **Test File Pattern:** `*.test.*`
- **Framework:** Unknown (check for test runner in project setup)
- **Example:**
  ```
  data-loader.test.ts
  user-profile.test.ts
  ```
- **Typical Test Structure:**
  ```typescript
  import { fetchData } from './data-loader';

  describe('fetchData', () => {
    it('returns expected data', () => {
      // test implementation
    });
  });
  ```

## Commands

| Command            | Purpose                                                      |
|--------------------|--------------------------------------------------------------|
| /restructure-docs  | Restructure or update project documentation and scripts      |
| /update-ua-graph   | Update knowledge graph artifacts for the analysis pipeline   |
```