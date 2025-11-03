import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap/core/providers/app_providers.dart';
import 'package:book_swap/data/models/book_model.dart';
import 'package:book_swap/data/services/firebase_service.dart';
import 'package:book_swap/presentation/pages/post_book_page.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_styles.dart';

class MyListingsPage extends ConsumerWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseService.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your listings')),
      );
    }

    final userBooksAsync = ref.watch(userBooksStreamProvider(currentUser.uid));

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('My Listings'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            elevation: 0,
          ),
          body: userBooksAsync.when(
            data: (books) {
              if (books.isEmpty) {
                return const _EmptyState();
              }

              final availableBooks = books.where((b) => b.status == SwapStatus.available).toList();
              final pendingBooks = books.where((b) => b.status == SwapStatus.pending).toList();
              final swappedBooks = books.where((b) => b.status == SwapStatus.swapped).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userBooksStreamProvider(currentUser.uid));
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
                      child: Column(
                        children: [
                          if (pendingBooks.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'Pending Swaps',
                              count: pendingBooks.length,
                              icon: Icons.hourglass_empty,
                              color: AppColors.warning,
                            ),
                            ...pendingBooks.map((book) => _MyBookCard(
                              book: book,
                              onEdit: () => _editBook(context, book),
                              onDelete: () => _deleteBook(context, ref, book),
                            )),
                            const SizedBox(height: 24),
                          ],
                          
                          if (availableBooks.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'Available Books',
                              count: availableBooks.length,
                              icon: Icons.book,
                              color: AppColors.success,
                            ),
                            ...availableBooks.map((book) => _MyBookCard(
                              book: book,
                              onEdit: () => _editBook(context, book),
                              onDelete: () => _deleteBook(context, ref, book),
                            )),
                            const SizedBox(height: 24),
                          ],

                          if (swappedBooks.isNotEmpty) ...[
                            _SectionHeader(
                              title: 'Completed Swaps',
                              count: swappedBooks.length,
                              icon: Icons.done_all,
                              color: Colors.grey,
                            ),
                            ...swappedBooks.map((book) => _MyBookCard(
                              book: book,
                              onEdit: null, // Can't edit swapped books
                              onDelete: () => _deleteBook(context, ref, book),
                            )),
                          ],
                          const SizedBox(height: 100), // Bottom padding
                        ],
                      ),
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
                    Text('Unable to load your books', style: AppStyles.headline3),
                    const SizedBox(height: 8),
                    Text('Please check your connection and try again', 
                         style: AppStyles.bodyText2,
                         textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(userBooksStreamProvider(currentUser.uid)),
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/post-book'),
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textDark,
            icon: const Icon(Icons.add),
            label: const Text('Add Book'),
          ),
        );
  }

  void _editBook(BuildContext context, BookModel book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PostBookPage(bookToEdit: book),
      ),
    );
  }

  Future<void> _deleteBook(BuildContext context, WidgetRef ref, BookModel book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseService.deleteBook(book.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete book: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppStyles.bodyText1.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: AppStyles.bodyTextSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyBookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MyBookCard({
    required this.book,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Book Cover
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.border,
                image: book.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(book.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: book.imageUrl == null
                  ? const Icon(Icons.book, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 16),
            
            // Book Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppStyles.cardTitle,
                    maxLines: 1,
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
                      const SizedBox(width: 8),
                      _StatusChip(status: book.status),
                    ],
                  ),
                  if (book.status == SwapStatus.pending && book.swapRequesterId != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Swap requested',
                      style: AppStyles.bodyTextSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Actions
            Column(
              children: [
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    color: AppColors.primary,
                    tooltip: 'Edit',
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    tooltip: 'Delete',
                  ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
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

    switch (status) {
      case SwapStatus.available:
        color = AppColors.success;
        text = 'Available';
        break;
      case SwapStatus.pending:
        color = AppColors.warning;
        text = 'Pending';
        break;
      case SwapStatus.swapped:
        color = Colors.grey;
        text = 'Swapped';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: AppColors.textDark.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No books posted yet',
            style: AppStyles.headline3.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by posting your first book!',
            style: AppStyles.bodyText1.copyWith(
              color: AppColors.textDark.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/post-book'),
            icon: const Icon(Icons.add),
            label: const Text('Post Your First Book'),
          ),
        ],
      ),
    );
  }
}
