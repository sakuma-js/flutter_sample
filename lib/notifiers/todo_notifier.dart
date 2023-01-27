import 'package:flutter_riverpod/flutter_riverpod.dart';

import './../models/todo.dart';

// UI側から操作可能にする
final todoProvider = StateNotifierProvider<TodosNotifier, List<Todo>>((ref) =>
  TodosNotifier()
);

class TodosNotifier extends StateNotifier<List<Todo>> {
  TodosNotifier() : super([]);

  void set(List<Todo> items) {
    state = items;
  }

  void add(Todo item) {
    state = [...state, item];
  }

  void remove(String id) {
    state = state.where((t) => t.id != id).toList();
  }

  void toggleDone(String id) {
    state = state
        .map((t) => t.id == id ? t.copyWith(done: !t.done) : t)
        .toList();
  }

  void edit(Todo item) {
    state = state
        .map((t) => t.id == item.id ? item : t)
        .toList();
  }

  List<Todo> match(String text) {
    return state.where((t) => t.text.contains(text)).toList();
  }
}