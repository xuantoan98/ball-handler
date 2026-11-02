import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_tokens.dart';
import 'theatre_components.dart';

bool timerPulseActive(double remainingMs) =>
    remainingMs <= 10000 && remainingMs > 0 && (remainingMs % 1000) > 750;

/// Remaining attempt time, visually tied to the pause control.
class AttemptTimerButton extends StatelessWidget {
  const AttemptTimerButton({
    super.key,
    required this.remainingMs,
    required this.onPause,
  });

  final double remainingMs;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final seconds = (remainingMs / 1000).ceil().clamp(0, 60);
    return Semantics(
      label: 'Còn $seconds giây trong tối đa 60 giây của màn này',
      child: Stack(
        key: const Key('attempt-timer'),
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 2,
            top: 1,
            width: 58,
            height: 48,
            child: CustomPaint(painter: _ClockRingPainter(remainingMs)),
          ),
          Positioned(
            left: 7,
            top: 5,
            width: 48,
            height: 42,
            child: TheatreButton(
              label: 'Tạm dừng',
              onPressed: onPause,
              icon: Icons.pause,
            ),
          ),
          Positioned(
            left: 2,
            right: 2,
            top: 0,
            height: 17,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: StageColors.ink,
                  border: Border.all(color: StageColors.goldEdge),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    '$seconds/60s',
                    style: const TextStyle(
                      color: StageColors.text,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClockRingPainter extends CustomPainter {
  const _ClockRingPainter(this.remainingMs);
  final double remainingMs;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: math.min(size.width, size.height) / 2 - 2,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2,
      false,
      Paint()
        ..color = StageColors.frameEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    final sweep = math.pi * 2 * (remainingMs / 60000).clamp(0, 1);
    final pulse = timerPulseActive(remainingMs);
    if (pulse) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        sweep,
        false,
        Paint()
          ..color = StageColors.goldCore
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..color = StageColors.gold
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5,
    );
  }

  @override
  bool shouldRepaint(covariant _ClockRingPainter oldDelegate) =>
      oldDelegate.remainingMs != remainingMs;
}
