import 'package:ai_workout_planner/models/week.dart';
import 'package:json_annotation/json_annotation.dart';
part 'workout_plan.g.dart';

@JsonSerializable()
class WorkoutPlan{
  final String name;
  final String description;
 final int numberOfWeeks;
 final  Week weekSchedule;



  WorkoutPlan({required this.name, required this.numberOfWeeks, required this.weekSchedule,required this.description});


  factory WorkoutPlan.fromJson(Map<String, dynamic> json) => _$WorkoutPlanFromJson(json);
  Map<String, dynamic> toJson() => _$WorkoutPlanToJson(this);
}
