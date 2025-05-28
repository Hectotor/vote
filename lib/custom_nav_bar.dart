import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toplyke/ADD/add_page.dart';
import 'package:toplyke/INSCRIPTION/connexion_screen.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ne pas afficher la barre si on est sur la page d'ajout (index 2)
    if (currentIndex == 2) return const SizedBox.shrink();
    
    return Container(
      height: 70,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconButton(Icons.home_outlined, Icons.home, 0),
          _buildIconButton(Icons.search_outlined, Icons.search, 1),
          _buildAddButton(context),
          _buildIconButton(Icons.notifications_outlined, Icons.notifications, 3),
          _buildIconButton(Icons.person_outline, Icons.person, 4),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData unselected, IconData selected, int index) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Icon(
        isSelected ? selected : unselected,
        size: 28,
        color: const Color(0xFF212121),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Vérifier si l'utilisateur est connecté
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConnexionPage()),
          );
          return;
        }
        
        // Naviguer vers la page d'ajout
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddPage()),
        );
      },
      child: const SizedBox(
        width: 50,
        height: 50,
        child: Icon(
          Icons.add_box_outlined,
          size: 30,
          color: Color(0xFF212121),
        ),
      ),
    );
  }
}
