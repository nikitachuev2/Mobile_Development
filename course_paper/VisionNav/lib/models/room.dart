class Room {
  final int? id;
  final int userId;
  final double width;
  final double depth;
  final String createdAt;

  Room({
    this.id,
    required this.userId,
    required this.width,
    required this.depth,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'width': width,
      'depth': depth,
      'created_at': createdAt,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as int?,
      userId: (map['user_id'] as int?) ?? 0,
      width: (map['width'] as num).toDouble(),
      depth: (map['depth'] as num).toDouble(),
      createdAt: map['created_at'] as String,
    );
  }

  Room copyWith({
    int? id,
    int? userId,
    double? width,
    double? depth,
    String? createdAt,
  }) {
    return Room(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      width: width ?? this.width,
      depth: depth ?? this.depth,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
