import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/leafguard_api_service.dart';
import '../../../services/scan_service.dart';
import '../../../services/tasks_service.dart';

class ScanResultDialog {
  static Future<void> show(
      BuildContext context,
      File selectedImage,
      IaLeafguardService iaService,
      ScanService scanService,
      ) async {
    try {
      final result = await iaService.predictDisease(selectedImage);
      final String maladie = result['maladies'] ?? 'Inconnu';
      final double? rawConfiance = result['confiance'];
      final double? displayedConfiance =
      rawConfiance != null ? rawConfiance * 100 : null;

      bool isBookmarked = false;
      String? scanId;
      String? imageUrl;
      bool tasksAdded = false;

      final session = Supabase.instance.client.auth.currentSession;
      final bool isAuthenticated = session != null;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          bool isDialogOpen = true;
          List<Map<String, dynamic>> diseaseTasks = [];
          bool hasLoadedTasks = false;

          return StatefulBuilder(
            builder: (context, setState) {
              Future<void> loadTasks() async {
                if (hasLoadedTasks) return;
                hasLoadedTasks = true;
                try {
                  final tasks = await TasksService(Supabase.instance.client)
                      .getTasksForDisease(maladie);
                  if (!isDialogOpen) return;
                  setState(() {
                    diseaseTasks = tasks;
                  });
                } catch (e) {
                  debugPrint("Erreur chargement tâches: $e");
                }
              }

              WidgetsBinding.instance.addPostFrameCallback((_) => loadTasks());

              return WillPopScope(
                onWillPop: () async {
                  isDialogOpen = false;
                  return true;
                },
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Résultat du Scan",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip: "Fermer",
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9, // 90% écran
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 500,
                        minHeight: 100,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  selectedImage,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                "Maladie détectée : $maladie",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Center(
                              child: Text(
                                "Confiance : ${displayedConfiance != null ? "${displayedConfiance.toStringAsFixed(2)}%" : "N/A"}",
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              "Tâches recommandées :",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 5),
                            if (diseaseTasks.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Aucune tâche trouvée pour cette maladie."),
                                    if (!isAuthenticated) ...[
                                      const SizedBox(height: 8),
                                      const Text(
                                        "Connectez-vous afin d’ajouter des tâches personnalisées.",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context.go('/auth');
                                        },
                                        child: const Text(
                                          "Se connecter",
                                          style: TextStyle(
                                            decoration: TextDecoration.underline,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: diseaseTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = diseaseTasks[index];
                                      final priority = task['priority'] ?? 'low';

                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          Icons.flag,
                                          size: 20,
                                          color: priority == 'high'
                                              ? Colors.red
                                              : priority == 'medium'
                                              ? Colors.orange
                                              : Colors.green,
                                        ),
                                        title: Text(task['title'] ?? 'Tâche'),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          isAuthenticated
                                              ? (tasksAdded
                                              ? "Tâches ajoutées ! Cliquez sur le bouton ci-dessous pour voir le calendrier."
                                              : "Pour ajouter ces tâches, cliquez sur l'icône calendrier.")
                                              : "Pour ajouter ces tâches, cliquez sur l'icône ci-dessous pour vous connecter ou vous inscrire.",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    if (isAuthenticated)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.orange,
                            ),
                            tooltip: isBookmarked
                                ? "Retirer des favoris"
                                : "Ajouter aux favoris",
                            onPressed: () async {
                              if (isBookmarked) {
                                if (scanId == null || imageUrl == null) {
                                  final scans = await scanService.getScans();
                                  if (scans.isNotEmpty) {
                                    scanId = scans.first['id']?.toString();
                                    imageUrl = scans.first['image_url']?.toString();
                                  } else {
                                    return;
                                  }
                                }
                                final confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Supprimer ce scan ?"),
                                    content: const Text(
                                        "Êtes-vous sûr de vouloir supprimer ce scan ? Cette action est irréversible."),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Annuler"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          "Supprimer",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmDelete == true) {
                                  try {
                                    await scanService.deleteScan(scanId!, imageUrl!);
                                    setState(() {
                                      isBookmarked = false;
                                      scanId = null;
                                      imageUrl = null;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Scan supprimé avec succès.")),
                                    );
                                  } catch (e) {
                                    debugPrint("Erreur suppression : $e");
                                  }
                                }
                              } else {
                                try {
                                  await scanService.addScan(
                                    imageFile: selectedImage,
                                    predictions: maladie,
                                    confidence: rawConfiance ?? 0.0,
                                  );
                                  final scans = await scanService.getScans();
                                  final addedScan = scans.firstWhere(
                                        (scan) =>
                                    scan['predictions'] == maladie &&
                                        scan['confidence'] == rawConfiance,
                                    orElse: () => {},
                                  );
                                  setState(() {
                                    isBookmarked = true;
                                    scanId = addedScan['id']?.toString();
                                    imageUrl = addedScan['image_url']?.toString();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Ajouté aux favoris !")),
                                  );
                                } catch (e) {
                                  debugPrint("Erreur ajout favoris : $e");
                                }
                              }
                            },
                          ),
                          if (diseaseTasks.isNotEmpty)
                            IconButton(
                              onPressed: () async {
                                if (tasksAdded) {
                                  Navigator.pop(context);
                                  GoRouter.of(context).go('/calendar');
                                } else {
                                  try {
                                    await TasksService(Supabase.instance.client).addTasksForDisease(maladie);
                                    setState(() {
                                      tasksAdded = true;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Tâches ajoutées au calendrier !")),
                                    );
                                  } catch (e) {
                                    debugPrint("Erreur ajout tâches : $e");
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Erreur : $e")),
                                    );
                                  }
                                }
                              },
                              icon: Icon(
                                tasksAdded ? Icons.calendar_month : Icons.calendar_today,
                                color: Colors.green,
                                size: 26,  // même taille que tu voulais
                              ),
                              tooltip: tasksAdded ? "Voir le calendrier" : "Ajouter au calendrier",
                              splashRadius: 20, // optionnel pour contrôler la zone de clic
                            ),
                        ],
                      )
                    else
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
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
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint("Erreur lors de l'analyse de l'image: $e");
    }
  }
}
