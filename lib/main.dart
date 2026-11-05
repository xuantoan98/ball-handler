import 'package:flutter/material.dart';

import 'design_tokens.dart';
import 'game/game_page.dart';
import 'services/game_audio.dart';
import 'services/lives_service.dart';
import 'services/rewarded_ads.dart';
import 'services/save_service.dart';
import 'services/tab_ownership.dart';

export 'game/game_page.dart' show GamePage;

void main() => runApp(const ShadowTheatreApp());

class ShadowTheatreApp extends StatelessWidget {
  const ShadowTheatreApp({
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
  Widget build(BuildContext context) => MaterialApp(
    title: 'Little Shadow Theatre',
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
      gameAudio: gameAudio,
    ),
  );
}
