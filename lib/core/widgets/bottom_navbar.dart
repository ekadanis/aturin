import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int currentPageIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentPage = ModalRoute.of(context)?.settings.name;
    if (currentPage == '/homepage') {
      currentPageIndex = 0;
    } else if (currentPage == '/taskpage') {
      currentPageIndex = 1;
    } else if (currentPage == '/profilepage') {
      currentPageIndex = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        elevation: 10,
        labelPadding: const EdgeInsets.only(top: 0),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        indicatorColor: const Color.fromARGB(0, 255, 255, 255),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontStyle: FontStyle.normal,
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 82, 99, 243),
            );
          }
          return const TextStyle(
              fontStyle: FontStyle.normal,
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 198, 214, 255), 
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: Color.fromARGB(255, 82, 99, 243),
            );
          }
          return const IconThemeData(
            color: Color.fromARGB(255, 198, 214, 255), 
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (currentPageIndex) => 
          setState(() {
            this.currentPageIndex = currentPageIndex;
            if (currentPageIndex == 0) {
              Navigator.pushReplacementNamed(context, '/homepage');
            } else if (currentPageIndex == 1) {
              Navigator.pushReplacementNamed(context, '/taskpage');
            } else if (currentPageIndex == 2) {
              Navigator.pushReplacementNamed(context, '/profilepage');
            }
          }),
        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/home-simple.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 198, 214, 255),
                BlendMode.srcIn
              )
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/home-simple.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 82, 99, 243),
                BlendMode.srcIn
                )
              ),
            label: 'Beranda'
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/task-list.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 198, 214, 255),
                BlendMode.srcIn
                )
              ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/task-list.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 82, 99, 243),
                BlendMode.srcIn
                )
              ),
            label: 'Tugas'
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/profile-circle.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 198, 214, 255),
                BlendMode.srcIn
                )
              ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/profile-circle.svg',
              height: 24,
              width: 24,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 82, 99, 243), 
                BlendMode.srcIn
                )
              ),
            label: 'Profil'
          ),
        ],
      ),
    );
  }
}