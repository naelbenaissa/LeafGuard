import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            "Veuillez vous connecter pour voir vos scans enregistrés.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.red[300] : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (recentScans.isEmpty) {
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
