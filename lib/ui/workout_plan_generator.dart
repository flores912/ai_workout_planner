import 'dart:convert';

import 'package:ai_workout_planner/consts/all_exercise_names.dart';
import 'package:ai_workout_planner/models/exercise.dart';
import 'package:ai_workout_planner/models/workout.dart';
import 'package:ai_workout_planner/models/workout_plan.dart';
import 'package:ai_workout_planner/ui/workout_card.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

import '../models/exercise_set.dart';
import '../models/week.dart';

class WorkoutPlanGenerator extends StatefulWidget {
  final String workoutCriteria;
  final String apiKey;

  final String? organizationId;
  const WorkoutPlanGenerator({super.key, required this.workoutCriteria, required this.apiKey, this.organizationId});

  @override
  WorkoutPlanGeneratorState createState() => WorkoutPlanGeneratorState();
}

class WorkoutPlanGeneratorState extends State<WorkoutPlanGenerator> {

  @override
  void initState() {
    super.initState();
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
        future: generateWorkoutPlan(workoutCriteria: widget.workoutCriteria),
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
    // System message request for generating a workout plan
    OpenAIChatCompletionChoiceMessageModel systemMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are a Fitness Expert. Based on the user's workout criteria, limitations, and preferences, create a comprehensive workout plan. Format your response as a JSON object that matches the structure of the 'WorkoutPlan' class, with an emphasis on the plan's name, description, and number of weeks. Example of the expected JSON response for a workout plan:\n"
                  "{\n"
                  "  'name': '4-Week Intensive Strength Training',\n"
                  "  'description': 'A plan designed to increase muscle strength and endurance through focused resistance training.',\n"
                  "  'numberOfWeeks': 4\n"
                  "}\n"
                  "Respond in this format."
          )
        ]
    );

    // User message request with workout criteria
    OpenAIChatCompletionChoiceMessageModel userMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(workoutCriteria)
        ]
    );

    // OpenAI Chat API call
    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      maxTokens: 1000,
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
            "You are a Fitness Expert. Based on the user preferences and limitations provided, create a weekly workout plan based on workout criteria provided by user.  Format your response as a JSON object that matches the structure of a 'Week' class. Example of the expected JSON response:\n"
                "{\n"
                "  'day1': { 'isRestDay': false},\n"
                "  'day2': {'isRestDay': true},\n"
                "  ... (and so on for each day of the week)\n"
                "}\n"
                "Respond in this format.")]
    );



    OpenAIChatCompletionChoiceMessageModel userMessageRequest =
    OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(workoutCriteria)]
    );


    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      maxTokens: 1000,
      temperature: 0.5,
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
    // System message request
    OpenAIChatCompletionChoiceMessageModel systemMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "Given the weekly workout plan:${week.toJson()}You are a Fitness Expert. Based on user preferences, limitations, and the context of the current week's workout schedule, generate a workout plan for day:$dayNumber. Use this list to pick exercises from database:$EXERCISE_NAMES_LIST. Use exact names as they are spelled here from this list to name exercise. Format your response as a JSON object that matches the structure of 'StraightSet' and 'SuperSet' classes. Example of the expected JSON response for a day's workout:\n"
                  "{\n"
                  "  'name': 'Strength Training',\n"
                  "  'exercises': [\n"
                  "    {\n"
                  "      'name': 'Squat',\n"
                  "      'index': 1,\n"
                  "      'numberOfSets': 4,\n"
                  "      'exerciseSet': {\n"
                  "         'exerciseSetType': 'StraightSet',\n"
                  "         'restDurationInSeconds': 90,\n"
                  "         'reps': 12\n"
                  "      }\n"
                  "    },\n"
                  "    {\n"
                  "      'name': 'Bench Press and Deadlift SuperSet',\n"
                  "      'index': 2,\n"
                  "      'numberOfSets': 3,\n"
                  "      'exerciseSet': {\n"
                  "         'exerciseSetType': 'SuperSet',\n"
                  "         'restDurationInSeconds': 60,\n"
                  "         'firstExercise': {'name': 'Bench Press', 'reps': 10},\n"
                  "         'firstExerciseReps': 10,\n"
                  "         'secondExercise': {'name': 'Deadlift', 'reps': 10},\n"
                  "         'secondExerciseReps': 10\n"
                  "      }\n"
                  "    }\n"
                  "    ... (more exercises)\n"
                  "  ]\n"
                  "}\n"
                  "Respond in this format."
          )
        ]
    );

    // User message request
    OpenAIChatCompletionChoiceMessageModel userMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(workoutCriteria)
        ]
    );

    // OpenAI Chat API call
    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      maxTokens: 1000,
      temperature: 0.5,
      n: 1,
      messages: [
        systemMessageRequest,
        userMessageRequest,
      ],
    );
    print('prompt:$systemMessageRequest');

    late Workout workoutOfDay;
    final message = chat.choices.first.message;

    if (message.content!.first.text != null) {
      String text = message.content!.first.text!;
      Map<String, dynamic> jsonResponse = jsonDecode(text);

      var workoutDetails = jsonResponse['exercises'] as List<dynamic>;
      List<Exercise> exercises = [];

      for (var detail in workoutDetails) {
        String exerciseName = detail['name'];
        int index = detail['index'];
        int numberOfSets = detail['numberOfSets'];
        var exerciseSetDetails = detail['exerciseSet'];

        Exercise exercise = exercises.firstWhere(
              (e) => e.name.toLowerCase() == exerciseName.toLowerCase(),
          orElse: () => throw Exception('Exercise not found:$exerciseName'),
        );

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

          Exercise firstExercise = exercises.firstWhere(
                (e) => e.name.toLowerCase() == firstExerciseDetails['name'].toLowerCase(),
            orElse: () => throw Exception('First exercise not found'),
          );

          Exercise secondExercise = exercises.firstWhere(
                (e) => e.name.toLowerCase() == secondExerciseDetails['name'].toLowerCase(),
            orElse: () => throw Exception('Second exercise not found'),
          );

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

        exercise.index = index;
        exercise.exerciseSet = exerciseSet;
        exercise.numberOfSets = numberOfSets;
        exercises.add(exercise);
      }

      workoutOfDay = Workout(
        name: jsonResponse['name'],
        exercises: exercises,
      );
    } else {
      print('No response or invalid format received from OpenAI.');
    }

    return workoutOfDay;
  }
  Future<void> generateWorkoutsForWeek({
    required String workoutCriteria,
    required Week week,
  }) async {
    if (!week.day1.isRestDay) {
      await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 1);
    }
    if (!week.day2.isRestDay) {
      await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 2);
    }
    if (!week.day3.isRestDay) {
      await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 3);
    }
    if (!week.day4.isRestDay) {
      await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 4);
    }
    if (!week.day5.isRestDay) {
      await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 5);
    }
    if (!week.day6.isRestDay) {
      await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 6);
    }
    if (!week.day7.isRestDay) {
      await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 7);
    }
  }

}
