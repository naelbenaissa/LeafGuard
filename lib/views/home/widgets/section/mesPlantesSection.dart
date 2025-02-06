import 'package:flutter/material.dart';

Widget mesPlantesSection() {
  return const Align(
    alignment: Alignment.topCenter,
    child: Padding(
      padding: EdgeInsets.only(top: 16.0),
      child: Text(
        "Mes plantes",
        style: TextStyle(fontSize: 18),
      ),
    ),
  );
}
