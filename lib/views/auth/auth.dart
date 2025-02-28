import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user_service.dart';
import '../bar/custom_bottombar.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/auth_password_field.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_toggle_text.dart';

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
  final TextEditingController birthdateController = TextEditingController();

  Future<void> _authenticate() async {
    try {
      if (!isLogin) {
        if (passwordController.text != confirmPasswordController.text) {
          _showSnackbar("Les mots de passe ne correspondent pas.");
          return;
        }
        if (nameController.text.isEmpty || surnameController.text.isEmpty) {
          _showSnackbar("Le nom et le prénom sont obligatoires.");
          return;
        }
        if (birthdateController.text.isNotEmpty) {
          DateTime birthDate = DateFormat("dd/MM/yyyy").parse(birthdateController.text);
          if (_calculateAge(birthDate) < 16) {
            _showSnackbar("Vous devez avoir au moins 16 ans pour vous inscrire.");
            return;
          }
        }
        final response = await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        if (response.user != null) {
          await userService.addUserData(
            response.user!.id,
            emailController.text.trim(),
            nameController.text.trim(),
            surnameController.text.trim(),
            phoneController.text.trim(),
            birthdateController.text.trim().isNotEmpty ? birthdateController.text.trim() : null,
          );
          if (mounted) context.go('/');
        }
      } else {
        final response = await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
        if (response.session != null && mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      _showSnackbar("Erreur : ${e.toString()}");
    }
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge!.color;

    return Scaffold(
      backgroundColor: colorScheme.background,
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
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 20),
              AuthTextField(controller: emailController, label: "Email", keyboardType: TextInputType.emailAddress),
              if (!isLogin) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: AuthTextField(controller: nameController, label: "Nom")),
                    const SizedBox(width: 10),
                    Expanded(child: AuthTextField(controller: surnameController, label: "Prénom")),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              AuthPasswordField(controller: passwordController, label: "Mot de passe"),
              if (!isLogin) ...[
                const SizedBox(height: 10),
                AuthPasswordField(controller: confirmPasswordController, label: "Confirmez le mot de passe"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: AuthTextField(controller: phoneController, label: "Téléphone (optionnel)", keyboardType: TextInputType.phone)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AuthTextField(
                        controller: birthdateController,
                        label: "Date de naissance (optionnel)",
                        readOnly: true,
                        suffixIcon: IconButton(icon: Icon(Icons.calendar_today, color: textColor), onPressed: () => _selectDate(context)),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              AuthButton(onPressed: _authenticate, text: isLogin ? "Connexion" : "Inscription"),
              const SizedBox(height: 10),
              AuthToggleText(isLogin: isLogin, onPressed: () => setState(() => isLogin = !isLogin))
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(),
    );
  }
}
