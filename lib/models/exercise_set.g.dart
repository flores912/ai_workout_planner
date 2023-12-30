// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) => ExerciseSet(
      restDurationInSeconds: json['restDurationInSeconds'] as int,
    );

Map<String, dynamic> _$ExerciseSetToJson(ExerciseSet instance) =>
    <String, dynamic>{
      'restDurationInSeconds': instance.restDurationInSeconds,
    };

StraightSet _$StraightSetFromJson(Map<String, dynamic> json) => StraightSet(
      restDurationInSeconds: json['restDurationInSeconds'] as int,
      reps: json['reps'] as int,
    );

Map<String, dynamic> _$StraightSetToJson(StraightSet instance) =>
    <String, dynamic>{
      'restDurationInSeconds': instance.restDurationInSeconds,
      'reps': instance.reps,
    };

SuperSet _$SuperSetFromJson(Map<String, dynamic> json) => SuperSet(
      restDurationInSeconds: json['restDurationInSeconds'] as int,
      secondExercise:
          Exercise.fromJson(json['secondExercise'] as Map<String, dynamic>),
      secondExerciseReps: json['secondExerciseReps'] as int,
    );

Map<String, dynamic> _$SuperSetToJson(SuperSet instance) => <String, dynamic>{
      'restDurationInSeconds': instance.restDurationInSeconds,
      'secondExercise': instance.secondExercise,
      'secondExerciseReps': instance.secondExerciseReps,
    };
