import 'package:ai_workout_planner/models/workout.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class WorkoutGenerator extends StatefulWidget {
  final String workoutPreferencesPrompt;
  final String apiKey;

  final String? organizationId;
  const WorkoutGenerator({super.key, required this.workoutPreferencesPrompt, required this.apiKey, this.organizationId});

  @override
  WorkoutGeneratorState createState() => WorkoutGeneratorState();
}

class WorkoutGeneratorState extends State<WorkoutGenerator> {

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
    return FutureBuilder<Workout>(
      future: null,
      builder: (context, snapshot) {
        return Container();
      }
    );
  }
  generateWorkout() async {
    OpenAICompletionModel completion = await OpenAI.instance.completion.create(
      model: "text-davinci-003",
      prompt: "Dart is a program",
      maxTokens: 1000,
      temperature: 0.5,
      n: 1,
    );

    print(completion.choices.first.text); // ...
    print(completion.systemFingerprint); // ...
    print(completion.id); // ...
  }
}
