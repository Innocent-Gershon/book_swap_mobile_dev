import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap/core/providers/app_providers.dart';
import 'package:book_swap/data/models/book_model.dart';
import 'package:book_swap/data/services/firebase_service.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_styles.dart';

class BrowseListingsPage extends ConsumerWidget {
  const BrowseListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksStreamProvider);
    final currentUser = FirebaseService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Books'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: booksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(booksStreamProvider);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return ListView.builder(
                  padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return _BookCard(
                      book: book,
                      isOwner: book.ownerId == currentUser?.uid,
                      onSwapTap: () => _initiateSwap(context, ref, book),
                      onChatTap: () => _navigateToChat(context, book),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: AppStyles.headline3,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppStyles.bodyText2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(booksStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/post-book'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textDark,
        icon: const Icon(Icons.add),
        label: const Text('Post Book'),
      ),
    );
  }

  Future<void> _navigateToChat(BuildContext context, BookModel book) async {
    final currentUser = FirebaseService.currentUser;
    if (currentUser == null) return;

    try {
      // Check if chat already exists
      final existingChat = await FirebaseService.findExistingChat(
        currentUser.uid, 
        book.ownerId, 
        book.id
      );

      String chatId;
      if (existingChat != null) {
        chatId = existingChat.id;
      } else {
        // Create new chat
        chatId = await FirebaseService.createChat(
          [currentUser.uid, book.ownerId],
          book.id,
        );
      }

      if (context.mounted) {
        context.push('/chat/$chatId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open chat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _initiateSwap(BuildContext context, WidgetRef ref, BookModel book) async {
    final currentUser = FirebaseService.currentUser;
    if (currentUser == null) return;

    try {
      await FirebaseService.initiateSwap(book.id, currentUser.uid);
      
      // Check if chat already exists or create new one
      final existingChat = await FirebaseService.findExistingChat(
        currentUser.uid, 
        book.ownerId, 
        book.id
      );

      String chatId;
      if (existingChat != null) {
        chatId = existingChat.id;
      } else {
        chatId = await FirebaseService.createChat(
          [currentUser.uid, book.ownerId],
          book.id,
        );
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap request sent! Chat created.'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Navigate to chat
        context.push('/chat/$chatId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send swap request: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _BookCard extends StatelessWidget {
  final BookModel book;
  final bool isOwner;
  final VoidCallback? onSwapTap;
  final VoidCallback? onChatTap;

  const _BookCard({
    required this.book,
    required this.isOwner,
    this.onSwapTap,
    this.onChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Container(
              width: 80,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.border,
                image: book.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(book.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: book.imageUrl == null
                  ? const Icon(
                      Icons.book,
                      size: 40,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Book Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppStyles.cardTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${book.author}',
                    style: AppStyles.cardSubtitle,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ConditionChip(condition: book.condition),
                      const Spacer(),
                      _StatusChip(status: book.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Owner: ${book.ownerEmail}',
                    style: AppStyles.bodyTextSmall.copyWith(
                      color: AppColors.textDark.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Action Buttons
                  Row(
                    children: [
                      if (!isOwner && book.status == SwapStatus.available) ...[
                        ElevatedButton.icon(
                          onPressed: onSwapTap,
                          icon: const Icon(Icons.swap_horiz, size: 18),
                          label: const Text('Swap'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textLight,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      TextButton.icon(
                        onPressed: onChatTap,
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Chat'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  final BookCondition condition;

  const _ConditionChip({required this.condition});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (condition) {
      case BookCondition.newBook:
        color = AppColors.success;
        text = 'New';
        break;
      case BookCondition.likeNew:
        color = Colors.blue;
        text = 'Like New';
        break;
      case BookCondition.good:
        color = AppColors.warning;
        text = 'Good';
        break;
      case BookCondition.used:
        color = Colors.grey;
        text = 'Used';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: AppStyles.bodyTextSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final SwapStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case SwapStatus.available:
        color = AppColors.success;
        text = 'Available';
        icon = Icons.check_circle_outline;
        break;
      case SwapStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case SwapStatus.swapped:
        color = Colors.grey;
        text = 'Swapped';
        icon = Icons.done_all;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppStyles.bodyTextSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
            Icons.book_outlined,
            size: 80,
            color: AppColors.textDark.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No books available yet',
            style: AppStyles.headline3.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to post a book for swapping!',
            style: AppStyles.bodyText1.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/post-book'),
            icon: const Icon(Icons.add),
            label: const Text('Post Your First Book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
