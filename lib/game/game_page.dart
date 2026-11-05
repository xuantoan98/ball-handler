import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../core/geometry.dart';
import '../core/lamp_drag.dart';
import '../core/level.dart';
import '../core/rules.dart';
import '../design_tokens.dart';
import '../services/lives_service.dart';
import '../services/game_audio.dart';
import '../services/platform_rewarded_ads.dart';
import '../services/rewarded_ads.dart';
import '../services/save_service.dart';
import '../services/tab_ownership.dart';
import 'result_effect.dart';
import 'stage_backdrop.dart';
import 'theatre_components.dart';
import 'home_screen.dart';
import 'game_language.dart';
import 'attempt_timer_button.dart';
import 'attempt_timer_save_queue.dart';
import 'game_session.dart';
import 'board_action_button.dart';
import 'board_canvas.dart';
import 'board_overlays.dart';
import 'result_panel.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    this.saveStore,
    this.clock,
    this.rewardIds,
    this.tabOwnership,
    this.gameAudio,
  });

  final SaveStore? saveStore;
  final GameClock? clock;
  final RewardIdFactory? rewardIds;
  final TabOwnership? tabOwnership;
  final GameAudio? gameAudio;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final GameSession _session;
  int get _levelIndex => _session.levelIndex;
  GameAttempt get _attempt => _session.attempt;
  LampDrag get _drag => _session.drag;
  late final Ticker _ticker;
  late final AnimationController _visualAnimation;
  final Stopwatch _motionClock = Stopwatch()..start();
  int _lastMovementMs = -10000;
  Offset _travelDirection = Offset.zero;
  Duration _lastElapsed = Duration.zero;
  ui.Image? _backdrop;
  ui.Image? _deskBackdrop;
  late final LivesService _lives;
  late final AttemptTimerSaveQueue _timerSaves;
  late final TabOwnership _ownership;
  late final MockRewardedAds _mockAds;
  late final RewardedAdSource _ads;
  late final RewardedAdCoordinator _reward;
  late final GameAudio _audio;
  final ResultEffect _resultEffect = ResultEffect();
  bool _hapticDone = false;
  bool _terminalPanelVisible = true;
  Timer? _terminalPanelTimer;
  bool _soundEnabled = true;
  GameLanguage _language = GameLanguage.vi;
  bool _settingsVisible = false;
  String _t(String value) => _language.text(value);
  bool _reduceMotion = false;
  Timer? _countdownTimer;
  bool _ready = false;
  bool _operationBusy = false;
  bool _soundSaveBusy = false;
  bool get _visualBusy => _operationBusy && !_soundSaveBusy;
  bool _terminalPending = false;
  bool _terminalSaveFailed = false;
  bool _adOpen = false;
  bool _homeVisible = true;
  bool _introVisible = false;
  int _lastTimerSecond = 60;
  bool get _nativeTestAds => !identical(_ads, _mockAds);
  bool get _adsUnavailable => _nativeTestAds && !kDebugMode;
  String? _notice;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = GameSession();
    _lives = LivesService(
      SaveService(widget.saveStore ?? PreferencesSaveStore()),
      widget.clock ?? const SystemGameClock(),
    );
    _timerSaves = AttemptTimerSaveQueue(_lives.setAttemptRemainingMs, (error) {
      if (mounted) setState(() => _notice = error.message);
    });
    _ownership = widget.tabOwnership ?? createTabOwnership();
    final ids = widget.rewardIds ?? MockRewardIdFactory();
    _mockAds = MockRewardedAds(ids);
    _ads = createPlatformRewardedAds(ids) ?? _mockAds;
    _reward = RewardedAdCoordinator(_ads, _lives);
    _audio = widget.gameAudio ?? GameAudio();
    _ticker = Ticker(_onFrame);
    _visualAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _loadBackdrop(_levelIndex);
    unawaited(_loadDeskBackdrop());
    unawaited(_initializeSession());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_reduceMotion) {
      _visualAnimation.stop();
    } else if (_attempt.phase != AttemptPhase.paused) {
      _visualAnimation.repeat();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _countdownTimer?.cancel();
    _timerSaves.dispose();
    _terminalPanelTimer?.cancel();
    _mockAds.dispose();
    _ownership.release();
    _visualAnimation.dispose();
    _backdrop?.dispose();
    _deskBackdrop?.dispose();
    if (widget.gameAudio == null) unawaited(_audio.dispose());
    super.dispose();
  }

  Future<void> _initializeSession() async {
    try {
      final writer = await _ownership.acquire();
      await _lives.initialize(readOnly: !writer);
      _soundEnabled = _lives.record.soundEnabled;
      _language = _lives.record.language;
      _audio.setEnabled(_soundEnabled);
      _audio.setMusicActive(true);
      if (!mounted) return;
      final active = writer ? _lives.activeLevel : null;
      setState(() {
        _ready = true;
        _introVisible = writer && !_lives.record.introSeen;
        if (active != null) {
          _session.restore(active, _lives.record.attemptRemainingMs ?? 60000);
          _lastTimerSecond = (_attempt.remainingMs / 1000).ceil();
          _notice =
              'Đã khôi phục ván và thời gian còn lại, không trừ thêm lượt.';
        }
      });
      if (active != null) {
        _loadBackdrop(active);
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
      final previousLives = _lives.lives;
      await _lives.refresh();
      if (mounted &&
          (previousLives != _lives.lives || _lives.untilNextRefill != null)) {
        setState(() {});
      }
    } on SaveFailure catch (error) {
      if (mounted) setState(() => _notice = error.message);
    }
  }

  Future<void> _loadBackdrop(int index) async {
    final data = await rootBundle.load(stageBackdropPath(index + 1));
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

  Future<void> _loadDeskBackdrop() async {
    final data = await rootBundle.load('assets/controls/lamp-desk-v3.webp');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    codec.dispose();
    if (!mounted) {
      frame.image.dispose();
      return;
    }
    setState(() => _deskBackdrop = frame.image);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _audio.setForeground(state == AppLifecycleState.resumed);
    if (state != AppLifecycleState.resumed) _reward.cancel();
    if (state == AppLifecycleState.resumed) {
      if (_attempt.phase != AttemptPhase.paused && !_reduceMotion) {
        _visualAnimation.repeat();
      }
    } else {
      _visualAnimation.stop();
    }
    if (state != AppLifecycleState.resumed &&
        _attempt.phase == AttemptPhase.playing) {
      _pause();
    }
  }

  bool get _phoneLandscape {
    final view = View.of(context);
    final size = view.physicalSize / view.devicePixelRatio;
    return size.width > size.height && size.height < 600;
  }

  @override
  void didChangeMetrics() {
    if (mounted && _phoneLandscape && _attempt.phase == AttemptPhase.playing) {
      _pause();
    }
  }

  void _onFrame(Duration elapsed) {
    final seconds = (elapsed - _lastElapsed).inMicroseconds / 1000000;
    _lastElapsed = elapsed;
    if (seconds <= 0 || _attempt.phase != AttemptPhase.playing) return;
    final previousPhase = _attempt.phase;
    final previousSwitches = _attempt.activatedSwitches;
    final previousGate = _attempt.gateOpen;
    final previousFeedback = _attempt.feedback;
    setState(() => _session.tick(seconds));
    _handleAttemptUpdate(
      previousPhase,
      previousSwitches,
      previousGate,
      previousFeedback,
    );
    final currentSecond = (_attempt.remainingMs / 1000).ceil();
    if (currentSecond != _lastTimerSecond) {
      _lastTimerSecond = currentSecond;
      _queueTimerSave();
    }
    if (_attempt.phase == AttemptPhase.won ||
        _attempt.phase == AttemptPhase.lost) {
      _ticker.stop();
      unawaited(_finishTerminal());
    }
  }

  void _handleAttemptUpdate(
    AttemptPhase previousPhase,
    int previousSwitches,
    bool previousGate,
    String previousFeedback,
  ) {
    if (_attempt.activatedSwitches > previousSwitches) {
      _audio.play(GameSound.switchOn);
    } else if (_attempt.feedback != previousFeedback &&
        _attempt.feedbackKind == AttemptFeedbackKind.wrongOrder) {
      _audio.play(GameSound.wrong);
    }
    if (!previousGate && _attempt.gateOpen) _audio.play(GameSound.gate);
    if (previousPhase != AttemptPhase.playing ||
        (_attempt.phase != AttemptPhase.won &&
            _attempt.phase != AttemptPhase.lost)) {
      return;
    }
    final collision =
        _attempt.phase == AttemptPhase.lost &&
        (_attempt.feedbackKind == AttemptFeedbackKind.hazard ||
            _attempt.feedbackKind == AttemptFeedbackKind.movingHazard);
    if (_resultEffect.begin(
      _attempt.phase,
      collision: collision,
      reducedMotion: _reduceMotion,
    )) {
      if (_resultEffect.panelDelay > Duration.zero) {
        _terminalPanelVisible = false;
        _terminalPanelTimer?.cancel();
        _terminalPanelTimer = Timer(_resultEffect.panelDelay, () {
          if (mounted) setState(() => _terminalPanelVisible = true);
        });
      }
      if (_attempt.phase == AttemptPhase.won) {
        _audio.play(GameSound.win);
      } else if (collision) {
        _audio.play(GameSound.collision);
      }
    }
  }

  void _clearResultEffect() {
    _terminalPanelTimer?.cancel();
    _terminalPanelTimer = null;
    _terminalPanelVisible = true;
    _resultEffect.reset();
  }

  void _queueTimerSave() {
    if (!_ready || _lives.activeLevel == null) return;
    _timerSaves.queue(_attempt.remainingMs.floor().clamp(0, 60000));
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
        _clearResultEffect();
        _hapticDone = false;
        setState(() {
          _session.start(levelIndex);
          _lastTimerSecond = 60;
          _lastMovementMs = -10000;
          _travelDirection = Offset.zero;
        });
        _loadBackdrop(levelIndex);
        _runClock();
      } else {
        setState(
          () => _notice = switch (result) {
            SessionResult.noLives =>
              _nativeTestAds
                  ? 'Hết lượt. Đợi hồi lượt hoặc xem quảng cáo thử nghiệm.'
                  : 'Hết lượt. Đợi hồi lượt hoặc xem quảng cáo mô phỏng.',
            SessionResult.readOnly =>
              'Tab này chỉ đọc. Hãy quay lại tab đang chơi.',
            SessionResult.alreadyActive => 'Đang có một ván chưa kết thúc.',
            SessionResult.locked => 'Qua màn trước để mở màn này.',
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
    _audio.setMusicActive(false);
    _visualAnimation.stop();
    _ticker.stop();
    _queueTimerSave();
    _drag.end(_drag.activePointer ?? -1);
    setState(() {
      _session.pause();
      _notice = null;
    });
  }

  void _resume() {
    _audio.setMusicActive(true);
    if (!_reduceMotion) _visualAnimation.repeat();
    setState(() {
      _session.resume();
      _notice = null;
    });
    _runClock();
  }

  void _resetCurrentAttempt() {
    if (_attempt.phase != AttemptPhase.playing) return;
    _clearResultEffect();
    setState(() {
      _session.resetPuzzle();
      _lastMovementMs = -10000;
      _travelDirection = Offset.zero;
    });
  }

  Future<void> _showPreview() async {
    if (_operationBusy || _terminalPending) return;
    if (_attempt.phase == AttemptPhase.paused) {
      setState(() => _operationBusy = true);
      try {
        await _timerSaves.flush();
        await _lives.abandonAttempt();
      } on SaveFailure catch (error) {
        if (mounted) setState(() => _notice = error.message);
        return;
      } finally {
        if (mounted) setState(() => _operationBusy = false);
      }
    }
    if (!mounted) return;
    _audio.setMusicActive(true);
    if (!_reduceMotion) _visualAnimation.repeat();
    _clearResultEffect();
    _ticker.stop();
    setState(() {
      _session.resetPreview();
      _lastMovementMs = -10000;
      _travelDirection = Offset.zero;
    });
  }

  Future<void> _finishTerminal() async {
    if (_terminalPending || !_ready) return;
    _terminalPending = true;
    setState(() => _operationBusy = true);
    try {
      await _timerSaves.flush();
      await _lives.finishAttempt(won: _attempt.phase == AttemptPhase.won);
      if (_resultEffect.collisionHaptic &&
          !_hapticDone &&
          !kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android) {
        _hapticDone = true;
        unawaited(HapticFeedback.mediumImpact());
      }
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
    _audio.setAdOpen(true);
    final outcome = await _reward.watch();
    _audio.setAdOpen(false);
    if (!mounted) return;
    setState(() {
      _adOpen = false;
      _notice = switch (outcome) {
        AdOutcome.earned => 'Đã nhận +1 lượt.',
        AdOutcome.cancelled =>
          _nativeTestAds
              ? 'Đã đóng quảng cáo thử nghiệm; không nhận lượt.'
              : 'Đã đóng quảng cáo mô phỏng; không nhận lượt.',
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
        title: Text(_t('Đặt lại dữ liệu lưu?')),
        content: Text(
          _t('Thao tác này xóa lượt và tiến độ bị lỗi trên thiết bị này.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_t('Hủy')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_t('Đặt lại')),
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
          _homeVisible = true;
          _introVisible = true;
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
    if (index < 0 || index >= m4Levels.length) return;
    _ticker.stop();
    _clearResultEffect();
    setState(() {
      _session.selectLevel(index);
      _lastMovementMs = -10000;
      _travelDirection = Offset.zero;
      _backdrop?.dispose();
      _backdrop = null;
      _notice = null;
    });
    _loadBackdrop(index);
  }

  Future<void> _acknowledgeIntro() async {
    if (_operationBusy || !_introVisible) return;
    setState(() {
      _operationBusy = true;
      _notice = null;
    });
    try {
      await _lives.setIntroSeen();
      if (mounted) setState(() => _introVisible = false);
    } on SaveFailure catch (error) {
      if (mounted) setState(() => _notice = error.message);
    } finally {
      if (mounted) setState(() => _operationBusy = false);
    }
  }

  void _openHomePlay() {
    if (_introVisible || _operationBusy) return;
    if (_lives.activeLevel != null) {
      setState(() {
        _homeVisible = false;
        _notice = null;
      });
      if (_phoneLandscape) return;
      _resume();
      return;
    }
    _selectLevel(_lives.currentLevel);
    setState(() {
      _homeVisible = false;
      _notice = null;
    });
  }

  Future<void> _toggleSound() async {
    if (!_ready || _operationBusy || _lives.isReadOnly) return;
    final next = !_soundEnabled;
    setState(() {
      _soundEnabled = next;
      _operationBusy = true;
      _soundSaveBusy = true;
    });
    _audio.setEnabled(next);
    try {
      await _lives.setSoundEnabled(next);
      _audio.play(GameSound.menu);
    } on SaveFailure catch (error) {
      _audio.setEnabled(!next);
      if (mounted) {
        setState(() {
          _soundEnabled = !next;
          _notice = error.message;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _operationBusy = false;
          _soundSaveBusy = false;
        });
      }
    }
  }

  Future<void> _selectLanguage(GameLanguage value) async {
    if (!_ready || _operationBusy || _lives.isReadOnly || value == _language) {
      return;
    }
    final previous = _language;
    setState(() {
      _language = value;
      _notice = null;
      _operationBusy = true;
      _soundSaveBusy = true;
    });
    try {
      await _lives.setLanguage(value);
      _audio.play(GameSound.menu);
    } on SaveFailure {
      if (mounted) {
        setState(() {
          _language = previous;
          _notice = 'Không lưu được ngôn ngữ. Vui lòng thử lại.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _operationBusy = false;
          _soundSaveBusy = false;
        });
      }
    }
  }

  Future<void> _openHomeLevels() async {
    if (_introVisible || _operationBusy) return;
    if (_lives.activeLevel != null) {
      await _showPreview();
      if (_lives.activeLevel != null || !mounted) return;
    }
    _selectLevel(0);
    if (mounted) setState(() => _homeVisible = false);
  }

  void _onBoardPointerDown(PointerDownEvent event, ViewportMapper mapper) {
    if (_attempt.phase != AttemptPhase.playing) return;
    final at = mapper.viewportToBoard(
      Point2(event.localPosition.dx, event.localPosition.dy),
    );
    if (at != null && _drag.begin(event.pointer, at)) setState(() {});
  }

  void _onBoardPointerMove(PointerMoveEvent event, ViewportMapper mapper) {
    if (_attempt.phase != AttemptPhase.playing) return;
    final at = mapper.viewportToBoard(
      Point2(event.localPosition.dx, event.localPosition.dy),
      allowOutside: true,
    );
    if (at == null || !_drag.move(event.pointer, at)) return;
    final previousPhase = _attempt.phase;
    final previousSwitches = _attempt.activatedSwitches;
    final previousGate = _attempt.gateOpen;
    final previousFeedback = _attempt.feedback;
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
    _handleAttemptUpdate(
      previousPhase,
      previousSwitches,
      previousGate,
      previousFeedback,
    );
    if (_attempt.phase == AttemptPhase.lost) unawaited(_finishTerminal());
  }

  void _endPointer(int pointer) {
    if (_drag.end(pointer)) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (_) => _audio.unlock(),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_ready && _homeVisible && _loadError == null) {
              return HomeScreen(
                lives: _lives.lives,
                refill: _lives.untilNextRefill,
                introVisible: _introVisible,
                busy: _visualBusy,
                soundBusy: _operationBusy,
                notice: _notice,
                onPlay: _openHomePlay,
                onLevels: _openHomeLevels,
                onAcknowledgeIntro: _acknowledgeIntro,
                soundEnabled: _soundEnabled,
                onToggleSound: _toggleSound,
                language: _language,
                settingsVisible: _settingsVisible,
                onOpenSettings: () => setState(() => _settingsVisible = true),
                onCloseSettings: () => setState(() => _settingsVisible = false),
                onSelectLanguage: _selectLanguage,
              );
            }
            if (constraints.maxWidth > constraints.maxHeight &&
                constraints.maxHeight < 600) {
              return Center(
                child: SizedBox(
                  width: math.min(360, constraints.maxWidth - 32),
                  height: 150,
                  child: TheatrePanel(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.screen_rotation,
                            color: StageColors.goldCore,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _attempt.phase == AttemptPhase.paused
                                ? _t('Xoay dọc để tiếp tục')
                                : _t('Xoay dọc để chơi'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: StageColors.text,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            final mapper = ViewportMapper.contain(
              viewportWidth: constraints.maxWidth,
              viewportHeight: constraints.maxHeight,
              boardWidth: SandboxGeometry.boardWidth,
              boardHeight: SandboxGeometry.boardHeight,
            );
            return Stack(
              children: [
                BoardCanvas(
                  attempt: _attempt,
                  drag: _drag,
                  backdrop: _backdrop,
                  deskBackdrop: _deskBackdrop,
                  resultEffect: _resultEffect,
                  language: _language,
                  reducedMotion: _reduceMotion,
                  animation: _visualAnimation,
                  motionClock: _motionClock,
                  lastMovementMs: _lastMovementMs,
                  travelDirection: _travelDirection,
                  lives: _lives.lives,
                  onPointerDown: (event) => _onBoardPointerDown(event, mapper),
                  onPointerMove: (event) => _onBoardPointerMove(event, mapper),
                  onPointerUp: (event) => _endPointer(event.pointer),
                  onPointerCancel: (event) => _endPointer(event.pointer),
                ),
                if (_attempt.phase == AttemptPhase.playing)
                  _placed(
                    mapper,
                    153,
                    6,
                    84,
                    50,
                    AttemptTimerButton(
                      remainingMs: _attempt.remainingMs,
                      language: _language,
                      onPause: _pause,
                    ),
                  ),
                if (_attempt.phase == AttemptPhase.playing)
                  _placed(
                    mapper,
                    311,
                    586,
                    59,
                    44,
                    _action(
                      'Đặt lại',
                      _resetCurrentAttempt,
                      icon: Icons.replay,
                    ),
                  ),
                if (_ready && _attempt.phase != AttemptPhase.playing)
                  _placed(
                    mapper,
                    27,
                    585,
                    96,
                    46,
                    _action(
                      _adsUnavailable
                          ? 'Ad chưa cấu hình'
                          : _adOpen
                          ? 'Đang tải ad…'
                          : _lives.lives == 3
                          ? 'Lượt đã đầy'
                          : _nativeTestAds
                          ? 'Xem ad test\n+1 lượt'
                          : 'Xem quảng cáo\n+1 lượt',
                      _adsUnavailable ||
                              _adOpen ||
                              _lives.lives == 3 ||
                              _lives.isReadOnly ||
                              _operationBusy
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
                        '${_t('Hồi sau')}\n${_countdown(_lives.untilNextRefill!)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: StageColors.goldCore,
                          fontSize: 11 * mapper.scale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (_attempt.phase != AttemptPhase.playing &&
                    _terminalPanelVisible)
                  ResultPanel(
                    map: mapper,
                    attempt: _attempt,
                    levelIndex: _levelIndex,
                    highestUnlocked: _lives.highestUnlocked,
                    lives: _lives.lives,
                    readOnly: _lives.isReadOnly,
                    ready: _ready,
                    busy: _operationBusy,
                    saveFailed: _terminalSaveFailed,
                    notice: _notice,
                    language: _language,
                    onBeginAttempt: _beginAttempt,
                    onSelectLevel: _selectLevel,
                    onRetrySave: _finishTerminal,
                    onResume: _resume,
                    onShowPreview: _showPreview,
                  ),
                if (_attempt.phase == AttemptPhase.paused)
                  _placed(
                    mapper,
                    316,
                    258,
                    40,
                    40,
                    SoundButton(
                      enabled: _soundEnabled,
                      language: _language,
                      onPressed: _operationBusy ? null : _toggleSound,
                    ),
                  ),
                if (_adOpen && identical(_ads, _mockAds))
                  MockAdOverlay(
                    scale: mapper.scale,
                    language: _language,
                    ads: _mockAds,
                    onCancel: _reward.cancel,
                  ),
                if (!_ready || _loadError != null || _lives.isReadOnly)
                  StatusOverlay(
                    scale: mapper.scale,
                    language: _language,
                    ready: _ready,
                    readOnly: _ready && _lives.isReadOnly && _loadError == null,
                    loadError: _loadError,
                    onRecover: _recoverSave,
                  ),
              ],
            );
          },
        ),
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
  }) => BoardActionButton(
    label: label,
    language: _language,
    onPressed: onPressed,
    icon: icon,
    small: small,
    primary: primary,
  );
}
