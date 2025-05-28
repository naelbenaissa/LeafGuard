import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Cette méthode est appelée quand l'utilisateur termine l'onboarding
  // Elle sauvegarde dans les préférences locales que l'onboarding est complété,
  // puis navigue vers la route principale ('/').
  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    // Utilise Future.microtask pour s'assurer que la navigation est
    // effectuée après la mise à jour des préférences.
    Future.microtask(() {
      context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      // Liste des pages de l'onboarding
      pages: [
        _buildPage(
          title: "Bienvenue sur LeafGuard",
          body:
          "Scannez, comprenez et agissez pour prendre soin de vos plantes !",
          imagePath: "assets/img/tutoriel/home.png",
        ),
        _buildPage(
          title: "Ajoutez des tâches",
          body:
          "Planifiez facilement l’entretien de vos plantes avec le calendrier intégré.",
          imagePath: "assets/img/tutoriel/task.png",
        ),
        _buildPage(
          title: "Diagnostic intelligent",
          body:
          "Utilisez l’IA pour identifier les maladies de vos plantes et recevoir des conseils.",
          imagePath: "assets/img/tutoriel/diagnostic.png",
        ),
        _buildPage(
          title: "Découvrez plus de 300 000 plantes",
          body:
          "Accédez à un guide complet avec des informations détaillées sur chaque plante.",
          imagePath: "assets/img/tutoriel/guide.png",
        ),
      ],

      // Appelé lorsque l'utilisateur clique sur "Terminé"
      onDone: () => _onIntroEnd(context),

      // Affiche le bouton "Passer"
      showSkipButton: true,

      skip: const Text(
        "Passer",
        style: TextStyle(color: Colors.black),
      ),

      // Icône pour passer à la page suivante
      next: const Icon(
        Icons.arrow_forward,
        color: Colors.black,
      ),

      // Bouton "Terminé"
      done: const Text("Terminé",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),

      // Personnalisation des points de progression
      dotsDecorator: DotsDecorator(
        size: const Size(10.0, 10.0),
        color: Colors.grey,
        activeSize: const Size(22.0, 10.0),
        activeColor: Colors.green,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  // Méthode privée pour construire une page d'onboarding avec image, titre et description
  PageViewModel _buildPage({
    required String title,
    required String body,
    required String imagePath,
  }) {
    return PageViewModel(
      // On remplace le titre classique par un widget vide pour personnaliser entièrement le corps
      titleWidget: const SizedBox(),
      bodyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath), // Illustration principale
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
