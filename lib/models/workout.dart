import 'package:json_annotation/json_annotation.dart';

import 'exercise.dart';
part 'workout.g.dart';


@JsonSerializable()
class Workout{
final String name;

List<Exercise>exercises = [];

  Workout({required this.name, required this.exercises});


factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);
Map<String, dynamic> toJson() => _$WorkoutToJson(this);
}

