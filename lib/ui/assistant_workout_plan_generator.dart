import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:open_ai_assistant_wrapper/apis/assistants/assistants_api.dart';
import 'package:open_ai_assistant_wrapper/apis/client.dart';
import 'package:open_ai_assistant_wrapper/apis/runs/runs_api.dart';
import 'package:open_ai_assistant_wrapper/apis/threads/role_enum.dart';
import 'package:open_ai_assistant_wrapper/models/assistant_model.dart';
import 'package:open_ai_assistant_wrapper/models/run_model.dart';
import 'package:open_ai_assistant_wrapper/models/thread_model.dart';
import 'package:string_similarity/string_similarity.dart';

import '../consts/exercises.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/week.dart';
import '../models/workout.dart';
import '../models/workout_plan.dart';

class AssistantWorkoutPlanGenerator extends StatefulWidget {

  final String apiKey;
  final String assistantId;


  // Additional optional parameters with default values
  final String fitnessLevel;
  final String workoutGoals;
  final String preferredExercises;
  final String equipmentAvailability;
  final String medicalConsiderations;
  final String timeAvailability;
  final int numberOfWorkoutsPerWeek;
  final String preferredWorkoutDays;
  final String preferredRestDays;
  final int numberOfWeeks;
  final Duration workoutDuration;
  const AssistantWorkoutPlanGenerator({super.key, required this.apiKey, required this.assistantId,this.fitnessLevel = 'beginner', // Default value
    this.workoutGoals = 'Increase strength and muscle mass', // Updated default value
    this.preferredExercises = 'Bodyweight exercises, Cardio', // Updated default value
    this.equipmentAvailability = 'Limited home equipment', // Updated default value
    this.medicalConsiderations = 'None', // Updated default value
    this.timeAvailability = '30-60 minutes per session', // Updated default value
    this.numberOfWorkoutsPerWeek = 3, // Default value
    this.preferredWorkoutDays = 'Monday, Wednesday, Friday', // Updated default value
    this.preferredRestDays = 'Weekends', // Updated default value
    this.workoutDuration = const Duration(minutes: 30),
    this.numberOfWeeks = 6,});

  @override
  _AssistantWorkoutPlanGeneratorState createState() =>
      _AssistantWorkoutPlanGeneratorState();
}




class _AssistantWorkoutPlanGeneratorState
    extends State<AssistantWorkoutPlanGenerator> {

  late String workoutCriteria;


  late OpenAIAssistantClient openAIAssistantClient;
  late Assistant assistant;

  late Thread thread;

  @override
  void initState() {
    super.initState();

    initAssistant();
    initThread();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  initAssistant() async {
    openAIAssistantClient = OpenAIAssistantClient(widget.apiKey);

    assistant =await openAIAssistantClient.assistants.retrieveAssistant(widget.assistantId);


  }

  initThread() async {
    thread = await openAIAssistantClient.threads.createThread();
  }
  Future<WorkoutPlan> generateWorkoutPlan({required String workoutCriteria}) async {

    openAIAssistantClient.messages.createMessage(threadId: thread.id, role: Role.user, content:  " Based on the user's workout criteria $workoutCriteria\n, create a comprehensive workout plan. Format your response as a JSON object that matches the structure of the 'WorkoutPlan' class, with an emphasis on the plan's name, description, and number of weeks. Example of the expected JSON response for a workout plan:\n"
        "{\n"
        "  'name': '(Workout Plan Name)',\n"
        "  'description': '(description)',\n"
        "  'numberOfWeeks': (number of weeks user wants)\n"
        "}\n"
        "Respond in this format.");




    Run run =await openAIAssistantClient.runs.createRun(threadId: thread.id, request: CreateRunRequest(assistantId: widget.assistantId));

    Run runStatus;
    do {
      await Future.delayed(Duration(seconds: 2));
      runStatus = await openAIAssistantClient.runs.retrieveRun(
          threadId: thread.id, runId: run.id);
    } while (runStatus.status != 'completed');

    final list = await openAIAssistantClient.messages
        .listMessages(threadId: thread.id);

    // Extracting response and creating WorkoutPlan object
    final message = list.messages.first.content.first.textValue!;
    WorkoutPlan workoutPlan;

    Map<String, dynamic> jsonResponse = jsonDecode(message);

    // Generate the week schedule using the generateWeekWorkoutSchedule method
    Week weekSchedule = await generateWeekWorkoutSchedule(workoutCriteria: workoutCriteria);

    workoutPlan = WorkoutPlan(
      name: jsonResponse['name'],
      description: jsonResponse['description'],
      numberOfWeeks: jsonResponse['numberOfWeeks'],
      weekSchedule: weekSchedule,
    );

    return workoutPlan;
  }

  Future<Week> generateWeekWorkoutSchedule({required String workoutCriteria}) async {
    // Construct the user prompt with a JSON example
    var content = "Based on this workout criteria: $workoutCriteria\n"
        "Create a weekly workout plan. Keep in mind rest time between each day. Format your response as a JSON object that matches the structure of a 'Week' class. Example of the expected JSON response:\n"
        "{\n"
        "  'day1': { 'isRestDay': false, 'workoutSplit': 'Chest and Triceps'},\n"
        "  'day2': {'isRestDay': true, 'workoutSplit': 'Rest'},\n"
        "  'day3': { 'isRestDay': false, 'workoutSplit': 'Legs'},\n"
        "  ... (and so on for each day of the week)\n"
        "}\n"
        "Respond in this format.";

    // Send the message to the OpenAI Assistant
    await openAIAssistantClient.messages.createMessage(
        threadId: thread.id,
        role: Role.user,
        content: content
    );

    // Create and await the run
    Run run = await openAIAssistantClient.runs.createRun(
        threadId: thread.id,
        request: CreateRunRequest(assistantId: widget.assistantId)
    );

    Run runStatus;
    do {
      await Future.delayed(Duration(seconds: 2));
      runStatus = await openAIAssistantClient.runs.retrieveRun(
          threadId: thread.id, runId: run.id);
    } while (runStatus.status != 'completed');

    // Retrieve the messages
    final list = await openAIAssistantClient.messages
        .listMessages(threadId: thread.id);

    // Extracting response and creating Week object
    final message = list.messages.first.content.first.textValue!;
    Week week;

    Map<String, dynamic> jsonResponse = jsonDecode(message);
    print("API response: $jsonResponse");

    week = Week.fromJson(jsonResponse);

    await generateWorkoutsForWeek(workoutCriteria: workoutCriteria, week: week);

    return week;
  }
  Future<Workout> generateWorkoutOfTheDay({
    required String workoutCriteria,
    required Week week,
    required int dayNumber
  }) async {
    // Convert each day of the week to JSON
    String day1Json = jsonEncode(week.day1.toJson());
    // ...similarly for other days

    // Construct the user prompt with a JSON example
    var content = "You are provided with a weekly workout schedule, detailed in the following JSON data for each day:\n"
        "Day 1: $day1Json\n"
    // ...similarly for other days
        "Based on the workout criteria: $workoutCriteria and the current week's schedule, generate a comprehensive workout plan for day number $dayNumber. The workout plan should be formatted as a JSON object. Each exercise in the plan can be of type 'straight', 'timed', or 'failure'. Here is the structure for the expected JSON response:\n\n"
        "{\n"
        "  'name': 'Workout Name',\n"
        "  'exercises': [...]\n"
        "}\n\n"
        "Please ensure the response is accurate and complete, adhering to this format.";

    // Send the message to the OpenAI Assistant
    await openAIAssistantClient.messages.createMessage(
        threadId: thread.id,
        role: Role.user,
        content: content
    );

    // Create and await the run
    Run run = await openAIAssistantClient.runs.createRun(
        threadId: thread.id,
        request: CreateRunRequest(assistantId: widget.assistantId)
    );

    Run runStatus;
    do {
      await Future.delayed(Duration(seconds: 2));
      runStatus = await openAIAssistantClient.runs.retrieveRun(
          threadId: thread.id, runId: run.id);
    } while (runStatus.status != 'completed');

    // Retrieve the messages
    final list = await openAIAssistantClient.messages.listMessages(threadId: thread.id);

    // Extracting response and creating Workout object
    final message = list.messages.first.content.first.textValue!;
    Map<String, dynamic> jsonResponse = jsonDecode(message);

    var workoutDetails = jsonResponse['exercises'] as List<dynamic>;
    List<Exercise> exercisesForWorkout = [];

    for (var detail in workoutDetails) {
      String exerciseName = detail['name'].toString().toLowerCase();
      int index = detail['index'];
      int numberOfSets = detail['numberOfSets'];
      var exerciseSetDetails = detail['exerciseSet'];

      Exercise? foundExercise = findClosestMatchExerciseByName(exerciseName);

      if (foundExercise == null) {
        print('Exercise not found: $exerciseName');
        continue;
      }

      foundExercise.index = index;
      foundExercise.numberOfSets = numberOfSets;
      foundExercise.exerciseSet = parseExerciseSet(exerciseSetDetails);

      exercisesForWorkout.add(foundExercise);
    }

    Workout workoutOfDay = Workout(
      name: jsonResponse['name'],
      exercises: exercisesForWorkout,
    );

    return workoutOfDay;
  }

  Future<void> generateWorkoutsForWeek({
    required String workoutCriteria,
    required Week week,
  }) async {
    if (!week.day1.isRestDay) {
      week.day1.workout =  await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 1);
    }
    if (!week.day2.isRestDay) {
      week.day2.workout= await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 2);
    }
    if (!week.day3.isRestDay) {
      week.day3.workout= await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 3);
    }
    if (!week.day4.isRestDay) {
      week.day4.workout=   await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 4);
    }
    if (!week.day5.isRestDay) {
      week.day5.workout=   await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 5);
    }
    if (!week.day6.isRestDay) {
      week.day6.workout=   await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 6);
    }
    if (!week.day7.isRestDay) {
      week.day7.workout=   await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 7);
    }
  }
  Exercise? findClosestMatchExerciseByName(String name) {
    double highestSimilarity = 0.0;
    Exercise? closestMatch;

    for (var exercise in AllExercises().list) {
      double similarity = StringSimilarity.compareTwoStrings(name, exercise.name.toLowerCase());
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
        closestMatch = exercise;
      }
    }

    // You can adjust the threshold value as needed
    if (highestSimilarity > 0.4) {
      return closestMatch;
    } else {
      return null;
    }
  }
  ExerciseSet parseExerciseSet(Map<String, dynamic> json) {
    ExerciseSetType setType = ExerciseSetType.values.firstWhere(
          (e) => e.toString().split('.').last == json['exerciseSetType'],
      orElse: () => throw Exception('Invalid exercise set type'),
    );

    switch (setType) {
      case ExerciseSetType.straight:
        return ExerciseSet(
          restDurationInSeconds: json['restDuration'],
          reps: json['reps'], // Note that this is nullable.
          exerciseSetType: setType,
        );

      case ExerciseSetType.timed:
        return ExerciseSet(
          restDurationInSeconds: json['restDuration'],
          timedSetInSeconds: json['timedSetInSeconds'], // Note that this is nullable.
          exerciseSetType: setType,
        );

      case ExerciseSetType.failure:
        return ExerciseSet(
          restDurationInSeconds: json['restDuration'],
          exerciseSetType: setType,
          // 'reps' and 'timedSetInSeconds' are not applicable for 'failure' type.
        );

      default:
        throw Exception('Unhandled exercise set type');
    }
  }


  initWorkoutCriteria(){

    // Constructing the workout criteria string
    workoutCriteria = 'Fitness Level: ${widget.fitnessLevel}\n'
        'Workout Goals: ${widget.workoutGoals}\n'
        'Preferred Exercises: ${widget.preferredExercises}\n'
        'Equipment Availability: ${widget.equipmentAvailability}\n'
        'Medical Considerations: ${widget.medicalConsiderations}\n'
        'Time Availability: ${widget.timeAvailability}\n'
        'Number of Workouts Per Week: ${widget.numberOfWorkoutsPerWeek}\n'
        'Preferred Workout Days: ${widget.preferredWorkoutDays}\n'
        'Preferred Rest Days: ${widget.preferredRestDays}\n'
        'Workout Duration: ${widget.workoutDuration.inMinutes} minutes'
        'Weeks: ${widget.numberOfWeeks} weeks';
  }
}
