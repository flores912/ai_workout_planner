import 'dart:convert';

import 'package:ai_workout_planner/consts/exercises.dart';
import 'package:ai_workout_planner/models/exercise.dart';
import 'package:ai_workout_planner/models/workout.dart';
import 'package:ai_workout_planner/ui/workout_plan_card.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

import '../consts/all_exercise_names.dart';
import '../models/exercise_set.dart';
import '../models/week.dart';
import '../models/workout_plan.dart';

class WorkoutPlanGenerator extends StatefulWidget {
  final String apiKey;
  final String? organizationId;

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
  final Duration workoutDuration;

  const WorkoutPlanGenerator({
    super.key,
    required this.apiKey,
    this.organizationId,
    this.fitnessLevel = 'beginner', // Default value
    this.workoutGoals = 'Increase strength and muscle mass', // Updated default value
    this.preferredExercises = 'Bodyweight exercises, Cardio', // Updated default value
    this.equipmentAvailability = 'Limited home equipment', // Updated default value
    this.medicalConsiderations = 'None', // Updated default value
    this.timeAvailability = '30-60 minutes per session', // Updated default value
    this.numberOfWorkoutsPerWeek = 3, // Default value
    this.preferredWorkoutDays = 'Monday, Wednesday, Friday', // Updated default value
    this.preferredRestDays = 'Weekends', // Updated default value
    this.workoutDuration = const Duration(minutes: 30), // Default value
  });
  @override
  WorkoutPlanGeneratorState createState() => WorkoutPlanGeneratorState();
}


class WorkoutPlanGeneratorState extends State<WorkoutPlanGenerator> {

  late List<String>selectedExercises;
  late String workoutCriteria;

  @override
  void initState() {
    super.initState();


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
        'Workout Duration: ${widget.workoutDuration.inMinutes} minutes';
    OpenAI.apiKey = widget.apiKey;
    if(widget.organizationId !=null){
      OpenAI.organization = widget.organizationId;
    }
    OpenAI.requestsTimeOut = const Duration(seconds: 30);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WorkoutPlan>(
        future: generateWorkoutPlan(workoutCriteria:workoutCriteria),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while the future is in progress
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Display an error message if the future completes with an error
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            // If the future completes with data, display your WorkoutPlanCard
            return WorkoutPlanCard(workoutPlan: snapshot.data!);
          } else {
            // This case handles a null data scenario
            return const Center(child: Text("No workout plan available."));
          }
        }
    );
  }


  Future<WorkoutPlan> generateWorkoutPlan({required String workoutCriteria}) async {

    selectedExercises = await selectExercisesForWorkoutPlan(workoutCriteria: workoutCriteria);
    // System message request for generating a workout plan
    OpenAIChatCompletionChoiceMessageModel systemMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are a Fitness Expert. Based on the user's workout criteria, limitations, and preferences, create a comprehensive workout plan. Format your response as a JSON object that matches the structure of the 'WorkoutPlan' class, with an emphasis on the plan's name, description, and number of weeks. Example of the expected JSON response for a workout plan:\n"
                  "{\n"
                  "  'name': '(Workout Plan Name)',\n"
                  "  'description': '(description)',\n"
                  "  'numberOfWeeks': (number of weeks user wants)\n"
                  "}\n"
                  "Respond in this format."
          )
        ]
    );

    // User message request with workout criteria
    OpenAIChatCompletionChoiceMessageModel userMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text('Here is my criteria to build workout plan:$workoutCriteria')
        ]
    );

    // OpenAI Chat API call
    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      temperature: 0.5,
      n: 1,
      messages: [
        systemMessageRequest,
        userMessageRequest,
      ],
    );

    // Extracting response and creating WorkoutPlan object
    final message = chat.choices.first.message;
    WorkoutPlan workoutPlan;

    if (message.content!.first.text != null) {
      String text = message.content!.first.text!;
      Map<String, dynamic> jsonResponse = jsonDecode(text);

      // Generate the week schedule using the generateWeekWorkoutSchedule method
      Week weekSchedule = await generateWeekWorkoutSchedule(workoutCriteria: workoutCriteria);

      workoutPlan = WorkoutPlan(
        name: jsonResponse['name'],
        description: jsonResponse['description'],
        numberOfWeeks: jsonResponse['numberOfWeeks'],
        weekSchedule: weekSchedule,
      );
    } else {
      throw Exception('No response or invalid format received from OpenAI.');
    }

    return workoutPlan;
  }

  Future<Week> generateWeekWorkoutSchedule({required String workoutCriteria}) async {


    /*TODO
    According to user preferences,limitations, and other info provided:
    -AI will respond with a week obj
      -which contains 7 days
        - each day contains a workout if its not a rest day
         - each workout contains list of exercises
         - exercise will contain setType and according to the set type ai will provide the values

     */
    // Construct the system prompt with a JSON example
    OpenAIChatCompletionChoiceMessageModel systemMessageRequest =
    OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "You are a Fitness Expert. Based on the user preferences and limitations provided, create a weekly workout plan based on workout criteria provided by user. Make sure you keep in mind rest time between each day(don't have intensive days next to each other working out same muscles). Format your response as a JSON object that matches the structure of a 'Week' class. Example of the expected JSON response:\n"
                "{\n"
                "  'day1': { 'isRestDay': false "
                "            'workoutSplit': Upper},\n"
                "  'day2': {'isRestDay': true"
                "           'workoutSplit': rest},\n"
                "  ... (and so on for each day of the week)\n"
                "}\n"
                "Respond in this format.")]
    );



    OpenAIChatCompletionChoiceMessageModel userMessageRequest =
    OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text('Here is my criteria to build workout plan:$workoutCriteria')]
    );


    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      temperature: 0.3,
      n: 1,
      messages: [
        systemMessageRequest,
        userMessageRequest,
      ],
    );





    final message = chat.choices.first.message;

   late Week week;


    if (message.content!.first.text != null) {
      String text = message.content!.first.text!;
      Map<String, dynamic> jsonResponse = jsonDecode(text);
      print("API response: $jsonResponse");

     week = Week.fromJson(jsonResponse);

   await generateWorkoutsForWeek(workoutCriteria: workoutCriteria, week: week);


    } else {
      print('No response or invalid format received from OpenAI.');
    }

    return week;

  }
  Future<Workout> generateWorkoutOfTheDay({
    required String workoutCriteria,
    required Week week,
    required int dayNumber
  }) async {
    // Convert each day of the week to JSON
    String day1Json = jsonEncode(week.day1.toJson());
    String day2Json = jsonEncode(week.day2.toJson());
    String day3Json = jsonEncode(week.day3.toJson());
    String day4Json = jsonEncode(week.day4.toJson());
    String day5Json = jsonEncode(week.day5.toJson());
    String day6Json = jsonEncode(week.day6.toJson());
    String day7Json = jsonEncode(week.day7.toJson());

    // System message request
    OpenAIChatCompletionChoiceMessageModel systemMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "Given the weekly workout plan with the following day schedules:\n"
                  "Day 1: $day1Json\n"
                  "Day 2: $day2Json\n"
                  "Day 3: $day3Json\n"
                  "Day 4: $day4Json\n"
                  "Day 5: $day5Json\n"
                  "Day 6: $day6Json\n"
                  "Day 7: $day7Json\n"
                  "You are a Fitness Expert. Generate a workout plan for day:$dayNumber of the week. "
                  "Use ONLY the following exercise names: $selectedExercises. "
                  "Respond with exercises exactly as they are named in the list. "
                  "Format your response as a JSON object with 'StraightSet' and 'SuperSet' classes where applicable. Add as many exercises according to workout criteria  "
                  "Example response format:\n"
                  "{\n"
                  "  'name': 'Workout Name(like Chest and triceps or Lower body)',\n"
                  "  'exercises': [\n"
                  "    { 'name': 'ExerciseNameFromList', 'index': 1, 'numberOfSets': 3, 'exerciseSet': { 'exerciseSetType': 'StraightSet', 'restDurationInSeconds': 90, 'reps': 10 } },\n"
                  "    { 'name': 'AnotherExerciseNameFromList', 'index': 2, 'numberOfSets': 2, 'exerciseSet': { 'exerciseSetType': 'SuperSet', 'restDurationInSeconds': 60, 'firstExercise': {...}, 'secondExercise': {...} } }\n"
                  "  ]\n"
                  "}\n"
          )
        ]);

    // User message request
    OpenAIChatCompletionChoiceMessageModel userMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text('Here is my criteria to build workout plan:$workoutCriteria')
        ]
    );

    // OpenAI Chat API call
    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      temperature: 0.4,
      n: 1,
      messages: [
        systemMessageRequest,
        userMessageRequest,
      ],
    );

    late Workout workoutOfDay;
    final message = chat.choices.first.message;

    if (message.content!.first.text != null) {
      String text = message.content!.first.text!;
      Map<String, dynamic> jsonResponse = jsonDecode(text);

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

        ExerciseSet exerciseSet;
        if (exerciseSetDetails['exerciseSetType'] == 'StraightSet') {
          exerciseSet = StraightSet(
            restDurationInSeconds: exerciseSetDetails['restDurationInSeconds'],
            reps: exerciseSetDetails['reps'],
            exerciseSetType: ExerciseSetType.straightSet,
          );
        } else if (exerciseSetDetails['exerciseSetType'] == 'SuperSet') {
          var firstExerciseDetails = exerciseSetDetails['firstExercise'];
          var secondExerciseDetails = exerciseSetDetails['secondExercise'];

          Exercise? firstExercise = findExerciseByName(firstExerciseDetails['name'].toLowerCase());
          Exercise? secondExercise = findExerciseByName(secondExerciseDetails['name'].toLowerCase());

          if (firstExercise == null || secondExercise == null) {
            print('One or both exercises in SuperSet not found');
            continue;
          }

          exerciseSet = SuperSet(
            restDurationInSeconds: exerciseSetDetails['restDurationInSeconds'],
            firstExerciseReps: firstExerciseDetails['reps'],
            secondExerciseReps: secondExerciseDetails['reps'],
            firstExercise: firstExercise,
            secondExercise: secondExercise,
            exerciseSetType: ExerciseSetType.superSet,
          );
        } else {
          throw Exception('Invalid exercise set type');
        }

        foundExercise.index = index;
        foundExercise.exerciseSet = exerciseSet;
        foundExercise.numberOfSets = numberOfSets;
        exercisesForWorkout.add(foundExercise);
      }

      workoutOfDay = Workout(
        name: jsonResponse['name'],
        exercises: exercisesForWorkout,
      );

    } else {
      print('No response or invalid format received from OpenAI.');
    }

    return workoutOfDay;
  }




// Helper function to find an exercise by name
  Exercise? findExerciseByName(String exerciseName) {
    // Assuming you have a global or accessible list of exercises
    for (var exercise in AllExercises().list) {
      if (exercise.name.toLowerCase() == exerciseName) {
        return exercise;
      }
    }
    return null;
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
  Future<List<String>> selectExercisesForWorkoutPlan({required String workoutCriteria}) async {
    print('Selecting exercises for plan');

    // Construct the system prompt with a JSON example
// Construct the system prompt for selecting exercises
    OpenAIChatCompletionChoiceMessageModel systemMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "As a Fitness Expert, select approximately 50 exercises from the following list based on the workout criteria: '$workoutCriteria'. Ensure a balanced selection suitable for a full-body workout, avoiding overuse of similar exercises. Use the exact spelling, grammar, and capitalization from the list:\n$EXERCISE_NAMES_LIST\n"
                "Format your response as a JSON array of selected exercise names. Example of the expected JSON response:\n"
                "[\n"
                "  'Exercise 1',\n"
                "  'Exercise 2',\n"
                "  ... (more exercises)\n"
                "]\n"
                "Respond in this format.")]
    );


// User message request with workout criteria
    OpenAIChatCompletionChoiceMessageModel userMessageRequest =
    OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Here is my criteria to build the workout plan (please follow the specified number of workouts per week): $workoutCriteria"
        )]
    );

    // OpenAI Chat API call
    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"}, // Use json_object as the response format
      model: "gpt-3.5-turbo-1106",
      temperature: 0.3,
      n: 1,
      messages: [
        systemMessageRequest,
        userMessageRequest,
      ],
    );

    final message = chat.choices.first.message;
    List<String> selectedExercises = [];

    if (message.content!.first.text != null) {
      String text = message.content!.first.text!;
      Map<String, dynamic> jsonResponse = jsonDecode(text);
      List<dynamic> exercisesList = jsonResponse['selectedExercises'];

      // Add selected exercises to the list
      exercisesList.forEach((exerciseName) {
        selectedExercises.add(exerciseName.toString());
      });
    } else {
      print('No response or invalid format received from OpenAI.');
    }

    return selectedExercises;
  }
  Exercise? findClosestMatchExerciseByName(String name) {
    double highestSimilarity = 0.0;
    Exercise? closestMatch;

    for (var exercise in AllExercises().list) { // Replace EXERCISE_LIST with your list of exercises
      double similarity = StringSimilarity.compareTwoStrings(name, exercise.name.toLowerCase());
      if (similarity > highestSimilarity) {
        highestSimilarity = similarity;
        closestMatch = exercise;
      }
    }

    // You can adjust the threshold value as needed
    if (highestSimilarity > 0.6) {
      return closestMatch;
    } else {
      return null;
    }
  }
}
