// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Week _$WeekFromJson(Map<String, dynamic> json) => Week(
      weekNumber: json['weekNumber'] as int?,
      day1: Day.fromJson(json['day1'] as Map<String, dynamic>),
      day2: Day.fromJson(json['day2'] as Map<String, dynamic>),
      day3: Day.fromJson(json['day3'] as Map<String, dynamic>),
      day4: Day.fromJson(json['day4'] as Map<String, dynamic>),
      day5: Day.fromJson(json['day5'] as Map<String, dynamic>),
      day6: Day.fromJson(json['day6'] as Map<String, dynamic>),
      day7: Day.fromJson(json['day7'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WeekToJson(Week instance) => <String, dynamic>{
      'weekNumber': instance.weekNumber,
      'day1': instance.day1,
      'day2': instance.day2,
      'day3': instance.day3,
      'day4': instance.day4,
      'day5': instance.day5,
      'day6': instance.day6,
      'day7': instance.day7,
    };
