import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget affichant une grille des scans récents de l’utilisateur connecté.
///
/// Affiche un message invitant à se connecter si l’utilisateur n’est pas authentifié.
/// Affiche un message si aucune donnée n’est disponible.
/// Chaque scan affiche une image, la prédiction, et le niveau de confiance.
/// Le callback [onScanTap] est déclenché lors de la sélection d’un scan.
class RecentScansGrid extends StatelessWidget {
  final List<Map<String, dynamic>> recentScans;
  final VoidCallback onScanTap;

  const RecentScansGrid({
    super.key,
    required this.recentScans,
    required this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final bool isAuthenticated = session != null;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (!isAuthenticated) {
      // Invite à se connecter si l’utilisateur n’est pas connecté
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Veuillez vous connecter pour voir vos scans enregistrés.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.red[300] : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/auth'),
                child: const Text(
                  "Se connecter",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (recentScans.isEmpty) {
      // Message si aucun scan disponible
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "Vous n'avez aucun scan enregistré",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey[400] : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Affichage de la grille de scans
    return SingleChildScrollView(
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentScans.length,
        itemBuilder: (context, index) {
          final scan = recentScans[index];

          return GestureDetector(
            onTap: onScanTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.network(
                        scan['image_url'],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image,
                          size: 50,
                          color: isDarkMode ? Colors.grey[500] : Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            scan['predictions'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Confiance: ${(scan['confidence'] * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
