// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Week _$WeekFromJson(Map<String, dynamic> json) => Week(
      weekNumber: json['weekNumber'] as int?,
      monday: Day.fromJson(json['monday'] as Map<String, dynamic>),
      tuesday: Day.fromJson(json['tuesday'] as Map<String, dynamic>),
      wednesday: Day.fromJson(json['wednesday'] as Map<String, dynamic>),
      thursday: Day.fromJson(json['thursday'] as Map<String, dynamic>),
      friday: Day.fromJson(json['friday'] as Map<String, dynamic>),
      saturday: Day.fromJson(json['saturday'] as Map<String, dynamic>),
      sunday: Day.fromJson(json['sunday'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WeekToJson(Week instance) => <String, dynamic>{
      'weekNumber': instance.weekNumber,
      'monday': instance.monday,
      'tuesday': instance.tuesday,
      'wednesday': instance.wednesday,
      'thursday': instance.thursday,
      'friday': instance.friday,
      'saturday': instance.saturday,
      'sunday': instance.sunday,
    };
