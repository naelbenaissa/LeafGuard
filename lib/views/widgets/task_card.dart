import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String description;
  final String priority;

  const TaskCard({
    super.key,
    required this.title,
    required this.description,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(Icons.task, color: Colors.green),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(
          Icons.flag,
          color: priority == 'high'
              ? Colors.red
              : priority == 'medium'
              ? Colors.orange
              : Colors.green,
        ),
      ),
    );
  }
}
