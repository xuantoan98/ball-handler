import 'package:flutter/material.dart';

import '../design_tokens.dart';
import 'game_language.dart';
import 'theatre_components.dart';

class IntroOverlay extends StatelessWidget {
  const IntroOverlay({
    super.key,
    required this.language,
    required this.busy,
    required this.onAcknowledgeIntro,
    this.notice,
  });
  final GameLanguage language;
  final bool busy;
  final VoidCallback? onAcknowledgeIntro;
  final String? notice;
  String _t(String value) => language.text(value);

  @override
  Widget build(BuildContext context) => Positioned.fill(
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
}

class SettingsPopup extends StatelessWidget {
  const SettingsPopup({
    super.key,
    required this.language,
    required this.soundBusy,
    required this.onCloseSettings,
    required this.onSelectLanguage,
    this.notice,
  });
  final GameLanguage language;
  final bool soundBusy;
  final VoidCallback onCloseSettings;
  final ValueChanged<GameLanguage> onSelectLanguage;
  final String? notice;
  String _t(String value) => language.text(value);

  @override
  Widget build(BuildContext context) => Positioned.fill(
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
