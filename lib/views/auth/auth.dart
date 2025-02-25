import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_service.dart';
import '../bar/custom_bottombar.dart';
import 'package:intl/intl.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  final SupabaseClient supabase = Supabase.instance.client;
  final UserService userService = UserService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthdateController = TextEditingController();

  Future<void> _authenticate() async {
    try {
      if (!isLogin) {
        // Vérifier si les mots de passe correspondent
        if (passwordController.text != confirmPasswordController.text) {
          _showSnackbar("Les mots de passe ne correspondent pas.");
          return;
        }

        if (nameController.text.isEmpty || surnameController.text.isEmpty) {
          _showSnackbar("Le nom et le prénom sont obligatoires.");
          return;
        }

        // Vérifier l'âge minimum de 16 ans si une date est entrée
        if (birthdateController.text.isNotEmpty) {
          DateTime? birthDate = DateFormat("dd/MM/yyyy").parse(
              birthdateController.text);
          DateTime today = DateTime.now();
          int age = today.year - birthDate.year;
          if (today.month < birthDate.month ||
              (today.month == birthDate.month && today.day < birthDate.day)) {
            age--;
          }
          if (age < 16) {
            _showSnackbar(
                "Vous devez avoir au moins 16 ans pour vous inscrire.");
            return;
          }
        }

        final response = await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        final user = response.user;
        if (user != null) {
          await userService.addUserData(
            user.id,
            emailController.text.trim(),
            nameController.text.trim(),
            surnameController.text.trim(),
            phoneController.text.trim(),
            birthdateController.text
                .trim()
                .isNotEmpty ? birthdateController.text.trim() : null,
          );

          if (mounted) {
            context.go('/');
          }
        }
      } else {
        final response = await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (response.session != null) {
          if (mounted) {
            context.go('/');
          }
        }
      }
    } catch (e) {
      _showSnackbar("Erreur : ${e.toString()}");
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    birthdateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
      // 16 ans en arrière
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        birthdateController.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                isLogin ? "Content de te revoir !" : "Créer un compte",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                  emailController, "Email", TextInputType.emailAddress),
              if (!isLogin) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTextField(
                        nameController, "Nom")),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField(
                        surnameController, "Prénom")),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              _buildPasswordField(
                  passwordController, "Mot de passe", isPasswordVisible, () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              }),
              if (!isLogin) ...[
                const SizedBox(height: 10),
                _buildPasswordField(
                    confirmPasswordController, "Confirmez le mot de passe",
                    isConfirmPasswordVisible, () {
                  setState(() {
                    isConfirmPasswordVisible = !isConfirmPasswordVisible;
                  });
                }),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildTextField(
                        phoneController, "Téléphone (optionnel)",
                        TextInputType.phone)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: birthdateController,
                        readOnly: true,
                        decoration: _inputDecoration(
                            "Date de naissance (optionnel)").copyWith(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType type = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: _inputDecoration(label),
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

  Widget _buildPasswordField(TextEditingController controller,
      String label,
      bool isVisible,
      VoidCallback onToggle,) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      decoration: _inputDecoration(label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggle,
        ),
      ),
    );
  }

}
