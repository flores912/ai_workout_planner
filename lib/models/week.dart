import 'package:json_annotation/json_annotation.dart';

import 'day.dart';
part 'week.g.dart';

@JsonSerializable()
class Week{
  final int? weekNumber;
  final Day day1;
  final Day day2;
  final Day day3;
  final Day day4;
  final Day day5;
  final Day day6;
  final Day day7;

  Week( {this.weekNumber,required this.day1, required this.day2, required this.day3, required this.day4, required this.day5, required this.day6, required this.day7});


  factory Week.fromJson(Map<String, dynamic> json) => _$WeekFromJson(json);
  Map<String, dynamic> toJson() => _$WeekToJson(this);
}
