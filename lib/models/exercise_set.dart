import 'package:json_annotation/json_annotation.dart';


part 'exercise_set.g.dart';

@JsonEnum()
enum ExerciseSetType { straight,timed,failure }

@JsonSerializable()
class ExerciseSet {
  final ExerciseSetType exerciseSetType;
  final int restDurationInSeconds;


  final int? reps;
  final int? timedSetInSeconds;



  ExerciseSet(  {required this.restDurationInSeconds,required this.exerciseSetType,this.reps, this.timedSetInSeconds,});

  Map<String, dynamic> toJson() => _$ExerciseSetToJson(this);

  factory ExerciseSet.fromJson(Map<String, dynamic> json) => _$ExerciseSetFromJson(json);

}



