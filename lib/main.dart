import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'core/geometry.dart';
import 'core/lamp_drag.dart';
import 'core/level.dart';
import 'core/rules.dart';
import 'design_tokens.dart';
import 'game/game_painter.dart';
import 'game/board_ui_layout.dart';
import 'game/theatre_components.dart';
import 'services/lives_service.dart';
import 'services/rewarded_ads.dart';
import 'services/save_service.dart';
import 'services/tab_ownership.dart';

void main() => runApp(const ShadowTheatreApp());

class ShadowTheatreApp extends StatelessWidget {
  const ShadowTheatreApp({
    super.key,
    this.saveStore,
    this.clock,
    this.rewardIds,
    this.tabOwnership,
  });

  final SaveStore? saveStore;
  final GameClock? clock;
  final RewardIdFactory? rewardIds;
  final TabOwnership? tabOwnership;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rạp bóng nhỏ — M2',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Nunito',
      colorScheme: ColorScheme.fromSeed(
        seedColor: StageColors.lilac,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: StageColors.background,
      useMaterial3: true,
    ),
    home: GamePage(
      saveStore: saveStore,
      clock: clock,
      rewardIds: rewardIds,
      tabOwnership: tabOwnership,
    ),
  );
}

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    this.saveStore,
    this.clock,
    this.rewardIds,
    this.tabOwnership,
  });

  final SaveStore? saveStore;
  final GameClock? clock;
  final RewardIdFactory? rewardIds;
  final TabOwnership? tabOwnership;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int _levelIndex = 0;
  late GameAttempt _attempt;
  late LampDrag _drag;
  late final Ticker _ticker;
  late final AnimationController _visualAnimation;
  final Stopwatch _motionClock = Stopwatch()..start();
  int _lastMovementMs = -10000;
  Offset _travelDirection = Offset.zero;
  Duration _lastElapsed = Duration.zero;
  ui.Image? _backdrop;
  late final LivesService _lives;
  late final TabOwnership _ownership;
  late final MockRewardedAds _ads;
  late final RewardedAdCoordinator _reward;
  Timer? _countdownTimer;
  bool _ready = false;
  bool _operationBusy = false;
  bool _terminalPending = false;
  bool _terminalSaveFailed = false;
  bool _adOpen = false;
  String? _notice;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attempt = GameAttempt(m2Levels[_levelIndex]);
    _lives = LivesService(
      SaveService(widget.saveStore ?? PreferencesSaveStore()),
      widget.clock ?? const SystemGameClock(),
    );
    _ownership = widget.tabOwnership ?? createTabOwnership();
    _ads = MockRewardedAds(widget.rewardIds ?? MockRewardIdFactory());
    _reward = RewardedAdCoordinator(_ads, _lives);
    _drag = LampDrag(initial: _attempt.lamp);
    _ticker = Ticker(_onFrame);
    _visualAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _loadBackdrop(_levelIndex);
    unawaited(_initializeSession());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _countdownTimer?.cancel();
    _ads.dispose();
    _ownership.release();
    _visualAnimation.dispose();
    _backdrop?.dispose();
    super.dispose();
  }

  Future<void> _initializeSession() async {
    try {
      final writer = await _ownership.acquire();
      await _lives.initialize(readOnly: !writer);
      if (!mounted) return;
      final active = writer ? _lives.activeLevel : null;
      setState(() {
        _ready = true;
        if (active != null) {
          _levelIndex = active;
          _attempt = GameAttempt(m2Levels[active])..start();
          _drag = LampDrag(initial: _attempt.lamp);
          _notice = 'Đã khôi phục ván ở điểm đầu màn, không trừ thêm lượt.';
        }
      });
      if (active != null) {
        _loadBackdrop(active);
        _runClock();
      }
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        unawaited(_refreshLives());
      });
    } on SaveFailure catch (error) {
      if (mounted) setState(() => _loadError = error.message);
    }
  }

  Future<void> _refreshLives() async {
    if (!_ready || _lives.isReadOnly || _operationBusy) return;
    try {
      await _lives.refresh();
      if (mounted) setState(() {});
    } on SaveFailure catch (error) {
      if (mounted) setState(() => _notice = error.message);
    }
  }

  Future<void> _loadBackdrop(int index) async {
    final data = await rootBundle.load(
      'assets/backgrounds/stage-0${index + 1}.png',
    );
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    if (!mounted || index != _levelIndex) {
      frame.image.dispose();
      return;
    }
    setState(() {
      _backdrop?.dispose();
      _backdrop = frame.image;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _reward.cancel();
    if (state == AppLifecycleState.resumed) {
      _visualAnimation.repeat();
    } else {
      _visualAnimation.stop();
    }
    if (state != AppLifecycleState.resumed &&
        _attempt.phase == AttemptPhase.playing) {
      _pause();
    }
  }

  void _onFrame(Duration elapsed) {
    final seconds = math.min(
      (elapsed - _lastElapsed).inMicroseconds / 1000000,
      .05,
    );
    _lastElapsed = elapsed;
    if (seconds <= 0 || _attempt.phase != AttemptPhase.playing) return;
    setState(() => _attempt.tick(seconds));
    if (_attempt.phase == AttemptPhase.won) {
      _ticker.stop();
      unawaited(_finishTerminal());
    }
  }

  void _runClock() {
    _lastElapsed = Duration.zero;
    if (!_ticker.isActive) _ticker.start();
  }

  Future<void> _beginAttempt(int levelIndex) async {
    if (!_ready || _operationBusy || _terminalPending || _adOpen) return;
    setState(() {
      _operationBusy = true;
      _notice = null;
    });
    try {
      final result = await _lives.startAttempt(levelIndex);
      if (!mounted) return;
      if (result == SessionResult.ok) {
        setState(() {
          _levelIndex = levelIndex;
          _attempt = GameAttempt(m2Levels[levelIndex])..start();
          _drag = LampDrag(initial: _attempt.lamp);
          _lastMovementMs = -10000;
          _travelDirection = Offset.zero;
        });
        _loadBackdrop(levelIndex);
        _runClock();
      } else {
        setState(
          () => _notice = switch (result) {
            SessionResult.noLives =>
              'Hết lượt. Đợi hồi lượt hoặc xem quảng cáo mô phỏng.',
            SessionResult.readOnly =>
              'Tab này chỉ đọc. Hãy quay lại tab đang chơi.',
            SessionResult.alreadyActive => 'Đang có một ván chưa kết thúc.',
            _ => 'Đang xử lý, vui lòng thử lại.',
          },
        );
      }
    } on SaveFailure catch (error) {
      if (mounted) setState(() => _notice = error.message);
    } finally {
      if (mounted) setState(() => _operationBusy = false);
    }
  }

  void _pause() {
    _ticker.stop();
    _drag.end(_drag.activePointer ?? -1);
    setState(() {
      _attempt.pause();
      _notice = null;
    });
  }

  void _resume() {
    setState(() {
      _attempt.resume();
      _notice = null;
    });
    _runClock();
  }

  void _resetCurrentAttempt() {
    if (_attempt.phase != AttemptPhase.playing) return;
    setState(() {
      _attempt.retry();
      _drag = LampDrag(initial: _attempt.lamp);
      _lastMovementMs = -10000;
      _travelDirection = Offset.zero;
    });
  }

  Future<void> _showPreview() async {
    if (_operationBusy || _terminalPending) return;
    if (_attempt.phase == AttemptPhase.paused) {
      setState(() => _operationBusy = true);
      try {
        await _lives.abandonAttempt();
      } on SaveFailure catch (error) {
        if (mounted) setState(() => _notice = error.message);
        return;
      } finally {
        if (mounted) setState(() => _operationBusy = false);
      }
    }
    if (!mounted) return;
    _ticker.stop();
    setState(() {
      _attempt.reset();
      _drag = LampDrag(initial: _attempt.lamp);
      _lastMovementMs = -10000;
      _travelDirection = Offset.zero;
    });
  }

  Future<void> _finishTerminal() async {
    if (_terminalPending || !_ready) return;
    _terminalPending = true;
    setState(() => _operationBusy = true);
    try {
      await _lives.finishAttempt(won: _attempt.phase == AttemptPhase.won);
      if (mounted) {
        setState(() {
          _notice = null;
          _terminalSaveFailed = false;
        });
      }
    } on SaveFailure catch (error) {
      if (mounted) {
        setState(() {
          _notice = error.message;
          _terminalSaveFailed = true;
        });
      }
    } finally {
      _terminalPending = false;
      if (mounted) setState(() => _operationBusy = false);
    }
  }

  Future<void> _watchAd() async {
    if (!_ready ||
        _operationBusy ||
        _adOpen ||
        _lives.lives == 3 ||
        _lives.isReadOnly) {
      return;
    }
    setState(() {
      _adOpen = true;
      _notice = null;
    });
    final outcome = await _reward.watch();
    if (!mounted) return;
    setState(() {
      _adOpen = false;
      _notice = switch (outcome) {
        AdOutcome.earned => 'Đã nhận +1 lượt.',
        AdOutcome.cancelled => 'Đã đóng quảng cáo mô phỏng; không nhận lượt.',
        AdOutcome.error => 'Quảng cáo hoặc lưu thưởng bị lỗi; không cộng lượt.',
        AdOutcome.full => 'Lượt đã đầy.',
        AdOutcome.busy => 'Quảng cáo đang chạy.',
      };
    });
  }

  Future<void> _recoverSave() async {
    if (_operationBusy || _lives.isReadOnly) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lại dữ liệu lưu?'),
        content: const Text(
          'Thao tác này xóa lượt và tiến độ bị lỗi trên thiết bị này.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đặt lại'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _operationBusy = true);
    try {
      await _lives.resetCorruptSave();
      if (mounted) {
        setState(() {
          _loadError = null;
          _ready = true;
          _notice = null;
        });
      }
    } on SaveFailure catch (error) {
      if (mounted) setState(() => _loadError = error.message);
    } finally {
      if (mounted) setState(() => _operationBusy = false);
    }
  }

  void _selectLevel(int index) {
    if (index < 0 || index >= m2Levels.length) return;
    _ticker.stop();
    setState(() {
      _levelIndex = index;
      _attempt = GameAttempt(m2Levels[index]);
      _drag = LampDrag(initial: _attempt.lamp);
      _lastMovementMs = -10000;
      _travelDirection = Offset.zero;
      _backdrop?.dispose();
      _backdrop = null;
    });
    _loadBackdrop(index);
  }

  void _endPointer(int pointer) {
    if (_drag.end(pointer)) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mapper = ViewportMapper.contain(
            viewportWidth: constraints.maxWidth,
            viewportHeight: constraints.maxHeight,
            boardWidth: SandboxGeometry.boardWidth,
            boardHeight: SandboxGeometry.boardHeight,
          );
          return Stack(
            children: [
              Listener(
                key: const Key('game-input'),
                behavior: HitTestBehavior.opaque,
                onPointerDown: (event) {
                  if (_attempt.phase != AttemptPhase.playing) return;
                  final at = mapper.viewportToBoard(
                    Point2(event.localPosition.dx, event.localPosition.dy),
                  );
                  if (at != null && _drag.begin(event.pointer, at)) {
                    setState(() {});
                  }
                },
                onPointerMove: (event) {
                  if (_attempt.phase != AttemptPhase.playing) return;
                  final at = mapper.viewportToBoard(
                    Point2(event.localPosition.dx, event.localPosition.dy),
                    allowOutside: true,
                  );
                  if (at == null || !_drag.move(event.pointer, at)) return;
                  setState(() {
                    final before = _attempt.shadow.center;
                    _attempt.moveLamp(_drag.position);
                    final after = _attempt.shadow.center;
                    final dx = after.x - before.x;
                    final dy = after.y - before.y;
                    final distance = math.sqrt(dx * dx + dy * dy);
                    if (distance > .2) {
                      _lastMovementMs = _motionClock.elapsedMilliseconds;
                      _travelDirection = Offset(dx / distance, dy / distance);
                    }
                    _drag.correctPosition(event.pointer, at, _attempt.lamp);
                    if (_attempt.phase == AttemptPhase.lost) {
                      _drag.end(event.pointer);
                      _ticker.stop();
                    }
                  });
                  if (_attempt.phase == AttemptPhase.lost) {
                    unawaited(_finishTerminal());
                  }
                },
                onPointerUp: (event) => _endPointer(event.pointer),
                onPointerCancel: (event) => _endPointer(event.pointer),
                child: Semantics(
                  label:
                      'Sân khấu của Bóng Mơ. '
                      'Cửa trăng ${_attempt.gateOpen ? 'đang mở' : 'đang khóa'}. '
                      'Kéo đèn vàng bằng một ngón để dẫn bóng.',
                  child: SizedBox.expand(
                    child: CustomPaint(
                      key: const Key('game-canvas'),
                      painter: GamePainter(
                        attempt: _attempt,
                        pressed: _drag.activePointer != null,
                        backdrop: _backdrop,
                        animation: _visualAnimation,
                        motionClock: _motionClock,
                        lastMovementMs: _lastMovementMs,
                        travelDirection: _travelDirection,
                        lives: _lives.lives,
                      ),
                    ),
                  ),
                ),
              ),
              if (_attempt.phase == AttemptPhase.playing)
                _placed(
                  mapper,
                  311,
                  11,
                  59,
                  44,
                  _action('Tạm dừng', _pause, icon: Icons.pause),
                ),
              if (_attempt.phase == AttemptPhase.playing)
                _placed(
                  mapper,
                  311,
                  586,
                  59,
                  44,
                  _action('Đặt lại', _resetCurrentAttempt, icon: Icons.replay),
                ),
              if (_ready && _attempt.phase != AttemptPhase.playing)
                _placed(
                  mapper,
                  27,
                  585,
                  96,
                  46,
                  _action(
                    _lives.lives == 3
                        ? 'Lượt đã đầy'
                        : 'Xem quảng cáo\n+1 lượt',
                    _lives.lives == 3 || _lives.isReadOnly || _operationBusy
                        ? null
                        : _watchAd,
                    small: true,
                    primary: _lives.lives < 3,
                  ),
                ),
              if (_ready &&
                  _attempt.phase != AttemptPhase.playing &&
                  _lives.untilNextRefill != null)
                _placed(
                  mapper,
                  270,
                  588,
                  92,
                  42,
                  Center(
                    child: Text(
                      'Hồi sau\n${_countdown(_lives.untilNextRefill!)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StageColors.goldCore,
                        fontSize: 11 * mapper.scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_attempt.phase != AttemptPhase.playing) _panel(mapper),
              if (_adOpen) _adOverlay(mapper),
              if (!_ready || _loadError != null || _lives.isReadOnly)
                _statusOverlay(mapper),
            ],
          );
        },
      ),
    ),
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

  String _countdown(Duration duration) {
    final seconds = (duration.inMilliseconds / 1000).ceil();
    final minutes = seconds ~/ 60;
    return '${minutes.toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _action(
    String label,
    VoidCallback? onPressed, {
    IconData? icon,
    bool small = false,
    bool primary = false,
  }) => TheatreButton(
    label: label,
    onPressed: onPressed,
    icon: icon,
    leading: primary
        ? switch (label) {
            'Bắt đầu' || 'Tiếp tục' || 'Màn tiếp theo' => Icons.play_arrow,
            'Thử lại' || 'Chơi lại' => Icons.replay,
            _ => null,
          }
        : null,
    small: small,
    tone: primary ? TheatreButtonTone.gold : TheatreButtonTone.lilac,
  );

  Widget _panel(ViewportMapper map) {
    final phase = _attempt.phase;
    final title = _terminalSaveFailed
        ? 'Chưa lưu kết quả'
        : switch (phase) {
            AttemptPhase.preview => _attempt.level.title,
            AttemptPhase.paused => 'Tạm dừng',
            AttemptPhase.won => 'Qua cửa trăng!',
            AttemptPhase.lost => 'Bóng chạm vùng đỏ',
            AttemptPhase.playing => '',
          };
    final defaultDetail = switch (phase) {
      AttemptPhase.preview => _attempt.level.hint,
      AttemptPhase.paused => 'Đồng hồ cửa đã dừng. Tiếp tục khi sẵn sàng.',
      AttemptPhase.won => 'Giữ toàn bộ bóng trong cửa đủ một giây.',
      AttemptPhase.lost => 'Thử đường khác để tránh cảm biến.',
      AttemptPhase.playing => '',
    };
    final detail = _operationBusy && phase != AttemptPhase.preview
        ? 'Đang lưu phiên chơi…'
        : _notice ?? defaultDetail;
    final scale = map.scale;
    final preview = phase == AttemptPhase.preview;
    return _placed(
      map,
      preview ? BoardUiLayout.preview.left : 30,
      preview ? BoardUiLayout.preview.top : 251,
      preview ? BoardUiLayout.preview.width : 330,
      preview ? BoardUiLayout.preview.height : 278,
      TheatrePanel(
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
                title,
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
                  detail,
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
                          _lives.lives == 0 ? 'Hết lượt' : 'Bắt đầu',
                          !_ready ||
                                  _operationBusy ||
                                  _lives.isReadOnly ||
                                  _lives.lives == 0
                              ? null
                              : () => _beginAttempt(_levelIndex),
                          primary: true,
                        ),
                      ),
                      SizedBox(width: 7 * scale),
                      Expanded(
                        child: _action(
                          'Màn trước',
                          _operationBusy || _levelIndex == 0
                              ? null
                              : () => _selectLevel(_levelIndex - 1),
                          small: true,
                        ),
                      ),
                      SizedBox(width: 7 * scale),
                      Expanded(
                        child: _action(
                          'Màn sau',
                          _operationBusy || _levelIndex == m2Levels.length - 1
                              ? null
                              : () => _selectLevel(_levelIndex + 1),
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
                    _terminalSaveFailed
                        ? 'Thử lưu lại'
                        : switch (phase) {
                            AttemptPhase.paused => 'Tiếp tục',
                            AttemptPhase.won =>
                              _levelIndex < m2Levels.length - 1
                                  ? 'Màn tiếp theo'
                                  : 'Chơi lại',
                            AttemptPhase.lost => 'Thử lại',
                            _ => '',
                          },
                    _operationBusy
                        ? null
                        : _terminalSaveFailed
                        ? _finishTerminal
                        : switch (phase) {
                            AttemptPhase.paused => _resume,
                            AttemptPhase.won =>
                              _levelIndex < m2Levels.length - 1
                                  ? () => _beginAttempt(_levelIndex + 1)
                                  : () => _beginAttempt(_levelIndex),
                            AttemptPhase.lost => () => _beginAttempt(
                              _levelIndex,
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
                          _operationBusy || _terminalSaveFailed
                              ? null
                              : _showPreview,
                          small: true,
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: _action(
                          phase == AttemptPhase.paused ? 'Bỏ ván' : 'Thử lại',
                          _operationBusy || _terminalSaveFailed
                              ? null
                              : phase == AttemptPhase.paused
                              ? _showPreview
                              : () => _beginAttempt(_levelIndex),
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
    );
  }

  Widget _adOverlay(ViewportMapper map) => Positioned.fill(
    child: ColoredBox(
      color: StageColors.background.withValues(alpha: .78),
      child: Center(
        child: SizedBox(
          width: 330 * map.scale,
          height: 285 * map.scale,
          child: TheatrePanel(
            child: Padding(
              padding: EdgeInsets.all(24 * map.scale),
              child: AnimatedBuilder(
                animation: _ads,
                builder: (context, _) => Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quảng cáo mô phỏng',
                      style: TextStyle(
                        color: StageColors.goldCore,
                        fontSize: 21 * map.scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      _ads.phase == AdPhase.loading
                          ? 'Đang tải…'
                          : 'Xem đủ 5 giây để nhận +1 lượt.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StageColors.text,
                        fontSize: 15 * map.scale,
                      ),
                    ),
                    LinearProgressIndicator(
                      value: _ads.progress,
                      color: StageColors.mint,
                      backgroundColor: StageColors.frameEdge,
                    ),
                    Text(
                      '${(5 - _ads.progress * 5).ceil().clamp(0, 5)} giây',
                      style: TextStyle(
                        color: StageColors.goldCore,
                        fontSize: 15 * map.scale,
                      ),
                    ),
                    SizedBox(
                      height: 46 * map.scale,
                      width: double.infinity,
                      child: _action('Đóng · không nhận lượt', _reward.cancel),
                    ),
                    if (kDebugMode)
                      TextButton(
                        onPressed: _ads.failForDebug,
                        child: const Text('Giả lập lỗi tải'),
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

  Widget _statusOverlay(ViewportMapper map) {
    final readOnly = _ready && _lives.isReadOnly && _loadError == null;
    return Positioned.fill(
      child: ColoredBox(
        color: StageColors.background.withValues(alpha: .82),
        child: Center(
          child: SizedBox(
            width: 340 * map.scale,
            height: 230 * map.scale,
            child: TheatrePanel(
              child: Padding(
                padding: EdgeInsets.all(22 * map.scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      !_ready && _loadError == null
                          ? 'Đang đọc phiên chơi…'
                          : readOnly
                          ? 'Tab chỉ đọc'
                          : 'Không mở được dữ liệu lưu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StageColors.goldCore,
                        fontSize: 20 * map.scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      readOnly
                          ? 'Một tab khác đang chơi. Đóng tab đó rồi tải lại để tiếp tục.'
                          : _loadError ?? 'Vui lòng đợi một chút.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: StageColors.text,
                        fontSize: 14 * map.scale,
                      ),
                    ),
                    if (_loadError != null && !_lives.isReadOnly)
                      SizedBox(
                        height: 48 * map.scale,
                        width: double.infinity,
                        child: _action(
                          'Đặt lại dữ liệu lỗi',
                          _recoverSave,
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
}
