import 'package:flutter/material.dart';
import '../COMPONENTS/reusable_login_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: ReusableLoginButton(),
            );
          }
          return const Center(
            child: Text('Notifications Page'),
          );
        },
      ),
    );
  }
}
