import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ball_handler/editor/editor_app.dart';

void main() {
  if (kReleaseMode) {
    throw StateError('Editor chỉ dành cho build dev.');
  }
  runApp(const MaterialApp(home: EditorApp()));
}
