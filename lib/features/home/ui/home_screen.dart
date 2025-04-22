import 'package:flutter/material.dart';
import 'package:relax_fik/features/alarm/ui/alarm_screen.dart';
import 'package:relax_fik/features/journal/ui/journal_screen.dart';
import 'package:relax_fik/features/meditation/ui/meditation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const MeditationScreen(),
    const JournalScreen(),
    const AlarmScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 71,
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.self_improvement),
              label: 'Ruang Tenang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Ruang Catatan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alarm),
              label: 'Ruang Alarm',
            ),
          ],
        ),
      ),
    );
  }
}