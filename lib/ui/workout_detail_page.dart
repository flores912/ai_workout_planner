import 'package:flutter/material.dart';
import 'package:ai_workout_planner/models/exercise.dart'; // Assuming the models are in this path
import 'package:ai_workout_planner/models/workout.dart';

import '../models/exercise_set.dart'; // Assuming the models are in this path

class WorkoutDetailPage extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailPage({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    List<Exercise> exercises = workout.exercises;

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.name),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100, // Height of the horizontal list
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: exercises.length,
              itemBuilder: (context, index) => Card(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(exercises[index].name),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, exerciseIndex) {
                var exercise = exercises[exerciseIndex];
                var exerciseSet = exercise.exerciseSet;
                return Column(
                  children: [
                    ListTile(
                      title: Text(exercise.name),
                      subtitle: Text('Exercise ${exerciseIndex + 1} of ${exercises.length}'),
                    ),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(), // To prevent inner list scroll
                      shrinkWrap: true,
                      itemCount: exercise.numberOfSets,
                      itemBuilder: (context, setIndex) {
                        return ListTile(
                          leading: CircleAvatar(child: Text('${setIndex + 1}')),
                          title: _buildSetTitle(exerciseSet, setIndex),
                          subtitle: Text('Rest for ${exerciseSet?.restDurationInSeconds}s'),
                          trailing: IconButton(
                            icon: Icon(Icons.timer),
                            onPressed: () {
                              // Implement set timer functionality
                            },
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetTitle(ExerciseSet? exerciseSet, int setIndex) {
    switch (exerciseSet?.exerciseSetType) {
      case ExerciseSetType.straight:
        return Text('${exerciseSet?.reps ?? 'Unknown'} Reps');
      case ExerciseSetType.timed:
        return Text('Timed Set for ${exerciseSet?.timedSetInSeconds ?? 'Unknown'} Seconds');
      case ExerciseSetType.failure:
        return Text('Reps till Failure');
      default:
        return Text('Unknown Set Type');
    }
  }
}
