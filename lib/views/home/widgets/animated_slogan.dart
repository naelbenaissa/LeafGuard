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
      Color(0xFF9DB33E),  // #9db33e (une nuance de vert clair)
      Color(0xFF55761A),  // #55761a (une nuance de vert moyen)
      Color(0xFF264E2C),  // #264e2c (une nuance de vert foncé)
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        currentIndex,
            (index) => Padding(
          padding: const EdgeInsets.only(bottom: 5), // Espacement entre les mots
          child: Text(
            widget.sloganWords[index],
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: colors[index % colors.length], // Applique une couleur différente à chaque mot
            ),
          ),
        ),
      ),
    );
  }
}
