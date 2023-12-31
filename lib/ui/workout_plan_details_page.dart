import 'package:ai_workout_planner/ui/workout_detail_page.dart';
import 'package:flutter/material.dart';

import '../models/day.dart';
import '../models/week.dart';
import '../models/workout_plan.dart';

class WorkoutPlanDetailsPage extends StatelessWidget {
  final WorkoutPlan workoutPlan;

  const WorkoutPlanDetailsPage({Key? key, required this.workoutPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a list of weeks based on the numberOfWeeks
    List<Week> weeks = List.generate(workoutPlan.numberOfWeeks, (_) => workoutPlan.weekSchedule);

    return Scaffold(
      appBar: AppBar(
        title: Text(workoutPlan.name),
      ),
      body: PageView.builder(
        itemCount: weeks.length,
        itemBuilder: (context, weekIndex) {
          Week week = weeks[weekIndex];
          return _buildWeekView(week, context, weekIndex + 1);
        },
      ),
    );
  }

  Widget _buildWeekView(Week week, BuildContext context, int weekNumber) {
    List<Day> days = [week.monday, week.tuesday, week.wednesday, week.thursday, week.friday, week.saturday, week.sunday];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Week $weekNumber'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              Day day = days[index];
              return ListTile(
                title: Text(day.isRestDay ? 'Rest Day' : day.workout!.name),
                subtitle: day.workout != null ? Text(day.workoutSplit) : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailPage(workout: day.workout!),
                    ),
                  );                },
              );
            },
          ),
        ),
      ],
    );
  }
}
