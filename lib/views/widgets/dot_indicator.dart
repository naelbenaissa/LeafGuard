import 'package:flutter/material.dart';

/// Decoration personnalisée pour afficher un indicateur en forme de point (dot)
class DotIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    // Crée le peintre personnalisé pour dessiner le point
    return _DotPainter();
  }
}

class _DotPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    // Configure la peinture : couleur verte, remplissage
    final Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    // Calcule la position horizontale du centre du cercle (milieu du widget)
    final double circleX = configuration.size!.width / 2 + offset.dx;

    // Position verticale légèrement au-dessus du bas du widget (4 pixels au-dessus)
    final double circleY = configuration.size!.height - 4;

    // Dessine un cercle rempli de rayon 4 pixels à la position calculée
    canvas.drawCircle(Offset(circleX, circleY), 4, paint);
  }
}
