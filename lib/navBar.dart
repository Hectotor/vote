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
            : BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedFontSize: 0,
                unselectedFontSize: 0,
                items: <BottomNavigationBarItem>[
                  _buildNavItem(
                    Icons.home_outlined,
                    Icons.home,
                    '',
                    0,
                  ),
                  _buildNavItem(
                    Icons.search_outlined,
                    Icons.search,
                    '',
                    1,
                  ),
                  _buildAddButton(),
                  _buildNavItem(
                    Icons.notifications_outlined,
                    Icons.notifications,
                    '',
                    3,
                  ),
                  _buildNavItem(
                    Icons.person_outline,
                    Icons.person,
                    '',
                    4,
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.grey[600],
                onTap: _onItemTapped,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: false,
                showUnselectedLabels: false,
              ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(
        _selectedIndex == index ? selectedIcon : unselectedIcon,
        size: 30, // Taille augmentée
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _buildAddButton() {
    return BottomNavigationBarItem(
      icon: Icon(
        Icons.add_circle,
        size: 38, // Taille augmentée
        color: Colors.grey[400],
      ),
      label: '',
    );
  }
}
