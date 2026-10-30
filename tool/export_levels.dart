import 'dart:convert';
import 'dart:io';

import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/core/level_validator.dart';

void main() {
  final issues = validateCatalog(m4Levels);
  if (issues.isNotEmpty) {
    stderr.writeln(issues.join('\n'));
    exitCode = 1;
    return;
  }
  final file = File('data/m4_levels.json');
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(m4Levels.map((l) => l.toJson()).toList())}\n',
  );
  stdout.writeln(
    'Exported ${m4Levels.length} validated levels to ${file.path}',
  );
}
