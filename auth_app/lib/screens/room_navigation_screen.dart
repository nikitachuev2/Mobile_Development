import 'dart:math';

import 'package:flutter/material.dart';
import 'package:csounddart/csound.dart';

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
  // Параметры шага и скорости звука
  static const double _stepMeters = 1.0;
  static const double _speedOfSound = 343.0; // м/с

  late Csound _csound;
  bool _csoundReady = false;
  bool _csoundError = false;

  // Текущее положение в помещении (в метрах)
  late double _posX;
  late double _posY;

  // Csound CSD-текст с твоим алгоритмом эхо-навигации (адаптирован)
  static const String _csdText = r'''
<CsoundSynthesizer>
<CsOptions>
-odac -m0
</CsOptions>

<CsInstruments>
sr = 44100
ksmps = 32
nchnls = 2
0dbfs = 1

gaDel init 0

; instr 1 — короткий шумовой пинг (запускается из Flutter при каждом шаге)
instr 1
  kEnv linseg 0, 0.01, 1, 0.1, 1, 0.05, 0
  aNoise rand 0.5 * kEnv
  outs aNoise, aNoise
  gaDel = gaDel + aNoise * 0.3
endin

; instr 2 — непрерывное эхо, зависящее от времени задержки kTime
instr 2
  kTime chnget "kTime"
  aIn tone gaDel, 3800
  aDel delayr 1
  aTap deltapi kTime
  delayw aIn + aTap * 0.3
  gaDel = 0
  outs aTap, aTap
endin

</CsInstruments>

<CsScore>
; Запускаем только инструмент 2, он работает всё время.
i 2 0 3600
</CsScore>
</CsoundSynthesizer>
''';

  @override
  void initState() {
    super.initState();

    // Стартовая позиция: центр помещения
    _posX = widget.room.width / 2.0;
    _posY = widget.room.depth / 2.0;

    _initCsound();
  }

  Future<void> _initCsound() async {
    try {
      _csound = Csound();

      final res = await _csound.compileCsdText(_csdText);
      if (res != 0) {
        setState(() {
          _csoundError = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ошибка компиляции Csound. Проверьте логи.'),
            ),
          );
        }
        return;
      }

      // Запуск аудио-потока
      _csound.perform();

      setState(() {
        _csoundReady = true;
      });

      // Первичная установка значения задержки по стартовой позиции
      _updateAudioForPosition();
    } catch (e) {
      setState(() {
        _csoundError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка инициализации Csound: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    if (!_csoundError) {
      // Останавливаем Csound при выходе с экрана
      _csound.stop();
      _csound.destroy();
    }
    super.dispose();
  }

  // Обновляем параметр kTime в Csound в зависимости от текущей позиции
  void _updateAudioForPosition() {
    if (!_csoundReady) return;

    final width = widget.room.width;
    final depth = widget.room.depth;

    // Расстояние до каждой стены
    final distLeft = _posX;
    final distRight = width - _posX;
    final distFront = _posY;
    final distBack = depth - _posY;

    final nearest = min(
      min(distLeft, distRight),
      min(distFront, distBack),
    );

    // Время задержки эха: туда-обратно до ближайшей стены
    double time = (2.0 * nearest / _speedOfSound);
    // Ограничим разумный диапазон для восприятия
    if (time < 0.05) time = 0.05;
    if (time > 0.7) time = 0.7;

    // Передаём время задержки в Csound
    _csound.setControlChannel("kTime", time);
  }

  // Запускаем шумовой пинг (instr 1) при каждом шаге
  Future<void> _triggerPing() async {
    if (!_csoundReady) return;
    try {
      await _csound.readScore("i1 0 0.2");
    } catch (_) {
      // Игнорируем одиночные ошибки при отправке события
    }
  }

  // Общий метод для попытки перемещения
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
      // Не сдвигаем позицию, но даём короткое эхо как сигнал стены
      _updateAudioForPosition();
      await _triggerPing();

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

    setState(() {
      _posX = newX;
      _posY = newY;
    });

    _updateAudioForPosition();
    await _triggerPing();
  }

  Future<void> _moveForward() async {
    // Вперёд — уменьшаем y (движение к "передней" стене)
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
          onPressed: _csoundReady ? onPressed : null,
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

    final distLeft = _posX;
    final distRight = width - _posX;
    final distFront = _posY;
    final distBack = depth - _posY;
    final nearest = min(
      min(distLeft, distRight),
      min(distFront, distBack),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Навигация по помещению'),
      ),
      body: SafeArea(
        child: Semantics(
          label:
              'Экран навигации по выбранному прямоугольному помещению. '
              'Используйте четыре кнопки для движения вперёд, назад, влево и вправо. '
              'Звуки эха помогают оценивать расстояние до стен.',
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
                      const SizedBox(height: 8.0),
                      if (!_csoundReady && !_csoundError)
                        const Text(
                          'Идёт инициализация звука. Пожалуйста, подождите...',
                        ),
                      if (_csoundError)
                        const Text(
                          'Произошла ошибка инициализации Csound. '
                          'Звуковая навигация может быть недоступна.',
                          style: TextStyle(color: Colors.red),
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
                      // Вперёд
                      _buildDirectionButton(
                        text: 'Вперёд',
                        semanticsLabel: 'Кнопка движения вперёд',
                        semanticsHint:
                            'Сделать шаг вперёд на один метр по направлению к передней стене.',
                        icon: Icons.arrow_upward,
                        onPressed: _moveForward,
                      ),
                      const SizedBox(height: 16.0),
                      // Влево / Вправо
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
                      // Назад
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
