import 'package:flutter/material.dart';
import 'package:aturin/dummy/home_page.dart';
import 'package:aturin/dummy/task_page.dart';
import 'package:aturin/dummy/profile_page.dart';

void main() {
  runApp(const Aturin());
}

class Aturin extends StatelessWidget {
  const Aturin({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aturin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/homepage': (context) => const HomePage(),
        '/taskpage': (context) => const TaskPage(),
        '/profilepage': (context) => const ProfilePage(),
      },
    );
  }
}
