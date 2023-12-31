// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) => ExerciseSet(
      restDurationInSeconds: json['restDurationInSeconds'] as int,
      exerciseSetType:
          $enumDecode(_$ExerciseSetTypeEnumMap, json['exerciseSetType']),
    );

Map<String, dynamic> _$ExerciseSetToJson(ExerciseSet instance) =>
    <String, dynamic>{
      'exerciseSetType': _$ExerciseSetTypeEnumMap[instance.exerciseSetType]!,
      'restDurationInSeconds': instance.restDurationInSeconds,
    };

const _$ExerciseSetTypeEnumMap = {
  ExerciseSetType.straightSet: 'straightSet',
  ExerciseSetType.superSet: 'superSet',
};

StraightSet _$StraightSetFromJson(Map<String, dynamic> json) => StraightSet(
      restDurationInSeconds: json['restDurationInSeconds'] as int,
      reps: json['reps'] as int,
      exerciseSetType:
          $enumDecode(_$ExerciseSetTypeEnumMap, json['exerciseSetType']),
    );

Map<String, dynamic> _$StraightSetToJson(StraightSet instance) =>
    <String, dynamic>{
      'exerciseSetType': _$ExerciseSetTypeEnumMap[instance.exerciseSetType]!,
      'restDurationInSeconds': instance.restDurationInSeconds,
      'reps': instance.reps,
    };

SuperSet _$SuperSetFromJson(Map<String, dynamic> json) => SuperSet(
      restDurationInSeconds: json['restDurationInSeconds'] as int,
      secondExercise:
          Exercise.fromJson(json['secondExercise'] as Map<String, dynamic>),
      secondExerciseReps: json['secondExerciseReps'] as int,
      firstExercise:
          Exercise.fromJson(json['firstExercise'] as Map<String, dynamic>),
      firstExerciseReps: json['firstExerciseReps'] as int,
      exerciseSetType:
          $enumDecode(_$ExerciseSetTypeEnumMap, json['exerciseSetType']),
    );

Map<String, dynamic> _$SuperSetToJson(SuperSet instance) => <String, dynamic>{
      'exerciseSetType': _$ExerciseSetTypeEnumMap[instance.exerciseSetType]!,
      'restDurationInSeconds': instance.restDurationInSeconds,
      'firstExercise': instance.firstExercise,
      'firstExerciseReps': instance.firstExerciseReps,
      'secondExercise': instance.secondExercise,
      'secondExerciseReps': instance.secondExerciseReps,
    };
