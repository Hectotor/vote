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
  late List<Widget> _pages;

  void _onItemTapped(int index) {
    if (index == 2) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const ConnexionPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        return;
      }
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AddPage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pages = const [
      HomePage(),
      SearchPage(),
      AddPage(),
      NotificationsPage(),
      UserPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _pages.map((page) {
                return SafeArea(
                  bottom: false,
                  child: page,
                );
              }).toList(),
            ),
            if (_selectedIndex != 2)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildIconButton(Icons.home_outlined, Icons.home, 0),
                        _buildIconButton(Icons.search_outlined, Icons.search, 1),
                        _buildAddButtonCustom(),
                        _buildIconButton(Icons.notifications_outlined, Icons.notifications, 3),
                        _buildIconButton(Icons.person_outline, Icons.person, 4),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData unselected, IconData selected, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        isSelected ? selected : unselected,
        size: 28,
        color: isSelected ? const Color(0xFF212121) : const Color(0xFF212121),
      ),
    );
  }

  Widget _buildAddButtonCustom() {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: SizedBox(
        width: 50,
        height: 50,
        child: const Icon(
          Icons.add_box_outlined,
          size: 30,
          color: Color(0xFF212121),
        ),
      ),
    );
  }
}
