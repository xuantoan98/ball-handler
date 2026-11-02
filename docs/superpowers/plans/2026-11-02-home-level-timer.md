# Home, Level Gate and 60 Second Attempt Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the approved v2 home and first-run guide, browsable locked levels, and a persistent 60-second attempt timer in the existing Flutter app.

**Architecture:** Keep `GamePage` as session owner and isolate decorative home UI in a focused widget. `GameAttempt` owns gameplay time, while `LivesService` commits remaining milliseconds and intro state with save schema migration. Existing `TheatreButton` and `TheatrePanel` render live controls over the approved decorative art.

**Tech Stack:** Flutter/Dart, `shared_preferences`, Flutter tests, Android SDK.

**Spec:** `docs/superpowers/specs/2026-11-02-home-level-timer-design.md` (approved v2).

## Global Constraints

- Flutter `lib/` code serves Android and web.
- 60 seconds per attempt; timeout loses one life; Reset and app restart keep remaining time.
- Browse 1–20 freely; Play only for `index <= highestUnlocked`.
- Home opens each app launch; guide appears only for a fresh writable save.
- Preserve uncommitted M7 work and do not publish or push.

## Review Focus

- Old v1/v2 saves with an active attempt resume at 60 seconds and do not re-show the guide.
- Failed timer/intro save does not falsely report a committed state.
- Timeout and win at the same tick resolve once as timeout.
- App background and home stop elapsed gameplay time.
- A locked level cannot start via direct service call.

---

### Task 1: Attempt timer

**Files:** `lib/core/rules.dart`, `test/core/rules_test.dart`.

- [ ] Add failing tests for exact 60-second timeout, same-tick exit priority, pause, reset preserving remaining time, retry creating a new 60-second attempt.
- [ ] Run `flutter test test/core/rules_test.dart` and confirm the new cases fail for missing behavior.
- [ ] Add `remainingMs`, `resetPuzzle()` and timer-aware `tick()`; keep `retry()` for a new attempt after a terminal result.
- [ ] Run core tests green.

### Task 2: Save and progression gate

**Files:** `lib/services/save_service.dart`, `lib/services/lives_service.dart`, `test/services/m3_services_test.dart`.

- [ ] Add failing tests for schema 3 migration, fresh intro, intro acknowledgement, locked start, timer save/reload and failed writes.
- [ ] Run service tests red.
- [ ] Add `introSeen` and `attemptRemainingMs` to `SaveRecord`; add `SessionResult.locked`, `setIntroSeen()`, `setAttemptRemainingMs()` to `LivesService`; initialize active timer at 60000 and clear it at terminal/abandon.
- [ ] Run service tests green.

### Task 3: Home and game UI

**Files:** `lib/game/home_screen.dart` (new), `lib/main.dart`, `pubspec.yaml`, `test/widget_test.dart`, `assets/...` approved home art.

- [ ] Add failing widget tests for home on launch, first-run guide once, browse locked level with disabled Play, active resume and timer semantics.
- [ ] Run widget tests red.
- [ ] Implement home art as decorative background and live Flutter text/buttons/popup with kit components; wire home state, level gate, timer save, countdown ring and final ten-second pulse.
- [ ] Run widget tests green at 390×844 and 360×800.

### Task 4: Verify and record

**Files:** `docs/PRODUCT.md`, `docs/PLAN.md`, `docs/DECISIONS.md`, `docs/PROGRESS.md`, `docs/QA.md`.

- [ ] Update product/plan decisions from the owner's explicit answers and record v2 design approval.
- [ ] Run `dart format`, `flutter analyze`, `flutter test`, `flutter build web`, and `flutter build apk --debug`; record actual outcomes.
- [ ] If Android device available, install/run and inspect home/guide/locked/time behavior; record what was actually observed.
- [ ] Review final diff for M7 preservation and no accidental publish.

## Execution record — 02/11/2026

Tasks 1–4 implemented inline. Red tests were observed for the missing attempt timer, save gate/schema, home/locked UI, HUD badge placement, restored preview notice, pulse timing and popup save-error overflow, then turned green. Final commands: `dart format lib test` (0 changes), `flutter analyze` (no issues), `flutter test` (69 pass), `flutter build web` (pass), `flutter build apk --debug` (pass), `git diff --check` (pass). Redmi install and visual smoke are recorded in `docs/QA.md`; fresh-save device checks confirmed the first-run popup, disabled Play and 60-second timeout loss. The visible 10-second pulse has only automated timing coverage. Original device save was restored with matching SHA-256. No push, release upload or public publication.
