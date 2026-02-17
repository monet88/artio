from __future__ import annotations

import argparse
from datetime import datetime, timezone
from pathlib import Path


def find_repo_root(start: Path) -> Path:
    # Walk upwards until we find a marker that suggests repo root
    for p in [start, *start.parents]:
        if (p / ".agent").exists() or (p / ".git").exists() or (p / "pyproject.toml").exists():
            return p
    return start


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--skill", required=True)
    parser.add_argument("--run-id", default="")
    args = parser.parse_args()

    repo_root = find_repo_root(Path.cwd())
    log_path = repo_root / ".agent" / "logs" / "skill-activation.log"
    log_path.parent.mkdir(parents=True, exist_ok=True)

    ts = datetime.now(timezone.utc).isoformat()
    line = f"{ts}\tskill={args.skill}\trun_id={args.run_id}\n"
    with open(log_path, "a", encoding="utf-8") as f:
        f.write(line)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
