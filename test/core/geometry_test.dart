import 'package:ball_handler/core/geometry.dart';
import 'package:ball_handler/core/lamp_drag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('projection S = 3P - 2L', () {
    test('known point and opposite motion', () {
      final shadow = projectPoint(const Point2(4, 7), const Point2(1, 2));
      expect(shadow.x, 10);
      expect(shadow.y, 17);

      final shifted = projectPoint(const Point2(4, 7), const Point2(11, 2));
      expect(shifted.x, shadow.x - 20);
      expect(shifted.y, shadow.y);
    });

    test('rectangle scales 3x and remains inside wall at extreme lights', () {
      final upperRight = projectRect(
        SandboxGeometry.caster,
        const Point2(99, 133.5),
      );
      expect(upperRight.left, 324);
      expect(upperRight.top, 426);
      expect(upperRight.width, 36);
      expect(upperRight.height, 54);
      expect(upperRight.right, SandboxGeometry.wallWidth);
      expect(upperRight.bottom, SandboxGeometry.wallHeight);

      final lowerLeft = projectRect(
        SandboxGeometry.caster,
        const Point2(261, 346.5),
      );
      expect(lowerLeft.left, 0);
      expect(lowerLeft.top, 0);
      expect(lowerLeft.right, lessThanOrEqualTo(SandboxGeometry.wallWidth));
      expect(lowerLeft.bottom, lessThanOrEqualTo(SandboxGeometry.wallHeight));
    });
  });

  group('viewport mapping', () {
    for (final size in [
      const Point2(1366, 768),
      const Point2(360, 800),
      const Point2(390, 844),
    ]) {
      test('round trip and letterbox at ${size.x} x ${size.y}', () {
        final mapper = ViewportMapper.contain(
          viewportWidth: size.x,
          viewportHeight: size.y,
          boardWidth: SandboxGeometry.boardWidth,
          boardHeight: SandboxGeometry.boardHeight,
        );
        final boardPoint = const Point2(220, 715);
        final viewportPoint = mapper.boardToViewport(boardPoint);
        final restored = mapper.viewportToBoard(viewportPoint)!;
        expect(restored.x, closeTo(boardPoint.x, 1e-9));
        expect(restored.y, closeTo(boardPoint.y, 1e-9));
        if (size.x > 390) {
          expect(mapper.viewportToBoard(const Point2(0, 0)), isNull);
        }
        expect(
          mapper.viewportToBoard(const Point2(-10, -10), allowOutside: true),
          isNotNull,
        );
      });
    }
  });

  test('control mapping clamps to light bounds and keeps shadow on wall', () {
    final minLight = SandboxGeometry.controlToLight(const Point2(-999, -999));
    final maxLight = SandboxGeometry.controlToLight(const Point2(999, 999));
    expect(minLight.x, SandboxGeometry.lightPlane.left);
    expect(minLight.y, SandboxGeometry.lightPlane.top);
    expect(maxLight.x, SandboxGeometry.lightPlane.right);
    expect(maxLight.y, SandboxGeometry.lightPlane.bottom);

    for (final control in [
      const Point2(49, 694),
      const Point2(341, 694),
      const Point2(49, 782),
      const Point2(341, 782),
      const Point2(220, 715),
    ]) {
      final rect = SandboxGeometry.shadowOnWall(control);
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(SandboxGeometry.wallWidth));
      expect(rect.bottom, lessThanOrEqualTo(SandboxGeometry.wallHeight));
    }
    final bottomRight = SandboxGeometry.shadowOnWall(const Point2(49, 694));
    final topRight = SandboxGeometry.shadowOnWall(const Point2(49, 782));
    final bottomLeft = SandboxGeometry.shadowOnWall(const Point2(341, 694));
    final topLeft = SandboxGeometry.shadowOnWall(const Point2(341, 782));
    expect(bottomRight.right, SandboxGeometry.wallWidth);
    expect(bottomRight.bottom, SandboxGeometry.wallHeight);
    expect(topRight.right, SandboxGeometry.wallWidth);
    expect(topRight.top, 0);
    expect(bottomLeft.left, 0);
    expect(bottomLeft.bottom, SandboxGeometry.wallHeight);
    expect(topLeft.left, 0);
    expect(topLeft.top, 0);
  });

  test('one pointer preserves grab offset, clamps, and cancels', () {
    final drag = LampDrag();
    expect(drag.begin(1, const Point2(230, 725)), isTrue);
    expect(drag.position.x, 220);
    expect(drag.position.y, 715);
    expect(drag.begin(2, const Point2(220, 715)), isFalse);
    expect(drag.move(2, const Point2(100, 700)), isFalse);
    expect(drag.move(1, const Point2(240, 735)), isTrue);
    expect(drag.position.x, 230);
    expect(drag.position.y, 725);
    expect(drag.move(1, const Point2(-1000, 1000)), isTrue);
    expect(drag.position.x, SandboxGeometry.controlCenters.left);
    expect(drag.position.y, SandboxGeometry.controlCenters.bottom);
    expect(drag.end(2), isFalse);
    expect(drag.end(1), isTrue);
    expect(drag.move(1, const Point2(300, 750)), isFalse);
  });
}
