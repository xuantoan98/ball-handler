import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_tokens.dart';

enum TheatreButtonTone { gold, lilac, outline }

/// Paper-ticket and round icon variants from the supplied UI kit.
class TheatreButton extends StatefulWidget {
  const TheatreButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.leading,
    this.small = false,
    this.tone = TheatreButtonTone.lilac,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? leading;
  final bool small;
  final TheatreButtonTone tone;

  @override
  State<TheatreButton> createState() => _TheatreButtonState();
}

class _TheatreButtonState extends State<TheatreButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final round = widget.icon != null;
    final dark = widget.tone == TheatreButtonTone.outline || !enabled;
    return Semantics(
      button: true,
      enabled: enabled,
      label: round ? widget.label : null,
      child: CustomPaint(
        painter: _TicketPainter(
          tone: widget.tone,
          disabled: !enabled,
          pressed: pressed,
          round: round,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (value) {
              if (pressed != value) setState(() => pressed = value);
            },
            customBorder: round
                ? const CircleBorder()
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
            child: Center(
              child: round
                  ? Tooltip(
                      message: widget.label,
                      child: Icon(
                        widget.icon,
                        size: 24,
                        color: dark ? StageColors.cream : StageColors.darkText,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.leading != null) ...[
                            Icon(
                              widget.leading,
                              size: 18,
                              color: dark
                                  ? StageColors.cream
                                  : StageColors.darkText,
                            ),
                            const SizedBox(width: 3),
                          ],
                          Flexible(
                            child: Text(
                              widget.label,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: TextStyle(
                                color: dark
                                    ? enabled
                                          ? StageColors.cream
                                          : StageColors.disabled
                                    : StageColors.darkText,
                                fontSize: widget.small ? 11 : 14,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                              ),
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

class _TicketPainter extends CustomPainter {
  const _TicketPainter({
    required this.tone,
    required this.disabled,
    required this.pressed,
    required this.round,
  });

  final TheatreButtonTone tone;
  final bool disabled;
  final bool pressed;
  final bool round;

  @override
  void paint(Canvas c, Size size) {
    final gold = tone == TheatreButtonTone.gold;
    final outline = tone == TheatreButtonTone.outline;
    final edge = disabled
        ? StageColors.frameEdge
        : gold
        ? StageColors.goldEdge
        : outline
        ? StageColors.gold
        : const Color(0xFFAC82B5);
    final top = disabled
        ? StageColors.frame
        : outline
        ? StageColors.frame
        : gold
        ? StageColors.goldCore
        : StageColors.lilacLight;
    final bottom = disabled
        ? StageColors.ink
        : outline
        ? StageColors.ink
        : gold
        ? const Color(0xFFF5AE49)
        : const Color(0xFFB6A0D2);
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: pressed ? [bottom, top] : [top, bottom],
    );
    if (round) {
      final radius = math.min(size.width, size.height) / 2 - 2;
      final center = rect.center;
      c.drawCircle(
        center.translate(0, 2),
        radius,
        Paint()
          ..color = Colors.black.withValues(alpha: .4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      c.drawCircle(
        center,
        radius,
        Paint()..shader = gradient.createShader(rect),
      );
      for (final (r, color, width) in [
        (radius, edge, 2.0),
        (radius - 3.5, StageColors.cream.withValues(alpha: .8), 1.0),
      ]) {
        c.drawCircle(
          center,
          r,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = width,
        );
      }
      _diamond(c, center.translate(0, -radius + 4), 2, edge);
      _diamond(c, center.translate(0, radius - 4), 2, edge);
      return;
    }
    final ticket = _ticket(rect.deflate(1.5), 8);
    c.drawPath(
      ticket.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: .4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    c.drawPath(ticket, Paint()..shader = gradient.createShader(rect));
    c.drawPath(
      ticket,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    c.drawPath(
      _ticket(rect.deflate(5), 5),
      Paint()
        ..color = StageColors.cream.withValues(alpha: disabled ? .2 : .72)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    for (final x in [12.0, size.width - 12]) {
      for (final y in [size.height * .26, size.height * .74]) {
        _diamond(c, Offset(x, y), 1.6, edge);
      }
    }
  }

  Path _ticket(Rect r, double cut) => Path()
    ..moveTo(r.left + cut, r.top)
    ..lineTo(r.right - cut, r.top)
    ..lineTo(r.right, r.top + cut)
    ..lineTo(r.right, r.bottom - cut)
    ..lineTo(r.right - cut, r.bottom)
    ..lineTo(r.left + cut, r.bottom)
    ..lineTo(r.left, r.bottom - cut)
    ..lineTo(r.left, r.top + cut)
    ..close();

  @override
  bool shouldRepaint(covariant _TicketPainter old) =>
      old.tone != tone ||
      old.disabled != disabled ||
      old.pressed != pressed ||
      old.round != round;
}

/// A decorative stage surround; the child retains normal Flutter semantics.
class TheatrePanel extends StatelessWidget {
  const TheatrePanel({super.key, required this.child, this.compact = false});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _PanelPainter(compact: compact),
    child: child,
  );
}

class _PanelPainter extends CustomPainter {
  const _PanelPainter({required this.compact});

  final bool compact;

  @override
  void paint(Canvas c, Size size) {
    final r = Offset.zero & size;
    final frame = RRect.fromRectAndRadius(
      r.deflate(2),
      const Radius.circular(17),
    );
    c.drawRRect(
      frame.shift(const Offset(0, 4)),
      Paint()
        ..color = Colors.black.withValues(alpha: .55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    c.drawRRect(
      frame,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF29365E), StageColors.ink, Color(0xFF14172E)],
        ).createShader(r),
    );
    for (final (inset, width, color) in [
      (2.0, 2.0, StageColors.goldEdge),
      (6.0, 1.2, StageColors.goldCore),
      (11.0, .8, StageColors.frameEdge),
    ]) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          r.deflate(inset),
          Radius.circular(18 - inset / 2),
        ),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width,
      );
    }
    for (final x in [18.0, size.width - 18]) {
      for (final y in [18.0, size.height - 18]) {
        _diamond(c, Offset(x, y), 3, StageColors.goldCore);
      }
    }
    _flourish(c, Offset(size.width / 2, 14), 1);
    if (compact) return;
    _flourish(c, Offset(size.width / 2, size.height - 14), -1);
    for (final left in [true, false]) {
      c.save();
      if (!left) {
        c.translate(size.width, 0);
        c.scale(-1, 1);
      }
      final curtain = Path()
        ..moveTo(14, 17)
        ..lineTo(89, 17)
        ..quadraticBezierTo(65, 30, 54, 54)
        ..quadraticBezierTo(37, 49, 21, 83)
        ..quadraticBezierTo(26, 52, 14, 17)
        ..close();
      c.drawPath(curtain, Paint()..color = const Color(0xFF593455));
      c.drawPath(
        curtain,
        Paint()
          ..color = StageColors.goldEdge
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
      c.drawLine(
        const Offset(35, 25),
        const Offset(28, 59),
        Paint()
          ..color = const Color(0xFF9F647B)
          ..strokeWidth = 2,
      );
      c.restore();
    }
    for (final x in [76.0, size.width - 76]) {
      c.drawLine(
        Offset(x, 16),
        Offset(x, 44),
        Paint()
          ..color = StageColors.goldEdge
          ..strokeWidth = .8,
      );
      _diamond(c, Offset(x, 48), 4, StageColors.goldCore);
    }
  }

  void _flourish(Canvas c, Offset center, int direction) {
    final p = Path()
      ..moveTo(center.dx - 40, center.dy)
      ..cubicTo(
        center.dx - 26,
        center.dy - 10 * direction,
        center.dx - 19,
        center.dy + 9 * direction,
        center.dx - 6,
        center.dy,
      )
      ..cubicTo(
        center.dx - 2,
        center.dy - 7 * direction,
        center.dx - 1,
        center.dy - 7 * direction,
        center.dx,
        center.dy,
      )
      ..cubicTo(
        center.dx + 1,
        center.dy - 7 * direction,
        center.dx + 2,
        center.dy - 7 * direction,
        center.dx + 6,
        center.dy,
      )
      ..cubicTo(
        center.dx + 19,
        center.dy + 9 * direction,
        center.dx + 26,
        center.dy - 10 * direction,
        center.dx + 40,
        center.dy,
      );
    c.drawPath(
      p,
      Paint()
        ..color = StageColors.goldEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );
    _diamond(c, center, 3.6, StageColors.goldCore);
  }

  @override
  bool shouldRepaint(covariant _PanelPainter old) => old.compact != compact;
}

void _diamond(Canvas c, Offset at, double r, Color color) {
  final p = Path()
    ..moveTo(at.dx, at.dy - r)
    ..lineTo(at.dx + r * .7, at.dy)
    ..lineTo(at.dx, at.dy + r)
    ..lineTo(at.dx - r * .7, at.dy)
    ..close();
  c.drawPath(p, Paint()..color = color);
}
