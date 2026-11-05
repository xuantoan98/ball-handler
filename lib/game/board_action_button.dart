import 'package:flutter/material.dart';

import 'game_language.dart';
import 'theatre_components.dart';

class BoardActionButton extends StatelessWidget {
  const BoardActionButton({
    super.key,
    required this.label,
    required this.language,
    this.onPressed,
    this.icon,
    this.small = false,
    this.primary = false,
  });

  final String label;
  final GameLanguage language;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool small;
  final bool primary;

  @override
  Widget build(BuildContext context) => TheatreButton(
    label: language.text(label),
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
}
