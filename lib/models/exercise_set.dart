import 'package:json_annotation/json_annotation.dart';

import 'exercise.dart';

part 'exercise_set.g.dart';

@JsonEnum()
enum ExerciseSetType { straightSet, superSet }

@JsonSerializable()
class ExerciseSet {
  final ExerciseSetType exerciseSetType;
  final int restDurationInSeconds;

  ExerciseSet( {required this.restDurationInSeconds,required this.exerciseSetType,});

  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => _$StraightSetFromJson(json);

}

@JsonSerializable()
class StraightSet extends ExerciseSet {
  final int reps;

  StraightSet({required super.restDurationInSeconds, required this.reps, required super.exerciseSetType});
  factory StraightSet.fromJson(Map<String, dynamic> json) => _$StraightSetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StraightSetToJson(this);
}

@JsonSerializable()
class SuperSet extends ExerciseSet {
  final Exercise firstExercise;
  final int firstExerciseReps;
  final Exercise secondExercise;
  final int secondExerciseReps;

  SuperSet({
    required super.restDurationInSeconds,
    required this.secondExercise,
    required this.secondExerciseReps,
    required this.firstExercise,
    required this.firstExerciseReps,
    required super.exerciseSetType,
  });

  factory SuperSet.fromJson(Map<String, dynamic> json) => _$SuperSetFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SuperSetToJson(this);
}



