import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

import '../models/room.dart';
import '../models/column_obstacle.dart';
import '../services/room_repository.dart';

class RoomNavigationScreen extends StatefulWidget {
  final Room room;

  const RoomNavigationScreen({
    super.key,
    required this.room,
  });

  @override
  State<RoomNavigationScreen> createState() => _RoomNavigationScreenState();
}

class _RoomNavigationScreenState extends State<RoomNavigationScreen> {
  // Шаг в метрах
  static const double _stepMeters = 1.0;

  // Максимальная дистанция, на которой мы начинаем слышать стены (3 шага)
  static const double _wallMaxDistanceMeters = 3.0;

  // Максимальная дистанция, на которой слышно колонну
  static const double _columnMaxDistanceMeters = 2.0;

  // Положение пользователя внутри комнаты
  late double _posX;
  late double _posY;

  late final AudioPlayer _stepsPlayer;
  late final AudioPlayer _wallPlayer;
  late final AudioPlayer _columnPlayer;

  // true — крутится бесконечный звук столкновения со стеной
  bool _wallPlaying = false;

  // true — крутится звук колонны (подход / столкновение)
  bool _columnPlaying = false;

  // Последняя зафиксированная дистанция до ближайшей стены
  double? _lastWallDistance;

  List<ColumnObstacle> _columns = const [];
  bool _isLoadingColumns = true;

  final RoomRepository _roomRepository = RoomRepository();

  // Защита от повторяющихся озвучиваний (например, если человек несколько раз жмёт в стену).
  String? _lastAnnounceText;
  DateTime? _lastAnnounceTime;

  @override
  void initState() {
    super.initState();

    // Старт — центр помещения
    _posX = widget.room.width / 2.0;
    _posY = widget.room.depth / 2.0;

    _stepsPlayer = AudioPlayer();
    _wallPlayer = AudioPlayer();
    _columnPlayer = AudioPlayer();

    // Запоминаем начальную дистанцию до стен,
    // но НИЧЕГО не играем до первого шага.
    _lastWallDistance = _nearestWallDistance();

    _loadColumns();
  }

  Future<void> _loadColumns() async {
    if (widget.room.id == null) {
      setState(() {
        _columns = const [];
        _isLoadingColumns = false;
      });
      return;
    }

    try {
      final cols = await _roomRepository.getColumnsForRoom(widget.room.id!);
      if (!mounted) return;
      setState(() {
        _columns = cols;
        _isLoadingColumns = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _columns = const [];
        _isLoadingColumns = false;
      });
    }
  }

  @override
  void dispose() {
    _stepsPlayer.dispose();
    _wallPlayer.dispose();
    _columnPlayer.dispose();
    super.dispose();
  }

  // === 1. Расстояние до ближайшей стены ===
  double _nearestWallDistance() {
    final width = widget.room.width;
    final depth = widget.room.depth;

    final distLeft = _posX;
    final distRight = width - _posX;
    final distFront = _posY;
    final distBack = depth - _posY;

    return min(
      min(distLeft, distRight),
      min(distFront, distBack),
    );
  }

  // === 2. Алгоритм перевода расстояния в громкость стены ===
  //
  // Требование:
  // - 3 шага до стены: ~30%
  // - 2 шага: ~60%
  // - 1 шаг и ближе: 100%
  double _wallVolumeFromDistance(double distance) {
    if (distance >= _wallMaxDistanceMeters) {
      return 0.0; // дальше 3 шагов — стены не слышно
    } else if (distance > 2.0) {
      return 0.3; // примерно 3 шага
    } else if (distance > 1.0) {
      return 0.6; // 2 шага
    } else {
      return 1.0; // 1 шаг и ближе к стене
    }
  }

  double _columnVolumeFromDistance(double distance) {
    if (distance >= _columnMaxDistanceMeters) {
      return 0.0;
    } else if (distance > 1.5) {
      return 0.3;
    } else if (distance > 1.0) {
      return 0.6;
    } else {
      return 1.0;
    }
  }

  // === 2.1 Геометрия колонн ===
  bool _isInsideColumn(double x, double y, ColumnObstacle c) {
    final left = c.fromLeft;
    final right = c.fromLeft + c.width;
    final top = c.fromFront;
    final bottom = c.fromFront + c.depth;
    return (x >= left && x <= right && y >= top && y <= bottom);
  }

  double _distancePointToRect(double x, double y, ColumnObstacle c) {
    final left = c.fromLeft;
    final right = c.fromLeft + c.width;
    final top = c.fromFront;
    final bottom = c.fromFront + c.depth;

    final dx = (x < left)
        ? left - x
        : (x > right)
            ? x - right
            : 0.0;
    final dy = (y < top)
        ? top - y
        : (y > bottom)
            ? y - bottom
            : 0.0;
    return sqrt(dx * dx + dy * dy);
  }

  double _nearestColumnDistance(double x, double y) {
    if (_columns.isEmpty) return double.infinity;
    var best = double.infinity;
    for (final c in _columns) {
      final d = _distancePointToRect(x, y, c);
      if (d < best) best = d;
    }
    return best;
  }

  // === 3. Звук шагов ===
  Future<void> _playStepSound() async {
    await _stepsPlayer.stop();
    await _stepsPlayer.play(
      AssetSource('sounds/steps.mp3'),
    );
  }

  // === 4. Специальный сценарий при ударе о стену ===
  //
  // При ударе:
  // - всегда включаем стену с громкостью 1.0
  // - звук стены идёт по кругу, пока пользователь не сделает успешный шаг
  // - включаем вибрацию на 3 секунды
  Future<void> _playWallHitMax() async {
    _wallPlaying = true;
    // На столкновении всегда перезапускаем звук, чтобы он был отчётливо слышен.
    await _wallPlayer.stop();
    await _wallPlayer.setReleaseMode(ReleaseMode.loop);
    await _wallPlayer.play(
      AssetSource('sounds/wall.mp3'),
      volume: 1.0,
    );
    await _vibrate3s();
  }

  Future<void> _playColumnHitMax() async {
    _columnPlaying = true;
    await _columnPlayer.stop();
    await _columnPlayer.setReleaseMode(ReleaseMode.loop);
    await _columnPlayer.play(
      AssetSource('sounds/colon.mp3'),
      volume: 1.0,
    );
    await _vibrate3s();
  }

  Future<void> _vibrate3s() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 3000);
      }
    } catch (_) {
      // если вибрация недоступна — просто игнорируем
    }
  }

  void _announce(String text) {
    // Простая защита от повторов (например, если человек несколько раз жмёт в стену)
    final now = DateTime.now();
    if (_lastAnnounceText == text &&
        _lastAnnounceTime != null &&
        now.difference(_lastAnnounceTime!).inMilliseconds < 900) {
      return;
    }
    _lastAnnounceText = text;
    _lastAnnounceTime = now;

    try {
      // Озвучивание для TalkBack/скринридера
      final dir = Directionality.maybeOf(context) ?? TextDirection.ltr;
      SemanticsService.announce(text, dir);
    } catch (_) {
      // ignore
    }
  }

  void _showNotification(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // === 5. Обновление звука стены при обычном шаге ===
  //
  // Требование: внутри 3 метров звук цикличен и меняет громкость.
  Future<void> _updateWallSound() async {
    final nearest = _nearestWallDistance();
    final vol = _wallVolumeFromDistance(nearest);

    if (vol <= 0.0) {
      if (_wallPlaying) {
        await _wallPlayer.stop();
        _wallPlaying = false;
      }
      _lastWallDistance = nearest;
      return;
    }

    if (!_wallPlaying) {
      _wallPlaying = true;
      await _wallPlayer.stop();
      await _wallPlayer.setReleaseMode(ReleaseMode.loop);
      await _wallPlayer.play(
        AssetSource('sounds/wall.mp3'),
        volume: vol,
      );
    } else {
      await _wallPlayer.setVolume(vol);
    }

    _lastWallDistance = nearest;
  }

  Future<void> _updateColumnSound() async {
    final d = _nearestColumnDistance(_posX, _posY);
    final vol = _columnVolumeFromDistance(d);
    if (vol <= 0.0) {
      if (_columnPlaying) {
        await _columnPlayer.stop();
        _columnPlaying = false;
      }
      return;
    }

    if (!_columnPlaying) {
      _columnPlaying = true;
      await _columnPlayer.stop();
      await _columnPlayer.setReleaseMode(ReleaseMode.loop);
      await _columnPlayer.play(
        AssetSource('sounds/colon.mp3'),
        volume: vol,
      );
    } else {
      await _columnPlayer.setVolume(vol);
    }
  }

  // === 6. Общая логика перемещения ===
  //
  // - Считаем новую позицию.
  // - Если удар о стену — НЕ двигаем координаты:
  //     * проигрываем шаг
  //     * включаем бесконечный звук стены (столкновение)
  // - Если шаг успешный — двигаем позицию,
  //     * проигрываем шаг
  //     * обновляем логику звука стены:
  //         - выключаем цикл, если он играл
  //         - при заходе в зону 2 м — один раз wall.mp3
  Future<void> _tryMove({
    required double dx,
    required double dy,
  }) async {
    final newX = _posX + dx;
    final newY = _posY + dy;

    final width = widget.room.width;
    final depth = widget.room.depth;

    final hitWall =
        (newX <= 0) || (newX >= width) || (newY <= 0) || (newY >= depth);

    String? wallSide;
    if (hitWall) {
      final sides = <String>[];
      if (newY <= 0) sides.add('передняя');
      if (newY >= depth) sides.add('задняя');
      if (newX <= 0) sides.add('левая');
      if (newX >= width) sides.add('правая');
      wallSide = sides.isEmpty ? null : sides.join(' и ');
    }

    final hitColumn = _columns.any((c) => _isInsideColumn(newX, newY, c));

    if (hitWall) {
      // Удар о стену: координаты НЕ меняются
      await _playStepSound();
      await _playWallHitMax(); // звук+вибрация

      final message = wallSide == null
          ? 'Вы упёрлись в стену. Дальше пройти нельзя.'
          : 'Вы упёрлись в ${wallSide} стену. Дальше пройти нельзя.';
      _announce(message);
      _showNotification(message);
      return;
    }

    if (hitColumn) {
      await _playStepSound();

      // Колонна: звук + вибрация + уведомление/озвучивание
      await _playColumnHitMax();

      const message = 'Вы столкнулись с колонной. Дальше пройти нельзя.';
      _announce(message);
      _showNotification(message);
      return;
    }

    // Обычный шаг
    setState(() {
      _posX = newX;
      _posY = newY;
    });

    await _playStepSound();
    await _updateWallSound();
    await _updateColumnSound();
  }

  Future<void> _moveForward() async {
    await _tryMove(dx: 0.0, dy: -_stepMeters);
  }

  Future<void> _moveBackward() async {
    await _tryMove(dx: 0.0, dy: _stepMeters);
  }

  Future<void> _moveLeft() async {
    await _tryMove(dx: -_stepMeters, dy: 0.0);
  }

  Future<void> _moveRight() async {
    await _tryMove(dx: _stepMeters, dy: 0.0);
  }

  Widget _buildDirectionButton({
    required String text,
    required String semanticsLabel,
    required String semanticsHint,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      hint: semanticsHint,
      child: SizedBox(
        width: 140,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(text),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.room.width;
    final depth = widget.room.depth;
    final nearest = _nearestWallDistance();
    final nearestCol = _nearestColumnDistance(_posX, _posY);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Навигация по помещению'),
      ),
      body: SafeArea(
        child: Semantics(
          label:
              'Экран навигации по выбранному прямоугольному помещению. '
              'Используйте четыре кнопки для движения вперёд, назад, влево и вправо. '
              'Звук шагов и звук стен помогают ориентироваться в помещении.',
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Semantics(
                  label:
                      'Координаты пользователя. По ширине ${_posX.toStringAsFixed(1)} метров. '
                      'По глубине ${_posY.toStringAsFixed(1)} метров.',
                  child: Text(
                    'Координаты: X=${_posX.toStringAsFixed(1)} м, Y=${_posY.toStringAsFixed(1)} м',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Semantics(
                  label:
                      'Размер помещения: ширина ${width.toStringAsFixed(1)} метров, '
                      'глубина ${depth.toStringAsFixed(1)} метров. '
                      'Текущая позиция: ${_posX.toStringAsFixed(1)} метров по ширине '
                      'и ${_posY.toStringAsFixed(1)} метров по глубине. '
                      'Ближайшая стена на расстоянии '
                      '${nearest.toStringAsFixed(1)} метров. '
                      '${_isLoadingColumns ? 'Колонны загружаются.' : _columns.isEmpty ? 'В помещении нет колонн.' : 'Ближайшая колонна на расстоянии ${nearestCol.toStringAsFixed(1)} метров.'}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Выбранное помещение',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Ширина: ${width.toStringAsFixed(1)} м, '
                        'глубина: ${depth.toStringAsFixed(1)} м.',
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Текущее положение:\n'
                        '• по ширине: ${_posX.toStringAsFixed(1)} м\n'
                        '• по глубине: ${_posY.toStringAsFixed(1)} м\n'
                        'Ближайшая стена: ${nearest.toStringAsFixed(1)} м\n'
                        '${_isLoadingColumns ? 'Колонны: загрузка…' : _columns.isEmpty ? 'Колонны: нет' : 'Ближайшая колонна: ${nearestCol.toStringAsFixed(1)} м'}',
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildDirectionButton(
                        text: 'Вперёд',
                        semanticsLabel: 'Кнопка движения вперёд',
                        semanticsHint:
                            'Сделать шаг вперёд на один метр по направлению к передней стене.',
                        icon: Icons.arrow_upward,
                        onPressed: _moveForward,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDirectionButton(
                            text: 'Влево',
                            semanticsLabel: 'Кнопка движения влево',
                            semanticsHint:
                                'Сделать шаг влево на один метр по направлению к левой стене.',
                            icon: Icons.arrow_back,
                            onPressed: _moveLeft,
                          ),
                          const SizedBox(width: 16.0),
                          _buildDirectionButton(
                            text: 'Вправо',
                            semanticsLabel: 'Кнопка движения вправо',
                            semanticsHint:
                                'Сделать шаг вправо на один метр по направлению к правой стене.',
                            icon: Icons.arrow_forward,
                            onPressed: _moveRight,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      _buildDirectionButton(
                        text: 'Назад',
                        semanticsLabel: 'Кнопка движения назад',
                        semanticsHint:
                            'Сделать шаг назад на один метр по направлению к задней стене.',
                        icon: Icons.arrow_downward,
                        onPressed: _moveBackward,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Semantics(
                  button: true,
                  label: 'Кнопка возврата на главный экран',
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Вернуться на главный экран'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
