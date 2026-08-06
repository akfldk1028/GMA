# SPEC-SP-001: Acceptance Criteria

## Metadata

| Field       | Value                                         |
|-------------|-----------------------------------------------|
| SPEC ID     | SPEC-SP-001                                   |
| Title       | SecPlan Workspace Transformation              |
| Created     | 2026-03-15                                    |
| Status      | Approved                                      |

---

## Quality Gates

- All acceptance criteria verified
- `dart analyze --no-fatal-infos` passes with zero errors
- `flutter test` passes for all new and modified test files
- No regressions in existing workspace functionality
- Code generation (`build_runner`) completes without errors

---

## AC-01: Dual Panel Layout

```gherkin
Given the workspace screen is loaded with a PDF
When the screen renders on desktop
Then a left panel (PDF Viewer) and right panel (Scrapnote Canvas) are displayed
And a draggable divider separates the two panels
And the default width ratio is 50:50
```

## AC-02: Panel Resize

```gherkin
Given the dual-panel layout is displayed
When the user drags the panel divider to the right
Then the left panel width increases and the right panel width decreases
And the ratio is constrained between 25% and 75% per panel
```

## AC-03: Panel Swap

```gherkin
Given the dual-panel layout is displayed with PDF on left and Scrapnote on right
When the user taps the Swap button in the header
Then the PDF moves to the right panel and the Scrapnote moves to the left panel
And a smooth animation (200ms) accompanies the transition
```

## AC-04: Panel Maximize

```gherkin
Given the dual-panel layout is displayed
When the user taps the Maximize button for the left panel
Then the left panel expands to full width
And the right panel is hidden
And the Maximize button changes to a Restore icon
```

## AC-05: Panel Restore

```gherkin
Given the left panel is maximized to full width
When the user taps the Restore button
Then the dual-panel layout returns at the previous width ratio
And a smooth animation (200ms) accompanies the transition
```

## AC-06: Layout Persistence

```gherkin
Given the user has resized panels to 60:40 ratio and swapped positions
When the user navigates away and returns to the same document
Then the panels restore to 60:40 ratio with swapped positions
```

## AC-07: Scrapnote Canvas as Right Panel

```gherkin
Given the workspace screen is loaded
When the screen renders
Then the right panel displays the Scrapnote Canvas (not LiveScrapsPanel)
And pen drawing is available on the Scrapnote Canvas
And existing captures/highlights from the current PDF are visible
```

---

## AC-08: Header Back Navigation

```gherkin
Given the workspace screen is displayed
When the user taps the Back button (<) in the header
Then the app navigates to the dashboard screen
```

## AC-09: Header Title Display

```gherkin
Given a PDF document is loaded
When the header renders
Then the document title is displayed in the header
And the title is derived from the PDF filename (without extension)
```

## AC-10: Header Title Editing

```gherkin
Given the document title is displayed in the header
When the user taps the title text
Then the title becomes an editable text field
When the user types a new title and presses Enter
Then the title is updated and persisted
```

## AC-11: Panel Controls in Header

```gherkin
Given the workspace screen is displayed
When the header renders
Then Swap, Resize indicator, and Maximize/Restore buttons are visible
And each button triggers the corresponding panel management action
```

## AC-12: Note View Toggle

```gherkin
Given the dual-panel layout is displayed
When the user taps the Note View icon in the header
Then the right panel (Scrapnote) visibility toggles
And the icon state reflects the current visibility
```

---

## AC-13: Tab Bar Display

```gherkin
Given two or more PDFs are open
When the tab bar renders
Then each open PDF has a tab showing its filename
And each tab has a close (X) button
And an add (+) button appears at the end
```

## AC-14: Tab Switching

```gherkin
Given three PDFs are open (A, B, C) with tab A active
When the user taps tab B
Then the PDF Viewer switches to display PDF B
And the Scrapnote Canvas loads the scrapnote linked to PDF B
And the sidebar updates to show items from PDF B
```

## AC-15: Tab Close

```gherkin
Given three PDFs are open (A, B, C) with tab B active
When the user taps the close (X) button on tab B
Then tab B is removed from the tab bar
And the PDF Viewer switches to the nearest tab (A or C)
And associated resources are cleaned up
```

## AC-16: Tab Add

```gherkin
Given at least one PDF is open
When the user taps the add (+) button
Then a file picker dialog opens for PDF selection
When the user selects a PDF file
Then a new tab is added to the tab bar
And the PDF Viewer loads the selected PDF
```

## AC-17: Single Tab Suppression

```gherkin
Given only one PDF is open
When the workspace screen renders
Then the tab bar is not displayed
When a second PDF is opened
Then the tab bar appears showing both tabs
```

---

## AC-18: Sidebar Filter Tabs

```gherkin
Given the left sidebar is visible
When the sidebar renders
Then filter tabs (All, Capture, Highlight, Pen) are displayed at the top
And the "All" filter is selected by default
```

## AC-19: Sidebar Item List - All

```gherkin
Given a PDF has 3 captures, 2 highlights, and 1 pen group
When the "All" filter is selected
Then all 6 items are listed: C-1, C-2, C-3, H-1, H-2, P-1
And captures show thumbnail previews
And highlights show text snippets
```

## AC-20: Sidebar Filter - Capture

```gherkin
Given a PDF has 3 captures and 2 highlights
When the user selects the "Capture" filter tab
Then only capture items (C-1, C-2, C-3) are displayed
And each shows a thumbnail preview
```

## AC-21: Sidebar Filter - Highlight

```gherkin
Given a PDF has 3 captures and 2 highlights
When the user selects the "Highlight" filter tab
Then only highlight items (H-1, H-2) are displayed
And each shows a text snippet
```

## AC-22: Sidebar Item Navigation

```gherkin
Given the sidebar shows item C-2 from page 5 of the PDF
When the user taps C-2
Then the PDF Viewer navigates to page 5
And the captured region is scrolled into view
```

## AC-23: Sidebar Toggle

```gherkin
Given the sidebar is visible (expanded at 200px width)
When the user taps the sidebar toggle button
Then the sidebar collapses with a slide animation
And the panel area expands to fill the freed space
When the user taps the toggle again
Then the sidebar expands back to 200px
```

---

## AC-24: Kebab Menu Display

```gherkin
Given the workspace screen is displayed
When the user taps the kebab (3-dot) icon in the header
Then a popup menu appears with items:
  | Search |
  | Cover Settings |
  | Page Template |
  | Page Settings |
  | Save as File |
  | Info |
And bottom action icons: Bookmark, Share, Export, Delete
```

## AC-25: Kebab Search

```gherkin
Given the kebab menu is open
When the user selects "Search"
Then the menu closes
And a search overlay appears on the PDF viewer
And the user can type search text to find in the PDF
```

## AC-26: Kebab Stub Items

```gherkin
Given the kebab menu is open
When the user selects "Cover Settings" or "Page Template" or "Page Settings" or "Info"
Then a toast notification displays "Coming Soon"
```

## AC-27: Kebab Bottom Actions

```gherkin
Given the kebab menu is open
When the user taps the Delete bottom action
Then a confirmation dialog appears
When the user confirms deletion
Then the current document is deleted and the workspace navigates to dashboard
```

---

## AC-28: Toolbar Always Visible

```gherkin
Given the workspace screen is loaded with a PDF
When the screen renders
Then the drawing toolbar is visible below the header
And it is visible regardless of whether drawing is active
```

## AC-29: Toolbar Panel Awareness

```gherkin
Given the toolbar is visible and the user taps inside the left panel (PDF)
When the user selects the Pen tool and draws
Then pen strokes appear on the PDF overlay
Given the user then taps inside the right panel (Scrapnote)
When the user draws with the same Pen tool
Then pen strokes appear on the Scrapnote Canvas
```

## AC-30: Toolbar Capture Button

```gherkin
Given the toolbar is visible
When the user taps the Capture button
Then the PDF Viewer enters rectangle selection mode
When the user drags a rectangle on the PDF
Then the capture confirmation popup appears (SPEC-SCRAPNOTE-001 flow)
```

## AC-31: Toolbar Highlight Button

```gherkin
Given the toolbar is visible
When the user taps the Highlight button
Then the PDF Viewer enters text highlight selection mode
When the user selects text on the PDF
Then the highlight confirmation popup appears (SPEC-SCRAPNOTE-001 flow)
```

## AC-32: Active Panel Indicator

```gherkin
Given the toolbar is visible
When the user clicks inside the left panel
Then the toolbar shows a visual indicator that the left panel is active
When the user clicks inside the right panel
Then the indicator changes to show the right panel is active
```

---

## Definition of Done

- [ ] All 32 acceptance criteria pass manual verification
- [ ] New Freezed models generate correctly with `build_runner`
- [ ] New Riverpod providers generate correctly with `riverpod_generator`
- [ ] `dart analyze` reports zero errors
- [ ] `flutter test` passes all tests
- [ ] No regressions in existing PDF viewer, drawing, or scrapnote functionality
- [ ] Panel layout persists correctly across app restarts
- [ ] Mobile layout degrades gracefully (single panel with sheets)
- [ ] Performance: panel resize maintains 60fps on desktop
- [ ] Toolbar correctly routes input to the focused panel

---

## Verification Methods

| Method | Scope | Tools |
|--------|-------|-------|
| Unit Testing | Provider logic, state transitions | flutter_test, mockito |
| Widget Testing | Widget rendering, interactions | flutter_test, WidgetTester |
| Integration Testing | Tab switch flow, capture flow | flutter_test |
| Manual Testing | Visual layout, animations, UX | Desktop app |
| Static Analysis | Code quality, type safety | dart analyze |
| Code Generation | Model and provider generation | build_runner |

---

## Traceability

| AC | Requirement | Milestone |
|----|------------|-----------|
| AC-01 to AC-07 | R-01 Panel Management | M1 |
| AC-08 to AC-12 | R-02 Header Redesign | M2 |
| AC-13 to AC-17 | R-03 Multi-PDF Tab Bar | M4 |
| AC-18 to AC-23 | R-04 Left Sidebar | M5 |
| AC-24 to AC-27 | R-05 Kebab Menu | M6 |
| AC-28 to AC-32 | R-06 Toolbar Unification | M3 |
