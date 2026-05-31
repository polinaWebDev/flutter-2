import 'package:flutter/foundation.dart';

import '../data/task_storage.dart';
import '../model/task.dart';

enum SortMode { byDate, byPriority }

enum FilterMode { all, active, done }

class TaskViewModel extends ChangeNotifier {
  //event-emitter
  final TaskStorage _storage;
  final List<Task> _tasks = []; //источник правды

  SortMode _sortMode = SortMode.byDate;
  FilterMode _filterMode = FilterMode.all;

  TaskViewModel(this._storage);

  SortMode get sortMode => _sortMode;
  FilterMode get filterMode => _filterMode;

  //список с учётом фильтра + сортировки
  List<Task> get visibleTasks {
    final result = _tasks.where((task) {
      if (_filterMode == FilterMode.active) return !task.isDone;
      if (_filterMode == FilterMode.done) return task.isDone;
      return true;
    }).toList();

    result.sort(
      (a, b) => _sortMode == SortMode.byDate
          ? b.createdAt.compareTo(a.createdAt)
          : b.priority.index.compareTo(a.priority.index),
    );

    return result;
  }

  Future<void> init() async {
    final saved = await _storage.load();
    _tasks.clear();
    _tasks.addAll(saved);
    notifyListeners();
  }

  void addTask(String title, Priority priority) {
    _tasks.add(Task(title: title, priority: priority, createdAt: DateTime.now()));
    _persist();
  }

  void editTask(Task task, String title, Priority priority, bool isDone) {
    task.title = title;
    task.priority = priority;
    task.isDone = isDone;
    _persist();
  }

  void toggleDone(Task task, bool value) {
    task.isDone = value;
    _persist();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    _persist();
  }

  void setSort(SortMode mode) {
    _sortMode = mode;
    notifyListeners();
  }

  void setFilter(FilterMode mode) {
    _filterMode = mode;
    notifyListeners();
  }

  //сохранить в стор и дёрнуть ребилд
  void _persist() {
    _storage.save(_tasks);
    notifyListeners();
  }
}
