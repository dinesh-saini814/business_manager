// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:bill_maker/screens/Home.dart';
import 'package:bill_maker/screens/info.dart';
import 'package:bill_maker/screens/user.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    const InfoPage(),
    const UserInfo(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        child: _pages[_selectedIndex],
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: GNav(
          gap: 8,
          backgroundColor: Colors.transparent,
          activeColor: Colors.black,
          color: Colors.grey.shade700,
          duration: const Duration(milliseconds: 800),
          tabBackgroundColor: Colors.grey.shade200,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          tabs: const [
            GButton(icon: Icons.home, text: 'Home'),
            GButton(icon: Icons.history_edu, text: 'History'),
            GButton(icon: Icons.person, text: 'Profile'),
          ],
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
        ),
      ),
    );
  }
}
