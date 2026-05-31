import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/task.dart';

//по сути локал-сторадж, только для мобилки
class TaskStorage {
  static const _key = 'tasks';

  Future<List<Task>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List;
    return list.map((e) => Task.fromJson(e)).toList();
  }

  Future<void> save(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
