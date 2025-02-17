import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_leafguard/services/tasks_service.dart';

import '../../../widgets/task_card.dart';

Widget mesTachesSection() {
  final SupabaseClient supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  final TasksService tasksService = TasksService(supabase);

  return FutureBuilder<List<Map<String, dynamic>>>(
    future: tasksService.fetchTasks(user?.id),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return Center(child: Text("Erreur : ${snapshot.error}"));
      }
      if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Center(child: Text("Aucune tâche trouvée"));
      }

      return FutureBuilder(
        future: initializeDateFormatting('fr_FR', null),
        builder: (context, localeSnapshot) {
          if (localeSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;
          final Map<String, List<Map<String, dynamic>>> groupedTasks = {};

          for (var task in tasks) {
            String formattedDate = DateFormat.yMMMMd('fr_FR')
                .format(DateTime.parse(task['due_date']));

            if (!groupedTasks.containsKey(formattedDate)) {
              groupedTasks[formattedDate] = [];
            }
            groupedTasks[formattedDate]!.add(task);
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: groupedTasks.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ...entry.value.map((task) {
                        return TaskCard(
                          title: task['title'],
                          description: task['description'],
                          priority: task['priority'],
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    },
  );
}
