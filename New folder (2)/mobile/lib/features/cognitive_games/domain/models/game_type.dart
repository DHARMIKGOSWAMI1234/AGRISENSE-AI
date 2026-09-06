enum CognitiveGameType {
  spatialPattern('spatial_pattern', 'Spatial Pattern Recognition', '🧩'),
  memoryMatch('memory_match', 'Cultural Memory Match', '👒'),
  routineRecall('routine_recall', 'Daily Routine Recall', '☕'),
  objectAssociation('object_association', 'Object Association', '🧺'),
  reminiscenceStoryboard('reminiscence_storyboard', 'Reminiscence Storyboard', '🖼️');

  final String id;
  final String displayName;
  final String emoji;

  const CognitiveGameType(this.id, this.displayName, this.emoji);

  static CognitiveGameType fromId(String id) {
    return CognitiveGameType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => CognitiveGameType.spatialPattern,
    );
  }
}
