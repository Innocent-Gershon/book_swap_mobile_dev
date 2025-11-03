import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap/core/providers/app_providers.dart';
import 'package:book_swap/data/models/chat_model.dart';
import 'package:book_swap/data/services/firebase_service.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_styles.dart';

class ChatsListPage extends ConsumerWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseService.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view chats')),
      );
    }

    final chatsAsync = ref.watch(userChatsStreamProvider(currentUser.uid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userChatsStreamProvider(currentUser.uid));
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView.builder(
                  padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final otherUserId = chat.participants
                        .firstWhere((id) => id != currentUser.uid);
                    
                    return _ChatTile(
                      chat: chat,
                      currentUserId: currentUser.uid,
                      otherUserId: otherUserId,
                      onTap: () => context.push('/chats/chat-detail/${chat.id}/$otherUserId'),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.refresh,
                  size: 64,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text('Unable to load chats', style: AppStyles.headline3),
                const SizedBox(height: 8),
                Text('Please check your connection and try again', 
                     style: AppStyles.bodyText2,
                     textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(userChatsStreamProvider(currentUser.uid)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textLight,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;
  final String currentUserId;
  final String otherUserId;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.currentUserId,
    required this.otherUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.person,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          otherUserId, // In a real app, you'd fetch the user's name
          style: AppStyles.cardTitle,
        ),
        subtitle: chat.lastMessage != null
            ? Text(
                chat.lastMessage!,
                style: AppStyles.bodyText2.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                'No messages yet',
                style: AppStyles.bodyText2.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chat.lastMessageTime != null)
              Text(
                _formatTime(chat.lastMessageTime!),
                style: AppStyles.bodyTextSmall.copyWith(
                  color: AppColors.textDark.withValues(alpha: 0.5),
                ),
              ),
            const SizedBox(height: 4),
            Icon(
              Icons.chevron_right,
              color: AppColors.textDark.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.textDark.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No chats yet',
            style: AppStyles.headline3.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by requesting a book swap!',
            style: AppStyles.bodyText1.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/browse'),
            icon: const Icon(Icons.book),
            label: const Text('Browse Books'),
          ),
        ],
      ),
    );
  }
}
