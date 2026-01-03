class ColumnObstacle {
  final int? id;
  final int roomId;

  /// Расстояние от передней стены (ось Y, 0 — передняя стена)
  final double fromFront;

  /// Расстояние от левой стены (ось X, 0 — левая стена)
  final double fromLeft;

  /// Ширина колонны по оси X
  final double width;

  /// Глубина колонны по оси Y
  final double depth;

  final String createdAt;

  const ColumnObstacle({
    this.id,
    required this.roomId,
    required this.fromFront,
    required this.fromLeft,
    required this.width,
    required this.depth,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'room_id': roomId,
      'from_front': fromFront,
      'from_left': fromLeft,
      'width': width,
      'depth': depth,
      'created_at': createdAt,
    };
  }

  factory ColumnObstacle.fromMap(Map<String, dynamic> map) {
    return ColumnObstacle(
      id: map['id'] as int?,
      roomId: map['room_id'] as int,
      fromFront: (map['from_front'] as num).toDouble(),
      fromLeft: (map['from_left'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      depth: (map['depth'] as num).toDouble(),
      createdAt: map['created_at'] as String,
    );
  }
}
