import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ui_leafguard/services/tasks_service.dart';

class CreateTask {
  static void show(BuildContext context, VoidCallback refreshTasks) {
    String title = "";
    String description = "";
    DateTime selectedDate = DateTime.now();
    String priority = "medium";

    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        DateTime selectedDateLocal = selectedDate;
        String priorityLocal = priority;

        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final textColor = theme.textTheme.bodyLarge!.color;
            final fieldColor = colorScheme.surfaceContainerHighest;

            return Dialog(
              backgroundColor: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SizedBox(
                width: 400,
                height: 500,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Nouvelle tâche",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Titre",
                          labelStyle: TextStyle(color: textColor),
                          filled: true,
                          fillColor: fieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: textColor),
                        onChanged: (value) => title = value,
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Description",
                          labelStyle: TextStyle(color: textColor),
                          filled: true,
                          fillColor: fieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: textColor),
                        onChanged: (value) => description = value,
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Date : ${DateFormat.yMMMMd('fr_CA').format(selectedDateLocal)}",
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.calendar_today, color: textColor),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDateLocal,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDateLocal = pickedDate;
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: priorityLocal,
                        decoration: InputDecoration(
                          labelText: "Priorité",
                          labelStyle: TextStyle(color: textColor),
                          filled: true,
                          fillColor: fieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        dropdownColor: fieldColor,
                        style: TextStyle(color: textColor),
                        items: [
                          {"value": "low", "label": "Basse"},
                          {"value": "medium", "label": "Moyenne"},
                          {"value": "high", "label": "Haute"},
                        ].map((item) {
                          return DropdownMenuItem<String>(
                            value: item["value"],
                            child: Text(item["label"]!, style: TextStyle(color: textColor)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              priorityLocal = value;
                              priority = value;
                            });
                          }
                        },
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: BorderSide(color: textColor!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text("Annuler"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (title.isEmpty || description.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Veuillez remplir tous les champs")),
                                );
                                return;
                              }
                              try {
                                final taskService = TasksService(Supabase.instance.client);
                                await taskService.addTask(user.id, title, description, selectedDateLocal, priorityLocal);
                                refreshTasks();
                                Navigator.of(context).pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Erreur: $e")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: fieldColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Ajouter", style: TextStyle(color: textColor)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

  }
}
