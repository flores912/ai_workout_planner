import 'package:json_annotation/json_annotation.dart';

import 'exercise_set.dart';
part 'exercise.g.dart';

@JsonSerializable()
class Exercise{
final String name;
final int id;
final Equipment equipment;
final TargetMuscle targetMuscle;
final BodyPart bodyPart;



int?index;
 ExerciseSet? exerciseSet;

 int? numberOfSets;


  Exercise(  {
    required this.id,
    required this.name,
    required this.equipment,
    required this.targetMuscle,
    required this.bodyPart,
    this.index,
    this.exerciseSet,
    this.numberOfSets,
  });

  //path to gif demo asset
 String get gifAsset => 'lib/assets/exercise_gifs/exercise_$id.gif';


factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);
Map<String, dynamic> toJson() => _$ExerciseToJson(this);
}
@JsonEnum()
enum Equipment {
  assisted,
  band,
  barbell,
  @JsonValue('body weight')
  bodyWeight,
  @JsonValue('bosu ball')
  bosuBall,
  cable,
  dumbbell,
  @JsonValue('elliptical machine')
  ellipticalMachine,
  @JsonValue('ez barbell')
  ezBarbell,
  hammer,
  kettlebell,
  @JsonValue('leverage machine')
  leverageMachine,
  @JsonValue('medicine ball')
  medicineBall,
  @JsonValue('olympic barbell')
  olympicBarbell,
  @JsonValue('resistance band')
  resistanceBand,
  roller,
  rope,
  @JsonValue('skierg machine')
  skiergMachine,
  @JsonValue('sled machine')
  sledMachine,
  @JsonValue('smith machine')
  smithMachine,
  @JsonValue('stability ball')
  stabilityBall,
  @JsonValue('stationary bike')
  stationaryBike,
  @JsonValue('stepmill machine')
  stepmillMachine,
  tire,
  @JsonValue('trap bar')
  trapBar,
  @JsonValue('upper body ergometer')
  upperBodyErgometer,
  weighted,
  @JsonValue('wheel roller')
  wheelRoller,
}

@JsonEnum()
enum TargetMuscle {
  abductors,
  abs,
  adductors,
  biceps,
  calves,
  @JsonValue('cardiovascular system')
  cardiovascularSystem,
  delts,
  forearms,
  glutes,
  hamstrings,
  lats,
  @JsonValue('levator scapulae')
  levatorScapulae,
  pectorals,
  quads,
  @JsonValue('serratus anterior')
  serratusAnterior,
  spine,
  traps,
  triceps,
  @JsonValue('upper back')
  upperBack,
}

@JsonEnum()
enum BodyPart {
  back,
  cardio,
  chest,
  @JsonValue('lower arms')
  lowerArms,
  @JsonValue('lower legs')
  lowerLegs,
  neck,
  shoulders,
  @JsonValue('upper arms')
  upperArms,
  @JsonValue('upper legs')
  upperLegs,
  waist,
}

