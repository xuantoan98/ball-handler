import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/rules.dart';
import '../design_tokens.dart';
import 'board_ui_layout.dart';
import 'moon_door_painter.dart';
import 'puppet_motion.dart';

/// The same wall rectangles used by GameAttempt are drawn without extra padding.
class GamePainter extends CustomPainter {
  GamePainter({
    required this.attempt,
    required this.pressed,
    required this.animation,
    required this.motionClock,
    required this.lastMovementMs,
    required this.travelDirection,
    required this.lives,
    this.backdrop,
  }) : super(repaint: animation);

  final GameAttempt attempt;
  final bool pressed;
  final ui.Image? backdrop;
  final Animation<double> animation;
  final Stopwatch motionClock;
  final int lastMovementMs;
  final Offset travelDirection;
  final int lives;

  static const _stageRect = BoardUiLayout.stage;
  static const _headerRect = BoardUiLayout.header;
  static const _statusRect = BoardUiLayout.hint;
  static const _shelfRect = BoardUiLayout.shelf;
  static const _deskRect = BoardUiLayout.desk;

  @override
  void paint(Canvas canvas, Size size) {
    final mapper = ViewportMapper.contain(
      viewportWidth: size.width,
      viewportHeight: size.height,
      boardWidth: SandboxGeometry.boardWidth,
      boardHeight: SandboxGeometry.boardHeight,
    );
    canvas.save();
    canvas.translate(mapper.offsetX, mapper.offsetY);
    canvas.scale(mapper.scale);
    canvas.clipRect(const Rect.fromLTWH(0, 0, 390, 844));
    _round(canvas, const Rect.fromLTWH(0, 0, 390, 844), 15, StageColors.ink);
    _stroke(
      canvas,
      const Rect.fromLTWH(2, 2, 386, 840),
      17,
      StageColors.frameEdge.withValues(alpha: .48),
      1,
    );
    _round(canvas, BoardUiLayout.stageFrame, 10, StageColors.shadow);
    _round(canvas, _stageRect, 6, StageColors.wall);
    if (backdrop == null) {
      _stage(canvas);
    } else {
      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndRadius(_stageRect, const Radius.circular(8)),
      );
      canvas.drawImageRect(
        backdrop!,
        Rect.fromLTWH(
          0,
          0,
          backdrop!.width.toDouble(),
          backdrop!.height.toDouble(),
        ),
        _stageRect,
        Paint()..filterQuality = FilterQuality.medium,
      );
      canvas.restore();
    }
    canvas.save();
    canvas.clipRect(_stageRect);
    _objects(canvas);
    _shadow(canvas);
    canvas.restore();
    _stroke(canvas, _stageRect.inflate(2), 8, StageColors.goldEdge, 1.6);
    _stroke(
      canvas,
      _stageRect.inflate(5),
      10,
      StageColors.frameEdge.withValues(alpha: .85),
      1,
    );
    for (final x in [21.0, 369.0]) {
      for (final y in [108.0, 564.0]) {
        _circle(canvas, Offset(x, y), 2.2, StageColors.gold);
      }
    }
    _shelf(canvas);
    _desk(canvas);
    _hud(canvas);
    if (kDebugMode && const bool.fromEnvironment('showGeometryDebug')) {
      _debug(canvas);
    }
    canvas.restore();
  }

  void _stage(Canvas c) {
    c.save();
    c.clipRect(_stageRect);
    _circle(
      c,
      const Offset(195, 340),
      175,
      StageColors.plum.withValues(alpha: .48),
    );
    _circle(
      c,
      const Offset(195, 340),
      118,
      StageColors.goldCore.withValues(alpha: .04),
    );
    _circle(
      c,
      const Offset(195, 340),
      68,
      StageColors.goldCore.withValues(alpha: .04),
    );
    _circle(c, const Offset(40, 90), 73, StageColors.plum);
    _circle(c, const Offset(346, 81), 76, StageColors.frame);
    for (final star in [
      const Offset(69, 130),
      const Offset(123, 146),
      const Offset(318, 121),
    ]) {
      _star(c, star, 7, StageColors.gold);
      _line(
        c,
        Offset(star.dx, 58),
        Offset(star.dx, star.dy - 9),
        StageColors.goldEdge,
        1,
      );
    }
    c.restore();
  }

  Rect _wall(Rect2 value) {
    final r = SandboxGeometry.wallRectToBoard(value);
    return Rect.fromLTWH(r.left, r.top, r.width, r.height);
  }

  void _objects(Canvas c) {
    final exit = _wall(attempt.level.exit);
    paintMoonDoor(
      c,
      exit,
      open: attempt.gateOpen,
      holding: attempt.insideExit && attempt.phase == AttemptPhase.playing,
      holdProgress: attempt.exitHoldSeconds,
      pulse: animation.value,
    );

    for (final hazard in attempt.level.hazards) {
      final box = _wall(hazard);
      _drop(c, box, 3, const Color(0xFFEF536A), 8, offset: const Offset(0, 4));
      _round(c, box, 2, const Color(0xFF9C3F59));
      c.save();
      c.clipRect(box);
      for (
        double x = box.left - box.height;
        x < box.right + box.height;
        x += 18
      ) {
        _line(
          c,
          Offset(x, box.bottom),
          Offset(x + box.height, box.top),
          const Color(0xFFF4777A),
          7,
        );
      }
      c.restore();
      _stroke(c, box, 2, const Color(0xFFF4777A), 2);
      _text(
        c,
        '!',
        box.center.dx - 5,
        box.center.dy - 15,
        28,
        StageColors.cream,
      );
    }

    for (var i = 0; i < attempt.level.switches.length; i++) {
      final box = _wall(attempt.level.switches[i]);
      final active = i < attempt.activatedSwitches;
      _drop(c, box, box.width / 2, StageColors.mint, 7);
      _circle(
        c,
        box.center,
        math.min(box.width, box.height) / 2,
        active ? StageColors.mint : const Color(0xFF467B86),
      );
      _circle(
        c,
        box.center,
        math.min(box.width, box.height) / 2 - 4,
        StageColors.mintDeep,
      );
      _star(c, box.center, 12, active ? StageColors.mint : StageColors.cream);
    }

    for (final gate in attempt.level.gates) {
      final box = _wall(gate);
      if (attempt.gateOpen) {
        _line(
          c,
          Offset(box.center.dx, box.top),
          Offset(box.center.dx, box.bottom),
          StageColors.mint.withValues(alpha: .45),
          2,
        );
      } else {
        _drop(c, box, 2, StageColors.goldEdge, 7);
        _round(c, box, 2, StageColors.ink);
        _stroke(c, box, 2, StageColors.goldEdge, 2);
        for (double y = box.top + 9; y < box.bottom; y += 21) {
          _line(
            c,
            Offset(box.left + 2, y),
            Offset(box.right - 2, y),
            StageColors.frameEdge,
            3,
          );
        }
        _text(
          c,
          'KHÓA',
          box.left - 14,
          box.center.dy - 38,
          12,
          StageColors.cream,
        );
      }
    }
  }

  void _shadow(Canvas c) {
    final box = _wall(attempt.shadow);
    _puppet(
      c,
      box,
      activity: PuppetMotion.activity(
        motionClock.elapsedMilliseconds,
        lastMovementMs,
      ),
      direction: travelDirection,
    );
  }

  void _shelf(Canvas c) {
    _round(c, _shelfRect, 11, StageColors.ink);
    _stroke(c, _shelfRect, 11, StageColors.goldEdge, 1.4);
    _stroke(c, _shelfRect.deflate(4), 8, StageColors.frameEdge, 1);
    for (final x in [35.0, if (attempt.phase != AttemptPhase.playing) 355.0]) {
      _star(c, Offset(x, 607), 5, StageColors.gold);
    }
    _puppet(
      c,
      const Rect.fromLTWH(176, 583, 38, 38),
      activity: PuppetMotion.activity(
        motionClock.elapsedMilliseconds,
        lastMovementMs,
      ),
      direction: travelDirection,
    );
    final plaque = const Rect.fromLTWH(154, 622, 82, 16);
    _round(c, plaque, 4, StageColors.gold);
    _stroke(c, plaque, 4, StageColors.goldEdge, 1);
    _text(c, 'Bóng Mơ', 168, 622, 11, StageColors.darkText, maxWidth: 65);
  }

  void _puppet(
    Canvas c,
    Rect box, {
    double activity = 0,
    Offset direction = Offset.zero,
  }) {
    final cycle = animation.value;
    c.save();
    c.translate(box.center.dx, box.center.dy);
    c.rotate(-direction.dx * activity * .055);
    c.translate(-box.center.dx, -box.center.dy);
    c.translate(0, PuppetMotion.bob(cycle, activity));
    _drop(c, box, 5, StageColors.gold, 7, offset: const Offset(0, 3));
    final left = box.left;
    final top = box.top;
    final w = box.width;
    final h = box.height;
    for (var i = 0; i < 4; i++) {
      final anchor = left + w * (.25 + i * .165);
      final tip = PuppetMotion.footTip(i, cycle, activity, direction);
      final leg = Path()
        ..moveTo(anchor - 2, top + h * .67)
        ..quadraticBezierTo(
          anchor + tip.dx * .35 - 2,
          top + h * .82,
          anchor + tip.dx - 1,
          top + h * .97 + tip.dy,
        )
        ..quadraticBezierTo(
          anchor + tip.dx + 2,
          top + h * .91 + tip.dy,
          anchor + 2,
          top + h * .67,
        )
        ..close();
      c.drawPath(leg, Paint()..color = StageColors.shadow);
      c.drawPath(
        leg,
        Paint()
          ..color = StageColors.goldEdge.withValues(alpha: .7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
    }
    final silhouette = Path()
      ..moveTo(left + w * .12, top + h * .24)
      ..lineTo(left + w * .08, top + h * .45)
      ..quadraticBezierTo(
        left + w * .02,
        top + h * .72,
        left + w * .2,
        top + h * .74,
      )
      ..quadraticBezierTo(
        left + w * .32,
        top + h * .7,
        left + w * .5,
        top + h * .76,
      )
      ..quadraticBezierTo(
        left + w * .7,
        top + h * .7,
        left + w * .8,
        top + h * .74,
      )
      ..quadraticBezierTo(
        left + w * .99,
        top + h * .72,
        left + w * .88,
        top + h * .24,
      )
      ..quadraticBezierTo(
        left + w * .78,
        top + h * .13,
        left + w * .5,
        top + h * .15,
      )
      ..quadraticBezierTo(
        left + w * .22,
        top + h * .12,
        left + w * .12,
        top + h * .24,
      )
      ..close();
    c.drawPath(silhouette, Paint()..color = StageColors.shadow);
    c.drawPath(
      silhouette,
      Paint()
        ..color = StageColors.goldEdge.withValues(alpha: .7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9,
    );
    final crown = Path()
      ..moveTo(left + w * .2, top + h * .22)
      ..lineTo(left + w * .15, top + h * .05)
      ..lineTo(left + w * .36, top + h * .13)
      ..lineTo(left + w * .46, top)
      ..lineTo(left + w * .62, top + h * .12)
      ..lineTo(left + w * .82, top + h * .04)
      ..lineTo(left + w * .79, top + h * .23)
      ..close();
    c.drawPath(crown, Paint()..color = StageColors.shadow);
    c.drawPath(
      crown,
      Paint()
        ..color = StageColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    for (final x in [.37, .65]) {
      final eye = Offset(left + w * x, top + h * .43);
      _circle(c, eye, w * .075, StageColors.goldCore);
      _circle(c, eye, w * .035, StageColors.gold);
    }
    c.restore();
  }

  void _desk(Canvas c) {
    _round(c, _deskRect, 18, StageColors.frame);
    _stroke(c, _deskRect, 18, StageColors.goldEdge, 2);
    if (attempt.phase != AttemptPhase.preview) {
      _stroke(c, _deskRect.deflate(5), 14, StageColors.frameEdge, 1.5);
    }
    for (final corner in [
      const Offset(25, 672),
      const Offset(365, 672),
      const Offset(25, 818),
      const Offset(365, 818),
    ]) {
      _star(c, corner, 4, StageColors.gold);
    }
    if (attempt.phase == AttemptPhase.preview) return;
    final deskOval = const Rect.fromLTWH(20, 669, 350, 143);
    _drop(c, deskOval, 72, StageColors.ink, 9, offset: const Offset(0, 3));
    c.drawOval(
      deskOval,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            StageColors.lilacLight,
            StageColors.lilac,
            Color(0xFF9A85B9),
          ],
          stops: [0, .72, 1],
        ).createShader(deskOval),
    );
    c.drawOval(
      deskOval.deflate(4),
      Paint()
        ..color = StageColors.cream.withValues(alpha: .45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    c.drawOval(
      deskOval.deflate(1),
      Paint()
        ..color = StageColors.goldEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    _line(
      c,
      const Offset(70, 755),
      const Offset(322, 755),
      StageColors.frame,
      2,
    );
    _line(
      c,
      const Offset(195, 708),
      const Offset(195, 798),
      StageColors.frame,
      2,
    );
    final center = Offset(attempt.lamp.x, attempt.lamp.y);
    c.drawCircle(
      center,
      33,
      Paint()
        ..color = StageColors.gold.withValues(alpha: .24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    _circle(c, center, 28, StageColors.frame);
    _circle(c, center, 26, StageColors.goldEdge);
    _circle(c, center, 23, StageColors.gold);
    _circle(c, center, 12, StageColors.goldCore);
    if (pressed) {
      c.drawCircle(
        center,
        31,
        Paint()
          ..color = StageColors.cream
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    for (var i = 0; i < 8; i++) {
      final a = math.pi * i / 4;
      _line(
        c,
        center + Offset(math.cos(a) * 14, math.sin(a) * 14),
        center + Offset(math.cos(a) * 20, math.sin(a) * 20),
        StageColors.goldEdge,
        2,
      );
    }
    _text(c, 'Kéo đèn · Dẫn bóng về cửa', 84, 814, 14, StageColors.cream);
  }

  void _hud(Canvas c) {
    _round(c, _headerRect, 13, StageColors.ink);
    _stroke(c, _headerRect, 13, StageColors.goldEdge, 1.7);
    _stroke(c, _headerRect.deflate(4), 9, StageColors.frameEdge, 1);
    _curl(c, const Offset(28, 24));
    for (var i = 0; i < 3; i++) {
      _lifeLantern(c, Offset(226.0 + i * 20, 33), i < lives);
    }
    _text(c, '$lives/3', 286, 25, 12, StageColors.cream);
    _text(
      c,
      'MÀN ${attempt.level.id.toString().padLeft(2, '0')}',
      96,
      25,
      16,
      StageColors.text,
    );
    final message = attempt.feedback.isEmpty
        ? attempt.level.hint
        : attempt.feedback;
    _round(c, _statusRect, 7, StageColors.cream);
    _stroke(c, _statusRect, 7, StageColors.goldEdge, 1.6);
    _star(c, const Offset(29, 81), 2, StageColors.goldEdge);
    _star(c, const Offset(361, 81), 2, StageColors.goldEdge);
    _text(
      c,
      message,
      34,
      66,
      12,
      StageColors.darkText,
      maxWidth: 322,
      maxLines: 2,
    );
  }

  void _lifeLantern(Canvas c, Offset center, bool lit) {
    c.save();
    c.translate(center.dx, center.dy);
    final amber = lit ? StageColors.goldCore : StageColors.disabled;
    if (lit) {
      c.drawCircle(
        Offset.zero,
        11,
        Paint()
          ..color = StageColors.gold.withValues(alpha: .38)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
    _line(c, const Offset(0, -12), const Offset(0, -9), amber, 1.4);
    _circle(c, const Offset(0, -12), 1.4, amber);
    final frame = Path()
      ..moveTo(-6, -7)
      ..quadraticBezierTo(0, -11, 6, -7)
      ..lineTo(5, 6)
      ..quadraticBezierTo(0, 9, -5, 6)
      ..close();
    c.drawPath(
      frame,
      Paint()..color = lit ? StageColors.goldEdge : StageColors.frameEdge,
    );
    final paper = Path()
      ..moveTo(-4.2, -5.8)
      ..quadraticBezierTo(0, -8, 4.2, -5.8)
      ..lineTo(3.5, 4.5)
      ..quadraticBezierTo(0, 6.5, -3.5, 4.5)
      ..close();
    c.drawPath(
      paper,
      Paint()..color = lit ? StageColors.goldCore : StageColors.ink,
    );
    if (lit) _circle(c, const Offset(0, -1), 2.3, StageColors.cream);
    _line(c, const Offset(-6.5, 8), const Offset(6.5, 8), amber, 1.4);
    c.restore();
  }

  void _debug(Canvas c) {
    final box = attempt.shadow;
    _text(
      c,
      'L ${attempt.lamp.x.toStringAsFixed(0)},${attempt.lamp.y.toStringAsFixed(0)}  S ${box.left.toStringAsFixed(0)},${box.top.toStringAsFixed(0)}',
      27,
      565,
      11,
      StageColors.cream,
    );
  }

  void _round(Canvas c, Rect r, double radius, Color color) => c.drawRRect(
    RRect.fromRectAndRadius(r, Radius.circular(radius)),
    Paint()..color = color,
  );
  void _drop(
    Canvas c,
    Rect r,
    double radius,
    Color color,
    double blur, {
    Offset offset = Offset.zero,
  }) {
    c.drawRRect(
      RRect.fromRectAndRadius(r.shift(offset), Radius.circular(radius)),
      Paint()
        ..color = color.withValues(alpha: .35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
  }

  void _stroke(Canvas c, Rect r, double radius, Color color, double width) =>
      c.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(radius)),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width,
      );
  void _circle(Canvas c, Offset p, double radius, Color color) =>
      c.drawCircle(p, radius, Paint()..color = color);
  void _line(Canvas c, Offset a, Offset b, Color color, double width) =>
      c.drawLine(
        a,
        b,
        Paint()
          ..color = color
          ..strokeWidth = width,
      );
  void _star(Canvas c, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final r = i.isEven ? radius : radius * .43;
      final p = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    c.drawPath(path..close(), Paint()..color = color);
  }

  void _curl(Canvas c, Offset at, {bool mirror = false}) {
    c.save();
    c.translate(at.dx, at.dy);
    if (mirror) c.scale(-1, 1);
    final path = Path()
      ..moveTo(0, 10)
      ..cubicTo(5, 8, 1, -1, 9, 1)
      ..cubicTo(17, 3, 8, 12, 18, 12)
      ..cubicTo(23, 12, 25, 8, 24, 5);
    c.drawPath(
      path,
      Paint()
        ..color = StageColors.goldEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9
        ..strokeCap = StrokeCap.round,
    );
    _circle(c, const Offset(23, 5), 1.6, StageColors.goldCore);
    c.restore();
  }

  void _text(
    Canvas c,
    String value,
    double x,
    double y,
    double size,
    Color color, {
    double maxWidth = 300,
    int maxLines = 1,
  }) {
    final text = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontFamily: 'Nunito',
          color: color,
          fontSize: size,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth);
    text.paint(c, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
