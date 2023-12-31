import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/day.dart';
import '../models/week.dart';
import '../models/workout_plan.dart';
import 'workout_detail_page.dart';

class WorkoutPlanDetailsPage extends StatelessWidget {
  final WorkoutPlan workoutPlan;

  const WorkoutPlanDetailsPage({Key? key, required this.workoutPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Day> days = [
      workoutPlan.weekSchedule.day1,
      workoutPlan.weekSchedule.day2,
      workoutPlan.weekSchedule.day3,
      workoutPlan.weekSchedule.day4,
      workoutPlan.weekSchedule.day5,
      workoutPlan.weekSchedule.day6,
      workoutPlan.weekSchedule.day7
    ];

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
            child: ListView.builder(
              itemCount: days.length,
              itemBuilder: (context, index) {
                Day day = days[index];
                return ListTile(
                  title: Text(
                    day.isRestDay ? 'Rest Day' : 'Workout Day',
                    style: TextStyle(color: day.isRestDay ? Colors.red : Colors.green),
                  ),
                  subtitle: day.workout != null ? Text(day.workout!.name) : null,
                  onTap: () {
                    if (!day.isRestDay && day.workout != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkoutDetailPage(workout: day.workout!),
                        ),
                      );
                    } else {
                      Fluttertoast.showToast(
                          msg: day.isRestDay ? "It's a rest day!" : "No workout available",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey[600],
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


