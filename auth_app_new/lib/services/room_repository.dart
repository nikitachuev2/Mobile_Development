import 'package:sqflite/sqflite.dart';

import '../models/room.dart';
import 'db_helper.dart';

class RoomRepository {
  RoomRepository._internal();
  static final RoomRepository _instance = RoomRepository._internal();
  factory RoomRepository() => _instance;

  final DBHelper _dbHelper = DBHelper.instance;

  Future<Room> createRoom({
    required double width,
    required double depth,
  }) async {
    if (width <= 0 || depth <= 0) {
      throw Exception('Ширина и глубина помещения должны быть больше нуля.');
    }

    final db = _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final room = Room(
      width: width,
      depth: depth,
      createdAt: now,
    );

    final id = await db.insert(
      'rooms',
      room.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return room.copyWith(id: id);
  }

  Future<List<Room>> getAllRooms() async {
    final db = _dbHelper.database;

    final result = await db.query(
      'rooms',
      orderBy: 'id DESC',
    );

    return result.map((map) => Room.fromMap(map)).toList();
  }

  Future<void> deleteRoom(int id) async {
    final db = _dbHelper.database;
    await db.delete(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
