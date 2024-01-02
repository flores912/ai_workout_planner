import 'dart:convert';

import 'package:ai_workout_planner/consts/exercises.dart';
import 'package:ai_workout_planner/models/exercise.dart';
import 'package:ai_workout_planner/models/workout.dart';
import 'package:ai_workout_planner/ui/workout_plan_card.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:open_ai_assistant_wrapper/apis/client.dart';
import 'package:string_similarity/string_similarity.dart';

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
  final int numberOfWeeks;
  final Duration workoutDuration;

  final String systemMessage;

  const WorkoutPlanGenerator({
    super.key,
    required this.apiKey,
    this.organizationId,
    this.systemMessage = 'You are a Fitness Expert.',
    this.fitnessLevel = 'beginner', // Default value
    this.workoutGoals = 'Increase strength and muscle mass', // Updated default value
    this.preferredExercises = 'Bodyweight exercises, Cardio', // Updated default value
    this.equipmentAvailability = 'Limited home equipment', // Updated default value
    this.medicalConsiderations = 'None', // Updated default value
    this.timeAvailability = '30-60 minutes per session', // Updated default value
    this.numberOfWorkoutsPerWeek = 3, // Default value
    this.preferredWorkoutDays = 'Monday, Wednesday, Friday', // Updated default value
    this.preferredRestDays = 'Weekends', // Updated default value
    this.workoutDuration = const Duration(minutes: 30),
    this.numberOfWeeks = 6,// Default value
  });
  @override
  WorkoutPlanGeneratorState createState() => WorkoutPlanGeneratorState();
}


class WorkoutPlanGeneratorState extends State<WorkoutPlanGenerator> {

  //late List<String>selectedExercises;
  late String workoutCriteria;

  late OpenAIChatCompletionChoiceMessageModel systemMessage;

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
      //   'Preferred Workout Days: ${widget.preferredWorkoutDays}\n'
      // 'Preferred Rest Days: ${widget.preferredRestDays}\n'
       'Workout Duration: ${widget.workoutDuration.inMinutes} minutes'
        'Weeks: ${widget.numberOfWeeks} weeks';
    OpenAI.apiKey = widget.apiKey;
    if(widget.organizationId !=null){
      OpenAI.organization = widget.organizationId;
    }
    OpenAI.requestsTimeOut = const Duration(seconds: 60);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

     systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              '${widget.systemMessage}\n '
                  'Format your responses in JSON in the structure the user wants.'
          )
        ]
    );

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

    //selectedExercises = await selectExercisesForWorkoutPlan(workoutCriteria: workoutCriteria);
    // System message request for generating a workout plan
    OpenAIChatCompletionChoiceMessageModel userMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              " Based on the user's workout criteria $workoutCriteria\n, create a comprehensive workout plan. Format your response as a JSON object that matches the structure of the 'WorkoutPlan' class, with an emphasis on the plan's name, description, and number of weeks. Example of the expected JSON response for a workout plan:\n"
                  "{\n"
                  "  'name': '(Workout Plan Name)',\n"
                  "  'description': '(description)',\n"
                  "  'numberOfWeeks': (number of weeks user wants)\n"
                  "}\n"
                  "Respond in this format."
          )
        ]
    );



    // OpenAI Chat API call
    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      temperature: 0.5,
      n: 1,
      messages: [
        systemMessage,
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
    OpenAIChatCompletionChoiceMessageModel userMessageRequest =
    OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Based on this workout criteria:$workoutCriteria\n"
                " Create a week workout plan based on workout criteria provided by user.  Example of the expected JSON response:\n"
                "{\n"
                "  'day1': { 'isRestDay': false "
                "            'workoutSplit': Chest and Triceps},\n"
                "  'day2': {'isRestDay': true"
                "           'workoutSplit': rest},\n"
                "  'day3': { 'isRestDay': false "
                "            'workoutSplit': Legs},\n"
                "  ... (and so on for each day until day7)\n"
                "}\n"
                "Respond in this format.")]
    );






    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      temperature: 0.2,
      n: 1,

      messages: [
        systemMessage,
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
// System message request
// System message request
    OpenAIChatCompletionChoiceMessageModel userMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are provided with a weekly workout schedule, detailed in the following JSON data for each day:\n"
                  "Day 1: $day1Json\n"
                  "Day 2: $day2Json\n"
                  "Day 3: $day3Json\n"
                  "Day 4: $day4Json\n"
                  "Day 5: $day5Json\n"
                  "Day 6: $day6Json\n"
                  "Day 7: $day7Json\n\n"
                  "Based on the workout criteria: $workoutCriteria and the current week's schedule, generate a comprehensive workout plan for day number $dayNumber. The workout plan should be formatted as a JSON object. Each exercise in the plan can be of type 'straight', 'timed', or 'failure'. Here is the structure for the expected JSON response:\n\n"
                  "{\n"
                  "  'name': 'Workout Name',\n"
                  "  'exercises': [\n"
                  "    // Example of a 'straight' set exercise\n"
                  "    {\n"
                  "      'name': 'Exercise Name',\n"
                  "      'index': 1, // Integer value\n"
                  "      'numberOfSets': 4, // Integer value\n"
                  "      'exerciseSet': {\n"
                  "         'exerciseSetType': 'straight',\n"
                  "         'restDuration': 90, // Integer value(Seconds)\n"
                  "         'reps': 12 // integer value\n"
                  "      }\n"
                  "    },\n"
                  "    // Example of a 'timed' set exercise\n"
                  "    {\n"
                  "      'name': 'Another Exercise Name',\n"
                  "      'index': 2, // Integer value\n"
                  "      'numberOfSets': 3, // Integer value\n"
                  "      'exerciseSet': {\n"
                  "         'exerciseSetType': 'timed',\n"
                  "         'restDuration': 60, // Integer value(Seconds)\n"
                  "         'timedSetInSeconds': 30 // Optional integer value\n"
                  "      }\n"
                  "    },\n"
                  "    // Example of a 'failure' set exercise (reps till failure)\n"
                  "    {\n"
                  "      'name': 'Third Exercise Name',\n"
                  "      'index': 3, // Integer value\n"
                  "      'numberOfSets': 2, // Integer value\n"
                  "      'exerciseSet': {\n"
                  "         'exerciseSetType': 'failure',\n"
                  "         'restDuration': 75 // Integer value(Seconds)\n"
                  "         // 'reps' field is not applicable for 'failure' type\n"
                  "      }\n"
                  "    }\n"
                  "    // Include additional exercises as needed\n"
                  "  ]\n"
                  "}\n\n"
                  "Please ensure the response is accurate and complete, adhering to this format."
          )
        ]
    );
    // User message request

    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      temperature: 0.8,
      n: 1,
      messages: [
        systemMessage,
        userMessageRequest],
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

        foundExercise.index = index;
        foundExercise.numberOfSets = numberOfSets;
        foundExercise.exerciseSet = parseExerciseSet(exerciseSetDetails);

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


}
