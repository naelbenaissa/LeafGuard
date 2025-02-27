import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    Future.microtask(() {
      context.go('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
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
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text(
        "Passer",
        style: TextStyle(color: Colors.black),
      ),
      next: const Icon(
        Icons.arrow_forward,
        color: Colors.black,
      ),
      done: const Text("Terminé",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
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

  PageViewModel _buildPage({
    required String title,
    required String body,
    required String imagePath,
  }) {
    return PageViewModel(
      // title: title,
      titleWidget: const SizedBox(),
      bodyWidget: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath),
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
