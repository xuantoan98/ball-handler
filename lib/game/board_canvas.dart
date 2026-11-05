import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/lamp_drag.dart';
import '../core/rules.dart';
import 'game_language.dart';
import 'game_painter.dart';
import 'result_effect.dart';

class BoardCanvas extends StatelessWidget {
  const BoardCanvas({
    super.key,
    required this.attempt,
    required this.drag,
    required this.backdrop,
    required this.deskBackdrop,
    required this.resultEffect,
    required this.language,
    required this.reducedMotion,
    required this.animation,
    required this.motionClock,
    required this.lastMovementMs,
    required this.travelDirection,
    required this.lives,
    required this.onPointerDown,
    required this.onPointerMove,
    required this.onPointerUp,
    required this.onPointerCancel,
  });

  final GameAttempt attempt;
  final LampDrag drag;
  final ui.Image? backdrop;
  final ui.Image? deskBackdrop;
  final ResultEffect resultEffect;
  final GameLanguage language;
  final bool reducedMotion;
  final Animation<double> animation;
  final Stopwatch motionClock;
  final int lastMovementMs;
  final Offset travelDirection;
  final int lives;
  final PointerDownEventListener onPointerDown;
  final PointerMoveEventListener onPointerMove;
  final PointerUpEventListener onPointerUp;
  final PointerCancelEventListener onPointerCancel;

  @override
  Widget build(BuildContext context) => Listener(
    key: const Key('game-input'),
    behavior: HitTestBehavior.opaque,
    onPointerDown: onPointerDown,
    onPointerMove: onPointerMove,
    onPointerUp: onPointerUp,
    onPointerCancel: onPointerCancel,
    child: Semantics(
      label: language == GameLanguage.vi
          ? 'Sân khấu của Bóng Mơ. Cửa trăng ${attempt.gateOpen ? 'đang mở' : 'đang khóa'}. Kéo đèn vàng bằng một ngón để dẫn bóng.'
          : 'Shadow stage. Moon door ${attempt.gateOpen ? 'open' : 'locked'}. Drag the yellow lamp with one finger to guide the shadow.',
      child: SizedBox.expand(
        child: CustomPaint(
          key: const Key('game-canvas'),
          painter: GamePainter(
            attempt: attempt,
            pressed: drag.activePointer != null,
            backdrop: backdrop,
            deskBackdrop: deskBackdrop,
            resultEffect: resultEffect,
            language: language,
            reducedMotion: reducedMotion,
            animation: animation,
            motionClock: motionClock,
            lastMovementMs: lastMovementMs,
            travelDirection: travelDirection,
            lives: lives,
          ),
        ),
      ),
    ),
  );
}
