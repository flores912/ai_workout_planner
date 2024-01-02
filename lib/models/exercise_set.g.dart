// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExerciseSet _$ExerciseSetFromJson(Map<String, dynamic> json) => ExerciseSet(
      restDurationInSeconds: json['restDurationInSeconds'] as int,
      exerciseSetType:
          $enumDecode(_$ExerciseSetTypeEnumMap, json['exerciseSetType']),
      reps: json['reps'] as int?,
      timedSetInSeconds: json['timedSetInSeconds'] as int?,
    );

Map<String, dynamic> _$ExerciseSetToJson(ExerciseSet instance) =>
    <String, dynamic>{
      'exerciseSetType': _$ExerciseSetTypeEnumMap[instance.exerciseSetType]!,
      'restDurationInSeconds': instance.restDurationInSeconds,
      'reps': instance.reps,
      'timedSetInSeconds': instance.timedSetInSeconds,
    };

const _$ExerciseSetTypeEnumMap = {
  ExerciseSetType.straight: 'straight',
  ExerciseSetType.timed: 'timed',
  ExerciseSetType.failure: 'failure',
};
