// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutPlan _$WorkoutPlanFromJson(Map<String, dynamic> json) => WorkoutPlan(
      name: json['name'] as String,
      numberOfWeeks: json['numberOfWeeks'] as int,
      weekSchedule: Week.fromJson(json['weekSchedule'] as Map<String, dynamic>),
      description: json['description'] as String,
    );

Map<String, dynamic> _$WorkoutPlanToJson(WorkoutPlan instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'numberOfWeeks': instance.numberOfWeeks,
      'weekSchedule': instance.weekSchedule,
    };
