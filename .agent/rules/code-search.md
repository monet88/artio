# Code Search & Navigation

**MANDATORY:** Follow this tool selection matrix. Do NOT default to grep/view_file when MCP tools give better results.

## Tool Selection Matrix

| Task | MUST USE | DO NOT USE |
|------|----------|------------|
| Concept search ("where does X happen?") | `mcp_ck-search_semantic_search` | ~~grep_search only~~ |
| Find files related to topic | `semantic_search` → then `grep_search` to verify | ~~find_by_name only~~ |
| Exact pattern match (regex, variable) | `grep_search` or `mcp_ck-search_lexical_search` | — |
| Combined semantic + regex | `mcp_ck-search_hybrid_search` | Running both manually |
| View class/method structure | `mcp_serena_get_symbols_overview` or `view_file_outline` | ~~view entire file~~ |
| Read specific symbol body | `mcp_serena_find_symbol(include_body=True)` | ~~view_file entire file~~ |
| Edit method/class | `mcp_serena_replace_symbol_body` / `insert_after_symbol` | ~~view + replace_file_content~~ |
| Rename across codebase | `mcp_serena_rename_symbol` | ~~manual find-replace~~ |
| Impact analysis (who calls X?) | `mcp_serena_find_referencing_symbols` | ~~grep for function name~~ |
| Dart analysis / errors | `mcp_dart-mcp-server_analyze_files` | ~~run_command flutter analyze~~ |
| Run tests | `mcp_dart-mcp-server_run_tests` | ~~run_command flutter test~~ |
| New file / non-code files | `write_to_file` | — |
| Files < 50 lines / config | `view_file` / `replace_file_content` | — |

## Search Strategy

### Discovery (exploring unknown code)
1. `mcp_ck-search_semantic_search` — find conceptually related code
2. `grep_search` — verify with exact keyword matches
3. Merge results, deduplicate

### Focused Query
- `mcp_ck-search_semantic_search` with `top_k: 3-5`

### Broad Discovery
- `mcp_ck-search_semantic_search` with `top_k: 10`, `snippet_length: 300`

### Always pass `path`
- Project root: `f:\CodeBase\flutter-app\artio`
- Or relevant subdirectory: `f:\CodeBase\flutter-app\artio\lib\features\create`

### `grep_search` Quirks ⚠️
When using the built-in `grep_search` tool:
- **Always provide a directory path** for `SearchPath`.
- Passing a direct file path to a single file causes the tool to silently fail and return 'No results found'.
- To search within a specific single file, set `SearchPath` to its parent directory and use the `Includes` parameter, or grep the directory and filter results yourself.

## Serena MCP — Correct Parameters

| Tool | Correct Param | WRONG (will error) |
|------|--------------|-------------------|
| `find_symbol` | `name_path_pattern` | ~~name_path~~ |
| `find_referencing_symbols` | `name_path` + `relative_path` | ~~name_path_pattern~~ |
| `replace_symbol_body` | `name_path` | ~~name_path_pattern~~ |
| `insert_after/before_symbol` | `name_path` | ~~name_path_pattern~~ |
| `rename_symbol` | `name_path` | ~~name_path_pattern~~ |
| `search_for_pattern` | `substring_pattern` | ~~pattern~~ |
| `list_dir` | `relative_path` + `recursive` (both required!) | — |
| `find_file` | `file_mask` + `relative_path` (both required!) | — |
| `get_symbols_overview` | `relative_path` (file only!) | ~~directory path~~ |

### Serena Setup (once per session if needed)
```
mcp_serena_activate_project → mcp_serena_check_onboarding_performed
```

## Tool Chaining Patterns

**Discovery → Edit:**
```
find_symbol(include_body=False) → find_symbol(include_body=True) → replace_symbol_body
```

**Reference-Aware Refactoring:**
```
find_symbol → find_referencing_symbols → rename_symbol
```

**Multi-File Edit:**
```
get_symbols_overview → insert_before/after_symbol → replace_symbol_body
```

**Partial Edit (few lines within large method):**
```
mcp_serena_replace_content(relative_path, needle, repl, mode="regex")
```

## CK-Search Index

- Model: `bge-small` (384 dims, fast)
- Index: `.ck/` directory, auto-refreshed on search
- Reindex: `mcp_ck-search_reindex` (only if model changed or index corrupt)
- Config: `.ckignore` controls what gets indexed (code-only, no docs/generated)
