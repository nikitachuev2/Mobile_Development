import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/room.dart';

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

  // Положение пользователя внутри комнаты
  late double _posX;
  late double _posY;

  late final AudioPlayer _stepsPlayer;
  late final AudioPlayer _wallPlayer;

  // true — крутится бесконечный звук столкновения со стеной
  bool _wallPlaying = false;

  // Последняя зафиксированная дистанция до ближайшей стены
  double? _lastWallDistance;

  @override
  void initState() {
    super.initState();

    // Старт — центр помещения
    _posX = widget.room.width / 2.0;
    _posY = widget.room.depth / 2.0;

    _stepsPlayer = AudioPlayer();
    _wallPlayer = AudioPlayer();

    // Запоминаем начальную дистанцию до стен,
    // но НИЧЕГО не играем до первого шага.
    _lastWallDistance = _nearestWallDistance();
  }

  @override
  void dispose() {
    _stepsPlayer.dispose();
    _wallPlayer.dispose();
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
  // Сейчас громкость по дистанции больше не используется,
  // но оставляю функцию, если захочешь вернуться к градациям.
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
  Future<void> _playWallHitMax() async {
    if (!_wallPlaying) {
      _wallPlaying = true;
      // Включаем бесконечный цикл wall.mp3
      await _wallPlayer.stop();
      await _wallPlayer.setReleaseMode(ReleaseMode.loop);
      await _wallPlayer.play(
        AssetSource('sounds/wall.mp3'),
        volume: 1.0,
      );
    } else {
      await _wallPlayer.setVolume(1.0);
    }
  }

  // === 5. Обновление звука стены при обычном шаге ===
  //
  // Здесь реализована логика:
  // - любой успешный шаг СНАЧАЛА выключает возможный бесконечный звук столкновения
  // - если при этом мы ВПЕРВЫЕ зашли в зону <= 2 метров,
  //   то проигрываем wall.mp3 ОДИН раз (без цикла)
  Future<void> _updateWallSound() async {
    final nearest = _nearestWallDistance();

    // Любой успешный шаг — мы больше не "врезаемся" в стену.
    // Останавливаем циклический звук, если он был.
    if (_wallPlaying) {
      await _wallPlayer.stop();
      _wallPlaying = false;
    }

    // Однократный звук при подходе на 2 шага:
    // переход из зоны > 2 м в зону <= 2 м.
    final prev = _lastWallDistance ?? double.infinity;

    if (prev > 2.0 && nearest <= 2.0) {
      // Проиграть один раз, без цикла
      await _wallPlayer.setReleaseMode(ReleaseMode.stop);
      await _wallPlayer.stop();
      await _wallPlayer.play(
        AssetSource('sounds/wall.mp3'),
        volume: 1.0,
      );
    }

    _lastWallDistance = nearest;
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

    if (hitWall) {
      // Удар о стену: координаты НЕ меняются
      await _playStepSound();
      await _playWallHitMax(); // стена звучит циклично на максимуме

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы упёрлись в стену. Дальше пройти нельзя.'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    // Обычный шаг
    setState(() {
      _posX = newX;
      _posY = newY;
    });

    await _playStepSound();
    await _updateWallSound();
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
                padding: const EdgeInsets.all(16.0),
                child: Semantics(
                  label:
                      'Размер помещения: ширина ${width.toStringAsFixed(1)} метров, '
                      'глубина ${depth.toStringAsFixed(1)} метров. '
                      'Текущая позиция: ${_posX.toStringAsFixed(1)} метров по ширине '
                      'и ${_posY.toStringAsFixed(1)} метров по глубине. '
                      'Ближайшая стена на расстоянии '
                      '${nearest.toStringAsFixed(1)} метров.',
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
                        'Ближайшая стена: ${nearest.toStringAsFixed(1)} м',
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
