import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_tokens.dart';
import 'game_language.dart';
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
    required this.language,
    required this.settingsVisible,
    required this.onOpenSettings,
    required this.onCloseSettings,
    required this.onSelectLanguage,
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
  final GameLanguage language;
  final bool settingsVisible;
  final VoidCallback? onOpenSettings;
  final VoidCallback onCloseSettings;
  final ValueChanged<GameLanguage> onSelectLanguage;

  String _t(String value) => language.text(value);

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
        right: 86,
        top: 48,
        width: 50,
        height: 50,
        child: TheatreButton(
          label: _t('Cài đặt'),
          icon: Icons.settings,
          onPressed: busy || soundBusy ? null : onOpenSettings,
          tone: TheatreButtonTone.outline,
        ),
      ),
      Positioned(
        right: 29,
        top: 48,
        width: 50,
        height: 50,
        child: SoundButton(
          enabled: soundEnabled,
          language: language,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _t('RẠP BÓNG NHỎ'),
                  maxLines: 1,
                  style: TextStyle(
                    color: StageColors.text,
                    fontSize: language == GameLanguage.en ? 21 : 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _t('Một ngọn đèn. Cả thế giới chuyển động.'),
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
            label: _t('Chơi ngay'),
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
            label: _t('Xem màn'),
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
                  ? '$lives / 3 ${_t('lượt')}'
                  : '$lives / 3 ${_t('lượt')}  ·  ${_clock(refill!)}',
              style: const TextStyle(
                color: StageColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
      if (notice != null && !introVisible && !settingsVisible)
        Positioned(
          left: 36,
          top: 553,
          width: 318,
          child: Text(
            _t(notice!),
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
      if (settingsVisible && !introVisible) _settingsPopup(),
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
                  Text(
                    _t('Cách chơi'),
                    style: TextStyle(
                      color: StageColors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _GuideLine(_t('Kéo đèn để dẫn bóng\nvề cửa trăng.')),
                  const SizedBox(height: 20),
                  _GuideLine(_t('Tránh vùng đỏ, bật sao\ntheo thứ tự.')),
                  const SizedBox(height: 20),
                  _GuideLine(_t('Mỗi lượt có 60 giây.\nTạm dừng sẽ dừng giờ.')),
                  Expanded(
                    child: Center(
                      child: notice == null
                          ? const SizedBox.shrink()
                          : Text(
                              _t(notice!),
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
                      label: _t('Đã hiểu'),
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

  Widget _settingsPopup() => Positioned.fill(
    child: ColoredBox(
      color: const Color(0xD90B1029),
      child: Center(
        child: SizedBox(
          key: const Key('settings-popup'),
          width: 334,
          height: 370,
          child: TheatrePanel(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.settings, color: StageColors.goldCore),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _t('Cài đặt'),
                          style: const TextStyle(
                            color: StageColors.text,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: _t('Đóng'),
                        onPressed: soundBusy ? null : onCloseSettings,
                        icon: const Icon(Icons.close),
                        color: StageColors.lilacLight,
                      ),
                    ],
                  ),
                  const Divider(color: StageColors.goldEdge, height: 22),
                  Text(
                    _t('Ngôn ngữ'),
                    style: const TextStyle(
                      color: StageColors.goldCore,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _t('Chọn ngôn ngữ hiển thị'),
                    style: const TextStyle(color: StageColors.secondaryText),
                  ),
                  const SizedBox(height: 15),
                  for (final option in GameLanguage.values) ...[
                    SizedBox(
                      height: 54,
                      child: TheatreButton(
                        label:
                            '${option.displayName}  ${language == option ? '✓' : ''}',
                        onPressed: soundBusy
                            ? null
                            : () => onSelectLanguage(option),
                        tone: language == option
                            ? TheatreButtonTone.gold
                            : TheatreButtonTone.lilac,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const Spacer(),
                  if (soundBusy)
                    Text(
                      _t('Đang lưu cài đặt…'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: StageColors.goldCore),
                    ),
                  if (notice != null)
                    Text(
                      _t(notice!),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        color: StageColors.text,
                        fontSize: 12,
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
    this.language = GameLanguage.vi,
  });
  final bool enabled;
  final VoidCallback? onPressed;
  final GameLanguage language;

  @override
  Widget build(BuildContext context) => IconButton.filledTonal(
    tooltip: language.text(enabled ? 'Tắt âm thanh' : 'Bật âm thanh'),
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
