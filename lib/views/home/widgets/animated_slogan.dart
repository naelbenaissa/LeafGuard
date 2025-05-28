import 'package:flutter/material.dart';

/// Widget animé affichant un slogan mot par mot avec une animation de délai entre chaque mot.
/// La première fois que le widget est affiché, chaque mot apparaît progressivement.
/// Après la première animation, tous les mots restent affichés instantanément sans ré-animer.
class AnimatedSlogan extends StatefulWidget {
  // Liste des mots composant le slogan à afficher
  final List<String> sloganWords;

  const AnimatedSlogan({super.key, required this.sloganWords});

  @override
  _AnimatedSloganState createState() => _AnimatedSloganState();
}

class _AnimatedSloganState extends State<AnimatedSlogan> {
  // Variable statique pour mémoriser si l'animation a déjà été jouée dans l'app (partagée entre instances)
  static bool _animationPlayed = false;

  // Index du mot courant affiché dans l'animation (nombre de mots affichés)
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (!_animationPlayed) {
      // Lance l'animation progressive si elle n'a pas encore été jouée
      _startAnimation();
    } else {
      // Si animation déjà jouée, affiche tous les mots d'un coup (sans animation)
      currentIndex = widget.sloganWords.length;
    }
  }

  /// Lance une animation asynchrone affichant progressivement les mots du slogan avec un délai
  void _startAnimation() async {
    for (int i = 0; i < widget.sloganWords.length; i++) {
      // Attendre 600ms avant d'afficher le mot suivant
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) { // Vérifie que le widget est toujours monté dans l'arbre
        setState(() {
          currentIndex = i + 1; // Incrémente le nombre de mots affichés
        });
      }
    }
    _animationPlayed = true; // Marque l'animation comme jouée pour éviter de la rejouer
  }

  @override
  Widget build(BuildContext context) {
    // Palette de couleurs utilisée pour colorer les mots du slogan en boucle
    final colors = [
      const Color(0xFF9DB33E),
      const Color(0xFF55761A),
      const Color(0xFF264E2C),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
        currentIndex, // Nombre de mots affichés actuellement
            (index) => Padding(
          padding: const EdgeInsets.only(bottom: 5), // Espacement vertical entre les mots
          child: Text(
            widget.sloganWords[index], // Mot à afficher
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: colors[index % colors.length], // Couleur cyclique selon l'index
            ),
          ),
        ),
      ),
    );
  }
}
