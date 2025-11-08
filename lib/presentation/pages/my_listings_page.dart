import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../data/models/swap_model.dart';
import '../../services/auth_service.dart';

class MyListingsPage extends ConsumerWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = AuthService.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text('Please Sign In', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text('Sign in to view your book collection', style: TextStyle(fontSize: 16, color: AppColors.textDark.withValues(alpha: 0.7))),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('My Books'),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                tabs: [
                  Tab(
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.library_books_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text('My Books'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_offer_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text('My Offers'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _MyBooksTab(userId: currentUser.uid),
            _MyOffersTab(userId: currentUser.uid),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/post-book'),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}

class _MyBooksTab extends ConsumerWidget {
  final String userId;
  
  const _MyBooksTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userBooksAsync = ref.watch(userBooksStreamProvider(userId));

    return userBooksAsync.when(
      data: (books) {
        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.library_books, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text('No Books Yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text('Add your first book to get started!', style: TextStyle(fontSize: 16, color: AppColors.textDark.withValues(alpha: 0.7))),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/post-book'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textLight,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        }

        final availableBooks = books.where((b) => b.status == SwapStatus.available).toList();
        final pendingBooks = books.where((b) => b.status == SwapStatus.pending).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(books.length.toString(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                          Text('Total', style: TextStyle(fontSize: 16, color: AppColors.textLight.withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(availableBooks.length.toString(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                          Text('Available', style: TextStyle(fontSize: 16, color: AppColors.textLight.withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(pendingBooks.length.toString(), style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                          Text('Pending', style: TextStyle(fontSize: 16, color: AppColors.textLight.withValues(alpha: 0.8))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Text('Your Books', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 16),
              
              ...books.map((book) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.menu_book, color: AppColors.primary, size: 28),
                  ),
                  title: Text(book.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(book.author, style: TextStyle(fontSize: 16, color: AppColors.textDark.withValues(alpha: 0.7))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(book.status).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          book.status.name.toUpperCase(),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getStatusColor(book.status)),
                        ),
                      ),
                    ],
                  ),
                  trailing: book.status == SwapStatus.pending 
                      ? _PendingSwapActions(book: book)
                      : PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: AppColors.textDark),
                          onSelected: (value) => _handleMenuAction(context, ref, value, book),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Edit', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(fontSize: 16, color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              )),
            ],
          ),
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('$error', style: TextStyle(fontSize: 16, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action, BookModel book) {
    switch (action) {
      case 'edit':
        context.push('/edit-book/${book.id}');
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, book);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Book', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete "${book.title}"? This action cannot be undone.', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(bookServiceProvider).deleteBook(book.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Book deleted successfully', style: TextStyle(fontSize: 16)),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete book: $e', style: TextStyle(fontSize: 16)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.available:
        return AppColors.success;
      case SwapStatus.pending:
        return AppColors.warning;
      case SwapStatus.swapped:
        return AppColors.primary;
    }
  }
}

class _PendingSwapActions extends ConsumerWidget {
  final BookModel book;
  
  const _PendingSwapActions({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _acceptSwap(context, ref),
          icon: Icon(Icons.check, color: AppColors.success),
          tooltip: 'Accept',
        ),
        IconButton(
          onPressed: () => _rejectSwap(context, ref),
          icon: Icon(Icons.close, color: Colors.red),
          tooltip: 'Reject',
        ),
      ],
    );
  }

  void _acceptSwap(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(swapServiceProvider).updateSwapStatusByBookId(book.id, 'accepted');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swap request accepted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept swap: $e')),
        );
      }
    }
  }

  void _rejectSwap(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(swapServiceProvider).updateSwapStatusByBookId(book.id, 'rejected');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swap request rejected')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject swap: $e')),
        );
      }
    }
  }
}

class _MyOffersTab extends ConsumerWidget {
  final String userId;
  
  const _MyOffersTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swapsAsync = ref.watch(userSwapsStreamProvider(userId));

    return swapsAsync.when(
      data: (swaps) {
        if (swaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.swap_horiz, size: 48, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text('No Offers Yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 8),
                Text('Your swap requests will appear here', style: TextStyle(fontSize: 16, color: AppColors.textDark.withValues(alpha: 0.7))),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.swap_horiz, color: AppColors.primary, size: 28),
                ),
                title: Text('Book Request', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Book ID: ${swap.bookId}', style: TextStyle(fontSize: 16, color: AppColors.textDark.withValues(alpha: 0.7))),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSwapStatusColor(swap.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        swap.status.label.toUpperCase(),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _getSwapStatusColor(swap.status)),
                      ),
                    ),
                  ],
                ),
                trailing: swap.status.label == 'accepted' 
                    ? ElevatedButton(
                        onPressed: () => context.push('/chat/${swap.ownerUserId}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textLight,
                        ),
                        child: const Text('Chat'),
                      )
                    : null,
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('$error', style: TextStyle(fontSize: 16, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Color _getSwapStatusColor(dynamic status) {
    final statusLabel = status is String ? status : status.label;
    switch (statusLabel) {
      case 'pending':
        return AppColors.warning;
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }
}
