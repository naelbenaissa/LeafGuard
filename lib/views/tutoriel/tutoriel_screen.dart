import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    // Utiliser `Future.microtask` pour éviter des conflits avec le contexte de navigation
    Future.microtask(() {
      context.go('/'); // Aller à la page d'accueil après onboarding
    });
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Bienvenue sur LeafGuard",
          body: "Scannez, comprenez et agissez pour prendre soin de vos plantes !",
          image: Image.asset("assets/img/onboarding1.png", height: 250),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Ajoutez des tâches",
          body: "Planifiez facilement l’entretien de vos plantes avec le calendrier intégré.",
          image: Image.asset("assets/img/onboarding2.png", height: 250),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Diagnostic intelligent",
          body: "Utilisez l’IA pour identifier les maladies de vos plantes et recevoir des conseils.",
          image: Image.asset("assets/img/onboarding3.png", height: 250),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "Découvrez plus de 300 000 plantes",
          body: "Accédez à un guide complet avec des informations détaillées sur chaque plante.",
          image: Image.asset("assets/img/onboarding4.png", height: 250),
          decoration: _pageDecoration(),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("Passer"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Terminé", style: TextStyle(fontWeight: FontWeight.bold)),
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

  PageDecoration _pageDecoration() {
    return const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
      bodyTextStyle: TextStyle(fontSize: 16.0),
      imagePadding: EdgeInsets.all(20),
      pageColor: Colors.white,
    );
  }
}
