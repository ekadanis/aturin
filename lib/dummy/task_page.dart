import 'package:flutter/material.dart';
import 'package:aturin/core/widgets/bottom_navbar.dart';

class TaskPage extends StatelessWidget{
  const TaskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Page'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Task Page!',
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