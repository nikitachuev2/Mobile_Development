import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5), // современная палитра
        visualDensity: VisualDensity.standard,
        textTheme: Typography.blackCupertino.apply(fontSizeFactor: 1.05),
      ),
      home: const ClickerScreen(),
    );
  }
}

class ClickerScreen extends StatefulWidget {
  const ClickerScreen({super.key});

  @override
  State<ClickerScreen> createState() => _ClickerScreenState();
}

class _ClickerScreenState extends State<ClickerScreen> {
  int _count = 0;

  void _increment() => setState(() => _count++);
  void _reset() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Заголовок сверху
                  Text(
                    'Hello! This is my first app on Flutter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Карточка со счётчиком: контраст, крупные цифры, Semantics
                  Card(
                    elevation: 4,
                    color: cs.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 28,
                      ),
                      child: Column(
                        children: [
                          Semantics(
                            liveRegion: true,
                            label: 'Counter value',
                            value: '$_count',
                            child: Text(
                              '$_count',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 56,
                                fontFeatures: const [FontFeature.tabularFigures()],
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'times tapped',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Кнопка увеличения
                  SizedBox(
                    width: double.infinity,
                    child: Tooltip(
                      message: 'Increase the counter by one',
                      child: ElevatedButton.icon(
                        onPressed: _increment,
                        icon: const Icon(Icons.add),
                        label: const Text('Click me'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56), // >=48px
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Кнопка сброса
                  SizedBox(
                    width: double.infinity,
                    child: Tooltip(
                      message: 'Reset the counter to zero',
                      child: OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          side: BorderSide(color: cs.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          foregroundColor: cs.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
 
