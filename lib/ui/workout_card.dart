import 'package:ai_workout_planner/models/workout.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';

class WorkoutCard extends StatelessWidget {

  final Workout workout ;
  const WorkoutCard({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTileCard(title: Text(workout.name)),
      ],
    );
  }
}
