import 'package:json_annotation/json_annotation.dart';

import 'exercise.dart';
part 'workout.g.dart';


@JsonSerializable()
class Workout{
final String name;

final List<Exercise>exercises;

  Workout({required this.name, required this.exercises});

}