#!/usr/bin/env python3
"""Interactive flow picker for Kerd mode skill.

Usage: python3 flow_picker.py '<json_array_of_step_strings>'

Renders a checklist in the terminal. All steps start enabled.
  - Up/Down or j/k: navigate
  - Space: toggle step on/off
  - Enter: confirm selection
  - q: quit without changes (exits with code 1)

Outputs JSON to stdout: array of objects with "index", "text", "enabled" fields.
"""

import curses
import json
import sys


def run_picker(stdscr, steps):
    curses.curs_set(0)
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_GREEN, -1)
    curses.init_pair(2, curses.COLOR_RED, -1)
    curses.init_pair(3, curses.COLOR_CYAN, -1)

    enabled = [True] * len(steps)
    cursor = 0

    while True:
        stdscr.clear()
        h, w = stdscr.getmaxyx()

        title = "Flow picker — Space: toggle, Enter: confirm, q: cancel"
        stdscr.addnstr(0, 0, title, w - 1, curses.A_BOLD | curses.color_pair(3))
        stdscr.addnstr(1, 0, "─" * min(len(title), w - 1), w - 1, curses.color_pair(3))

        for i, step in enumerate(steps):
            if i + 3 >= h:
                break
            marker = "[x]" if enabled[i] else "[ ]"
            color = curses.color_pair(1) if enabled[i] else curses.color_pair(2)
            prefix = " > " if i == cursor else "   "
            attr = curses.A_BOLD if i == cursor else 0
            line = f"{prefix}{marker} {i + 1}. {step}"
            stdscr.addnstr(i + 3, 0, line, w - 1, attr | color)

        footer_y = min(len(steps) + 4, h - 1)
        if footer_y < h:
            count = sum(enabled)
            footer = f"{count}/{len(steps)} steps enabled"
            stdscr.addnstr(footer_y, 0, footer, w - 1, curses.A_DIM)

        stdscr.refresh()

        key = stdscr.getch()
        if key in (ord("q"), ord("Q")):
            return None
        elif key in (curses.KEY_UP, ord("k")):
            cursor = max(0, cursor - 1)
        elif key in (curses.KEY_DOWN, ord("j")):
            cursor = min(len(steps) - 1, cursor + 1)
        elif key == ord(" "):
            enabled[cursor] = not enabled[cursor]
        elif key in (curses.KEY_ENTER, 10, 13):
            return [
                {"index": i, "text": steps[i], "enabled": enabled[i]}
                for i in range(len(steps))
            ]


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 flow_picker.py '<json_array>'", file=sys.stderr)
        sys.exit(2)

    try:
        steps = json.loads(sys.argv[1])
    except json.JSONDecodeError as e:
        print(f"Invalid JSON: {e}", file=sys.stderr)
        sys.exit(2)

    if not isinstance(steps, list) or not all(isinstance(s, str) for s in steps):
        print("Expected a JSON array of strings", file=sys.stderr)
        sys.exit(2)

    try:
        result = curses.wrapper(run_picker, steps)
    except curses.error:
        print("NO_TTY", file=sys.stderr)
        sys.exit(3)

    if result is None:
        sys.exit(1)

    print(json.dumps(result))


if __name__ == "__main__":
    main()
