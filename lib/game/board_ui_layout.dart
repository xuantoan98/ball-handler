import 'package:flutter/widgets.dart';

/// Fixed logical board regions. The gaps are intentional visual whitespace.
/// Gameplay coordinates remain in SandboxGeometry.
abstract final class BoardUiLayout {
  static const header = Rect.fromLTWH(16, 10, 358, 46);
  static const hint = Rect.fromLTWH(25, 64, 340, 33);
  static const stage = Rect.fromLTWH(26.25, 111, 337.5, 450);
  static const stageFrame = Rect.fromLTWH(21.25, 106, 347.5, 460);
  static const shelf = Rect.fromLTWH(20, 576, 350, 65);
  static const desk = Rect.fromLTWH(8, 654, 374, 182);
  static const preview = Rect.fromLTWH(15, 663, 360, 165);
}
