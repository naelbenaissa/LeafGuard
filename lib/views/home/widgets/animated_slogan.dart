import 'package:flutter/material.dart';

class AnimatedSlogan extends StatefulWidget {
  final List<String> sloganWords;
  const AnimatedSlogan({super.key, required this.sloganWords});

  @override
  _AnimatedSloganState createState() => _AnimatedSloganState();
}

class _AnimatedSloganState extends State<AnimatedSlogan> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    for (int i = 0; i < widget.sloganWords.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600)); // Pause entre chaque mot
      if (mounted) {
        setState(() {
          currentIndex = i + 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF9DB33E),
      const Color(0xFF55761A),
      const Color(0xFF264E2C),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        currentIndex,
            (index) => Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            widget.sloganWords[index],
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: colors[index % colors.length], // Applique une couleur différente à chaque mot
            ),
          ),
        ),
      ),
    );
  }
}
