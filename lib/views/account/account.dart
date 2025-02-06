import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Compte'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text('Mon Compte'),
      ),
    );
  }
}
