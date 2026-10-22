import 'package:ball_handler/core/geometry.dart';
import 'package:ball_handler/game/board_ui_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('board components have visible gaps and preview stays within desk', () {
    expect(
      BoardUiLayout.hint.top - BoardUiLayout.header.bottom,
      greaterThanOrEqualTo(8),
    );
    expect(
      BoardUiLayout.stageFrame.top - BoardUiLayout.hint.bottom,
      greaterThanOrEqualTo(8),
    );
    expect(
      BoardUiLayout.shelf.top - BoardUiLayout.stageFrame.bottom,
      greaterThanOrEqualTo(8),
    );
    expect(
      BoardUiLayout.desk.top - BoardUiLayout.shelf.bottom,
      greaterThanOrEqualTo(10),
    );
    expect(
      BoardUiLayout.preview.left - BoardUiLayout.desk.left,
      greaterThanOrEqualTo(7),
    );
    expect(
      BoardUiLayout.preview.top - BoardUiLayout.desk.top,
      greaterThanOrEqualTo(8),
    );
    expect(
      BoardUiLayout.desk.right - BoardUiLayout.preview.right,
      greaterThanOrEqualTo(7),
    );
    expect(
      BoardUiLayout.desk.bottom - BoardUiLayout.preview.bottom,
      greaterThanOrEqualTo(8),
    );
    expect(BoardUiLayout.stage.left, SandboxGeometry.wallOnBoard.left);
    expect(BoardUiLayout.stage.top, SandboxGeometry.wallOnBoard.top);
    expect(BoardUiLayout.stage.width, SandboxGeometry.wallOnBoard.width);
    expect(BoardUiLayout.stage.height, SandboxGeometry.wallOnBoard.height);
  });
}
