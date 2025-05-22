import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../COMPONENTS/avatar.dart';
import '../USERS/user_page.dart';
import '../POSTS/post_detail_page.dart';
import 'notification_model.dart';
import 'notification_service.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Marquer la notification comme lue lorsqu'elle est affichée
    if (!notification.isRead) {
      NotificationService.markAsRead(notification.id);
    }

    return InkWell(
      onTap: () {
        // Naviguer vers le contenu concerné en fonction du type de notification
        _navigateToContent(context);
        
        // Appeler le callback si fourni
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar de l'utilisateur qui a déclenché la notification
            Avatar(userId: notification.sourceUserId, radius: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contenu de la notification
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: notification.sourceUserName ?? 'Un utilisateur',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${notification.message}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date de la notification
                  Text(
                    timeago.format(notification.timestamp.toDate(), locale: 'fr'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Icône en fonction du type de notification
            _getNotificationIcon(),
          ],
        ),
      ),
    );
  }

  // Obtenir l'icône en fonction du type de notification
  Widget _getNotificationIcon() {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'like':
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        iconData = Icons.comment;
        iconColor = Colors.blue;
        break;
      case 'follow':
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case 'mention':
        iconData = Icons.alternate_email;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.orange;
    }

    return Icon(iconData, color: iconColor, size: 20);
  }

  // Naviguer vers le contenu concerné
  void _navigateToContent(BuildContext context) {
    switch (notification.type) {
      case 'like':
      case 'comment':
        if (notification.postId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(postId: notification.postId!),
            ),
          );
        }
        break;
      case 'follow':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserPage(userId: notification.sourceUserId),
          ),
        );
        break;
      case 'mention':
        if (notification.postId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(postId: notification.postId!),
            ),
          );
        }
        break;
      default:
        // Ne rien faire pour les autres types
        break;
    }
  }
}
