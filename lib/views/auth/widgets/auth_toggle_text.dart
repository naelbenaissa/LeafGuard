import 'package:flutter/material.dart';

class AuthToggleText extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onPressed;

  const AuthToggleText({
    super.key,
    required this.isLogin,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Text(
          isLogin
              ? "Vous n'avez pas de compte ? Inscrivez-vous"
              : "Vous avez déjà un compte ? Connectez-vous",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
