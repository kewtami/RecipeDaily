import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final Map<String, bool> _followStatus = {
    'user1': false,
    'user2': true,
    'user3': false,
  };

  final List<NotificationItem> _todayNotifications = [
    NotificationItem(
      id: '1',
      userId: 'user1',
      userName: 'Combucha',
      avatarUrl: '',
      action: 'now following you',
      time: '5 mins',
      type: NotificationType.follow,
    ),
    NotificationItem(
      id: '2',
      userId: 'user2',
      userName: 'Zayn',
      secondUserName: 'Combucha',
      avatarUrl: '',
      action: 'liked your recipe',
      time: '20 mins',
      type: NotificationType.like,
      recipeImageUrl: '',
    ),
  ];

  final List<NotificationItem> _yesterdayNotifications = [
    NotificationItem(
      id: '3',
      userId: 'user3',
      userName: 'Zayn',
      avatarUrl: '',
      action: 'have followed you',
      time: '1 day 1h',
      type: NotificationType.follow,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ),
      body: _buildNotificationsList(),
    );
  }

  Widget _buildNotificationsList() {
    if (_todayNotifications.isEmpty && _yesterdayNotifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll see notifications here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (_todayNotifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionHeader('Today'),
          ..._todayNotifications.map((notification) {
            return _buildNotificationItem(notification);
          }).toList(),
        ],
        
        if (_yesterdayNotifications.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildSectionHeader('Yesterday'),
          ..._yesterdayNotifications.map((notification) {
            return _buildNotificationItem(notification);
          }).toList(),
        ],
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    final isFollowed = _followStatus[notification.userId] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[300],
            backgroundImage: notification.avatarUrl.isNotEmpty
                ? NetworkImage(notification.avatarUrl)
                : null,
            child: notification.avatarUrl.isEmpty
                ? Text(
                    notification.userName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  )
                : null,
          ),
          
          const SizedBox(width: 12),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationText(notification),
                const SizedBox(height: 2),
                Text(
                  notification.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Action button or recipe image
          if (notification.type == NotificationType.follow)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _followStatus[notification.userId] = !isFollowed;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowed ? Colors.grey[300] : const Color(0xFFFF6B35),
                foregroundColor: isFollowed ? Colors.grey[700] : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                isFollowed ? 'Followed' : 'Follow',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (notification.type == NotificationType.like && 
                   notification.recipeImageUrl != null)
            GestureDetector(
              onTap: () {
                // Navigate to recipe detail
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: notification.recipeImageUrl!.isNotEmpty
                    ? Image.network(
                        notification.recipeImageUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 56,
                            height: 56,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 24),
                          );
                        },
                      )
                    : Container(
                        width: 56,
                        height: 56,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 24),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationText(NotificationItem notification) {
    if (notification.secondUserName != null) {
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
          children: [
            TextSpan(
              text: notification.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: notification.secondUserName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextSpan(text: ' ${notification.action}'),
          ],
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
          children: [
            TextSpan(
              text: notification.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            TextSpan(text: ' ${notification.action}'),
          ],
        ),
      );
    }
  }
}

// Models
enum NotificationType {
  follow,
  like,
  comment,
}

class NotificationItem {
  final String id;
  final String userId;
  final String userName;
  final String? secondUserName;
  final String avatarUrl;
  final String action;
  final String time;
  final NotificationType type;
  final String? recipeImageUrl;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.userName,
    this.secondUserName,
    required this.avatarUrl,
    required this.action,
    required this.time,
    required this.type,
    this.recipeImageUrl,
  });
}