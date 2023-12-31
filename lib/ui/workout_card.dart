import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';

import '../models/workout_plan.dart';

class WorkoutPlanCard extends StatelessWidget {

  final WorkoutPlan workoutPlan ;
  const WorkoutPlanCard({super.key, required this.workoutPlan});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExpansionTileCard(title: Text(workoutPlan.name),subtitle: Text(workoutPlan.description),),
      ],
    );
  }
}
