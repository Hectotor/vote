import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/main.dart';
import 'home/home_page.dart';
import 'search/search_page.dart';
import 'add/add_page.dart';
import 'notification/notifications_page.dart';
import 'users/user_page.dart';
import 'INSCRIPTION/connexion_screen.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;
  List<Widget> _pages = [];

  void _onItemTapped(int index) {
    // Vérifier la connexion avant d'ouvrir la page d'ajout ou la page utilisateur
    if (index == 2 || index == 4) { // Index de la page AddPage (2) et UserPage (4)
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ConnexionPage()),
        );
        return;
      }
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const SearchPage(),
      const AddPage(),
      const NotificationsPage(),
      const UserPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
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
        size: 30,
      ),
      label: label,
    );
  }

  BottomNavigationBarItem _buildAddButton() {
    return BottomNavigationBarItem(
      icon: Icon(
        Icons.add,
        size: 38, // Taille augmentée
        color: Colors.grey[600],
      ),
      label: '',
    );
  }
}
