import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_tokens.dart';

/// Paints inside [bounds], which is also the exact gameplay exit rectangle.
/// The soft halo is decorative; neither it nor the foliage changes collision.
void paintMoonDoor(
  Canvas canvas,
  Rect bounds, {
  required bool open,
  required bool holding,
  required double holdProgress,
  required double pulse,
}) {
  final w = bounds.width;
  final h = bounds.height;
  final frame = bounds.deflate(1);
  final inner = Rect.fromLTRB(
    frame.left + w * .09,
    frame.top + h * .09,
    frame.right - w * .09,
    frame.bottom - h * .07,
  );
  final framePath = _arch(frame);
  final innerPath = _arch(inner);
  final glow = open ? StageColors.mint : const Color(0xFF769B9A);
  final twinkle = .86 + .14 * math.sin(pulse * math.pi * 2);

  canvas.drawPath(
    framePath,
    Paint()
      ..color = Colors.black.withValues(alpha: .65)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
  );
  canvas.drawPath(
    framePath,
    Paint()
      ..color = glow.withValues(alpha: open ? .34 * twinkle : .12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  );
  canvas.drawPath(
    framePath,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF704A28), StageColors.goldCore, StageColors.goldEdge],
        stops: [0, .47, 1],
      ).createShader(frame),
  );

  canvas.drawPath(
    innerPath,
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: open
            ? const [Color(0xFF071F2D), Color(0xFF0B4A46), Color(0xFF28715A)]
            : const [Color(0xFF111E2E), Color(0xFF254445), Color(0xFF38544D)],
      ).createShader(inner),
  );
  canvas.drawPath(
    innerPath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF0B2735),
  );
  canvas.drawPath(
    framePath,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = StageColors.goldEdge,
  );
  canvas.drawPath(
    _arch(frame.deflate(2.8)),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .75
      ..color = StageColors.goldCore.withValues(alpha: .86),
  );

  canvas.save();
  canvas.clipPath(innerPath);
  final moonCenter = Offset(bounds.center.dx + w * .025, bounds.top + h * .54);
  final radius = math.min(w * .31, h * .28);
  final outer = Path()
    ..addOval(Rect.fromCircle(center: moonCenter, radius: radius));
  final cutout = Path()
    ..addOval(
      Rect.fromCircle(
        center: moonCenter.translate(-radius * .43, -radius * .28),
        radius: radius * .94,
      ),
    );
  final crescent = Path.combine(PathOperation.difference, outer, cutout);
  canvas.drawPath(
    crescent,
    Paint()
      ..color = StageColors.mint.withValues(alpha: open ? .62 * twinkle : .18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
  );
  canvas.drawPath(
    crescent,
    Paint()..color = open ? const Color(0xFF8AFFD9) : const Color(0xFF789D99),
  );
  canvas.drawPath(
    crescent,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = open ? const Color(0xFFD5FFE8) : const Color(0xFF9AB6AA),
  );

  for (final speck in <(double, double, double)>[
    (.24, .37, 1.0),
    (.76, .29, .8),
    (.73, .72, .7),
    (.32, .77, .65),
  ]) {
    canvas.drawCircle(
      Offset(bounds.left + w * speck.$1, bounds.top + h * speck.$2),
      speck.$3,
      Paint()..color = StageColors.goldCore.withValues(alpha: open ? .75 : .36),
    );
  }
  canvas.restore();

  // The pendant star visually marks the entrance rather than the goal area.
  final starCenter = Offset(bounds.center.dx, bounds.top + h * .13);
  canvas.drawLine(
    Offset(starCenter.dx, bounds.top + 1),
    starCenter.translate(0, -h * .045),
    Paint()
      ..color = StageColors.goldCore.withValues(alpha: .8)
      ..strokeWidth = .85,
  );
  final star = _star(starCenter, w * .11);
  canvas.drawPath(
    star,
    Paint()
      ..color = StageColors.goldCore.withValues(alpha: .72 * twinkle)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  );
  canvas.drawPath(star, Paint()..color = StageColors.goldCore);

  _foliage(canvas, bounds, left: true);
  _foliage(canvas, bounds, left: false);
  canvas.drawLine(
    Offset(bounds.left + 3, bounds.bottom - 2),
    Offset(bounds.right - 3, bounds.bottom - 2),
    Paint()
      ..color = StageColors.goldCore
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round,
  );

  if (!open) {
    _lock(canvas, Offset(bounds.center.dx, bounds.bottom - h * .13), w);
  } else if (holding) {
    final rail = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        bounds.left + w * .18,
        bounds.bottom - h * .085,
        w * .64,
        3.5,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(rail, Paint()..color = const Color(0xFF102B2E));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rail.left,
          rail.top,
          rail.width * holdProgress.clamp(0.0, 1.0),
          rail.height,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = StageColors.goldCore,
    );
  }
}

Path _arch(Rect r) {
  final w = r.width;
  final h = r.height;
  return Path()
    ..moveTo(r.left, r.bottom)
    ..lineTo(r.left, r.top + h * .23)
    ..cubicTo(
      r.left + w * .03,
      r.top + h * .10,
      r.center.dx - w * .16,
      r.top + h * .025,
      r.center.dx,
      r.top,
    )
    ..cubicTo(
      r.center.dx + w * .16,
      r.top + h * .025,
      r.right - w * .03,
      r.top + h * .10,
      r.right,
      r.top + h * .23,
    )
    ..lineTo(r.right, r.bottom)
    ..close();
}

Path _star(Offset center, double radius) {
  final path = Path();
  for (var i = 0; i < 16; i++) {
    final angle = -math.pi / 2 + i * math.pi / 8;
    final r = i.isEven ? radius : radius * .23;
    final point = Offset(
      center.dx + math.cos(angle) * r,
      center.dy + math.sin(angle) * r,
    );
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

void _foliage(Canvas canvas, Rect bounds, {required bool left}) {
  final baseX = left
      ? bounds.left + bounds.width * .14
      : bounds.right - bounds.width * .14;
  final direction = left ? 1.0 : -1.0;
  final baseY = bounds.bottom - bounds.height * .04;
  final stem = Paint()
    ..color = const Color(0xFF79B884)
    ..strokeWidth = 1.25
    ..strokeCap = StrokeCap.round;
  canvas.drawLine(
    Offset(baseX, baseY),
    Offset(baseX + direction * bounds.width * .16, baseY - bounds.height * .23),
    stem,
  );
  for (final leaf in <(double, double, double)>[
    (0, -.19, -.08),
    (.08, -.14, .13),
    (.15, -.23, .09),
    (.18, -.08, .16),
  ]) {
    final at = Offset(
      baseX + direction * bounds.width * leaf.$1,
      baseY + bounds.height * leaf.$2,
    );
    final tip = Offset(
      at.dx + direction * bounds.width * leaf.$3,
      at.dy - bounds.height * .075,
    );
    final path = Path()
      ..moveTo(at.dx, at.dy)
      ..quadraticBezierTo(at.dx - direction * 4, at.dy - 6, tip.dx, tip.dy)
      ..quadraticBezierTo(at.dx + direction * 7, at.dy - 4, at.dx, at.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF77B685));
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFC0D994).withValues(alpha: .65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .55,
    );
  }
}

void _lock(Canvas canvas, Offset center, double width) {
  final lockWidth = width * .17;
  final body = RRect.fromRectAndRadius(
    Rect.fromCenter(center: center, width: lockWidth, height: lockWidth * .7),
    const Radius.circular(1.5),
  );
  canvas.drawArc(
    Rect.fromCenter(
      center: center.translate(0, -lockWidth * .34),
      width: lockWidth * .59,
      height: lockWidth * .7,
    ),
    math.pi,
    math.pi,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = StageColors.goldCore,
  );
  canvas.drawRRect(body, Paint()..color = StageColors.goldEdge);
  canvas.drawCircle(center, 1, Paint()..color = const Color(0xFF2C382F));
}
