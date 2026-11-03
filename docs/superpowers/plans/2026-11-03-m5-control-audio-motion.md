# M5 Control, Audio and Motion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver the approved ornate lamp desk, CC0 music/SFX with a saved mute control, and restrained home/stage/win/loss motion in the existing Flutter app.

**Architecture:** Keep `GameAttempt` as the only gameplay state. A visual-only desk image sits under the Canvas lamp, a central audio controller owns a small set of asset players, and a visual-effects controller reads phase/event changes without changing collision. `GamePage` coordinates lifecycle, save, UI, and one-shot cues.

**Tech Stack:** Flutter 3.47.7, Dart 3.13.5, `audioplayers` 6.x, local WebP/audio assets; Android and web from `lib/`.

**Spec:** `docs/superpowers/specs/2026-11-03-m5-control-audio-motion-design.md`

## Global Constraints

- M5 only. Keep x49..341/y694..782 lamp travel, current touch radius, 20 level rules, 60-second limit, save format, ads adapter, and result persistence.
- No fixed lamp in the production desk bitmap; no UI text or apparent collision objects in it.
- CC0 audio files only, with original source URL, author, license, edits and checksums in `docs/ASSETS.md`.
- Respect platform reduced motion; no decorative haptic/particles/parallax when disabled. No public release/push.

## Review Focus

- Fast repeated collision input: one haptic/SFX/particle sequence and one saved loss.
- Background/resume while music is playing: pause/resume at most one loop and honor saved mute.
- Web autoplay restriction: first gesture unlocks audio without a broken player state.
- Reset/preview/retry during an effect: old effect is cancelled and no gameplay state changes.
- Narrow mobile viewport: desk art does not occlude lamp, reset, or title.

---

### Task 1: Production desk and movable lamp

**Files:** Create `assets/controls/lamp-desk-v3.webp`; modify `pubspec.yaml`, `lib/game/game_painter.dart`, `docs/ASSETS.md`; test `test/game/game_painter_test.dart`.

**Interfaces:** `GamePainter` accepts decoded `ui.Image? deskBackdrop` beside stage `backdrop`; render static desk art before a Flutter Canvas lamp at `attempt.lamp`.

- [ ] Write a painter test asserting the art does not change lamp hit geometry and a game board renders at both target widths.
- [ ] Run the focused test to see the missing desk asset/interface failure.
- [ ] Export an empty-center WebP from the approved preview using imagegen, inspect it, and add it as a Flutter asset. Keep the lamp separate and enhance its layered sun/pressed halo.
- [ ] Run focused painter/drag tests and inspect a Redmi screenshot for corner reach and art readability.
- [ ] Commit only desk, painter, test, and provenance files.

### Task 2: Local CC0 audio and saved mute

**Files:** Create `lib/services/game_audio.dart`, `assets/audio/*`, audio license/provenance file; modify `pubspec.yaml`, `lib/main.dart`, `lib/game/home_screen.dart`, `docs/ASSETS.md`; test `test/services/game_audio_test.dart`, `test/widget_test.dart`.

**Interfaces:** `GameAudio` exposes `setEnabled(bool)`, `setForeground(bool)`, `setMusicActive(bool)`, `play(GameSound)`, `dispose()`; `GamePage` uses `LivesService.setSoundEnabled(bool)` for persistence. Inject a fake audio controller in widget tests as needed.

- [ ] Add failing tests for mute persistence, repeated sound dedupe, lifecycle/ad pause, and button semantics on home/pause.
- [ ] Run focused tests and confirm the intended failures.
- [ ] Choose/listen to the CC0 loop and concise SFX, store only selected files, add `audioplayers`, implement central controller and volume rules, connect toggle in home/pause.
- [ ] Run focused tests and Android/web audio smoke; record browser first-gesture behavior.
- [ ] Commit audio, UI toggle, tests, license and provenance.

### Task 3: Event cues, haptic and result effect

**Files:** Create `lib/game/result_effect.dart`; modify `lib/main.dart`, `lib/game/game_painter.dart`; test `test/game/result_effect_test.dart`, `test/widget_test.dart`.

**Interfaces:** `ResultEffect` takes a one-shot `AttemptPhase` transition and `reducedMotion` flag, exposes visual progress/particles to painter, and never changes `GameAttempt`. `GamePage` triggers `HapticFeedback.mediumImpact` once after a successfully saved collision loss on Android.

- [ ] Write failing tests for one-shot win/loss cues, timeout/no haptic, reset cancellation, reduced motion and unchanged collision state.
- [ ] Run focused tests and confirm failure.
- [ ] Implement 12–20 seeded gold/lilac paper particles confined to stage for 500–700ms, mint win pulse and brief coral loss border; synchronize sounds with state transitions and save success for haptic.
- [ ] Run focused tests, inspect win/loss on Redmi, and ensure terminal save still runs once.
- [ ] Commit effects and tests.

### Task 4: Home and stage entrance motion, integration QA

**Files:** Modify `lib/game/home_screen.dart`, `lib/main.dart`, `docs/PROGRESS.md`, `docs/QA.md`; test `test/widget_test.dart`.

**Interfaces:** Decorative `AnimationController`/tweens only; home buttons remain operable from first frame, first-run intro follows entrance. Stage objects appear with exact gameplay state. Reduced motion yields static state.

- [ ] Add widget tests for entrance completion, immediate tap access, first-run intro and reduced motion.
- [ ] Run focused tests and confirm failure.
- [ ] Implement staggered home fade/6–10px rise and short stage frame/panel reveal; stop ornamental tickers in pause/background.
- [ ] Run `dart format lib test`, `flutter analyze`, `flutter test`, `flutter build web`, `flutter build apk --debug`; test Android device with saved data protected, record actual commands/results and frame timing where feasible.
- [ ] Run `git diff --check`, review all changed files, and commit scoped final QA/docs changes.
