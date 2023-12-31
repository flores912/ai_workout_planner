// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Day _$DayFromJson(Map<String, dynamic> json) => Day(
      workout: json['workout'] == null
          ? null
          : Workout.fromJson(json['workout'] as Map<String, dynamic>),
      isRestDay: json['isRestDay'] as bool,
      workoutSplit: json['workoutSplit'] as String,
    );

Map<String, dynamic> _$DayToJson(Day instance) => <String, dynamic>{
      'workout': instance.workout,
      'isRestDay': instance.isRestDay,
      'workoutSplit': instance.workoutSplit,
    };
