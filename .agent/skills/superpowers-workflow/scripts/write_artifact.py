from __future__ import annotations

import argparse
import sys
from pathlib import Path

def find_repo_root(start: Path) -> Path:
    for p in [start, *start.parents]:
        if (p / ".agent").exists() or (p / ".git").exists():
            return p
    return start

def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--path", required=True, help="Repo-relative path to write, e.g. artifacts/superpowers/brainstorm.md")
    args = parser.parse_args()

    repo_root = find_repo_root(Path.cwd()).resolve()
    out_path = (repo_root / args.path).resolve()
    if not str(out_path).startswith(str(repo_root) + "/") and out_path != repo_root:
        print(f"Error: resolved path {out_path} is outside repo root {repo_root}", file=sys.stderr)
        return 1
    out_path.parent.mkdir(parents=True, exist_ok=True)

    content = sys.stdin.read()
    out_path.write_text(content, encoding="utf-8")
    print(str(out_path))
    return 0

if __name__ == "__main__":
    raise SystemExit(main())