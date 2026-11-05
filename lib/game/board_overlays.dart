import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design_tokens.dart';
import '../services/rewarded_ads.dart';
import 'board_action_button.dart';
import 'game_language.dart';
import 'theatre_components.dart';

class MockAdOverlay extends StatelessWidget {
  const MockAdOverlay({
    super.key,
    required this.scale,
    required this.language,
    required this.ads,
    required this.onCancel,
  });

  final double scale;
  final GameLanguage language;
  final MockRewardedAds ads;
  final VoidCallback onCancel;

  String _t(String value) => language.text(value);

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: StageColors.background.withValues(alpha: .78),
      child: Center(
        child: SizedBox(
          width: 330 * scale,
          height: 285 * scale,
          child: TheatrePanel(
            child: Padding(
              padding: EdgeInsets.all(24 * scale),
              child: AnimatedBuilder(
                animation: ads,
                builder: (context, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t('Quảng cáo mô phỏng'),
                      style: TextStyle(
                        color: StageColors.goldCore,
                        fontSize: 21 * scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _t(switch (ads.phase) {
                        AdPhase.loading => 'Đang tải…',
                        AdPhase.saving => 'Đang lưu thưởng…',
                        _ => 'Xem đủ 5 giây để nhận +1 lượt.',
                      }),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StageColors.text,
                        fontSize: 15 * scale,
                      ),
                    ),
                    LinearProgressIndicator(
                      value: ads.progress,
                      color: StageColors.mint,
                      backgroundColor: StageColors.frameEdge,
                    ),
                    Text(
                      ads.phase == AdPhase.saving
                          ? _t('Đang lưu')
                          : '${(5 - ads.progress * 5).ceil().clamp(0, 5)} ${_t('giây')}',
                      style: TextStyle(
                        color: StageColors.goldCore,
                        fontSize: 15 * scale,
                      ),
                    ),
                    SizedBox(
                      height: 46 * scale,
                      width: double.infinity,
                      child: BoardActionButton(
                        label: ads.phase == AdPhase.saving
                            ? 'Đang lưu thưởng…'
                            : 'Đóng · không nhận lượt',
                        language: language,
                        onPressed: ads.phase == AdPhase.saving
                            ? null
                            : onCancel,
                      ),
                    ),
                    if (kDebugMode && ads.phase != AdPhase.saving)
                      TextButton(
                        onPressed: ads.failForDebug,
                        child: Text(_t('Giả lập lỗi tải')),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class StatusOverlay extends StatelessWidget {
  const StatusOverlay({
    super.key,
    required this.scale,
    required this.language,
    required this.ready,
    required this.readOnly,
    required this.loadError,
    required this.onRecover,
  });

  final double scale;
  final GameLanguage language;
  final bool ready;
  final bool readOnly;
  final String? loadError;
  final VoidCallback onRecover;

  String _t(String value) => language.text(value);

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: StageColors.background.withValues(alpha: .82),
      child: Center(
        child: SizedBox(
          width: 340 * scale,
          height: 230 * scale,
          child: TheatrePanel(
            child: Padding(
              padding: EdgeInsets.all(22 * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    _t(
                      !ready && loadError == null
                          ? 'Đang đọc phiên chơi…'
                          : readOnly
                          ? 'Tab chỉ đọc'
                          : 'Không mở được dữ liệu lưu',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StageColors.goldCore,
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    _t(
                      readOnly
                          ? 'Một tab khác đang chơi. Đóng tab đó rồi tải lại để tiếp tục.'
                          : loadError ?? 'Vui lòng đợi một chút.',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: StageColors.text,
                      fontSize: 14 * scale,
                    ),
                  ),
                  if (loadError != null && !readOnly)
                    SizedBox(
                      height: 48 * scale,
                      width: double.infinity,
                      child: BoardActionButton(
                        label: 'Đặt lại dữ liệu lỗi',
                        language: language,
                        onPressed: onRecover,
                        primary: true,
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
