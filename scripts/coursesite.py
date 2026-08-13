"""Shared rendering helpers for the .qmd pages.

Loads the JSON emitted by ``build_data.py`` and turns it into the small HTML
fragments (badges, links) that go into the itables tables. Kept out of the
pages themselves so the two data pages stay short and consistent.
"""

from __future__ import annotations

import html
import json
from pathlib import Path
from urllib.parse import quote

DATA_DIR = Path(__file__).resolve().parent.parent / "_data"


def load(name: str):
    return json.loads((DATA_DIR / f"{name}.json").read_text(encoding="utf-8"))


def href(path: str) -> str:
    """URL-encode a project-relative path (spaces, parens, & in folder names)."""
    return quote(path, safe="/#=")


def link(path: str, text: str, cls: str = "", title: str = "") -> str:
    attrs = f' class="{cls}"' if cls else ""
    attrs += f' title="{html.escape(title, quote=True)}"' if title else ""
    return f'<a href="{href(path)}"{attrs}>{html.escape(text)}</a>'


def show_table(df, columnDefs: list[dict]) -> None:
    """Render a DataFrame as the site's standard interactive table.

    Both data pages share this so they stay visually identical; only the
    per-column widths and sortability differ. ``allow_html`` is safe here
    because every cell is built by the helpers above, which HTML-escape
    everything drawn from the spreadsheet or a filename.
    """
    from itables import show

    show(
        df,
        allow_html=True,
        showIndex=False,
        classes="display compact cell-border course-table",
        columnDefs=columnDefs,
        lengthMenu=[[25, 50, -1], [25, 50, "All"]],
        order=[[0, "asc"]],
        scrollX=True,
    )


def video_cell(videos: list[dict]) -> str:
    if not videos:
        return '<span class="muted">—</span>'
    return " ".join(
        f'<a class="pill pill-video" href="{html.escape(v["url"], quote=True)}" '
        f'target="_blank" rel="noopener">▶ {html.escape(v["label"])}</a>'
        for v in videos
    )


def notes_cell(notes: list[dict], set_labels: list[str]) -> str:
    """One pill per notes file, grouped by set and labelled with its numbers."""
    if not notes:
        return '<span class="muted">—</span>'
    out = []
    for label in set_labels:
        items = [n for n in notes if n["set"] == label]
        if not items:
            continue
        short = short_set_name(label)
        pills = []
        for n in items:
            nums = ", ".join(str(x) for x in n.get("note_nos", [n["note_no"]]))
            tip = n.get("title", "")
            if n.get("note"):
                tip = f"{tip} — {n['note']}" if tip else n["note"]
            pills.append(link(n["file"], f"{short} {nums}", "pill pill-notes", tip))
        out.append(" ".join(pills))
    return " ".join(out)


def short_set_name(label: str) -> str:
    """Shorten a set's folder name so it fits on a badge.

    A full header like "NotesPartial Andrew van Paridon" is too long for a
    table cell, so it is trimmed for display only — the full label is still
    what must match the folder name, and is shown in the page's set listing.

    "Solutions (2017)"                -> "2017"        (parenthesised part wins)
    "NotesPartial Andrew van Paridon" -> "Andrew"
    "NotesYeolim2018"                 -> "Yeolim2018"

    The prefixes stripped below are cosmetic guesses at today's two naming
    habits, not a required convention: a set named anything else simply keeps
    its first word, and any label this cannot shorten is shown in full. Adding
    a set never requires touching this function.
    """
    import re

    if (m := re.search(r"\(([^)]+)\)", label)) and m.group(1).strip():
        return m.group(1).strip()

    s = re.sub(r"^notes\s*", "", label, flags=re.I)
    s = re.sub(r"^(partial|full)\s*", "", s, flags=re.I).strip()
    return (s.split()[0] if s.split() else label) or label


def usage_cell(usage: list[dict]) -> str:
    if not usage:
        return '<span class="muted">—</span>'
    out = []
    for u in usage:
        cls = "pill pill-used" if u["done"] else "pill pill-unused"
        mark = "✓" if u["done"] else "○"
        out.append(f'<span class="{cls}">{mark} {html.escape(u["label"])}</span>')
    return " ".join(out)


def problem_cell(link_info: dict, hw_no: int) -> str:
    target = link_info["pdf"]
    if link_info.get("matched"):
        target = f"{target}#page={link_info['page']}"
        text = f"Problem {hw_no}"
        tip = f"Opens the combined problem set at page {link_info['page']}"
    else:
        text = f"Problem {hw_no} (full doc)"
        tip = "Page anchor unavailable — opens the combined problem set"
    return link(target, text, "pill pill-problem", tip)


def solutions_cell(solutions: list[dict], set_labels: list[str]) -> str:
    if not solutions:
        return '<span class="muted">—</span>'
    out = []
    for label in set_labels:
        for s in (x for x in solutions if x["set"] == label):
            out.append(solution_pill(s, label))
    return " ".join(out)


def solution_pill(s: dict, label: str) -> str:
    short = short_set_name(label)
    warn = "" if s["approved"] else ' <span class="warn" title="Not instructor-reviewed">⚠</span>'
    tip = "" if s["approved"] else "Not instructor-reviewed"

    if s.get("file"):
        main = link(s["file"], f"{short} · {s['code']}", "pill pill-solution", tip)
    else:
        main = f'<span class="pill pill-solution pill-nopdf" title="No PDF in this set — supporting files only">{html.escape(short)} · {html.escape(s["code"])}</span>'

    extras = ""
    if s.get("supporting_files"):
        files = " ".join(
            link(f["file"], f["name"], "pill pill-file") for f in s["supporting_files"]
        )
        extras = (
            f'<details class="support"><summary>{len(s["supporting_files"])} file(s)'
            f"</summary>{files}</details>"
        )
    return f"{main}{warn}{extras}"
