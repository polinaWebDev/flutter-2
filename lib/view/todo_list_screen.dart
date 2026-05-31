import 'package:flutter/material.dart';

import '../data/task_storage.dart';
import '../model/task.dart';
import '../viewmodel/task_view_model.dart';
import 'task_dialog.dart';
import 'task_tile.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TaskViewModel _viewModel = TaskViewModel(TaskStorage());

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _openAddDialog() {
    showTaskDialog(
      context,
      title: 'Новая задача',
      onSave: (text, priority, _) => _viewModel.addTask(text, priority),
    );
  }

  void _openEditDialog(Task task) {
    showTaskDialog(
      context,
      title: 'Редактировать задачу',
      initialText: task.title,
      initialPriority: task.priority,
      initialDone: task.isDone,
      showDoneSwitch: true,
      onSave: (text, priority, isDone) => _viewModel.editTask(task, text, priority, isDone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список дел'),
        actions: [
          //сортировка
          PopupMenuButton<SortMode>(
            icon: const Icon(Icons.sort),
            tooltip: 'Сортировка',
            onSelected: _viewModel.setSort,
            itemBuilder: (context) => const [
              PopupMenuItem(value: SortMode.byDate, child: Text('По дате создания')),
              PopupMenuItem(value: SortMode.byPriority, child: Text('По важности')),
            ],
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          final tasks = _viewModel.visibleTasks;
          return Column(
            children: [
              _buildFilters(),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'Задач нет.\nНажмите + чтобы добавить.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskTile(
                            task: task,
                            onToggleDone: (value) => _viewModel.toggleDone(task, value),
                            onEdit: () => _openEditDialog(task),
                            onDelete: () => _viewModel.deleteTask(task),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _filterChip('Все', FilterMode.all),
          const SizedBox(width: 8),
          _filterChip('Активные', FilterMode.active),
          const SizedBox(width: 8),
          _filterChip('Выполненные', FilterMode.done),
        ],
      ),
    );
  }

  Widget _filterChip(String label, FilterMode mode) {
    return ChoiceChip(
      label: Text(label),
      selected: _viewModel.filterMode == mode,
      onSelected: (_) => _viewModel.setFilter(mode),
    );
  }
}
