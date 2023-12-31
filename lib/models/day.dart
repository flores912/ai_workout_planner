import 'package:ai_workout_planner/models/workout.dart';
import 'package:json_annotation/json_annotation.dart';
part 'day.g.dart';
@JsonSerializable()
class Day{
  Workout? workout;
 final bool isRestDay;

  Day({this.workout, required this.isRestDay});


 factory Day.fromJson(Map<String, dynamic> json) => _$DayFromJson(json);
 Map<String, dynamic> toJson() => _$DayToJson(this);


}
