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
      label: 'Còn $seconds giây trong tối đa 60 giây của màn này. Tạm dừng',
      child: Stack(
        key: const Key('attempt-timer'),
        children: [
          Positioned.fill(
            child: TheatreButton(
              label: '${seconds}s',
              onPressed: onPause,
              leading: Icons.pause,
              tone: TheatreButtonTone.outline,
            ),
          ),
          Positioned(
            left: 7,
            right: 7,
            bottom: 6,
            height: 4,
            child: IgnorePointer(
              child: LinearProgressIndicator(
                value: (remainingMs / 60000).clamp(0, 1),
                backgroundColor: StageColors.frameEdge,
                color: timerPulseActive(remainingMs)
                    ? StageColors.goldCore
                    : StageColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
