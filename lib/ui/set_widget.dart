import 'package:flutter/material.dart';

class SetWidget extends StatelessWidget {
  final int setNumber;

  const SetWidget({super.key, required this.setNumber});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Set $setNumber'),
      // Add more details about the set if needed
    );
  }
}
