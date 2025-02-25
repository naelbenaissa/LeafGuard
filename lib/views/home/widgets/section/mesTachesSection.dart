import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_leafguard/services/tasks_service.dart';
import '../../../widgets/task_card.dart';

class MesTachesSection extends StatefulWidget {
  const MesTachesSection({super.key});

  @override
  _MesTachesSectionState createState() => _MesTachesSectionState();
}

class _MesTachesSectionState extends State<MesTachesSection> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TasksService tasksService = TasksService(Supabase.instance.client);
  bool showPastTasks = false;
  Future<List<Map<String, dynamic>>>? _futureTasks;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  /// 🔄 Recharge la liste des tâches
  void _refreshTasks() {
    final user = supabase.auth.currentUser;
    setState(() {
      _futureTasks = tasksService.fetchTasks(user?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureTasks,
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
          future: initializeDateFormatting('fr_CA', null),
          builder: (context, localeSnapshot) {
            if (localeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = snapshot.data!;
            final Map<String, List<Map<String, dynamic>>> groupedTasks = {};
            DateTime today = DateTime.now();
            today = DateTime(today.year, today.month, today.day);

            for (var task in tasks) {
              DateTime taskDate = DateTime.parse(task['due_date']);
              bool isPastTask = taskDate.isBefore(today) && taskDate.day != today.day;
              if (!showPastTasks && isPastTask) continue;

              String formattedDate = DateFormat.yMMMMd('fr_CA').format(taskDate);
              if (!groupedTasks.containsKey(formattedDate)) {
                groupedTasks[formattedDate] = [];
              }
              groupedTasks[formattedDate]!.add(task);
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showPastTasks = !showPastTasks;
                        });
                      },
                      icon: Icon(
                        showPastTasks
                            ? Icons.history_toggle_off
                            : Icons.history,
                        color: Colors.white,
                      ),
                      label: Text(
                        showPastTasks
                            ? "Masquer les tâches passées"
                            : "Afficher les tâches passées",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        backgroundColor: showPastTasks
                            ? Colors.green.shade700
                            : Colors.green.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
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
                                padding:
                                const EdgeInsets.symmetric(vertical: 8.0),
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
                                  id: task['id'].toString(),
                                  title: task['title'],
                                  description: task['description'],
                                  priority: task['priority'],
                                  refreshTasks: _refreshTasks,
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
