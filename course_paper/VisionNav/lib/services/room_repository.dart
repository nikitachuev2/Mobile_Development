import 'package:sqflite/sqflite.dart';

import '../models/room.dart';
import '../models/column_obstacle.dart';
import 'db_helper.dart';

class RoomRepository {
  RoomRepository._internal();
  static final RoomRepository _instance = RoomRepository._internal();
  factory RoomRepository() => _instance;

  final DBHelper _dbHelper = DBHelper.instance;

  Future<Room> createRoom({
    required int userId,
    required double width,
    required double depth,
  }) async {
    if (width <= 0 || depth <= 0) {
      throw Exception('Ширина и глубина помещения должны быть больше нуля.');
    }

    final db = _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final room = Room(
      userId: userId,
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

  Future<List<Room>> getRoomsForUser(int userId) async {
    final db = _dbHelper.database;
    final result = await db.query(
      'rooms',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
    return result.map((map) => Room.fromMap(map)).toList();
  }

  Future<void> deleteRoom({required int id, required int userId}) async {
    final db = _dbHelper.database;
    await db.delete(
      'rooms',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
  }

  // ------------------------------
  //         К О Л О Н Н Ы
  // ------------------------------

  Future<ColumnObstacle> addColumn({
    required int roomId,
    required double fromFront,
    required double fromLeft,
    required double width,
    required double depth,
  }) async {
    if (fromFront < 0 || fromLeft < 0) {
      throw Exception('Расстояние от стен не может быть отрицательным.');
    }
    if (width <= 0 || depth <= 0) {
      throw Exception('Размеры колонны должны быть больше нуля.');
    }

    final db = _dbHelper.database;
    final now = DateTime.now().toIso8601String();

    final col = ColumnObstacle(
      roomId: roomId,
      fromFront: fromFront,
      fromLeft: fromLeft,
      width: width,
      depth: depth,
      createdAt: now,
    );

    final id = await db.insert(
      'columns',
      col.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return ColumnObstacle(
      id: id,
      roomId: roomId,
      fromFront: fromFront,
      fromLeft: fromLeft,
      width: width,
      depth: depth,
      createdAt: now,
    );
  }

  Future<List<ColumnObstacle>> getColumnsForRoom(int roomId) async {
    final db = _dbHelper.database;
    final result = await db.query(
      'columns',
      where: 'room_id = ?',
      whereArgs: [roomId],
      orderBy: 'id DESC',
    );
    return result.map((m) => ColumnObstacle.fromMap(m)).toList();
  }
}
