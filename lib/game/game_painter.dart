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
import 'result_effect.dart';
import 'game_language.dart';

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
    this.language = GameLanguage.vi,
    this.backdrop,
    this.deskBackdrop,
    this.resultEffect,
    this.reducedMotion = false,
  }) : super(repaint: animation);

  final GameAttempt attempt;
  final bool pressed;
  final ui.Image? backdrop;
  final ui.Image? deskBackdrop;
  final ResultEffect? resultEffect;
  final bool reducedMotion;
  final Animation<double> animation;
  final Stopwatch motionClock;
  final int lastMovementMs;
  final Offset travelDirection;
  final int lives;
  final GameLanguage language;

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
      _paintBackdrop(canvas, backdrop!, _stageRect);
      canvas.restore();
    }
    canvas.save();
    canvas.clipRect(_stageRect);
    _objects(canvas);
    _shadow(canvas);
    _paintResultEffect(canvas);
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

  void _paintResultEffect(Canvas canvas) {
    final effect = resultEffect;
    if (effect == null || !effect.active || !effect.visualsEnabled) return;
    final progress = effect.progressAt(effect.elapsed);
    if (progress >= 1) return;
    final exit = _wall(attempt.level.exit);
    if (effect.phase == AttemptPhase.won) {
      final burst = math.sin(progress * math.pi).clamp(0.0, 1.0);
      for (final (index, color) in [
        StageColors.mint,
        StageColors.goldCore,
      ].indexed) {
        final radius = 10 + progress * (65 + index * 36);
        canvas.drawOval(
          exit.inflate(radius),
          Paint()
            ..color = color.withValues(alpha: burst * (.7 - index * .16))
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3 - index.toDouble(),
        );
      }
      for (var i = 0; i < 12; i++) {
        final angle = i * math.pi / 6 + progress * .15;
        final direction = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(
          exit.center + direction * (38 + progress * 48),
          exit.center + direction * (52 + progress * 95),
          Paint()
            ..color = StageColors.goldCore.withValues(alpha: burst * .75)
            ..strokeCap = StrokeCap.round
            ..strokeWidth = i.isEven ? 2.5 : 1.5,
        );
      }
      for (final particle in effect.particles) {
        final position =
            exit.center +
            Offset(particle.dx * progress, particle.dy * progress);
        final size = particle.radius * (1 - progress * .65);
        final paint = Paint()
          ..color =
              (particle.gold ? StageColors.goldCore : StageColors.lilacLight)
                  .withValues(alpha: 1 - progress);
        if (particle.gold) {
          canvas.drawPath(
            Path()
              ..moveTo(position.dx, position.dy - size)
              ..lineTo(position.dx + size * .55, position.dy)
              ..lineTo(position.dx, position.dy + size)
              ..lineTo(position.dx - size * .55, position.dy)
              ..close(),
            paint,
          );
        } else {
          canvas.drawCircle(position, size, paint);
        }
      }
      final bannerOpacity =
          ((progress - .12) / .22).clamp(0.0, 1.0) *
          ((1 - progress) / .18).clamp(0.0, 1.0);
      if (bannerOpacity > 0) {
        final banner = Rect.fromCenter(
          center: Offset(_stageRect.center.dx, _stageRect.top + 55),
          width: 224 + burst * 12,
          height: 48,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(banner, const Radius.circular(13)),
          Paint()
            ..color = StageColors.ink.withValues(alpha: .86 * bannerOpacity),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(banner, const Radius.circular(13)),
          Paint()
            ..color = StageColors.goldCore.withValues(alpha: bannerOpacity)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        final title = TextPainter(
          text: TextSpan(
            text: language.text('✦  HOÀN THÀNH!  ✦'),
            style: TextStyle(
              fontFamily: 'Nunito',
              color: StageColors.cream.withValues(alpha: bannerOpacity),
              fontWeight: FontWeight.w900,
              fontSize: 21,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        title.paint(
          canvas,
          Offset(
            banner.center.dx - title.width / 2,
            banner.center.dy - title.height / 2,
          ),
        );
      }
    } else if (effect.collisionHaptic) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          _stageRect.deflate(2),
          const Radius.circular(6),
        ),
        Paint()
          ..color = StageColors.coral.withValues(alpha: (1 - progress) * .65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  /// Keep the illustrated top/bottom proscenium at its native proportions.
  /// Only the quiet central wall is shortened to fit the gameplay viewport.
  void _paintBackdrop(Canvas canvas, ui.Image image, Rect destination) {
    final width = image.width.toDouble();
    final height = image.height.toDouble();
    final scale = destination.width / width;
    final visibleHeight = destination.height / scale;
    final basePaint = Paint()..filterQuality = FilterQuality.medium;
    if (visibleHeight >= height) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, width, height),
        destination,
        basePaint,
      );
      return;
    }
    final join = visibleHeight * .54;
    final fade = math.min(80.0, visibleHeight * .1);
    final fadeStart = join - fade / 2;
    final lowerSourceStart = height - (visibleHeight - fadeStart);
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, lowerSourceStart, width, height),
      Rect.fromLTRB(
        destination.left,
        destination.top + fadeStart * scale,
        destination.right,
        destination.bottom,
      ),
      basePaint,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, width, fadeStart),
      Rect.fromLTRB(
        destination.left,
        destination.top,
        destination.right,
        destination.top + fadeStart * scale,
      ),
      basePaint,
    );
    const strips = 16;
    for (var i = 0; i < strips; i++) {
      final sourceTop = fadeStart + fade * i / strips;
      final sourceBottom = fadeStart + fade * (i + 1) / strips;
      final alpha = (1 - (i + .5) / strips).clamp(0.0, 1.0);
      canvas.drawImageRect(
        image,
        Rect.fromLTRB(0, sourceTop, width, sourceBottom),
        Rect.fromLTRB(
          destination.left,
          destination.top + sourceTop * scale,
          destination.right,
          destination.top + sourceBottom * scale,
        ),
        Paint()
          ..filterQuality = FilterQuality.medium
          ..color = Colors.white.withValues(alpha: alpha),
      );
    }
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
      _paintDanger(c, _wall(hazard));
    }
    for (final hazard in attempt.movingHazardBounds) {
      _paintDanger(c, _wall(hazard), moving: true);
    }

    for (final solid in attempt.level.solids) {
      final box = _wall(solid);
      _round(c, box, 5, StageColors.ink);
      _stroke(c, box, 5, StageColors.goldEdge, 2);
      _stroke(c, box.deflate(4), 3, StageColors.frameEdge, 1);
      for (double y = box.top + 11; y < box.bottom - 5; y += 18) {
        _line(
          c,
          Offset(box.left + 5, y),
          Offset(box.right - 5, y),
          StageColors.frameEdge.withValues(alpha: .65),
          1.5,
        );
      }
      for (final point in [
        box.topLeft + const Offset(5, 5),
        box.topRight + const Offset(-5, 5),
        box.bottomLeft + const Offset(5, -5),
        box.bottomRight + const Offset(-5, -5),
      ]) {
        _circle(c, point, 1.5, StageColors.gold);
      }
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

    for (var i = 0; i < attempt.level.gates.length; i++) {
      final gate = attempt.level.gates[i];
      final box = _wall(gate);
      if (attempt.isGateOpen(i)) {
        _line(
          c,
          Offset(box.center.dx, box.top),
          Offset(box.center.dx, box.bottom),
          StageColors.mint.withValues(alpha: .45),
          2,
        );
        if (attempt.level.gateWindowSeconds != null) {
          final progress =
              (attempt.gateWindowRemaining / attempt.level.gateWindowSeconds!)
                  .clamp(0.0, 1.0);
          final ring = Rect.fromCircle(
            center: Offset(box.center.dx, box.top + 19),
            radius: 11,
          );
          c.drawArc(
            ring,
            -math.pi / 2,
            math.pi * 2 * progress,
            false,
            Paint()
              ..color = StageColors.mint
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = 3,
          );
        }
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
          language.text('KHÓA'),
          box.left - 14,
          box.center.dy - 38,
          12,
          StageColors.cream,
        );
      }
    }
  }

  void _paintDanger(Canvas c, Rect box, {bool moving = false}) {
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
    if (moving) {
      _stroke(c, box.deflate(3), 2, StageColors.cream, 1);
      _text(
        c,
        '↕',
        box.center.dx - 7,
        box.center.dy - 11,
        18,
        StageColors.cream,
      );
    } else {
      _text(
        c,
        '!',
        box.center.dx - 5,
        box.center.dy - 15,
        28,
        StageColors.cream,
      );
    }
  }

  void _shadow(Canvas c) {
    final box = _wall(attempt.shadow);
    _puppet(
      c,
      box,
      activity: reducedMotion
          ? 0
          : PuppetMotion.activity(
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
      const Rect.fromLTWH(181, 580, 28, 42),
      activity: reducedMotion
          ? 0
          : PuppetMotion.activity(
              motionClock.elapsedMilliseconds,
              lastMovementMs,
            ),
      direction: travelDirection,
    );
    final plaque = const Rect.fromLTWH(154, 622, 82, 16);
    _round(c, plaque, 4, StageColors.gold);
    _stroke(c, plaque, 4, StageColors.goldEdge, 1);
    _text(
      c,
      language.text('Bóng Mơ'),
      168,
      622,
      11,
      StageColors.darkText,
      maxWidth: 65,
    );
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
    final artBox = box.deflate(2);
    c.drawOval(
      Rect.fromCenter(
        center: artBox.center + const Offset(0, 3),
        width: artBox.width * .82,
        height: artBox.height * .8,
      ),
      Paint()
        ..color = StageColors.gold.withValues(alpha: .24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // The animated silhouette stays inside the exact collision rectangle.
    c.clipRect(box);
    final left = artBox.left;
    final top = artBox.top;
    final w = artBox.width;
    final h = artBox.height;
    for (var i = 0; i < 2; i++) {
      final anchor = left + w * (.38 + i * .22);
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
    final cape = Path()
      ..moveTo(left + w * .36, top + h * .54)
      ..quadraticBezierTo(
        left + w * .18,
        top + h * .55,
        left + w * .04,
        top + h * .88,
      )
      ..quadraticBezierTo(
        left + w * .22,
        top + h * .82,
        left + w * .27,
        top + h * .95,
      )
      ..quadraticBezierTo(
        left + w * .42,
        top + h * .84,
        left + w * .5,
        top + h * .94,
      )
      ..quadraticBezierTo(
        left + w * .64,
        top + h * .85,
        left + w * .77,
        top + h * .95,
      )
      ..quadraticBezierTo(
        left + w * .85,
        top + h * .75,
        left + w * .97,
        top + h * .83,
      )
      ..quadraticBezierTo(
        left + w * .8,
        top + h * .58,
        left + w * .65,
        top + h * .54,
      )
      ..close();
    c.drawPath(cape, Paint()..color = StageColors.shadow);
    c.drawPath(
      cape,
      Paint()
        ..color = StageColors.frameEdge.withValues(alpha: .9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9,
    );
    _circle(
      c,
      Offset(left + w * .08, top + h * .65),
      w * .065,
      StageColors.shadow,
    );
    _circle(
      c,
      Offset(left + w * .92, top + h * .65),
      w * .065,
      StageColors.shadow,
    );
    final head = Rect.fromLTWH(left + w * .1, top + h * .14, w * .8, h * .53);
    c.drawOval(head, Paint()..color = StageColors.shadow);
    c.drawOval(
      head,
      Paint()
        ..color = StageColors.goldEdge.withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .8,
    );
    final crown = Path()
      ..moveTo(left + w * .15, top + h * .22)
      ..lineTo(left + w * .11, top + h * .045)
      ..lineTo(left + w * .34, top + h * .125)
      ..lineTo(left + w * .43, top)
      ..lineTo(left + w * .61, top + h * .105)
      ..lineTo(left + w * .85, top + h * .035)
      ..lineTo(left + w * .8, top + h * .24)
      ..close();
    c.drawPath(crown, Paint()..color = StageColors.gold);
    c.drawPath(
      crown,
      Paint()
        ..color = StageColors.goldEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    for (final x in [.36, .65]) {
      final eye = Offset(left + w * x, top + h * .4);
      _circle(c, eye, w * .085, StageColors.goldCore);
    }
    c.restore();
  }

  void _desk(Canvas c) {
    if (deskBackdrop != null && attempt.phase != AttemptPhase.preview) {
      c.save();
      c.clipRRect(
        RRect.fromRectAndRadius(_deskRect, const Radius.circular(18)),
      );
      c.drawImageRect(
        deskBackdrop!,
        Rect.fromLTWH(
          0,
          0,
          deskBackdrop!.width.toDouble(),
          deskBackdrop!.height.toDouble(),
        ),
        _deskRect,
        Paint()..filterQuality = FilterQuality.medium,
      );
      c.restore();
      _lamp(c);
      return;
    }
    _round(c, _deskRect, 18, StageColors.frame);
    _stroke(c, _deskRect, 18, StageColors.goldEdge, 2);
    _stroke(
      c,
      _deskRect.deflate(4),
      15,
      StageColors.gold.withValues(alpha: .48),
      1,
    );
    _curl(c, const Offset(23, 671));
    _curl(c, const Offset(367, 671), mirror: true);
    _curl(c, const Offset(23, 808));
    _curl(c, const Offset(367, 808), mirror: true);
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
    for (final x in [48.0, 342.0]) {
      for (final y in [709.0, 775.0]) {
        _star(c, Offset(x, y), 4, StageColors.goldEdge);
      }
    }
    for (var i = 0; i <= 12; i++) {
      final x = 78.0 + i * 19.5;
      _circle(
        c,
        Offset(x, 693),
        i == 6 ? 2.2 : 1,
        StageColors.goldEdge.withValues(alpha: .8),
      );
      _circle(
        c,
        Offset(x, 787),
        i == 6 ? 2.2 : 1,
        StageColors.goldEdge.withValues(alpha: .8),
      );
    }
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
    _lamp(c);
  }

  void _lamp(Canvas c) {
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
    _circle(c, center, 18, StageColors.goldCore);
    _circle(c, center, 12, StageColors.gold);
    _circle(c, center, 7, StageColors.goldCore);
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
      _star(
        c,
        center + Offset(math.cos(a) * 25, math.sin(a) * 25),
        2.6,
        StageColors.goldCore,
      );
    }
    _text(
      c,
      language.text('Kéo đèn · Dẫn bóng về cửa'),
      84,
      814,
      14,
      StageColors.cream,
    );
  }

  void _hud(Canvas c) {
    _round(c, _headerRect, 13, StageColors.ink);
    _stroke(c, _headerRect, 13, StageColors.goldEdge, 1.7);
    _stroke(c, _headerRect.deflate(4), 9, StageColors.frameEdge, 1);
    _round(c, const Rect.fromLTWH(22, 15, 126, 36), 8, StageColors.frame);
    _stroke(
      c,
      const Rect.fromLTWH(22, 15, 126, 36),
      8,
      StageColors.goldEdge,
      1,
    );
    _round(c, const Rect.fromLTWH(246, 15, 121, 36), 8, StageColors.frame);
    _stroke(
      c,
      const Rect.fromLTWH(246, 15, 121, 36),
      8,
      StageColors.goldEdge,
      1,
    );
    _text(
      c,
      '${language.text('MÀN')} ${attempt.level.id.toString().padLeft(2, '0')}',
      30,
      17,
      12,
      StageColors.goldCore,
      maxWidth: 110,
    );
    _text(
      c,
      language.text(attempt.level.title),
      30,
      33,
      10,
      StageColors.text,
      maxWidth: 110,
    );
    for (var i = 0; i < 3; i++) {
      _lifeLantern(c, Offset(260.0 + i * 19, 33), i < lives);
    }
    _text(c, '$lives/3', 322, 25, 13, StageColors.cream, maxWidth: 40);
    final message = attempt.feedback.isEmpty
        ? attempt.level.hint
        : attempt.feedback;
    _round(c, _statusRect, 7, StageColors.cream);
    _stroke(c, _statusRect, 7, StageColors.goldEdge, 1.6);
    _star(c, const Offset(29, 81), 2, StageColors.goldEdge);
    _star(c, const Offset(361, 81), 2, StageColors.goldEdge);
    _text(
      c,
      language.text(message),
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
