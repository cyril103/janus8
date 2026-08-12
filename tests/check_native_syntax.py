#!/usr/bin/env python3
"""Validate that Janus8 keeps native bitwise syntax in executable source."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def executable_source(text: str) -> str:
    """Replace comments and string contents while preserving token boundaries."""
    output: list[str] = []
    index = 0
    state = "code"
    quote = ""

    while index < len(text):
        current = text[index]
        following = text[index + 1] if index + 1 < len(text) else ""

        if state == "code":
            if current == "/" and following == "/":
                output.extend("  ")
                index += 2
                state = "line_comment"
                continue
            if current == "/" and following == "*":
                output.extend("  ")
                index += 2
                state = "block_comment"
                continue
            if current in ('"', "'"):
                quote = current
                output.append(" ")
                index += 1
                state = "string"
                continue
            output.append(current)
            index += 1
            continue

        if state == "line_comment":
            output.append("\n" if current == "\n" else " ")
            index += 1
            if current == "\n":
                state = "code"
            continue

        if state == "block_comment":
            if current == "*" and following == "/":
                output.extend("  ")
                index += 2
                state = "code"
            else:
                output.append("\n" if current == "\n" else " ")
                index += 1
            continue

        if current == "\\" and index + 1 < len(text):
            output.extend("  ")
            index += 2
        elif current == quote:
            output.append(" ")
            index += 1
            state = "code"
        else:
            output.append("\n" if current == "\n" else " ")
            index += 1

    if state in ("block_comment", "string"):
        raise ValueError(f"unterminated {state.replace('_', ' ')}")
    return "".join(output)


def require(source: str, description: str, pattern: str) -> None:
    if re.search(pattern, source, re.MULTILINE) is None:
        raise ValueError(f"missing native syntax: {description}")


def main() -> int:
    if len(sys.argv) != 4:
        print("usage: check_native_syntax.py CORE CORE_TESTS OPCODE_TESTS", file=sys.stderr)
        return 2

    core = executable_source(Path(sys.argv[1]).read_text())
    core_tests = executable_source(Path(sys.argv[2]).read_text())
    opcode_tests = executable_source(Path(sys.argv[3]).read_text())

    if re.search(r"\b(?:byteAnd|byteOr|byteXor|spriteBit)\b", core):
        raise ValueError("legacy arithmetic bit helper is still present")

    requirements = (
        ("opcode family shift", r"\bopcode\s*>>\s*usize\(12\)"),
        ("X nibble extraction", r"\(opcode\s*>>\s*usize\(8\)\)\s*&\s*uint\(0xF\)"),
        ("Y nibble extraction", r"\(opcode\s*>>\s*usize\(4\)\)\s*&\s*uint\(0xF\)"),
        ("byte mask", r"\bopcode\s*&\s*uint\(0xFF\)"),
        ("address mask", r"\bopcode\s*&\s*uint\(0xFFF\)"),
        (
            "8XY1 native OR branch",
            r"else\s+if\s+sub\s*==\s*uint\(1\)\s*\{\s*registers\.set\(x,\s*vx\s*\|\s*vy\)\s*\}",
        ),
        (
            "8XY2 native AND branch",
            r"else\s+if\s+sub\s*==\s*uint\(2\)\s*\{\s*registers\.set\(x,\s*vx\s*&\s*vy\)\s*\}",
        ),
        (
            "8XY3 native XOR branch",
            r"else\s+if\s+sub\s*==\s*uint\(3\)\s*\{\s*registers\.set\(x,\s*vx\s*\^\s*vy\)\s*\}",
        ),
        ("logical right shift", r"unsignedByte\(vx\)\s*>>\s*usize\(1\)"),
        ("left shift", r"unsignedByte\(vx\)\s*<<\s*usize\(1\)"),
        ("sprite bit mask", r"uint\(0x80\)\s*>>\s*column"),
    )
    for description, pattern in requirements:
        require(core, description, pattern)

    require(core_tests, "hexadecimal core opcode", r"\buint\(0x60FE\)")
    require(opcode_tests, "hexadecimal sprite opcode", r"\buint\(0xA20A\)")
    require(core, "binary font byte", r"\bbyte\(0b1111_0000\)")

    print("native Janus syntax: ok")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as error:
        print(error, file=sys.stderr)
        raise SystemExit(1)
