# CLAUDE.md — Dynamics & Simulation course website

This file is the build brief for this repo. Read it fully before making changes. The site is a **Quarto website** that presents this course's lectures, homework, notes, and solutions, all driven by `Dynamics&Sim-MasterSheet.xlsx` so that updating the course each year means editing the spreadsheet (and dropping files in matching folders), not editing code.

Course: Dynamics & Simulation, AKA Intermediate Dynamics (ME 4730/5730 on ruina.org). Instructor: Prof. Andy Ruina. Currently taught at Plaksha University, reusing Cornell-recorded lecture videos.

## 1. Before you touch anything: verify prerequisites

The person running you was told to do two things by hand before this build starts. **Check both; if either isn't done, stop and tell them what's missing instead of working around it in code.**

1. **Five corrupted cells in `Dynamics&Sim-MasterSheet.xlsx` must be retyped as plain text.** Excel auto-converted some "N, M" style entries into dates. Check these cells in the `Lectures` sheet — if any still holds a `datetime` value, the fix wasn't done:
   - `D4` (Lecture 3 row, "NotesPartial Andrew van Paridon" column) — was showing as `2026-02-03`
   - `D10` and `D11` (Lecture 9 and 10 rows, same column) — were showing as `2026-09-10`
   - `E16` (Lecture 15 row, "NotesYeolim2018" column) — was showing as `2026-08-09`
   - `E17` (Lecture 16 row, same column) — was showing as `2026-12-13`

   These should read as plain lecture-note-number lists like `9, 10`. If you find *other* date-typed cells in mapping columns beyond this list (this can recur if someone types a similar pattern later), flag them too rather than guessing the intended value.

2. **The solutions folder must be renamed**: `Homework/HomeworkSolutions2017/` → `Homework/Solutions (2017)/`, so it matches the `Solutions (2017)` column header in the `Homeworks` sheet exactly (see §3 — this exact-match convention is how new solution sets get auto-discovered).

Also confirm this folder is a git repo yet (`git status`). If not, `git init` it as part of this build — see §8.

## 2. Repository layout

```
DynamicsWebsite/                        (Quarto project root — cwd)
├── _quarto.yml
├── CLAUDE.md                           (this file)
├── styles.css
├── Dynamics&Sim-MasterSheet.xlsx       ← SOURCE OF TRUTH, edited by hand each year
├── CourseOutline.md                    ← prose source for the Course Outline page
├── index.qmd / outline.qmd / lectures.qmd / homework.qmd / about.qmd   (pages — build these)
├── scripts/
│   └── build_data.py                   ← pre-render script (build this, see §4)
├── _data/                              ← generated JSON, gitignored, regenerated every render
├── files/                              ← generated: clean copies of the 2 PDFs that need page-anchor links (see §4.4)
├── Homework/
│   ├── HomeworkAssignments/
│   │   ├── Homework Plaksha Dyn & Sim.pdf   (the combined 61-problem set, 33 pages)
│   │   ├── Homework Plaksha Dyn & Sim.tex   (source — don't link, don't parse; PDF text is enough, see §4.4)
│   │   ├── Homework-Policy.pdf              (grading/submission policy — embed, don't transcribe)
│   │   ├── Homework-Policy.tex              (source — don't link)
│   │   └── HomeworkFigs/                    (LaTeX build assets only — ignore entirely)
│   └── Solutions (2017)/               (renamed per §1.2 — one PDF per problem, Q01..Q45ish, plus a few subfolders with supporting .m/.png files, plus some stray files — see §5)
├── Notes/
│   ├── NotesPartial Andrew van Paridon/    (17 files, "Lecture 01 ....pdf" .. "Lecture 17 ....pdf")
│   └── NotesYeolim2018/                    (40 files, "1. 08-24 ....pdf" .. "40. 12-3.pdf")
└── rpmath.sty                           (LaTeX macro package — irrelevant to the site, ignore)
```

`rpmath.sty`, and every `.tex`/`.synctex.gz` file, are LaTeX build artifacts for the professor's own workflow. **Never link to them from the site.** The compiled PDFs are what students see.

## 3. The master sheet — schema and the extensibility rule

`Dynamics&Sim-MasterSheet.xlsx` has two sheets. **The whole point of this architecture is that adding a year of videos, a new notes-taker, or a new solutions set should never require a code change** — only a new column (with a specific header pattern) and, for Notes/Solutions, a same-named folder. Implement column detection by pattern, not by hardcoding today's exact headers.

### Sheet `Lectures` (currently 42 rows)

| Column | Meaning |
|---|---|
| `Lec No.` | fixed identity column |
| `Name of Lecture` | fixed |
| Any column matching `Link (...)` | a video-link set. Label = text inside the parens (e.g. "2020"). Value = a URL (handle the cell holding more than one URL, comma/whitespace separated, gracefully). |
| Any other column | a **notes set**. Label = the full header text, which **must exactly match a folder name under `Notes/`**. Cell value = which note number(s) in that folder cover this lecture. |

Notes-set cell values come in several shapes — parse defensively:
- blank → nothing to show
- a number (`7`, `7.0`) → single note number
- `"16, 17"` → multiple note numbers
- `"03, 04 -> MATLAB, vector products notes"` or `"17, 18, 19 - inverted pendulums of sorts"` → leading comma-separated numbers followed by free-text commentary after `->` or `-`; extract the numbers, and it's fine to keep the trailing text as a tooltip/caption if convenient, but don't let it break number parsing
- a `datetime` object → the Excel-autocorrect bug from §1.1. After the prerequisite fix these shouldn't appear; if one does anyway, log a warning and skip rather than crashing.

To resolve a note number `N` to an actual file: find the file in that notes-set's folder whose name starts with `N` (zero-padded or not) followed by `.` or whitespace, e.g. `N=1` matches `Lecture 01 Introduction.pdf` in Andrew's folder and `1. 08-24 Intro-pos-vel.pdf` in Yeolim's folder. Use a regex like `^0*{N}[.\s]`.

### Sheet `Homeworks` (currently 61 rows)

| Column | Meaning |
|---|---|
| `Homework No. (Plaksha Doc)` | fixed identity column. **This number is the same numbering rendered inside the combined homework PDF** (confirmed: e.g. row 31 → "31. Double pendulum. 2D." appears on PDF page 13; row 34 → "34. Mass in slot on turntable." on page 15) — see §4.4. |
| Any column matching `Done Last Time (...)` | a usage-history entry. Label = text in parens (e.g. "2025 Plaksha"). Value = `y`/`n` (case-insensitive) → boolean. Treat this the same extensible way as Link columns: there may eventually be more than one such column (e.g. a future `Done Last Time (2027 Plaksha)`), and a homework row should be able to show usage across all of them. |
| Any other column | a **solutions set**. Label = full header text, which **must exactly match a folder name under `Homework/`** (e.g. `Solutions (2017)`). Cell value = a code like `Q01` identifying the solution file(s) for this problem in that folder. |

## 4. Data pipeline

**Architecture: a Python pre-render script reads the xlsx and scans the folders on every `quarto render`, emitting JSON that the pages consume.** Wire it up via `_quarto.yml`:

```yaml
project:
  type: website
  pre-render: scripts/build_data.py
```

Pages are computational `.qmd` files (Python/Jupyter engine) with a code cell that loads the JSON from `_data/` and renders a table via **`itables`** (client-side sortable/searchable/filterable DataTables — still a fully static site, no backend). Add `_data/` to `.gitignore` — it's fully derived, never hand-edit it.

Python deps (`requirements.txt`): `openpyxl`, `pandas`, `itables`, `pypdf` (or shell out to `pdftotext -layout`, confirmed available and gave clean layout-preserving text when tested — either is fine, pick whichever gives more reliable text for §4.4).

### 4.1 `_data/lectures.json` — suggested shape

```json
[
  {
    "lec_no": 1,
    "name": "Course Introduction, Kinematics, Constitutive Laws, Laws of Mechanics",
    "videos": [{"label": "2020", "url": "https://vod.video.cornell.edu/..."}],
    "notes": [
      {"set": "NotesPartial Andrew van Paridon", "note_no": 1, "file": "Notes/NotesPartial Andrew van Paridon/Lecture 01 Introduction.pdf"},
      {"set": "NotesYeolim2018", "note_no": 1, "file": "Notes/NotesYeolim2018/1. 08-24 Intro-pos-vel.pdf"}
    ]
  }
]
```

### 4.2 `_data/homeworks.json` — suggested shape

```json
[
  {
    "hw_no": 1,
    "usage": [{"label": "2025 Plaksha", "done": true}],
    "problem_link": {"pdf": "files/homework-problems.pdf", "page": 4, "matched": true},
    "solutions": [
      {"set": "Solutions (2017)", "code": "Q01", "file": "Homework/Solutions (2017)/Q01_MAE57304730_F17.pdf", "approved": true, "supporting_files": []}
    ]
  }
]
```

Plus a per-solutions-set list of **unmapped files** (see §5) for the "other materials" section.

### 4.3 Solutions matching

For a solutions cell value like `Q01`, search that set's folder (and one level into subfolders — `Q23`, `Q25`, `Q27`, `Q34` each live inside a same-named subfolder alongside supporting `.m`/`.png` files, e.g. `Solutions (2017)/Q25_MAE57304730_F17/Q25_MAE57304730_F17.pdf`) for the file matching `^Q01.*\.pdf$` case-insensitively. Any sibling non-PDF files in that subfolder are `supporting_files`.

**Approval-status badge:** if the matched filename or its containing subfolder name contains (case-insensitive) any of `NotApproved`, `NotYetApproved`, `NonFinalized`, `NotAndyApproved`, `NotAndyAproved` (yes, that misspelling exists in a real filename — match it too), or `DamnGood` (implies "not officially approved" per the folder it came from), mark `"approved": false` and show a small ⚠ "not instructor-reviewed" badge in the UI. Keep this keyword list as an easily-editable constant.

**Duplicate files:** `Q45 - NotAndyApproved.pdf` and `Q45_MAE57304730_F17_NotAndyAproved.pdf` are byte-identical. Dedupe by content hash; when duplicates exist, keep the one matching the cleaner `Q##_COURSE_TERM...` pattern and drop the rest from listings.

**Unmapped/stray files** (e.g. `AaronSondoval3DSolutions.pdf`, `FA12 Exam Q_MAE57304730_NotApproved.pdf`, and other exam-question PDFs that don't match any `Q##` the sheet references): don't discard these — collect whatever's left in each solutions folder after processing all mapped codes, and surface them in a secondary "other materials in this set" listing on the Homework page (still apply the approval-badge check to them).

### 4.4 Homework-problem → PDF page linking

Confirmed feasible: the combined PDF (`Homework/HomeworkAssignments/Homework Plaksha Dyn & Sim.pdf`, 33 pages) renders each problem as an auto-numbered `"N. Title"` line, and `N` matches `Homework No. (Plaksha Doc)` from the sheet (spot-checked several: #9 "Canon ball." p.4, #22 "Simple pendulum." p.11, #31 "Double pendulum. 2D." p.13, #34 "Mass in slot on turntable." p.15, #37 "Rolling cylinder" p.16, #61 "Spinning top in 3D." p.32).

Extract per-page text (`pdftotext -layout` or `pypdf`), then for each `hw_no` search for a line matching `^\s*{hw_no}\.\s+\S` at or after the page where `hw_no - 1` was found (the monotonicity constraint avoids matching stray numbers elsewhere, like equation numbers). Record the page. **This heuristic won't be perfect** — spot-check the results against the anchors above; if a problem number can't be found or would violate monotonicity, fall back to `{"pdf": "files/homework-problems.pdf", "page": 1, "matched": false}` (link to the whole doc) rather than guessing. Log which numbers fell back so it's easy to spot-check.

**Copy, don't link in place**, exactly two files into a new `files/` folder with clean names (no spaces/`&`, both because of the `#page=` fragment and general link hygiene):
- `Homework/HomeworkAssignments/Homework Plaksha Dyn & Sim.pdf` → `files/homework-problems.pdf`
- `Homework/HomeworkAssignments/Homework-Policy.pdf` → `files/homework-policy.pdf`

Every other linked file (the ~150 individual note/solution PDFs, which do have spaces/parens in their paths) can stay exactly where it is — just make sure the pipeline URL-encodes hrefs properly (spaces → `%20`, etc.) rather than mass-renaming everything.

**Add `Notes/`, `Homework/`, and `files/` explicitly under `project: resources:` in `_quarto.yml`.** Don't rely on Quarto's automatic link-scanning to catch files referenced only from JSON-driven/itables-rendered links — declare them so they're guaranteed to land in `_site/` on every build, or GitHub Pages links will 404 in production even though `quarto preview` works locally.

## 5. Pages

- **`index.qmd` (Home)** — short welcome, course title/instructor, quick links to the other pages. A one-line stat summary pulled from the data (e.g. "42 lectures · 61 homework problems") is a nice touch, not required.
- **`outline.qmd` (Course Outline)** — sourced from `CourseOutline.md`. **First, edit `CourseOutline.md` once** to delete its `## Lecture Schedule` table and the "all lecture links are available at tinyurl..." line — that data is now stale (only 30 of 42 lectures) and fully superseded by the live Lectures page. Keep Course Overview, Learning Outcomes, Recommended Resources, and Grading.
- **`lectures.qmd`** — interactive table from `lectures.json`: Lec No., Name, video links (badges per year), notes links (badges per set/author).
- **`homework.qmd`** — interactive table from `homeworks.json`: HW No., usage-history badges ("Used 2025" etc.), a link to the problem (deep-linked PDF page per §4.4), solution links per set (with ⚠ badges where unapproved). Below the table: the embedded Homework Policy (`files/homework-policy.pdf` in an inline viewer + a plain download link, on its own section — don't transcribe the policy to markdown, it's not meant to be re-typeset). Below that: the "other materials" listing of unmapped solution-folder files from §4.3.
- **`about.qmd`** — keep minimal, but add a short "how to update this site" section (this doubles as the professor/future-maintainer doc):
  1. Edit `Dynamics&Sim-MasterSheet.xlsx` — add rows, or add a new `Link (YYYY)` / `Solutions (...)` / `Done Last Time (...)` column.
  2. For a new notes or solutions set, create a folder under `Notes/` or `Homework/` **named exactly like the new column header**, and drop the files in it.
  3. Run `quarto render` locally to check it.
  4. `git add -A && git commit -m "..." && git push` — GitHub Actions redeploys automatically (§8).

Update `_quarto.yml` navbar to: Home, Course Outline, Lectures, Homework, About.

## 6. Styling

`_quarto.yml` currently has `theme: [cosmo, brand]` but there's no `_brand.yml` in the repo, which will error or silently no-op. No branding decisions were specified for this build — just drop `brand` and use `theme: cosmo` alone. Visual polish beyond that is your call.

## 7. Hosting & deployment — GitHub Pages

- `git init` this repo if it isn't one yet (confirm per §1).
- Add a `.gitignore` covering `_site/`, `_data/`, `.quarto/`.
- Add `.github/workflows/publish.yml` using `quarto-dev/quarto-actions/publish` (or `quarto-dev/quarto-actions/render` + `peaceiris/actions-gh-pages`) targeting `gh-pages`, triggered on push to the main branch. The workflow needs to install the Python deps from `requirements.txt` before rendering, since `pre-render` requires them.
- The site is intentionally **fully public** — no auth, no password gate. Still fine to add a plain `robots.txt`/meta description; no indexing restriction was requested though, so don't add `noindex`.
- After scaffolding the workflow, tell the user the exact commands to create the GitHub repo and push (in case `gh` isn't authenticated in your environment) rather than assuming you can do it silently.
- Repo size note: individual PDFs top out around 15MB (well under GitHub's 100MB hard limit), so plain git is fine — no need for Git LFS, just flagging it as something to reconsider if the materials grow substantially.

## 8. Explicit non-goals

- Don't parse/split the homework problems LaTeX or PDF into individual per-problem files. Link into the combined PDF (§4.4).
- Don't transcribe the Homework Policy into markdown. Embed the PDF.
- Don't hardcode lecture/homework counts, column names for specific years, or specific author names anywhere — always derive from the sheet at render time. The whole design point is that next year's update is a spreadsheet + folder change, not a code change.
- Don't touch `rpmath.sty` or any `.tex`/`.synctex.gz` file, and don't link to them.

## 9. Suggested build order

1. Verify prerequisites (§1). Stop and report if not done.
2. Scaffold `scripts/build_data.py`, get it emitting `_data/lectures.json` and `_data/homeworks.json` correctly — test standalone before wiring into Quarto. Spot-check a handful of rows against the actual folders by hand.
3. Wire up `pre-render` in `_quarto.yml`, build the two data pages with `itables`.
4. Edit `CourseOutline.md`, build `outline.qmd`, `index.qmd`, refresh `about.qmd`.
5. Fix the theme (§6), update the navbar.
6. `quarto render` locally; click through every page; verify a sample of links (a video URL, a notes PDF, a solution PDF with a badge, an unmapped "other materials" file, the deep-linked homework page anchor, the embedded policy PDF).
7. Git init + GitHub Actions workflow (§7); document the push/create-repo steps for the user.
8. Final pass: confirm nothing links to `.tex`/`.synctex.gz`/`rpmath.sty`, confirm `project: resources` covers everything needed, confirm `_data/` is gitignored.
