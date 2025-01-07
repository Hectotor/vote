import 'package:flutter/material.dart';
import 'package:vote_app/main.dart';
import 'home/home_page.dart';
import 'search/search_page.dart';
import 'add/add_page.dart';
import 'notification/notifications_page.dart';
import 'users/user_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    SearchPage(),
    AddPage(),
    NotificationsPage(),
    UserPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: _selectedIndex == 2
            ? null // Hide the navigation bar when on AddPage
            : Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey,
                      width: 0.2,
                    ),
                  ),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashFactory: NoSplash.splashFactory,
                    highlightColor: Colors.transparent,
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        activeIcon: Icon(Icons.home),
                        label: 'Accueil',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search_outlined),
                        activeIcon: Icon(Icons.search),
                        label: 'Recherche',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_circle_outline, size: 40),
                        activeIcon: Icon(Icons.add_circle, size: 40),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.notifications_outlined),
                        activeIcon: Icon(Icons.notifications),
                        label: 'Alertes',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        activeIcon: Icon(Icons.person),
                        label: 'Profil',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: Colors.grey,
                    onTap: _onItemTapped,
                    type: BottomNavigationBarType.fixed,
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                  ),
                ),
              ),
      ),
    );
  }
}
