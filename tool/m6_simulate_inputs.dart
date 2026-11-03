import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ball_handler/core/geometry.dart';
import 'package:ball_handler/core/level.dart';
import 'package:ball_handler/core/rules.dart';

/// Synthetic waypoint tolerance probe against the shipping rules.
/// It does not model perception, exploration, or visual correction by people.
class Profile {
  const Profile(this.name, this.jitter, this.durationScale, this.extraWait);
  final String name;
  final double jitter;
  final double durationScale;
  final double extraWait;
}

const profiles = <Profile>[
  Profile('reference', 0, 1, 0),
  Profile('small_offset', 2, 1, 0),
  Profile('medium_offset', 5, 1, 0),
  Profile('hesitant', 2, 1.25, .5),
  Profile('slow_imprecise', 8, 1.35, .8),
];

Map<String, Object?> trial(Level level, Profile profile, int run) {
  final rng = Random(
    20261103 + level.id * 1000 + profiles.indexOf(profile) * 100 + run,
  );
  final attempt = GameAttempt(level)..start();
  for (final step in level.solutionSteps) {
    if (attempt.phase != AttemptPhase.playing) break;
    if (step.lamp == null) {
      attempt.tick(step.seconds * profile.durationScale);
    } else {
      if (profile.extraWait > 0) attempt.tick(profile.extraWait);
      if (attempt.phase != AttemptPhase.playing) break;
      final p = step.lamp!;
      final dx = (rng.nextDouble() * 2 - 1) * profile.jitter;
      final dy = (rng.nextDouble() * 2 - 1) * profile.jitter;
      final target = SandboxGeometry.controlCenters.clampPoint(
        Point2(p.x + dx, p.y + dy),
      );
      attempt.moveLampTimed(target, step.seconds * profile.durationScale);
    }
  }
  if (attempt.phase == AttemptPhase.playing) {
    attempt.tick(level.solutionHoldSeconds);
  }
  return {
    'phase': attempt.phase.name,
    'feedback': attempt.feedback,
    'gateOpen': attempt.gateOpen,
    'insideExit': attempt.insideExit,
    'elapsedSeconds': (60000 - attempt.remainingMs) / 1000,
  };
}

void main() {
  const repeats = 25;
  final rows = <Map<String, Object?>>[];
  for (final level in m4Levels) {
    for (final profile in profiles) {
      var won = 0;
      var lost = 0;
      var incomplete = 0;
      final times = <double>[];
      final reasons = <String, int>{};
      for (var run = 0; run < repeats; run++) {
        final result = trial(level, profile, run);
        final phase = result['phase'] as String;
        if (phase == 'won') {
          won++;
          times.add(result['elapsedSeconds'] as double);
        } else if (phase == 'lost') {
          lost++;
          final reason = result['feedback'] as String;
          reasons[reason] = (reasons[reason] ?? 0) + 1;
        } else {
          incomplete++;
          final feedback = result['feedback'] as String;
          final reason =
              feedback == 'Đạo cụ đang chắn đường bóng.' ||
                  feedback == 'Cửa chắn đang khóa. Hãy chạm công tắc sao.'
              ? feedback
              : result['gateOpen'] == false
              ? 'Chưa mở cửa sau đường mốc'
              : 'Chưa vào trọn cửa sau đường mốc';
          reasons[reason] = (reasons[reason] ?? 0) + 1;
        }
      }
      times.sort();
      rows.add({
        'level': level.id,
        'profile': profile.name,
        'won': won,
        'lost': lost,
        'incomplete': incomplete,
        'medianWinSeconds': times.isEmpty ? null : times[times.length ~/ 2],
        'reasons': reasons,
      });
    }
  }
  final output = {
    'kind': 'synthetic waypoint perturbation, not human playtest',
    'seed': 20261103,
    'repeatsPerLevelProfile': repeats,
    'profiles': [
      for (final p in profiles)
        {
          'name': p.name,
          'waypointOffsetControlPx': p.jitter,
          'moveAndWaitDurationScale': p.durationScale,
          'extraWaitBeforeEachMoveSeconds': p.extraWait,
        },
    ],
    'results': rows,
  };
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(output));
}
