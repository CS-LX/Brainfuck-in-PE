#!/usr/bin/env python3
"""Convert .bf source files to MASM assembly embedded in .text$bf."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BF_CHARS = set("+-<>[],.")
CHUNK_SIZE = 64


def strip_comments(source: str) -> str:
    lines: list[str] = []
    for line in source.splitlines():
        if ";" in line:
            line = line[: line.index(";")]
        lines.append(line)
    return "\n".join(lines)


def strip_bf(source: str) -> str:
    return "".join(ch for ch in strip_comments(source) if ch in BF_CHARS)


def name_from_path(path: Path) -> str:
    return "BF_Prog_" + path.stem.replace("-", "_").title().replace("_", "")


def emit_db_lines(code: str) -> list[str]:
    lines: list[str] = []
    for i in range(0, len(code), CHUNK_SIZE):
        chunk = code[i : i + CHUNK_SIZE]
        escaped = chunk.replace("'", "''")
        lines.append(f"    db '{escaped}'")
    lines.append("    db 0")
    return lines


def generate_program_block(bf_path: Path) -> str:
    source = bf_path.read_text(encoding="utf-8")
    code = strip_bf(source)
    symbol = name_from_path(bf_path)

    body = "\n".join(emit_db_lines(code))
    return (
        f"; from {bf_path.name}\n"
        f"public {symbol}\n"
        f"{symbol} label byte\n"
        f"{body}\n"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description="Convert Brainfuck to MASM .text$bf assembly")
    parser.add_argument("inputs", nargs="+", type=Path, help=".bf source files")
    parser.add_argument("-o", "--output", type=Path, required=True, help="Output .asm path")
    args = parser.parse_args()

    blocks: list[str] = []
    for bf_path in args.inputs:
        if not bf_path.is_file():
            print(f"error: {bf_path} not found", file=sys.stderr)
            return 1
        blocks.append(generate_program_block(bf_path))

    merged = (
        "; AUTO-GENERATED - DO NOT EDIT\n"
        "bf_text segment 'CODE'\n"
        "align 16\n"
        "\n"
        + "\n".join(blocks)
        + "\nbf_text ends\nend\n"
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(merged, encoding="utf-8")
    print(f"Generated {args.output} from {len(args.inputs)} program(s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
