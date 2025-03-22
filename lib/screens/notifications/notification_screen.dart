import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationProvider.notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                if (userId != null) {
                  await notificationProvider.markAllAsRead(userId);
                }
              },
              icon: const Icon(Icons.done_all),
              label: const Text('Mark all as read'),
            ),
        ],
      ),
      body: notificationProvider.notifications.isEmpty
          ? _buildEmptyNotifications()
          : _buildNotificationList(notificationProvider, userId),
    );
  }

  Widget _buildEmptyNotifications() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Notifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any notifications yet',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(NotificationProvider notificationProvider, String? userId) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notificationProvider.notifications.length,
      itemBuilder: (context, index) {
        final notification = notificationProvider.notifications[index];
        return _buildNotificationCard(notification, notificationProvider, userId);
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, NotificationProvider notificationProvider, String? userId) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: Dismissible(
        key: Key(notification.id),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          color: AppTheme.dangerColor,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          if (userId != null) {
            notificationProvider.deleteNotification(notification.id, userId);
          }
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: notification.isRead
                  ? Colors.transparent
                  : AppTheme.primaryColor.withOpacity(0.3),
              width: notification.isRead ? 0 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (!notification.isRead && userId != null) {
                notificationProvider.markAsRead(notification.id, userId);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color:
                          Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(notification.isRead ? 0.7 : 0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDateTime(notification.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateToCheck == today) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday, ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}