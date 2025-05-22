import 'package:flutter/material.dart';
import '../models/reusable_login_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_model.dart';
import 'notification_service.dart';
import 'notification_item.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<void> _refreshNotifications() async {
    // Attendre un court instant pour simuler le rafraîchissement
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton pour créer une notification d'exemple
                TextButton.icon(
                  icon: const Icon(Icons.add_alert),
                  label: const Text('Exemple'),
                  onPressed: () async {
                    await NotificationService.createExampleNotification();
                  },
                ),
                // Bouton pour marquer toutes les notifications comme lues
                StreamBuilder<int>(
                  stream: NotificationService.getUnreadCount(),
                  builder: (context, snapshot) {
                    final hasUnread = snapshot.hasData && snapshot.data! > 0;
                    return hasUnread
                        ? IconButton(
                            icon: const Icon(Icons.done_all),
                            onPressed: () async {
                              await NotificationService.markAllAsRead();
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: ReusableLoginButton(),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: _refreshNotifications,
                  child: StreamBuilder<List<NotificationModel>>(
                    stream: NotificationService.getNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune notification',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final notifications = snapshot.data!;
                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Dismissible(
                            key: Key(notification.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              NotificationService.deleteNotification(notification.id);
                            },
                            child: NotificationItem(
                              notification: notification,
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
