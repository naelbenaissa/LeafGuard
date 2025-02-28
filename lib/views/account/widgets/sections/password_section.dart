import 'package:flutter/material.dart';
import '../../../../services/user_service.dart';

class ChangePasswordSection extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const ChangePasswordSection({super.key, required this.isExpanded, required this.onTap});

  @override
  _ChangePasswordSectionState createState() => _ChangePasswordSectionState();
}

class _ChangePasswordSectionState extends State<ChangePasswordSection> {
  final UserService userService = UserService();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> changePassword() async {
    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty || oldPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tous les champs sont obligatoires.")),
      );
      return;
    }

    if (newPassword == oldPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nouveau mot de passe doit être différent de l'ancien.")),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les nouveaux mots de passe ne correspondent pas.")),
      );
      return;
    }

    try {
      bool isOldPasswordValid = await userService.verifyOldPassword(oldPassword);
      if (!isOldPasswordValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("L'ancien mot de passe est incorrect.")),
        );
        return;
      }

      await userService.changePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mot de passe mis à jour avec succès !")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $error")),
      );
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isPasswordVisible,
    required Function(bool) onVisibilityChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: GestureDetector(
          onLongPress: () => onVisibilityChanged(true),
          onLongPressUp: () => onVisibilityChanged(false),
          child: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            Icons.lock,
            color: widget.isExpanded
                ? Colors.green
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          title: const Text("Changer le mot de passe"),
          onTap: widget.onTap,
        ),
        if (widget.isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildPasswordField(
                  controller: oldPasswordController,
                  label: "Ancien mot de passe",
                  isPasswordVisible: _isOldPasswordVisible,
                  onVisibilityChanged: (visible) {
                    setState(() {
                      _isOldPasswordVisible = visible;
                    });
                  },
                ),
                _buildPasswordField(
                  controller: newPasswordController,
                  label: "Nouveau mot de passe",
                  isPasswordVisible: _isNewPasswordVisible,
                  onVisibilityChanged: (visible) {
                    setState(() {
                      _isNewPasswordVisible = visible;
                    });
                  },
                ),
                _buildPasswordField(
                  controller: confirmPasswordController,
                  label: "Confirmer le mot de passe",
                  isPasswordVisible: _isConfirmPasswordVisible,
                  onVisibilityChanged: (visible) {
                    setState(() {
                      _isConfirmPasswordVisible = visible;
                    });
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: changePassword,
                  child: const Text("Modifier"),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
