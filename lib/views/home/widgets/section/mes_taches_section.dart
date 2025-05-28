import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui_leafguard/services/tasks_service.dart';
import '../../../widgets/task_card.dart';
import 'package:go_router/go_router.dart';

/// Widget affichant la section "Mes Tâches"
class MesTachesSection extends StatefulWidget {
  const MesTachesSection({super.key});

  @override
  _MesTachesSectionState createState() => _MesTachesSectionState();
}

class _MesTachesSectionState extends State<MesTachesSection> {
  // Instance du client Supabase
  final SupabaseClient supabase = Supabase.instance.client;

  // Service personnalisé pour gérer les tâches
  final TasksService tasksService = TasksService(Supabase.instance.client);

  // Booléen pour afficher ou non les tâches passées
  bool showPastTasks = false;

  // Future contenant la liste des tâches à afficher
  Future<List<Map<String, dynamic>>>? _futureTasks;

  @override
  void initState() {
    super.initState();
    // Chargement initial des tâches lors de la création du widget
    _refreshTasks();
  }

  /// Méthode pour recharger la liste des tâches depuis le service
  void _refreshTasks() {
    final user = supabase.auth.currentUser; // Récupération de l'utilisateur connecté
    setState(() {
      // Affectation d'un nouveau Future qui récupère les tâches de l'utilisateur
      _futureTasks = tasksService.fetchTasks(user?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser; // Récupération utilisateur connecté

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureTasks, // Future qui charge la liste des tâches
      builder: (context, snapshot) {
        // Affichage d'un loader pendant le chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Gestion des erreurs lors du chargement des données
        if (snapshot.hasError) {
          return Center(child: Text("Erreur : ${snapshot.error}"));
        }
        // Cas où aucune tâche n'est trouvée ou la liste est vide
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              _refreshTasks();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Aucune tâche trouvée.",
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Planifiez vos tâches dans le calendrier pour mieux organiser vos plantes.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Affiche un message et bouton de connexion si l'utilisateur n'est pas connecté
                    user == null
                        ? Column(
                      children: [
                        const Text(
                          "Veuillez vous connecter pour accéder au calendrier et gérer vos tâches.",
                          style: TextStyle(fontSize: 16, color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            context.go('/auth'); // Redirection vers la page de connexion
                          },
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                        : TextButton(
                      onPressed: () {
                        context.go('/calendar'); // Redirection vers le calendrier si connecté
                      },
                      child: const Text(
                        "Ouvrir le calendrier",
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Chargement des données de localisation pour le formatage de date en français canadien
        return FutureBuilder(
          future: initializeDateFormatting('fr_CA', null),
          builder: (context, localeSnapshot) {
            if (localeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = snapshot.data!;
            // Date du jour, sans l'heure (uniquement année, mois, jour)
            DateTime today = DateTime.now();
            today = DateTime(today.year, today.month, today.day);

            // Séparation des tâches en tâches passées et tâches à venir (dont aujourd'hui)
            List<Map<String, dynamic>> upcomingTasks = [];
            List<Map<String, dynamic>> pastTasks = [];

            for (var task in tasks) {
              DateTime taskDate = DateTime.parse(task['due_date']);
              // Détermine si la tâche est passée (avant aujourd'hui, mais pas aujourd'hui)
              bool isPastTask = taskDate.isBefore(today) && taskDate.day != today.day;
              if (isPastTask) {
                pastTasks.add(task);
              } else {
                upcomingTasks.add(task);
              }
            }

            // Selon l'état du bouton, affiche soit toutes les tâches, soit seulement celles à venir
            final filteredTasks = showPastTasks ? tasks : upcomingTasks;

            // Regroupe les tâches par date formatée en chaîne lisible
            final Map<String, List<Map<String, dynamic>>> groupedTasks = {};
            for (var task in filteredTasks) {
              DateTime taskDate = DateTime.parse(task['due_date']);
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
                          // Inverse l'état d'affichage des tâches passées
                          showPastTasks = !showPastTasks;
                        });
                      },
                      icon: Icon(
                        showPastTasks ? Icons.history_toggle_off : Icons.history,
                        color: Colors.white,
                      ),
                      label: Text(
                        showPastTasks
                            ? "Masquer les tâches passées"
                            : "Afficher les tâches passées",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        backgroundColor: showPastTasks ? Colors.green.shade700 : Colors.green.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),

                // Message spécial si on a uniquement des tâches passées et qu'on ne veut pas les afficher
                if (!showPastTasks && upcomingTasks.isEmpty && pastTasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "Vous avez uniquement des tâches antérieures à aujourd'hui.",
                          style: TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Pour ajouter de nouvelles tâches, rendez-vous dans le calendrier.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        user == null
                            ? Column(
                          children: [
                            const Text(
                              "Veuillez vous connecter pour accéder au calendrier et gérer vos tâches.",
                              style: TextStyle(fontSize: 16, color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () {
                                context.go('/auth');
                              },
                              child: const Text(
                                "Se connecter",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        )
                            : TextButton(
                          onPressed: () {
                            context.go('/calendar');
                          },
                          child: const Text(
                            "Ouvrir le calendrier",
                            style: TextStyle(
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Affichage de la liste des tâches regroupées par date dans une zone scrollable
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
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  entry.key, // Affiche la date formatée comme titre de groupe
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                  ),
                                ),
                              ),
                              // Liste des tâches pour cette date
                              ...entry.value.map((task) {
                                return TaskCard(
                                  id: task['id'].toString(),
                                  title: task['title'],
                                  description: task['description'],
                                  priority: task['priority'],
                                  refreshTasks: _refreshTasks, // Permet de rafraîchir la liste depuis la carte tâche
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
