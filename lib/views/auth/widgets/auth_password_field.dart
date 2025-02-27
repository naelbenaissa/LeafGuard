import 'package:flutter/material.dart';

class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  _AuthPasswordFieldState createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: GestureDetector(
          onLongPress: () {
            setState(() {
              _isPasswordVisible = true;
            });
          },
          onLongPressUp: () {
            setState(() {
              _isPasswordVisible = false;
            });
          },
          child: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
        ),
      ),
    );
  }
}
