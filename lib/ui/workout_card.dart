import 'package:ai_workout_planner/ui/workout_detail_page.dart';
import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;

  const WorkoutCard({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(workout.name),
        subtitle: Text('Exercises: ${workout.exercises.length}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailPage(workout: workout,),
            ),
          );
        },
      ),
    );
  }
}
