// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exercise _$ExerciseFromJson(Map<String, dynamic> json) => Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      equipment: $enumDecode(_$EquipmentEnumMap, json['equipment']),
      targetMuscle: $enumDecode(_$TargetMuscleEnumMap, json['targetMuscle']),
      bodyPart: $enumDecode(_$BodyPartEnumMap, json['bodyPart']),
      index: json['index'] as int?,
      exerciseSet: json['exerciseSet'] == null
          ? null
          : ExerciseSet.fromJson(json['exerciseSet'] as Map<String, dynamic>),
      numberOfSets: json['numberOfSets'] as int?,
    );

Map<String, dynamic> _$ExerciseToJson(Exercise instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'equipment': _$EquipmentEnumMap[instance.equipment]!,
      'targetMuscle': _$TargetMuscleEnumMap[instance.targetMuscle]!,
      'bodyPart': _$BodyPartEnumMap[instance.bodyPart]!,
      'index': instance.index,
      'exerciseSet': instance.exerciseSet,
      'numberOfSets': instance.numberOfSets,
    };

const _$EquipmentEnumMap = {
  Equipment.assisted: 'assisted',
  Equipment.band: 'band',
  Equipment.barbell: 'barbell',
  Equipment.bodyWeight: 'body weight',
  Equipment.bosuBall: 'bosu ball',
  Equipment.cable: 'cable',
  Equipment.dumbbell: 'dumbbell',
  Equipment.ellipticalMachine: 'elliptical machine',
  Equipment.ezBarbell: 'ez barbell',
  Equipment.hammer: 'hammer',
  Equipment.kettlebell: 'kettlebell',
  Equipment.leverageMachine: 'leverage machine',
  Equipment.medicineBall: 'medicine ball',
  Equipment.olympicBarbell: 'olympic barbell',
  Equipment.resistanceBand: 'resistance band',
  Equipment.roller: 'roller',
  Equipment.rope: 'rope',
  Equipment.skiergMachine: 'skierg machine',
  Equipment.sledMachine: 'sled machine',
  Equipment.smithMachine: 'smith machine',
  Equipment.stabilityBall: 'stability ball',
  Equipment.stationaryBike: 'stationary bike',
  Equipment.stepmillMachine: 'stepmill machine',
  Equipment.tire: 'tire',
  Equipment.trapBar: 'trap bar',
  Equipment.upperBodyErgometer: 'upper body ergometer',
  Equipment.weighted: 'weighted',
  Equipment.wheelRoller: 'wheel roller',
};

const _$TargetMuscleEnumMap = {
  TargetMuscle.abductors: 'abductors',
  TargetMuscle.abs: 'abs',
  TargetMuscle.adductors: 'adductors',
  TargetMuscle.biceps: 'biceps',
  TargetMuscle.calves: 'calves',
  TargetMuscle.cardiovascularSystem: 'cardiovascular system',
  TargetMuscle.delts: 'delts',
  TargetMuscle.forearms: 'forearms',
  TargetMuscle.glutes: 'glutes',
  TargetMuscle.hamstrings: 'hamstrings',
  TargetMuscle.lats: 'lats',
  TargetMuscle.levatorScapulae: 'levator scapulae',
  TargetMuscle.pectorals: 'pectorals',
  TargetMuscle.quads: 'quads',
  TargetMuscle.serratusAnterior: 'serratus anterior',
  TargetMuscle.spine: 'spine',
  TargetMuscle.traps: 'traps',
  TargetMuscle.triceps: 'triceps',
  TargetMuscle.upperBack: 'upper back',
};

const _$BodyPartEnumMap = {
  BodyPart.back: 'back',
  BodyPart.cardio: 'cardio',
  BodyPart.chest: 'chest',
  BodyPart.lowerArms: 'lower arms',
  BodyPart.lowerLegs: 'lower legs',
  BodyPart.neck: 'neck',
  BodyPart.shoulders: 'shoulders',
  BodyPart.upperArms: 'upper arms',
  BodyPart.upperLegs: 'upper legs',
  BodyPart.waist: 'waist',
};
