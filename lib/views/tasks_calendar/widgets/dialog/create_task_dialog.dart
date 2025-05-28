import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Pour formater la date dans la langue/fr locale
import 'package:supabase_flutter/supabase_flutter.dart'; // Client Supabase pour l'authentification et la BD
import 'package:ui_leafguard/services/tasks_service.dart'; // Service personnalisé pour gérer les tâches

/// Classe statique pour afficher la boîte de dialogue de création d'une tâche
class CreateTask {
  /// Affiche la boîte de dialogue permettant de créer une nouvelle tâche
  /// [context] : contexte Flutter actuel
  /// [refreshTasks] : callback pour rafraîchir la liste des tâches après ajout
  static void show(BuildContext context, VoidCallback refreshTasks) {
    // Variables locales pour stocker les champs du formulaire
    String title = "";
    String description = "";
    DateTime selectedDate = DateTime.now(); // Date initiale = aujourd'hui
    String priority = "medium"; // Priorité par défaut

    // Récupération de l'instance Supabase et de l'utilisateur courant
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Vérification que l'utilisateur est connecté
    if (user == null) {
      // Si pas connecté, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté")),
      );
      return; // Quitter la méthode
    }

    // Affichage de la boîte de dialogue modale
    showDialog(
      context: context,
      builder: (context) {
        // Variables locales dans le builder pour gérer l'état local
        DateTime selectedDateLocal = selectedDate;
        String priorityLocal = priority;

        // StatefulBuilder permet de mettre à jour l'UI dans la boîte de dialogue
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
                      // Titre de la boîte de dialogue
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

                      // Champ texte pour le titre de la tâche
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
                        onChanged: (value) => title = value, // Mise à jour variable
                      ),
                      const SizedBox(height: 10),

                      // Champ texte multi-lignes pour la description
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
                        onChanged: (value) => description = value, // Mise à jour variable
                      ),
                      const SizedBox(height: 10),

                      // Affichage et sélection de la date
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          "Date : ${DateFormat.yMMMMd('fr_CA').format(selectedDateLocal)}", // Formattage de la date
                          style: TextStyle(fontSize: 16, color: textColor),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.calendar_today, color: textColor),
                          onPressed: () async {
                            // Affiche un sélecteur de date
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDateLocal,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            // Si l'utilisateur choisit une date, on met à jour l'état local
                            if (pickedDate != null) {
                              setState(() {
                                selectedDateLocal = pickedDate;
                                selectedDate = pickedDate; // Synchronisation avec variable principale
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Sélecteur déroulant pour la priorité de la tâche
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Priorité",
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: priorityLocal,
                            isExpanded: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: fieldColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                              // Mise à jour de la priorité dans l'état local et global
                              if (value != null) {
                                setState(() {
                                  priorityLocal = value;
                                  priority = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Boutons d'annulation et de validation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Bouton pour fermer la boîte de dialogue sans enregistrer
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

                          // Bouton pour ajouter la tâche
                          ElevatedButton(
                            onPressed: () async {
                              // Validation simple : tous les champs obligatoires doivent être remplis
                              if (title.isEmpty || description.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Veuillez remplir tous les champs")),
                                );
                                return;
                              }
                              try {
                                // Création d'une instance du service de tâches avec Supabase
                                final taskService = TasksService(Supabase.instance.client);
                                // Appel asynchrone pour ajouter la tâche dans la base
                                await taskService.addTask(user.id, title, description, selectedDateLocal, priorityLocal);
                                // Rafraîchissement de la liste des tâches via le callback
                                refreshTasks();
                                // Fermeture de la boîte de dialogue
                                Navigator.of(context).pop();
                              } catch (e) {
                                // Affichage d'une erreur en cas de problème
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
