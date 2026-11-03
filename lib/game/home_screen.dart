import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_tokens.dart';
import 'theatre_components.dart';
import 'entrance_motion.dart';

/// Decorative stage art stays separate from live, accessible Flutter controls.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.lives,
    required this.onPlay,
    required this.onLevels,
    required this.introVisible,
    required this.onAcknowledgeIntro,
    required this.soundEnabled,
    required this.onToggleSound,
    this.soundBusy = false,
    this.refill,
    this.busy = false,
    this.notice,
  });

  final int lives;
  final Duration? refill;
  final VoidCallback? onPlay;
  final VoidCallback? onLevels;
  final bool introVisible;
  final VoidCallback? onAcknowledgeIntro;
  final bool busy;
  final String? notice;
  final bool soundEnabled;
  final VoidCallback? onToggleSound;
  final bool soundBusy;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = math.min(
        constraints.maxWidth / 390,
        constraints.maxHeight / 844,
      );
      return Center(
        child: SizedBox(
          width: 390 * scale,
          height: 844 * scale,
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(width: 390, height: 844, child: _stage(context)),
          ),
        ),
      );
    },
  );

  Widget _stage(BuildContext context) => Stack(
    key: const Key('home-screen'),
    children: [
      const Positioned.fill(
        child: Image(
          image: AssetImage('assets/backgrounds/home-stage-v2.png'),
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        right: 29,
        top: 48,
        width: 50,
        height: 50,
        child: SoundButton(
          enabled: soundEnabled,
          onPressed: busy || soundBusy ? null : onToggleSound,
        ),
      ),
      Positioned(
        left: 38,
        top: 119,
        width: 314,
        height: 102,
        child: EntranceMotion(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: StageColors.background.withValues(alpha: .91),
              border: Border.all(color: StageColors.goldEdge, width: 2.3),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RẠP BÓNG NHỎ',
                  maxLines: 1,
                  style: TextStyle(
                    color: StageColors.text,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Một ngọn đèn. Cả thế giới chuyển động.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: StageColors.lilacLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        left: 61,
        top: 594,
        width: 268,
        height: 60,
        child: EntranceMotion(
          delayFraction: .12,
          child: TheatreButton(
            label: 'Chơi ngay',
            onPressed: busy ? null : onPlay,
            leading: Icons.play_arrow,
            tone: TheatreButtonTone.gold,
          ),
        ),
      ),
      Positioned(
        left: 61,
        top: 668,
        width: 268,
        height: 60,
        child: EntranceMotion(
          delayFraction: .24,
          child: TheatreButton(
            label: 'Xem màn',
            onPressed: busy ? null : onLevels,
            leading: Icons.theaters,
          ),
        ),
      ),
      Positioned(
        left: 85,
        top: 752,
        width: 220,
        height: 39,
        child: TheatrePanel(
          compact: true,
          child: Center(
            child: Text(
              refill == null
                  ? '$lives / 3 lượt'
                  : '$lives / 3 lượt  ·  ${_clock(refill!)}',
              style: const TextStyle(
                color: StageColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
      if (notice != null && !introVisible)
        Positioned(
          left: 36,
          top: 553,
          width: 318,
          child: Text(
            notice!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: StageColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      if (introVisible)
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
              ? Duration.zero
              : const Duration(milliseconds: 600),
          builder: (context, progress, child) =>
              progress < 1 ? const SizedBox.shrink() : _intro(),
        ),
    ],
  );

  Widget _intro() => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xCC0B1029),
      child: Center(
        child: SizedBox(
          key: const Key('intro-popup'),
          width: 334,
          height: 409,
          child: TheatrePanel(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
              child: Column(
                children: [
                  const Text(
                    'Cách chơi',
                    style: TextStyle(
                      color: StageColors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _GuideLine('Kéo đèn để dẫn bóng\nvề cửa trăng.'),
                  const SizedBox(height: 20),
                  const _GuideLine('Tránh vùng đỏ, bật sao\ntheo thứ tự.'),
                  const SizedBox(height: 20),
                  const _GuideLine(
                    'Mỗi lượt có 60 giây.\nTạm dừng sẽ dừng giờ.',
                  ),
                  Expanded(
                    child: Center(
                      child: notice == null
                          ? const SizedBox.shrink()
                          : Text(
                              notice!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: StageColors.text,
                                fontSize: 12,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 59,
                    width: double.infinity,
                    child: TheatreButton(
                      label: 'Đã hiểu',
                      onPressed: busy ? null : onAcknowledgeIntro,
                      tone: TheatreButtonTone.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  String _clock(Duration duration) {
    final seconds = (duration.inMilliseconds / 1000).ceil();
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

class SoundButton extends StatelessWidget {
  const SoundButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: enabled ? 'Tắt âm thanh' : 'Bật âm thanh',
    onPressed: onPressed,
    icon: Icon(enabled ? Icons.volume_up : Icons.volume_off),
    style: IconButton.styleFrom(
      backgroundColor: StageColors.ink,
      foregroundColor: StageColors.goldCore,
      side: const BorderSide(color: StageColors.goldEdge, width: 2),
    ),
  );
}

class _GuideLine extends StatelessWidget {
  const _GuideLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        '✦',
        style: TextStyle(color: StageColors.goldCore, fontSize: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            color: StageColors.text,
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
