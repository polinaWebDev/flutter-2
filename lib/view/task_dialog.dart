import 'package:flutter/material.dart';

import '../model/task.dart';

typedef OnSaveTask = void Function(String text, Priority priority, bool isDone);

void showTaskDialog(
  BuildContext context, {
  required String title,
  String initialText = '',
  Priority initialPriority = Priority.medium,
  bool initialDone = false,
  bool showDoneSwitch = false,
  required OnSaveTask onSave,
}) {
  final controller = TextEditingController(text: initialText);
  var selectedPriority = initialPriority;
  var isDone = initialDone;

  showDialog(
    context: context,
    builder: (context) {
      //локальный стейт окна, чтобы дропдаун обновлялся
      return StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Текст задачи',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  initialValue: selectedPriority,
                  decoration: const InputDecoration(
                    labelText: 'Важность',
                    border: OutlineInputBorder(),
                  ),
                  items: Priority.values
                      .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setLocalState(() => selectedPriority = value);
                  },
                ),
                if (showDoneSwitch)
                  SwitchListTile(
                    title: const Text('Выполнено'),
                    value: isDone,
                    onChanged: (value) => setLocalState(() => isDone = value),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
              FilledButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;
                  onSave(text, selectedPriority, isDone);
                  Navigator.pop(context);
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      );
    },
  ).then((_) => controller.dispose());
}
