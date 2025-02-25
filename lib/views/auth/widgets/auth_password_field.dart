import 'package:flutter/material.dart';

class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isVisible;
  final VoidCallback onToggle;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.isVisible,
    required this.onToggle,
  });

  @override
  _AuthPasswordFieldState createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: !widget.isVisible,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[200],
        suffixIcon: IconButton(
          icon: Icon(widget.isVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: widget.onToggle,
        ),
      ),
    );
  }
}
