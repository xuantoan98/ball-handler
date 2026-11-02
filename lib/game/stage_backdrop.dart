/// A distinct decorative wall plate for each authored level.
String stageBackdropPath(int levelId) {
  if (levelId < 1 || levelId > 20) {
    throw RangeError.range(levelId, 1, 20, 'levelId');
  }
  return 'assets/backgrounds/stage-${levelId.toString().padLeft(2, '0')}-v2.webp';
}
