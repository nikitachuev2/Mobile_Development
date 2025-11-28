class Room {
  final int? id;
  final double width;
  final double depth;
  final String createdAt;

  Room({
    this.id,
    required this.width,
    required this.depth,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'width': width,
      'depth': depth,
      'created_at': createdAt,
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as int?,
      width: (map['width'] as num).toDouble(),
      depth: (map['depth'] as num).toDouble(),
      createdAt: map['created_at'] as String,
    );
  }

  Room copyWith({
    int? id,
    double? width,
    double? depth,
    String? createdAt,
  }) {
    return Room(
      id: id ?? this.id,
      width: width ?? this.width,
      depth: depth ?? this.depth,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
