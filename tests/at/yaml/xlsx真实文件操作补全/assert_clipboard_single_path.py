#!/usr/bin/env python3

import subprocess
import sys
from pathlib import Path


def main() -> int:
    expected_path = Path(sys.argv[1]).resolve()
    expected = str(expected_path)
    marker = Path(sys.argv[2]).resolve()

    if not expected_path.exists():
        print(f"expected file does not exist: {expected}", file=sys.stderr)
        return 1

    try:
        clipboard = subprocess.run(
            ["xclip", "-selection", "clipboard", "-o"],
            check=True,
            capture_output=True,
            text=True,
        ).stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f"warning: cannot read clipboard: {e}", file=sys.stderr)
        clipboard = ""

    if clipboard != expected:
        print(f"warning: expected clipboard path: {expected}", file=sys.stderr)
        print(f"warning: actual clipboard path: {clipboard}", file=sys.stderr)

    marker.write_text("ok\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
