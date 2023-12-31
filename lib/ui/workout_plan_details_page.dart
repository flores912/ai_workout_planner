import 'package:flutter/material.dart';
import '../models/day.dart';
import '../models/week.dart';
import '../models/workout_plan.dart';
import 'workout_detail_page.dart';

class WorkoutPlanDetailsPage extends StatelessWidget {
  final WorkoutPlan workoutPlan;

  const WorkoutPlanDetailsPage({Key? key, required this.workoutPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workoutPlan.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Description: ${workoutPlan.description}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Week ${workoutPlan.weekSchedule.weekNumber ?? ''}'),
            subtitle: Text('Click on a day to see the workout details.'),
          ),
          Expanded(
            child: ListView(
              children: _buildDayTiles(workoutPlan.weekSchedule, context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDayTiles(Week week, BuildContext context) {
    List<Day> days = [week.day1, week.day2, week.day3, week.day4, week.day5, week.day6, week.day7];
    return days.map((day) {
      return ListTile(
        title: Text(
          day.isRestDay ? 'Rest Day' : 'Workout Day',
          style: TextStyle(color: day.isRestDay ? Colors.red : Colors.green),
        ),
        subtitle: day.workout != null ? Text(day.workout!.name) : null,
        onTap: !day.isRestDay
            ? () {
          if (day.workout != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutDetailPage(workout: day.workout!),
              ),
            );
          }
        }
            : null,
      );
    }).toList();
  }
}


