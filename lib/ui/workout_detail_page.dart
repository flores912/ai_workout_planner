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
          // Assuming `gifPath` is a property in Exercise model that holds the path to the GIF
          Image.asset(
            'exercises[0].gifPath', //todo add gif path
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          ListTile(
            title: Text(exercises[0].name),
            subtitle: Text('Exercise 1 of ${exercises.length}'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises[0].numberOfSets, // Assuming `numberOfSets` is a property in the Exercise model
              itemBuilder: (context, setIndex) {
                var exerciseSet = exercises[0].exerciseSet; // Assuming each Exercise has an ExerciseSet
                // Check the type of the exercise set
                switch (exerciseSet?.exerciseSetType) {
                  case ExerciseSetType.straight:
                  // Handle straight sets
                    return ListTile(
                      leading: CircleAvatar(child: Text('${setIndex + 1}')),
                      title: Text('${exerciseSet?.reps ?? 'Unknown'} Reps'),
                      subtitle: Text('Rest for ${exerciseSet?.restDurationInSeconds}s'),
                      trailing: IconButton(
                        icon: Icon(Icons.timer),
                        onPressed: () {
                          // Implement set timer functionality
                        },
                      ),
                    );

                  case ExerciseSetType.timed:
                  // Handle timed sets
                    return ListTile(
                      leading: CircleAvatar(child: Text('${setIndex + 1}')),
                      title: Text('Timed Set for ${exerciseSet?.timedSetInSeconds ?? 'Unknown'} Seconds'),
                      subtitle: Text('Rest for ${exerciseSet?.restDurationInSeconds}s'),
                      trailing: IconButton(
                        icon: Icon(Icons.timer),
                        onPressed: () {
                          // Implement set timer functionality
                        },
                      ),
                    );

                  case ExerciseSetType.failure:
                  // Handle failure sets
                    return ListTile(
                      leading: CircleAvatar(child: Text('${setIndex + 1}')),
                      title: Text('Reps till Failure'),
                      subtitle: Text('Rest for ${exerciseSet?.restDurationInSeconds}s'),
                      trailing: IconButton(
                        icon: Icon(Icons.timer),
                        onPressed: () {
                          // Implement set timer functionality
                        },
                      ),
                    );

                  default:
                  // If the exerciseSet type is not recognized, return an empty Container
                    return Container();
                }
              },
            ),
          ),


        ],
      ),
    );
  }
}
