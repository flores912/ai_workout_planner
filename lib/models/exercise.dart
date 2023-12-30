import 'package:json_annotation/json_annotation.dart';

import 'exercise_set.dart';
part 'exercise.g.dart';

@JsonSerializable()
class Exercise{
final String name;
 List<ExerciseSet> sets = [];
  Exercise({
    required this.name,
    required this.sets,
  });

factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}