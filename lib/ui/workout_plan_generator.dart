import 'dart:convert';

import 'package:ai_workout_planner/consts/exercises.dart';
import 'package:ai_workout_planner/models/exercise.dart';
import 'package:ai_workout_planner/models/workout.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:string_similarity/string_similarity.dart';

import '../models/exercise_set.dart';
import '../models/week.dart';
import '../models/workout_plan.dart';

class WorkoutPlanGenerator {
  final String apiKey;
  final String? organizationId;

  // Additional optional parameters with default values
  final String fitnessLevel;
  final String workoutGoals;
  final String equipmentAvailability;
  final String medicalConsiderations;
  final String preferredWorkoutDays;
  final int numberOfWeeks;
  final Duration workoutDuration;

  final String aiInstructions;

  final OpenAIChatCompletionChoiceMessageModel systemAiMessage;

  List<OpenAIChatCompletionChoiceMessageModel> messageHistory = [];


  WorkoutPlanGenerator({
    required this.apiKey,
    this.organizationId,
    this.aiInstructions = 'You are a Fitness Expert.',
    this.fitnessLevel = 'beginner', // Default value
    this.workoutGoals = 'Increase strength and muscle mass', // Updated default value
    this.equipmentAvailability = 'Limited home equipment', // Updated default value
    this.medicalConsiderations = 'None', // Updated default value
    this.preferredWorkoutDays = 'Monday, Wednesday, Friday', // Updated default value
    this.workoutDuration = const Duration(minutes: 30),
    this.numberOfWeeks = 6,// Default value
  }): systemAiMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
            '${aiInstructions}\n '
                'Format your responses in JSON in the structure the user wants.'
        )
      ]);





  //late List<String>selectedExercises;






  Future<WorkoutPlan> generateWorkoutPlan() async {
    messageHistory.add(systemAiMessage);

    // Constructing the workout criteria string
   String workoutCriteria = 'Fitness Level: ${fitnessLevel}\n'
        'Workout Goals: ${workoutGoals}\n'
        'Equipment Availability: ${equipmentAvailability}\n'
        'Medical Considerations: ${medicalConsiderations}\n'
        'Preferred Workout Days: ${preferredWorkoutDays}\n'
        'Workout Duration: ${workoutDuration.inMinutes} minutes'
        'Weeks: ${numberOfWeeks} weeks';
    OpenAI.apiKey = apiKey;
    if(organizationId !=null){
      OpenAI.organization = organizationId;
    }
    OpenAI.requestsTimeOut = const Duration(seconds: 60);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;


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

messageHistory.add(userMessageRequest);

    // OpenAI Chat API call
    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      temperature: 0.3,
      messages: messageHistory,
    );

    // Extracting response and creating WorkoutPlan object
    final message = chat.choices.first.message;

    // Add the AI response to the message history.
    messageHistory.add(OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.assistant,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(message.content!.first.text ?? 'No response')
        ]
    ));
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
    OpenAIChatCompletionChoiceMessageModel userMessageRequest =
    OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Based on this number of workouts per week criteria and keeping in mind Preferred Workout Days create a weekly workout plan. The response should strictly adhere to the structure of the example provided. and should not include any additional details such as sets, reps, distances, or durations. Simply specify if each day is a rest day or not, and if not, provide the workout split for the day. Here is an example of the expected JSON object response:\n"
                "{\n"
                "  'monday': {'isRestDay': false, 'workoutSplit': 'Chest and Triceps'},\n"
                "  'tuesday': {'isRestDay': true, 'workoutSplit': 'Rest'},\n"
                "  'wednesday': {'isRestDay': false, 'workoutSplit': 'Legs'},\n"
                "  // continue for each day of the week\n"
                "}\n"
                "Please respond only in this format and avoid adding any extra details.")]
    );




    messageHistory.add(userMessageRequest);



    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      temperature: 0.2,
      n: 1,

      messages: messageHistory
    );





    final message = chat.choices.first.message;

   late Week week;


    if (message.content!.first.text != null) {
      String text = message.content!.first.text!;
      Map<String, dynamic> jsonResponse = jsonDecode(text);
      print("API response: $jsonResponse");

      week = Week.fromJson(jsonResponse);

      // Add the AI response to the message history.
      messageHistory.add(OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(message.content!.first.text ?? 'No response')
          ]
      ));

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
    String day1Json = jsonEncode(week.monday.toJson());
    String day2Json = jsonEncode(week.tuesday.toJson());
    String day3Json = jsonEncode(week.wednesday.toJson());
    String day4Json = jsonEncode(week.thursday.toJson());
    String day5Json = jsonEncode(week.friday.toJson());
    String day6Json = jsonEncode(week.saturday.toJson());
    String day7Json = jsonEncode(week.sunday.toJson());


    // System message request
// System message request
// System message request
    OpenAIChatCompletionChoiceMessageModel userMessageRequest = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(

                  "Based on the workout criteria and the current week's schedule, generate a comprehensive workout plan for day number $dayNumber. The workout plan should be formatted as a JSON object. Each exercise in the plan can be of type 'straight', 'timed', or 'failure'. Here is the structure for the expected JSON response:\n\n"
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


    messageHistory.add(userMessageRequest);
    final chat = await OpenAI.instance.chat.create(
      responseFormat: {"type": "json_object"},
      model: "gpt-3.5-turbo-1106",
      temperature: 0.8,
      n: 1,
      messages: messageHistory
    );


    late Workout workoutOfDay;
    final message = chat.choices.first.message;

    // Add the AI response to the message history.
    messageHistory.add(OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.assistant,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(message.content!.first.text ?? 'No response')
        ]
    ));

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

          //todo if exercise not found create a new exercise obj???
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
    if (!week.monday.isRestDay) {
    week.monday.workout =  await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 1);
    }
    if (!week.tuesday.isRestDay) {
      week.tuesday.workout= await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 2);
    }
    if (!week.wednesday.isRestDay) {
      week.wednesday.workout= await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 3);
    }
    if (!week.thursday.isRestDay) {
      week.thursday.workout=   await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 4);
    }
    if (!week.friday.isRestDay) {
      week.friday.workout=   await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 5);
    }
    if (!week.saturday.isRestDay) {
      week.saturday.workout=   await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 6);
    }
    if (!week.sunday.isRestDay) {
      week.sunday.workout=   await generateWorkoutOfTheDay(workoutCriteria: workoutCriteria, week: week, dayNumber: 7);
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
    if (highestSimilarity > 0.3) {
      return closestMatch;
    } else {
      return null;
    }
  }


}
