import 'package:flutter/material.dart';
import 'package:aturin/core/widgets/bottom_navbar.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: const  Center(
        child: Text(
          'Welcome to the Home Page!',
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