import 'package:flutter/material.dart';

import '../core/geometry.dart';
import '../core/level.dart';
import '../core/rules.dart';
import '../design_tokens.dart';
import 'board_action_button.dart';
import 'board_ui_layout.dart';
import 'entrance_motion.dart';
import 'game_language.dart';
import 'theatre_components.dart';

class ResultPanel extends StatelessWidget {
  const ResultPanel({
    super.key,
    required this.map,
    required this.attempt,
    required this.levelIndex,
    required this.highestUnlocked,
    required this.lives,
    required this.readOnly,
    required this.ready,
    required this.busy,
    required this.saveFailed,
    required this.language,
    required this.onBeginAttempt,
    required this.onSelectLevel,
    required this.onRetrySave,
    required this.onResume,
    required this.onShowPreview,
    this.notice,
  });
  final ViewportMapper map;
  final GameAttempt attempt;
  final int levelIndex;
  final int highestUnlocked;
  final int lives;
  final bool readOnly;
  final bool ready;
  final bool busy;
  final bool saveFailed;
  final String? notice;
  final GameLanguage language;
  final ValueChanged<int> onBeginAttempt;
  final ValueChanged<int> onSelectLevel;
  final VoidCallback onRetrySave;
  final VoidCallback onResume;
  final VoidCallback onShowPreview;

  Widget _action(
    String label,
    VoidCallback? onPressed, {
    bool small = false,
    bool primary = false,
  }) => BoardActionButton(
    label: label,
    language: language,
    onPressed: onPressed,
    small: small,
    primary: primary,
  );

  Widget _placed(
    ViewportMapper map,
    double x,
    double y,
    double w,
    double h,
    Widget child,
  ) => Positioned(
    left: map.offsetX + x * map.scale,
    top: map.offsetY + y * map.scale,
    width: w * map.scale,
    height: h * map.scale,
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final phase = attempt.phase;
    final title = saveFailed
        ? 'Chưa lưu kết quả'
        : switch (phase) {
            AttemptPhase.preview => attempt.level.title,
            AttemptPhase.paused => 'Tạm dừng',
            AttemptPhase.won => 'Qua cửa trăng!',
            AttemptPhase.lost =>
              attempt.remainingMs == 0 ? 'Hết 60 giây' : 'Bóng chạm vùng đỏ',
            AttemptPhase.playing => '',
          };
    final defaultDetail = switch (phase) {
      AttemptPhase.preview =>
        levelIndex > highestUnlocked
            ? 'Qua màn ${levelIndex.toString().padLeft(2, '0')} để mở.'
            : attempt.level.hint,
      AttemptPhase.paused => 'Đồng hồ ván đã dừng. Tiếp tục khi sẵn sàng.',
      AttemptPhase.won => 'Giữ toàn bộ bóng trong cửa đủ một giây.',
      AttemptPhase.lost =>
        attempt.remainingMs == 0
            ? 'Hết giờ tính thua. Thử lại với 60 giây mới.'
            : 'Thử đường khác để tránh cảm biến.',
      AttemptPhase.playing => '',
    };
    final detail = busy && phase != AttemptPhase.preview
        ? 'Đang lưu phiên chơi…'
        : notice ?? defaultDetail;
    final scale = map.scale;
    final preview = phase == AttemptPhase.preview;
    return _placed(
      map,
      preview ? BoardUiLayout.preview.left : 30,
      preview ? BoardUiLayout.preview.top : 251,
      preview ? BoardUiLayout.preview.width : 330,
      preview ? BoardUiLayout.preview.height : 278,
      EntranceMotion(
        key: ValueKey('panel-$phase'),
        child: TheatrePanel(
          compact: preview,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              (preview ? 12 : 18) * scale,
              (preview ? 22 : 62) * scale,
              (preview ? 12 : 18) * scale,
              (preview ? 11 : 20) * scale,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language.text(title),
                  key: const Key('panel-title'),
                  textAlign: TextAlign.center,
                  maxLines: preview ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: StageColors.goldCore,
                    fontSize: (preview ? 17 : 22) * scale,
                    fontWeight: FontWeight.w900,
                    shadows: const [
                      Shadow(color: StageColors.goldEdge, blurRadius: 8),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    language.text(detail),
                    textAlign: TextAlign.center,
                    maxLines: preview ? 2 : 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: StageColors.secondaryText,
                      fontSize: (preview ? 14 : 15) * scale,
                      height: preview ? 1.08 : 1.2,
                    ),
                  ),
                ),
                if (preview)
                  SizedBox(
                    height: 49 * scale,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _action(
                            levelIndex > highestUnlocked
                                ? 'Chưa mở'
                                : lives == 0
                                ? 'Hết lượt'
                                : 'Bắt đầu',
                            !ready ||
                                    busy ||
                                    readOnly ||
                                    lives == 0 ||
                                    levelIndex > highestUnlocked
                                ? null
                                : () => onBeginAttempt(levelIndex),
                            primary: true,
                          ),
                        ),
                        SizedBox(width: 7 * scale),
                        Expanded(
                          child: _action(
                            'Màn trước',
                            busy || levelIndex == 0
                                ? null
                                : () => onSelectLevel(levelIndex - 1),
                            small: true,
                          ),
                        ),
                        SizedBox(width: 7 * scale),
                        Expanded(
                          child: _action(
                            'Màn sau',
                            busy || levelIndex == m4Levels.length - 1
                                ? null
                                : () => onSelectLevel(levelIndex + 1),
                            small: true,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  SizedBox(
                    height: 49 * scale,
                    width: double.infinity,
                    child: _action(
                      saveFailed
                          ? 'Thử lưu lại'
                          : switch (phase) {
                              AttemptPhase.paused => 'Tiếp tục',
                              AttemptPhase.won =>
                                levelIndex < m4Levels.length - 1
                                    ? 'Màn tiếp theo'
                                    : 'Chơi lại',
                              AttemptPhase.lost => 'Thử lại',
                              _ => '',
                            },
                      busy
                          ? null
                          : saveFailed
                          ? onRetrySave
                          : switch (phase) {
                              AttemptPhase.paused => onResume,
                              AttemptPhase.won =>
                                levelIndex < m4Levels.length - 1
                                    ? () => onBeginAttempt(levelIndex + 1)
                                    : () => onBeginAttempt(levelIndex),
                              AttemptPhase.lost => () => onBeginAttempt(
                                levelIndex,
                              ),
                              _ => null,
                            },
                      primary: true,
                    ),
                  ),
                  SizedBox(
                    height: 43 * scale,
                    child: Row(
                      children: [
                        Expanded(
                          child: _action(
                            'Xem màn',
                            busy || saveFailed ? null : onShowPreview,
                            small: true,
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: _action(
                            phase == AttemptPhase.paused ? 'Bỏ ván' : 'Thử lại',
                            busy || saveFailed
                                ? null
                                : phase == AttemptPhase.paused
                                ? onShowPreview
                                : () => onBeginAttempt(levelIndex),
                            small: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
