# XOK Note (쏙 노트) GUI Design System

## Project Overview

This project is the GUI redesign for **XOK Note (쏙 노트)**.

XOK Note is an AI-powered note application that helps users extract key information from large amounts of content and organize it into structured, readable notes.

The HTML/CSS created in this project **is not production code.**
It is a **high-fidelity GUI prototype** intended for handoff to Flutter developers.

---

## Brand Philosophy

The meaning of **쏙(XOK)** is:
> "Extract only the essential information and organize it into your own notes."

Core keywords: Simplicity · Focus · Structure · Readability · Calm · Professional · Spacious · Efficient

The UI should never compete with the user's content. Content must always remain the primary focus.

---

## Design Direction

Reference quality (NOT visual identity): Apple HIG · Notion · Arc Browser · Linear · Obsidian

Reference only: spacing · hierarchy · consistency · interaction quality · overall polish

---

## Visual Design Principles

**Prioritize:** Readability · Consistency · Simplicity · Spacious layout · Clear visual hierarchy

**Avoid:** unnecessary decoration · excessive gradients · skeuomorphic effects · heavy borders · excessive shadows

---

## Color System

```css
--color-background: #F7F3EE;   /* App bg, workspace, large empty areas */
--color-surface:    #FFFFFF;   /* Cards, popups, search bars, menus, dialogs */
--color-primary:    #1F2937;   /* Logo, titles, nav, main text, icons, primary buttons */
--color-accent:     #D9462F;   /* Active, selected, CTA, notification, current page, focus — use sparingly, never as large bg */
--color-divider:    #E7DED4;   /* Borders, dividers, input outlines */
--color-text-secondary: #6B7280;
--color-disabled:   #B6B6B6;
--color-hover:      #F2EEE8;
--color-success:    #2E8B57;
--color-warning:    #E09F3E;
--color-error:      #C0392B;
```

---

## Typography

**Font:** Pretendard → Inter → sans-serif

| Name    | Size | Weight |
|---------|------|--------|
| Display | 32px | 700    |
| H1      | 28px | 700    |
| H2      | 24px | 600    |
| H3      | 20px | 600    |
| Body    | 16px | 400    |
| Small   | 14px | 400    |
| Caption | 12px | 400    |

Line height: Heading 1.3 · Body 1.6 · Caption 1.4

Rules: Never overuse bold. Use secondary text color instead of reducing opacity.

---

## Radius System

```css
--radius-sm: 8px;
--radius-md: 12px;
--radius-lg: 20px;
--radius-floating: 24px;
```

---

## Spacing System (8px Grid)

Allowed values: `4 · 8 · 12 · 16 · 24 · 32 · 48 · 64`

Never invent arbitrary spacing values. Whitespace is the primary separator.

```css
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-6: 24px;
--space-8: 32px;
--space-12: 48px;
--space-16: 64px;
```

---

## Shadow

Use minimally. Only allowed for: Dialog · Context Menu · Floating Menu · Sort Dropdown.
Cards rely on spacing, not shadows.

---

## Icons

Style: Rounded · Line icons · Minimal
Default color: Primary
Filled icons: only when interaction requires stronger emphasis.

---

## Layout

- **Device frame:** 1280×800px (16:10 tablet), JS auto-scale to browser window
- **Sidebar collapsed:** 64px
- **Sidebar expanded:** 312px
- **AppBar height:** 64px
- **Target environment:** Tablet (no hover effects on sidebar nav items)

---

## Component Architecture

Core components (always reuse, never duplicate):
`AppBar · Sidebar · SearchBar · SortBar · SortDropdown · NoteCard · FolderCard · OverflowMenu · FloatingButton · Dialog · InputField · Chip · Badge · IconButton · ColorSwatch · SizeDot`

---

## Component Specs

### Sidebar (`app-sidebar`)
- Single unified component — collapsed (64px) / expanded (312px)
- Width transition: `220ms ease`
- **Header:** `height: 64px`, flex row — toggle button (64px fixed) + logo
- **Logo** (`app-sidebar__logo`): `width: 100px; height: 44px`, `object-fit: contain`, `object-position: left 70%`
  - Hidden via `opacity: 0` when collapsed, `opacity: 1` when expanded
  - File: `assets/images/logo.png` (PNG, transparent background, 500×220px artboard)
- **Nav items** (`sidebar-nav__item`): full-width, `position: relative`, no hover effects (tablet)
  - Active state uses `::before` pseudo-element: `inset: 2px 8px`, `border-radius: 8px`, `background: var(--color-hover)`
  - Active text color: `var(--color-accent)`
  - Icon wrap: always 64px wide, centered — ensures icon alignment in both states
  - Labels: hidden via `opacity: 0` when collapsed, `opacity: 1` when expanded

### AppBar (`appbar`)
- Height: 64px, `background: var(--color-background)`, bottom border
- Hidden when search is active (`appbar--hidden`)

### Search AppBar (`search-appbar`)
- Shown when search is active (`search-appbar--active`)
- Back button + text input

### Sort Bar (`sort-bar`)
- Contains `sort-bar__wrap` (position: relative) for dropdown anchoring
- Button shows current sort label; clicking toggles sort dropdown

### Sort Dropdown (`sort-dropdown`)
- Appears below sort button (`sort-dropdown--open`)
- `min-width: 200px`, `border-radius: 12px`, shadow: `var(--shadow-menu)`
- Active item: `color: var(--color-accent)`, `font-weight: 500`
- Options: 생성일 (최신순) · 생성일 (오래된순) · 수정일 (최신순) · 수정일 (오래된순) · 제목 (가나다순) · 제목 (가나다 역순)
- Selecting an item updates the sort bar label and closes dropdown

### Overflow Menu (`overflow-menu`)
- `width: 216px`, `border-radius: 12px`, shadow: `var(--shadow-menu)`
- Shown via `overflow-menu--open`
- Default position: `position: absolute`, top-right of AppBar (as used on the Home screen)
- **Anchored variant** (`overflow-menu--anchored`): positions `top: calc(100% + 4px); right: 0` relative to
  a `position: relative` wrapper instead of the AppBar — use this whenever the trigger isn't the AppBar's
  own `···` button (e.g. the Note screen's toolbar `⋮` button). Always reuse this component for any
  dropdown/context-menu list; never hand-roll a new menu shell.
- Items: icon + label, optional `overflow-menu__divider` between groups

### Note Card (`note-card`)
- `background: var(--color-surface)`, `border-radius: 12px`, bottom border
- Thumbnail height: 156px (dark or light variant)
- Info area: title (Small/Medium) + date (Caption/Secondary)

### Screen Deco (`screen-deco`)
- Decorative background image: `assets/images/deco.png`
- `position: absolute; bottom: 20px; right: 60px; width: 560px`
- `opacity: 0.25`, `pointer-events: none`, `z-index: 0`
- Note grid sits above deco (`z-index: 1`)
- **Rule:** Content (cards) always renders above deco. As notes fill the grid, deco stays behind.

### Icon Button (`icon-btn`)
- `40×40px`, `border-radius: var(--radius-sm)`, color `--color-primary`, hover bg `--color-hover`
- Modifiers: `icon-btn--sm` (32×32px), `icon-btn--active` (persistent hover bg + `--color-accent` icon color)
- Icon size is enforced in CSS regardless of svg markup attributes: 22px in the default button,
  16px in `--sm` — don't hand-tune per-icon svg sizes
- Use for every standalone icon-only button (toolbars, panel headers) instead of writing bespoke button CSS

### Chip (`chip`)
- Pill button: fixed `height: 28px`, Small(14px) label, `line-height: 1`, content centered,
  `border-radius: var(--radius-full)`, `border: var(--border-default)`, surface bg —
  keep chips compact, they are suggestions not CTAs
- Text-only by default (AI Agent skill chips carry no icon); `chip__icon` (12px, accent tint)
  is available when an icon genuinely helps
- Use for skill/action suggestions (e.g. AI Agent panel quick actions)

### Color Swatch / Size Dot (`color-swatch` / `size-dot`)
- `color-swatch`: 22px circle; `--active` shows a `--color-hover` plate via `outline: 4px solid` —
  the same active language as `icon-btn--active` / `size-dot--active`, and visible on every ink
  color including black (a primary-colored ring disappears on the black swatch)
- Swatch colors are content-authoring colors (pen ink), not design tokens — define as
  `color-swatch--{name}` modifiers (e.g. `color-swatch--red`) rather than inline styles
- `size-dot`: 28px hit target with a centered dot (`--sm` 4px / `--md` 7px / `--lg` 10px);
  `--active` tints the dot `--color-accent` and adds a `--color-hover` background

### Note Editor Shell (`note-shell` / `note-topbar` / `note-content` / `note-rail` / `note-editor` / `note-panel`)
- Used on the Note screen (`Note/soknote-note-prototype`) instead of `app-sidebar`/`app-main` —
  this is a document-editing view reached by opening a note, not the list shell
- Top-level: `.app-shell` (shared, flex row by default) holds a single `.note-shell` child
  (flex column) so the header can span the *full* width above the rail/editor/panel, matching
  the reference screenshots where back/title/tools/tabs sit above everything, not just the editor:
  ```
  .app-shell > .note-shell
    > .note-topbar          (full width — row + tabstrip, see below)
    > .note-content (flex row, flex: 1)
        > .note-rail
        > .note-editor      (no header of its own — just note-editor__pages)
        > .note-panel
  ```
- `note-topbar`: two stacked rows spanning the full shell width —
  `note-topbar__row` (56px single row — back button + title on the left, drawing-tool
  `note-toolbar__group` centered, link/split/AI/more `note-toolbar__group--end` pinned right,
  via `grid-template-columns: 1fr auto 1fr`) then `note-topbar__tabstrip` (40px open-document
  tab strip) below it. Do not reintroduce a separate 56px `note-toolbar` bar, and do not nest
  `note-topbar` back inside `note-editor` — it must stay a sibling of `note-content` inside
  `note-shell` so it sits above the rail too.
- `note-rail` (152px, left) / `note-editor` (flex: 1, center, just `note-editor__pages` —
  scrollable page stack + floating `page-nav` pill) / `note-panel` (flex: 1, right — same width
  as `note-editor`): all three are flush at the same top y-position inside `note-content`, each
  starting its own content (rail filter tabs, PDF page, `note-panel__header`) immediately —
  there is no per-column header offsetting one column lower than another.
- `note-rail__tabs`: single flex row of 3 filter tabs (전체/하이라이트/구조 — no counts),
  `white-space: nowrap` + `flex: 1 1 auto` so labels never wrap in the 152px rail; adjacent tabs
  are separated by a 1px `--border-default` vertical divider (`.note-rail__tab + .note-rail__tab`);
  active tab = accent text + 2px accent bottom underline (no pill background).
- `note-topbar__tabstrip`: `--color-background` strip; `note-tab` has a full `--border-default`
  border, `--color-surface` bg; active tab = `--color-hover` bg + accent-tinted icon/label.
- `note-editor__pages` has **no padding** — `note-page` cards are edge-to-edge (no border-radius,
  `--space-1` gap between pages), matching the reference PDF viewer. Page `⋯` menu dots are horizontal.
- `note-panel` (`position: relative`): the Scraps view is always visible; `.ai-agent` is a
  floating panel (400×520px, `--radius-lg`, `--shadow-dialog`, vertically centered near the
  panel's right edge, `z-index: 30`) toggled with `ai-agent--active`. Empty scrap list body
  (`note-panel__scraps`) renders 28px ruled rows via `repeating-linear-gradient` plus a faint
  centered hint (`note-panel__empty-hint`, `--color-disabled`); the "No scraps yet" empty-state
  text lives in the left rail (`note-rail__list`).
- `note-panel__header` height: 40px (shared by Scraps and AI Agent headers).
- Document/page content is a **generic placeholder** (`pdf-ph__*` bars/blocks — no real document
  text or images) colored via the `--color-pdf-*` tokens in tokens.css. Never reuse those tokens
  for app chrome, and never put real presentation content back into the pages

---

## State Management (JS)

```js
const State = {
  sidebarExpanded:  false,  // app-sidebar--expanded
  searchActive:     false,  // appbar--hidden + search-appbar--active
  overflowMenuOpen: false,  // overflow-menu--open
  sortDropdownOpen: false,  // sort-dropdown--open
};
```

All state changes go through `applyState()` — never toggle classes directly.

---

## File Structure

This design system is shared across every screen folder under `GUI/`. Never
copy these files into a screen folder — always reference `shared/` by relative
path so every screen stays on the same tokens and components.

```
GUI/
├── CLAUDE.md              ← this file — applies to every screen folder
├── shared/
│   ├── css/
│   │   ├── reset.css
│   │   ├── tokens.css       ← CSS variables (design tokens)
│   │   ├── layout.css       ← device frame, app shell, sidebar, screen, grid
│   │   └── components.css   ← all component styles
│   └── assets/
│       ├── images/
│       │   ├── logo.png     ← app logo (500×220px artboard, transparent PNG)
│       │   └── deco.png     ← background decoration (logomark, transparent PNG)
│       └── icons/
└── <screen-folder>/        ← e.g. Home/soknote-gui-prototype
    ├── index.html          ← links shared/css/*.css and shared/assets/* by relative path
    ├── js/
    │   └── main.js          ← state management & interactions
    ├── screens/
    └── components/
```

When adding a new screen folder, link the shared files the same way
(`../../shared/css/...`, `../../shared/assets/...`) rather than duplicating
them — see [Home/soknote-gui-prototype/index.html](Home/soknote-gui-prototype/index.html)
for the reference pattern.

---

## HTML Rules

- Semantic HTML
- HTML and CSS always separated
- No inline styles
- Meaningful class names (BEM-like: `block__element--modifier`)
- Avoid unnecessary nesting
- All UI text in Korean (target audience: Korean users)

---

## CSS Rules

- Always use CSS variables — never hardcode colors, spacing, radius, or font sizes
- No hover effects on sidebar nav items (tablet environment)
- Shadows only for menus, dropdowns, dialogs

---

## JavaScript Rules

Only for UI interaction: Sidebar Toggle · Search Open/Close · Overflow Menu · Sort Dropdown · Dialog · Dropdown · Accordion

Do NOT implement application logic.

---

## Workflow Rules

**Always work one component at a time.**

Never regenerate an entire page when only one component changes.

---

## Scope Control Rules

Only modify the component explicitly requested. Do not change global layout, navigation, typography, colors, spacing, or other components unless explicitly instructed.

---

## Persistent Working Rules

Unless explicitly instructed otherwise:
- Preserve the existing design system
- Preserve the current visual language
- Preserve spacing, typography, color, and component architecture rules
- Never redesign unrelated areas
- Never regenerate the entire application
- Focus only on the requested component

---

## Output Rules

- Separate HTML and CSS
- Keep files modular
- Write clean, readable code
- Use reusable class names
- Avoid unnecessary complexity
- Make the result suitable for Flutter developer handoff
