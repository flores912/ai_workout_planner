import 'package:json_annotation/json_annotation.dart';

import 'exercise.dart';

part 'exercise_set.g.dart';

@JsonEnum()
enum ExerciseSetType { straightSet, superSet }

@JsonSerializable()
class ExerciseSet {
  final int restDurationInSeconds;

  ExerciseSet({required this.restDurationInSeconds,});

  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => _$StraightSetFromJson(json);

}

@JsonSerializable()
class StraightSet extends ExerciseSet {
  final int reps;

  StraightSet({required super.restDurationInSeconds, required this.reps});
  factory StraightSet.fromJson(Map<String, dynamic> json) => _$StraightSetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StraightSetToJson(this);
}

@JsonSerializable()
class SuperSet extends ExerciseSet {
  final Exercise secondExercise;
  final int secondExerciseReps;

  SuperSet({
    required super.restDurationInSeconds,
    required this.secondExercise,
    required this.secondExerciseReps,
  });

  factory SuperSet.fromJson(Map<String, dynamic> json) => _$SuperSetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SuperSetToJson(this);
}



