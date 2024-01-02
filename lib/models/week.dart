import 'package:json_annotation/json_annotation.dart';

import 'day.dart';
part 'week.g.dart';

@JsonSerializable()
class Week{
  final int? weekNumber;
  final Day monday;
  final Day tuesday;
  final Day wednesday;
  final Day thursday;
  final Day friday;
  final Day saturday;
  final Day sunday;

  Week( {this.weekNumber,required this.monday, required this.tuesday, required this.wednesday, required this.thursday, required this.friday, required this.saturday, required this.sunday});


  factory Week.fromJson(Map<String, dynamic> json) => _$WeekFromJson(json);
  Map<String, dynamic> toJson() => _$WeekToJson(this);
}
