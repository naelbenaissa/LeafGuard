import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_service.dart';
import '../bar/custom_bottombar.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final SupabaseClient supabase = Supabase.instance.client;
  final UserService userService = UserService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String errorMessage = '';

  Future<void> _authenticate() async {
    setState(() {
      errorMessage = '';
    });

    try {
      if (isLogin) {
        // Connexion utilisateur
        final response = await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (response.session != null) {
          if (mounted) {
            context.go('/');
          }
        }
      } else {
        // Vérifier si les mots de passe correspondent
        if (passwordController.text != confirmPasswordController.text) {
          setState(() {
            errorMessage = "Les mots de passe ne correspondent pas.";
          });
          return;
        }

        final response = await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
          emailRedirectTo: null,
        );


        final user = response.user;
        if (user != null) {
          await userService.addUserData(
            user.id,
            nameController.text.trim(),
            surnameController.text.trim(),
            phoneController.text.trim(),
          );

          if (mounted) {
            context.go('/');
          }
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur : ${e.toString()}";
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              isLogin ? "Content de te revoir !" : "Créer un compte",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration("Email"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: _inputDecoration("Mot de passe"),
            ),
            if (!isLogin) ...[
              const SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: _inputDecoration("Confirmez le mot de passe"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: _inputDecoration("Nom (optionnel)"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: surnameController,
                decoration: _inputDecoration("Prénom (optionnel)"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Numéro de téléphone (optionnel)"),
              ),
            ],
            const SizedBox(height: 10),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                isLogin ? "Connexion" : "Inscription",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(
                isLogin
                    ? "Vous n'avez pas de compte ? Inscrivez-vous"
                    : "Vous avez déjà un compte ? Connectez-vous",
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      filled: true,
      fillColor: Colors.grey[200],
    );
  }
}
