import 'dart:math';
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Slider Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF0EA5E9),
        textTheme: Typography.whiteCupertino.apply(
          fontSizeFactor: 1.05,
        ),
      ),
      home: const NumberSliderGameScreen(),
    );
  }
}

class NumberSliderGameScreen extends StatefulWidget {
  const NumberSliderGameScreen({super.key});

  @override
  State<NumberSliderGameScreen> createState() =>
      _NumberSliderGameScreenState();
}

class _RoundResult {
  final int round;
  final int target;
  final int guess;
  final int diff;

  const _RoundResult({
    required this.round,
    required this.target,
    required this.guess,
    required this.diff,
  });
}

class _NumberSliderGameScreenState extends State<NumberSliderGameScreen> {
  final Random _random = Random();

  int _round = 0; // 1..3
  int? _target; // hidden number 1..100
  int _sliderValue = 50; // 1..100

  String _statusText =
      'Press "Start round" to begin. You have 3 rounds in total.';

  List<_RoundResult> _results = [];

  bool get _gameOver =>
      _round >= 3 && _target == null && _results.length == 3;

  void _startOrNextRound() {
    setState(() {
      if (_gameOver) {
        _round = 0;
        _results = [];
        _target = null;
        _sliderValue = 50;
        _statusText =
            'New game. Press "Start round" to begin. You have 3 rounds.';
        return;
      }

      if (_target != null) {
        _statusText =
            'Round $_round is in progress. Move the slider and press "Guess".';
        return;
      }

      if (_round >= 3) {
        _statusText =
            'Game finished. Press "Play again" to start a new game.';
        return;
      }

      _round += 1;
      _target = _random.nextInt(100) + 1; // 1..100
      _sliderValue = 50;
      _statusText =
          'Round $_round of 3. Move the slider and press "Guess" to match the hidden number.';
    });
  }

  void _makeGuess() {
    if (_target == null) {
      setState(() {
        _statusText =
            'There is no active round. Press "Start round" first, then move the slider and press "Guess".';
      });
      return;
    }

    final int guess = _sliderValue;
    final int target = _target!;
    final int diff = (target - guess).abs();

    String feedback;
    if (diff == 0) {
      feedback = 'Perfect! Your guess $guess is exactly the target.';
    } else {
      final String relation = guess < target ? 'too low' : 'too high';
      String closeness;
      if (diff <= 3) {
        closeness = 'Very close.';
      } else if (diff <= 10) {
        closeness = 'Close.';
      } else {
        closeness = 'Far from the target.';
      }
      feedback =
          'Your guess $guess is $relation. $closeness The hidden number was $target.';
    }

    setState(() {
      _results = [
        ..._results,
        _RoundResult(round: _round, target: target, guess: guess, diff: diff),
      ];
      _target = null;

      if (_round >= 3) {
        _statusText = '$feedback ${_buildSummaryText()}';
      } else {
        _statusText =
            '$feedback Get ready for the next round. Press "Start round" to continue.';
      }
    });
  }

  String _buildSummaryText() {
    if (_results.isEmpty) {
      return 'Game over.';
    }
    final int count = _results.length;
    final int wins = _results.where((r) => r.diff == 0).length;
    final int totalDiff = _results.fold(0, (sum, r) => sum + r.diff);
    final int bestDiff =
        _results.map((r) => r.diff).reduce((a, b) => a < b ? a : b);
    final double avgDiff = totalDiff / count;

    return 'Game finished. Exact guesses: $wins of $count. '
        'Best distance: $bestDiff. Average distance: ${avgDiff.toStringAsFixed(1)}.';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF020617),
                Color(0xFF0F172A),
                Color(0xFF0B1120),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: cs.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Number Slider Game',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Round ${_round.clamp(0, 3)} / 3',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Guess a hidden number from 1 to 100 using the slider.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Status (liveRegion)
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _statusText,
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Slider card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.white.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.16),
                            width: 1.1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Move the slider, then press "Guess".',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Semantics(
                              liveRegion: true,
                              label: 'Slider position in percent',
                              value: '$_sliderValue percent',
                              child: Text(
                                '$_sliderValue%',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontFeatures: [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '1 is the far left, 100 is the far right.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 8,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 11,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 20,
                                ),
                              ),
                              child: Slider(
                                value: _sliderValue.toDouble(),
                                min: 1,
                                max: 100,
                                divisions: 99,
                                label: '$_sliderValue%',
                                semanticFormatterCallback: (double value) {
                                  return '${value.round()} percent';
                                },
                                onChanged: (double value) {
                                  setState(() {
                                    _sliderValue = value.round();
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  '1',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  '100',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Buttons row
                      Row(
                        children: [
                          Expanded(
                            child: Tooltip(
                              message: _gameOver
                                  ? 'Start a new 3-round game'
                                  : 'Generate a new hidden number for the next round',
                              child: FilledButton(
                                onPressed: _startOrNextRound,
                                style: FilledButton.styleFrom(
                                  minimumSize:
                                      const Size.fromHeight(44),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: Text(
                                  _gameOver
                                      ? 'Play again'
                                      : (_target == null
                                          ? 'Start round'
                                          : 'Round $_round'),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Tooltip(
                              message:
                                  'Send your current slider value as a guess for this round',
                              child: OutlinedButton(
                                onPressed:
                                    _target == null ? null : _makeGuess,
                                style: OutlinedButton.styleFrom(
                                  minimumSize:
                                      const Size.fromHeight(44),
                                  side: BorderSide(
                                    color: _target == null
                                        ? Colors.white24
                                        : cs.primary,
                                    width: 1.3,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(999),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Guess'),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Results chips
                      if (_results.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _results
                                .map(
                                  (r) => Container(
                                    margin:
                                        const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(999),
                                      color: Colors.white.withOpacity(0.06),
                                    ),
                                    child: Text(
                                      'R${r.round}: guess ${r.guess}, target ${r.target}, diff ${r.diff}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
