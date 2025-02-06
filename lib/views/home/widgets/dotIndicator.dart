import 'package:flutter/material.dart';

class DotIndicator extends Decoration {
  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _DotPainter();
  }
}

class _DotPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final double circleX = configuration.size!.width / 2 + offset.dx;
    final double circleY = configuration.size!.height - 4;

    canvas.drawCircle(Offset(circleX, circleY), 4, paint);
  }
}
