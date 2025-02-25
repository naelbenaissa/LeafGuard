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
    int start = (currentPage - 2).clamp(1, totalPages - 4);
    int end = (start + 4).clamp(1, totalPages);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        for (int i = start; i <= end; i++)
          if (i == currentPage)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('$i',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          else
            TextButton(
              onPressed: () => onPageChanged(i),
              child: Text('$i'),
            ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),
      ],
    );
  }
}
