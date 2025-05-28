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
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
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
  bool hasPartialInput() => _hasPartialInput();

  Future<bool> confirmLeavePage() => _confirmLeavePage();

  Future<void> _authenticate() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;
      final name = nameController.text.trim();
      final surname = surnameController.text.trim();
      final phone = phoneController.text.trim();
      final birthdate = birthdateController.text.trim();

      // Vérification des champs vides
      if (email.isEmpty || password.isEmpty) {
        _showSnackbar("Veuillez remplir tous les champs obligatoires.");
        return;
      }

      if (!email.contains('@') || !email.contains('.')) {
        _showSnackbar("Veuillez saisir une adresse e-mail valide.");
        return;
      }

      if (!isLogin) {
        // Vérification des champs supplémentaires pour l'inscription
        if (name.isEmpty || surname.isEmpty) {
          _showSnackbar("Le nom et le prénom sont obligatoires.");
          return;
        }

        if (confirmPassword.isEmpty) {
          _showSnackbar("Veuillez confirmer votre mot de passe.");
          return;
        }

        if (password != confirmPassword) {
          _showSnackbar("Les mots de passe ne correspondent pas.");
          return;
        }

        if (!_isPasswordValid(password)) {
          _showSnackbar("Le mot de passe doit contenir entre 8 et 15 caractères, avec au moins une majuscule, une minuscule, un chiffre et un caractère spécial.");
          return;
        }

        if (birthdate.isNotEmpty) {
          try {
            final birthDateParsed = DateFormat("dd/MM/yyyy").parse(birthdate);
            if (_calculateAge(birthDateParsed) < 16) {
              _showSnackbar("Vous devez avoir au moins 16 ans pour vous inscrire.");
              return;
            }
          } catch (e) {
            _showSnackbar("Format de date de naissance invalide. Utilisez le format jj/mm/aaaa.");
            return;
          }
        }

        // Création du compte
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null) {
          await userService.addUserData(
            response.user!.id,
            email,
            name,
            surname,
            phone.isNotEmpty ? phone : null,
            birthdate.isNotEmpty ? birthdate : null,
          );
          if (mounted) context.go('/');
        } else {
          _showSnackbar("L'inscription a échoué. Veuillez réessayer.");
        }

      } else {
        try {
          final response = await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );

          if (response.session != null && mounted) {
            context.go('/');
          } else {
            _showSnackbar("Email ou mot de passe incorrect.");
          }
        } on AuthException catch (e) {
          final message = e.message.toLowerCase();

          if (message.contains("invalid login credentials")) {
            _showSnackbar("Email ou mot de passe incorrect.");
          } else if (message.contains("user not found")) {
            _showSnackbar("Utilisateur non trouvé.");
          } else {
            _showSnackbar("Erreur : ${e.message}");
          }
        }


      }
    } catch (e) {
      _showSnackbar("Une erreur est survenue : ${e.toString()}");
    }
  }


  /// Vérifie si le mot de passe respecte les critères de sécurité
  bool _isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~%?^+=.,:;_\-])[A-Za-z\d!@#\$&*~%?^+=.,:;_\-]{8,15}$');
    return regex.hasMatch(password);
  }

  /// Calcule l'âge à partir de la date de naissance
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

  Future<bool> _confirmLeavePage() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Quitter la page ?"),
        content: const Text("Vous avez commencé à remplir le formulaire. Si vous quittez cette page, les informations saisies seront perdues."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Rester"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Quitter"),
          ),
        ],
      ),
    ) ??
        false;
  }

  bool _hasPartialInput() {
    return [
      emailController,
      passwordController,
      confirmPasswordController,
      nameController,
      surnameController,
      phoneController,
      birthdateController,
    ].any((controller) => controller.text.trim().isNotEmpty);
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

    return WillPopScope(
        onWillPop: () async {
      if (_hasPartialInput()) {
        return await _confirmLeavePage();
      }
      return true;
    },
    child: Scaffold(
      backgroundColor: colorScheme.surface,
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
    )
    );
  }
}
