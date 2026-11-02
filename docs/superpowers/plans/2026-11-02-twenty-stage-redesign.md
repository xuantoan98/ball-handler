# Twenty-Stage Theatre Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship 20 distinct, progressively harder Flutter levels with the approved home-quality theatre art, Bóng Mơ and lamp desk, while keeping gameplay and collision legible.

**Architecture:** `Level` and `GameAttempt` own all static/dynamic collision and timing; `GamePainter` renders that state. Twenty hand-authored levels use a deterministic replay and one unique decorative stage background each. Keep all interactive objects code-drawn; bitmap art is decorative only.

**Tech Stack:** Flutter 3.47.7, Dart 3.13.5, CustomPainter, existing pure-Dart rules/validator and image assets.

**Spec:** `docs/superpowers/specs/2026-11-02-twenty-stage-redesign-design.md`

## Global Constraints

- Shared `lib/` code for Android and web; retain save IDs, level unlocks, lives, 60-second attempts and M7 ad logic.
- One lamp/one shadow with `S = 3P − 2L`; wall 360×480; door requires full shadow for 1 second.
- Danger coral loses, ink/brass solid stops, mint star/door interacts; visible geometry matches collision.
- Pause/background freezes all clocks and moving objects; reset restores puzzle but retains remaining attempt time.
- No public release or ad-live integration. No claims of user playtest without evidence.

## Review Focus

- A moving danger crossing a stationary shadow must lose once, including a large elapsed tick (Task 1).
- A timed gate expiring while overlapped or during exit hold must behave as in the spec, without trapping the shadow (Task 1).
- A fast lamp drag cannot skip solid blockers, moving danger, or a closed gate (Task 1).
- Every authored level must replay within 60 seconds with room for a human drag, not merely a zero-time teleport (Task 2).
- Decorations must not read as hazards, switches or walkable platforms; inspect actual Android renders (Tasks 3–5).

---

### Task 1: Deterministic obstacle and gate rules

**Files:** Modify `lib/core/level.dart`, `lib/core/rules.dart`, `lib/core/level_validator.dart`; tests in `test/core/rules_test.dart`, `test/core/level_validator_test.dart`.

**Interfaces:** `Level` gains `solids: List<Rect2>`, `movingHazards: List<MovingHazard>`, `gateWindowSeconds: double?`, `solutionSteps: List<SolutionStep>` while retaining v1 decode. `MovingHazard` has bounds, travel delta and period; `SolutionStep` is move or wait. `GameAttempt` exposes current moving bounds and gate window remaining; painter consumes them.

- [ ] Add failing tests for solid swept stop and no life loss; moving hazard contact on drag and while stationary; pause freeze; deterministic reset; timed gate expiry/overlap/exit hold; fast drag precedence.
- [ ] Run targeted tests and confirm failures are missing behavior.
- [ ] Implement schema v2 and pure-Dart rules with fixed-step or analytic contact resolution; preserve old level behavior.
- [ ] Run targeted and full suite green; validate JSON v1 migration and editor compatibility.
- [ ] Commit rules and tests.

### Task 2: Twenty hand-authored puzzles and replay

**Files:** Modify `lib/core/level_catalog.dart`, `lib/core/level_validator.dart`, `data/m4_levels.json`, `docs/M4_LEVEL_SCHEMA.md`; tests in `test/core/level_catalog_test.dart` and existing M4 tests.

**Interfaces:** Catalog remains `m4Levels` with IDs 1–20 for app/save compatibility. Validator executes `solutionSteps` with elapsed time and checks all 20 wins before 60 seconds.

- [ ] Add failing catalog tests for 20 unique scene/puzzle signatures, progressive introduction at 04/08/13/17 and time-aware replay.
- [ ] Run test red.
- [ ] Author 20 layouts with varied solid clusters, coral hazards, moving shutters, ordered stars, timed gates and a safe reference route for each; keep visible clearances generous.
- [ ] Run catalog validation, `dart run tool/export_levels.dart`, targeted/full tests; inspect replay timings.
- [ ] Commit levels and schema docs.

### Task 3: Bóng Mơ and lamp desk

**Files:** Modify `lib/game/game_painter.dart`, `lib/game/board_ui_layout.dart`, `lib/design_tokens.dart`; optional focused new painter files; tests in `test/game/`.

**Interfaces:** Painter draws the same 36×54 visible silhouette/hitbox unless rules intentionally change both. Desk keeps `SandboxGeometry.controlCenters` x49..341/y694..782 and a small movable sun knob.

- [ ] Add failing painter/widget tests for asset-independent character bounds, desk drag extremes and visual semantics of solid/moving/timed objects.
- [ ] Run tests red.
- [ ] Build Bóng Mơ matching approved home concept and the ornate but usable lilac/brass desk; draw all gameplay objects from actual bounds/state.
- [ ] Run tests and inspect rendered 360×800/390×844 frames; correct overpaint and readability.
- [ ] Commit painter and tests.

### Task 4: Twenty distinct stage backdrops

**Files:** Create `assets/backgrounds/stage-01-v2.webp` … `stage-20-v2.webp`; modify stage asset selection in `lib/main.dart`, `docs/ASSETS.md`; add a focused asset test.

**Interfaces:** Stage background lookup is total for level IDs 1–20, no fallback to repeating the old three images. Images have no interactive objects or text and are clipped to the stage wall.

- [ ] Add failing asset mapping/load test for all 20 IDs.
- [ ] Run test red.
- [ ] Generate distinct paper-cut backgrounds from approved home/UI Kit reference, central low-detail wall and chapter-specific edge scenery; inspect each, save versioned WebPs, record prompt/source.
- [ ] Wire asset loading and run targeted/full tests, web build and Android debug build.
- [ ] Commit assets, mapping and documentation.

### Task 5: Device review and evidence

**Files:** Modify `docs/QA.md`, `docs/PROGRESS.md`, `docs/DECISIONS.md`; save screenshots under `docs/qa/twenty-stages/`.

- [ ] Run `dart format lib test`, `flutter analyze`, `flutter test`, `dart run tool/export_levels.dart`, `flutter build web`, `flutter build apk --debug`, `git diff --check`; record exact outcomes.
- [ ] If Redmi remains connected, install APK, capture representative stages across all chapters, test one-finger drag and timed/moving behavior without altering original save permanently; record what was actually observed.
- [ ] Review diff for M7/save preservation and no publish; update QA and progress with limitations, especially unplayed levels.
- [ ] Request one whole-branch code review and fix important findings; commit evidence/docs.

## Execution record

Tasks 1–4 implemented in local `develop` commits `2fe28c2`, `e23e799`, `c51ad2d`, `95f6ab5`; review fixes and evidence follow. Final local checks: 84/84 Flutter tests, clean analyze, 20 validated levels, web and Android debug builds. Seven representative boards were rendered through Flutter test at 390×844; Android device QA and human playtest remain open because `adb devices -l` was empty. No public release or push.
