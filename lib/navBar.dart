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
  final int initialIndex;
  
  const NavBar({super.key, this.initialIndex = 0});

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late int _selectedIndex;
  List<Widget> _pages = [];

  void _onItemTapped(int index) {
    // Si on clique sur le bouton d'ajout
    if (index == 2) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const ConnexionPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        return;
      }
      // Naviguer vers AddPage sans transition
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const AddPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
      return;
    }
    
    // Pour les autres onglets
    if (index == 4) { // Page utilisateur
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const ConnexionPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
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
    _selectedIndex = widget.initialIndex;
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
