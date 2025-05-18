import 'package:flutter/material.dart';
import 'navBar.dart';

class PageWrapper extends StatelessWidget {
  final Widget child;
  final bool showNavBar;
  final int currentIndex;
  final Widget? bottomWidget; // Pour des widgets supplémentaires comme CommentInput

  const PageWrapper({
    Key? key,
    required this.child,
    this.showNavBar = true,
    this.currentIndex = 0,
    this.bottomWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showNavBar) {
      return child;
    }

    if (child is Scaffold) {
      final scaffold = child as Scaffold;
      return Scaffold(
        appBar: scaffold.appBar,
        body: scaffold.body,
        floatingActionButton: scaffold.floatingActionButton,
        backgroundColor: scaffold.backgroundColor,
        drawer: scaffold.drawer,
        endDrawer: scaffold.endDrawer,
        bottomNavigationBar: bottomWidget != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  bottomWidget!,
                  _buildNavBar(context),
                ],
              )
            : _buildNavBar(context),
      );
    }

    // Si child n'est pas un Scaffold, on l'enveloppe dans un Scaffold
    return Scaffold(
      body: child,
      bottomNavigationBar: bottomWidget != null
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                bottomWidget!,
                _buildNavBar(context),
              ],
            )
          : _buildNavBar(context),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[800]!, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 0 ? Icons.home : Icons.home_outlined,
              size: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 1 ? Icons.search : Icons.search_outlined,
              size: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              size: 38,
              color: Colors.grey[600],
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 3 ? Icons.notifications : Icons.notifications_outlined,
              size: 30,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              currentIndex == 4 ? Icons.person : Icons.person_outline,
              size: 30,
            ),
            label: '',
          ),
        ],
        currentIndex: currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          if (index != currentIndex) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => NavBar(initialIndex: index),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
