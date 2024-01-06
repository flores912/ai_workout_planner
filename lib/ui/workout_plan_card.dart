import 'package:flutter/material.dart';

import '../models/workout_plan.dart';

import 'package:ai_workout_planner/ui/workout_plan_details_page.dart'; // Import your WorkoutPlanDetailsPage

class WorkoutPlanCard extends StatelessWidget {
  final WorkoutPlan workoutPlan;
  Color? titleBackgroundColor;
  final TextStyle titleTextStyle;
  final EdgeInsets titlePadding;
  final Icon leadingIcon;
  final TextStyle subtitleTextStyle;

  WorkoutPlanCard({
    super.key,
    required this.workoutPlan,
    this.titleBackgroundColor,
    this.titleTextStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.leadingIcon = const Icon(Icons.fitness_center),
    this.subtitleTextStyle = const TextStyle(),
  });

  @override
  Widget build(BuildContext context) {
    titleBackgroundColor ??= Theme.of(context).primaryColor;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutPlanDetailsPage(workoutPlan: workoutPlan),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title with background color
            Container(
              padding: titlePadding,
              decoration: BoxDecoration(
                color: titleBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Text(
                workoutPlan.name,
                style: titleTextStyle,
              ),
            ),
            ListTile(
              leading: leadingIcon,
              title: Text(workoutPlan.name, style: subtitleTextStyle),
              subtitle: Text('Weeks: ${workoutPlan.numberOfWeeks}'),
              isThreeLine: true,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                workoutPlan.description,
                style: subtitleTextStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


