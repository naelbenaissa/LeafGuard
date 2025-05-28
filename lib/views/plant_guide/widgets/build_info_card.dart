import 'package:flutter/material.dart';

/// Widget pour afficher une carte d'information stylisée.
///
/// Affiche une icône, un titre et une valeur avec des couleurs personnalisables
/// pour s'adapter au mode clair ou sombre.
///
/// - [icon] : icône affichée à gauche.
/// - [title] : texte du titre en gras.
/// - [value] : texte de la valeur alignée à droite.
/// - [textColor] : couleur du texte.
/// - [cardColor] : couleur de fond de la carte.
///
/// La carte est stylisée avec un fond arrondi et une ombre légère.
Widget buildInfoCard(IconData icon, String title, String value, Color textColor, Color cardColor) {
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(icon, size: 30, color: Colors.green),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: TextStyle(fontSize: 18, color: textColor.withOpacity(0.8)),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}
