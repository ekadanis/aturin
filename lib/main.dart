import 'package:flutter/material.dart';

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
      home: HomePage(),
      routes: {
        '/homepage': (context) => HomePage(),
        '/taskpage': (context) => TaskPage(),
        '/profilepage': (context) => ProfilePage(),
      },
    );
  }
}
