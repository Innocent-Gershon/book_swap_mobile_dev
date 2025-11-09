import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../theme/app_colors.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please sign in to view notifications')),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotificationsList(userId: currentUser.uid, showUnreadOnly: false),
          _NotificationsList(userId: currentUser.uid, showUnreadOnly: true),
        ],
      ),
    );
  }
}

class _NotificationsList extends ConsumerWidget {
  final String userId;
  final bool showUnreadOnly;

  const _NotificationsList({required this.userId, required this.showUnreadOnly});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: NotificationService().getNotificationsStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Failed to load notifications', style: TextStyle(fontSize: 16, color: AppColors.textPrimary)),
              ],
            ),
          );
        }

        var notifications = snapshot.data ?? [];
        
        if (showUnreadOnly) {
          notifications = notifications.where((n) => n['isRead'] == false).toList();
        }

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 64,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  showUnreadOnly ? 'No Unread Notifications' : 'No Notifications Yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  showUnreadOnly 
                      ? 'You\'re all caught up!'
                      : 'When you receive swap requests or updates,\nthey\'ll appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return _NotificationCard(
              notification: notification,
              onTap: () => _handleNotificationTap(context, notification),
            );
          },
        );
      },
    );
  }

  void _handleNotificationTap(BuildContext context, Map<String, dynamic> notification) async {
    // Mark as read
    if (notification['isRead'] == false) {
      await NotificationService().markAsRead(notification['id']);
    }

    final type = notification['type'];
    
    if (type == 'swap_request') {
      context.go('/my-listings');
    } else if (type == 'swap_accepted' || type == 'swap_rejected') {
      context.go('/my-listings');
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final type = notification['type'] as String;
    final isRead = notification['isRead'] as bool;
    final timestamp = notification['createdAt'];
    
    IconData icon;
    Color iconColor;
    Color bgColor;
    
    switch (type) {
      case 'swap_request':
        icon = Icons.swap_horiz_rounded;
        iconColor = AppColors.accent;
        bgColor = AppColors.accent.withValues(alpha: 0.1);
        break;
      case 'swap_accepted':
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        bgColor = AppColors.success.withValues(alpha: 0.1);
        break;
      case 'swap_rejected':
        icon = Icons.cancel_rounded;
        iconColor = AppColors.error;
        bgColor = AppColors.error.withValues(alpha: 0.1);
        break;
      case 'swap_request_sent':
        icon = Icons.send_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        break;
      default:
        icon = Icons.notifications_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primary.withValues(alpha: 0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? AppColors.card : AppColors.card.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? AppColors.divider : iconColor.withValues(alpha: 0.3),
          width: isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] ?? 'Notification',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: iconColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'] ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (notification['bookTitle'] != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.book_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  notification['bookTitle'],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final DateTime dateTime = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM d, yyyy').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }
}
