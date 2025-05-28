import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Nombre max de boutons de page affichés
    const maxPagesToShow = 5;

    // Calculer la première page à afficher
    int start = currentPage - (maxPagesToShow ~/ 2);
    int end = currentPage + (maxPagesToShow ~/ 2);

    if (start < 1) {
      start = 1;
      end = (maxPagesToShow).clamp(1, totalPages);
    }

    if (end > totalPages) {
      end = totalPages;
      start = (end - maxPagesToShow + 1).clamp(1, totalPages);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        for (int i = start; i <= end; i++)
          i == currentPage
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '$i',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
              : TextButton(
            onPressed: () => onPageChanged(i),
            child: Text('$i'),
          ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    );
  }
}
