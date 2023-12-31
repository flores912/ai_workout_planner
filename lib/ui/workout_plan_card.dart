import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/workout_plan.dart';


class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlan workoutPlan;
  final Color titleBackgroundColor;
  final TextStyle titleTextStyle;
  final EdgeInsets titlePadding;
  final Icon leadingIcon;
  final TextStyle subtitleTextStyle;

  const WorkoutPlanCard({
    super.key,
    required this.workoutPlan,
    this.titleBackgroundColor = Colors.blueAccent,
    this.titleTextStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.leadingIcon = const Icon(Icons.fitness_center),
    this.subtitleTextStyle = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title with background color
        Container(
          padding: titlePadding,
          decoration: BoxDecoration(
            color: titleBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            workoutPlan.name,
            style: titleTextStyle,
          ),
        ),
        const SizedBox(height: 8), // Spacing between title and card
        // Expansion Tile Card
        ExpansionTileCard(
          leading: leadingIcon,
          title: Text(workoutPlan.name),
          subtitle: Text(workoutPlan.description, style: subtitleTextStyle),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Number of Weeks: ${workoutPlan.numberOfWeeks}'),
            ),
            // Additional details of the workout plan can be added here
          ],
        ),
      ],
    );
  }
}


