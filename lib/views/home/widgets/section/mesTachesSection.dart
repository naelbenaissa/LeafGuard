import 'package:flutter/material.dart';

Widget mesTachesSection() {
  return Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Text(
        "Mes Tâches",
        style: TextStyle(fontSize: 18),
      ),
    ),
  );
}
