import 'package:flutter/material.dart';

import '../models/room.dart';
import '../services/room_repository.dart';
import '../widgets/app_text_field.dart';
import 'room_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _widthController = TextEditingController();
  final _depthController = TextEditingController();

  final RoomRepository _roomRepository = RoomRepository();

  List<Room> _rooms = [];
  bool _isLoadingList = false;
  bool _isCreatingRoom = false;
  int? _selectedRoomId;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _widthController.dispose();
    _depthController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoadingList = true;
    });

    try {
      final rooms = await _roomRepository.getAllRooms();
      setState(() {
        _rooms = rooms;
        if (_rooms.isNotEmpty && _selectedRoomId == null) {
          _selectedRoomId = _rooms.first.id;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при загрузке помещений: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingList = false;
        });
      }
    }
  }

  String? _validateDimension(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Введите значение.';
    }
    final numValue = double.tryParse(text.replaceAll(',', '.'));
    if (numValue == null) {
      return 'Введите число, например: 5.0';
    }
    if (numValue <= 0) {
      return 'Значение должно быть больше нуля.';
    }
    return null;
  }

  Future<void> _onCreateRoomPressed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final widthText = _widthController.text.trim().replaceAll(',', '.');
    final depthText = _depthController.text.trim().replaceAll(',', '.');

    final width = double.parse(widthText);
    final depth = double.parse(depthText);

    setState(() {
      _isCreatingRoom = true;
    });

    try {
      final room = await _roomRepository.createRoom(
        width: width,
        depth: depth,
      );

      if (!mounted) return;

      setState(() {
        _rooms.insert(0, room);
        _selectedRoomId = room.id;
        _widthController.clear();
        _depthController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Помещение успешно создано и сохранено.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при создании помещения: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingRoom = false;
        });
      }
    }
  }

  Future<void> _onDeleteRoom(Room room) async {
    if (room.id == null) return;

    await _roomRepository.deleteRoom(room.id!);

    setState(() {
      _rooms.removeWhere((r) => r.id == room.id);
      if (_selectedRoomId == room.id) {
        _selectedRoomId = _rooms.isNotEmpty ? _rooms.first.id : null;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Помещение удалено.'),
        ),
      );
    }
  }

  void _onSelectRoom(Room room) {
    setState(() {
      _selectedRoomId = room.id;
    });
  }

  void _onStartNavigationPressed() {
    if (_rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала создайте хотя бы одно помещение.'),
        ),
      );
      return;
    }

    final selected = _rooms.firstWhere(
      (room) => room.id == _selectedRoomId,
      orElse: () => _rooms.first,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RoomNavigationScreen(room: selected),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> listChildren = [];

    listChildren.addAll([
      const SizedBox(height: 8.0),
      Text(
        'Генерация прямоугольных помещений',
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8.0),
      const Text(
        'Задайте ширину и глубину помещения, чтобы создать прямоугольную комнату. '
        'Все созданные помещения сохраняются в списке ниже.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24.0),
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _widthController,
              label: 'Ширина помещения (в метрах)',
              hint: 'Введите ширину, например 5.0',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              validator: _validateDimension,
            ),
            const SizedBox(height: 16.0),
            AppTextField(
              controller: _depthController,
              label: 'Глубина помещения (в метрах)',
              hint: 'Введите глубину, например 7.5',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              validator: _validateDimension,
            ),
            const SizedBox(height: 16.0),
            Semantics(
              button: true,
              label: _isCreatingRoom
                  ? 'Кнопка создания помещения, выполняется операция.'
                  : 'Кнопка создания нового помещения',
              child: SizedBox(
                height: 48.0,
                child: ElevatedButton(
                  onPressed: _isCreatingRoom ? null : _onCreateRoomPressed,
                  child: _isCreatingRoom
                      ? const CircularProgressIndicator.adaptive()
                      : const Text('Создать помещение'),
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24.0),
      Text(
        'Список созданных помещений',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8.0),
    ]);

    if (_isLoadingList) {
      listChildren.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      );
    } else if (_rooms.isEmpty) {
      listChildren.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Вы ещё не создали ни одного помещения.',
          ),
        ),
      );
    } else {
      for (var i = 0; i < _rooms.length; i++) {
        final room = _rooms[i];
        final isSelected = room.id == _selectedRoomId;
        final index = _rooms.length - i;

        listChildren.add(
          Semantics(
            selected: isSelected,
            label:
                'Помещение номер $index. Ширина: ${room.width.toStringAsFixed(2)} метров. '
                'Глубина: ${room.depth.toStringAsFixed(2)} метров. '
                '${isSelected ? 'Выбрано для навигации.' : 'Нажмите, чтобы выбрать это помещение.'}',
            child: Card(
              elevation: isSelected ? 4.0 : 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: ListTile(
                onTap: () => _onSelectRoom(room),
                title: Text(
                  'Помещение $index',
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'Ширина: ${room.width.toStringAsFixed(2)} м, '
                  'глубина: ${room.depth.toStringAsFixed(2)} м',
                ),
                trailing: Semantics(
                  button: true,
                  label: 'Удалить помещение номер $index',
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Удалить помещение',
                    onPressed: () => _onDeleteRoom(room),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Главный экран навигации'),
      ),
      body: SafeArea(
        child: Semantics(
          label:
              'Главный экран создания и выбора прямоугольных помещений для навигации',
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: listChildren,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Semantics(
                  button: true,
                  label: _rooms.isEmpty
                      ? 'Кнопка старта навигации недоступна, так как нет помещений.'
                      : 'Кнопка старта навигации по выбранному помещению.',
                  child: SizedBox(
                    width: double.infinity,
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: _rooms.isEmpty
                          ? null
                          : _onStartNavigationPressed,
                      child: const Text('Старт навигации'),
                    ),
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
