import 'package:json_annotation/json_annotation.dart';

part 'todo.g.dart';

@JsonSerializable()
class Todo {
  int? id;
  String item;
  bool completed;

  Todo({this.id, required this.item, required this.completed});

  /// Connect the generated [_$TodoFromJson] function to the `fromJson`
  /// factory.
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);

  /// Connect the generated [_$TodoToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  @override
  String toString() => 'Todo{item: $item, completed: $completed}';
}
