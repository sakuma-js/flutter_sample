import 'package:freezed_annotation/freezed_annotation.dart';
part 'todo.freezed.dart';

@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String text,
    required String? memo,
    required String? label,
    required DateTime? dateTime,
    required bool done,
  }) = _Todo;
}