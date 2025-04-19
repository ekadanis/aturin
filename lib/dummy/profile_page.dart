import 'package:flutter/material.dart';
import 'package:aturin/core/widgets/bottom_navbar.dart';

class ProfilePage extends StatelessWidget{
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Page'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the User Page!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(),
    );
  }
}