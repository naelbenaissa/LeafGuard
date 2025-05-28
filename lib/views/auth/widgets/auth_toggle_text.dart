import 'package:flutter/material.dart';

/// Texte interactif permettant de basculer entre les écrans de connexion et d'inscription.
/// Affiche un message contextuel selon l'état actuel (login ou signup),
/// avec un style visuel mis en avant (vert et gras).
class AuthToggleText extends StatelessWidget {
  final bool isLogin; // Indique si l'écran actuel est celui de connexion
  final VoidCallback onPressed; // Callback déclenché au clic sur le texte

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
