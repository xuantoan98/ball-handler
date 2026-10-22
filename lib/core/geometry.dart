import 'dart:math' as math;

/// Engine-independent coordinates used by the shadow rules.
class Point2 {
  const Point2(this.x, this.y);

  final double x;
  final double y;

  Point2 operator +(Point2 other) => Point2(x + other.x, y + other.y);
  Point2 operator -(Point2 other) => Point2(x - other.x, y - other.y);
}

class Rect2 {
  const Rect2(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
  Point2 get center => Point2(left + width / 2, top + height / 2);

  Point2 clampPoint(Point2 point) => Point2(
    point.x.clamp(left, right).toDouble(),
    point.y.clamp(top, bottom).toDouble(),
  );

  bool contains(Point2 point) =>
      point.x >= left &&
      point.x <= right &&
      point.y >= top &&
      point.y <= bottom;
}

/// L at z=0, P at z=1, shadow wall at z=3: S = 3P - 2L.
Point2 projectPoint(Point2 caster, Point2 light) =>
    Point2(3 * caster.x - 2 * light.x, 3 * caster.y - 2 * light.y);

Rect2 projectRect(Rect2 caster, Point2 light) {
  final topLeft = projectPoint(Point2(caster.left, caster.top), light);
  return Rect2(topLeft.x, topLeft.y, caster.width * 3, caster.height * 3);
}

/// Uniform contain scaling with letterboxing. Input and output are logical pixels.
class ViewportMapper {
  ViewportMapper.contain({
    required this.viewportWidth,
    required this.viewportHeight,
    required this.boardWidth,
    required this.boardHeight,
  }) : assert(viewportWidth > 0),
       assert(viewportHeight > 0),
       assert(boardWidth > 0),
       assert(boardHeight > 0);

  final double viewportWidth;
  final double viewportHeight;
  final double boardWidth;
  final double boardHeight;

  double get scale =>
      math.min(viewportWidth / boardWidth, viewportHeight / boardHeight);
  double get offsetX => (viewportWidth - boardWidth * scale) / 2;
  double get offsetY => (viewportHeight - boardHeight * scale) / 2;

  Point2 boardToViewport(Point2 board) =>
      Point2(offsetX + board.x * scale, offsetY + board.y * scale);

  Point2? viewportToBoard(Point2 viewport, {bool allowOutside = false}) {
    final board = Point2(
      (viewport.x - offsetX) / scale,
      (viewport.y - offsetY) / scale,
    );
    if (!allowOutside &&
        (board.x < 0 ||
            board.x > boardWidth ||
            board.y < 0 ||
            board.y > boardHeight)) {
      return null;
    }
    return board;
  }
}

/// Fixed caster and control mapping shared by the M2 prototype levels.
abstract final class SandboxGeometry {
  static const boardWidth = 390.0;
  static const boardHeight = 844.0;
  static const wallWidth = 360.0;
  static const wallHeight = 480.0;
  static const caster = Rect2(174, 231, 12, 18);

  // The 25px visual lamp stays within the desk at all four center extremes.
  static const controlCenters = Rect2(49, 694, 292, 88);
  // These exact limits let the 36x54 shadow touch all four wall edges.
  static const lightPlane = Rect2(99, 133.5, 162, 213);

  // 360 x 480 wall is uniformly scaled to 337.5 x 450 on the board.
  static const wallOnBoard = Rect2(26.25, 111, 337.5, 450);

  static Point2 controlToLight(Point2 control) {
    final clamped = controlCenters.clampPoint(control);
    final tx = (clamped.x - controlCenters.left) / controlCenters.width;
    final ty = (clamped.y - controlCenters.top) / controlCenters.height;
    return Point2(
      lightPlane.left + tx * lightPlane.width,
      lightPlane.top + ty * lightPlane.height,
    );
  }

  static Rect2 shadowOnWall(Point2 control) =>
      projectRect(caster, controlToLight(control));

  static Rect2 wallRectToBoard(Rect2 wall) {
    final factor = wallOnBoard.height / wallHeight;
    return Rect2(
      wallOnBoard.left + wall.left * factor,
      wallOnBoard.top + wall.top * factor,
      wall.width * factor,
      wall.height * factor,
    );
  }
}
