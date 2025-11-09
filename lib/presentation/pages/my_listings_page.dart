import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../services/auth_service.dart';
import '../widgets/book/enhanced_book_card.dart';

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
                child: const Icon(Icons.person_outline, size: 48, color: Color(0xFF1A1B3A)),
              ),
              const SizedBox(height: 16),
              const Text('Please Sign In', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A1B3A))),
              const SizedBox(height: 8),
              Text('Sign in to view your book collection', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1B3A),
                const Color(0xFF2D1B69),
                const Color(0xFF1E213D),
                Colors.white,
              ],
              stops: const [0.0, 0.3, 0.5, 0.8],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accent, AppColors.accentLight],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.library_books, color: Color(0xFF1A1B3A), size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Collection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('Manage your books', style: TextStyle(fontSize: 13, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                    tabs: const [
                      Tab(height: 44, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.library_books_rounded, size: 16), SizedBox(width: 6), Flexible(child: Text('My Books', overflow: TextOverflow.ellipsis))])),
                      Tab(height: 44, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.inbox_rounded, size: 16), SizedBox(width: 6), Flexible(child: Text('Requests', overflow: TextOverflow.ellipsis))])),
                      Tab(height: 44, child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.local_offer_rounded, size: 16), SizedBox(width: 6), Flexible(child: Text('My Offers', overflow: TextOverflow.ellipsis))])),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _MyBooksTab(userId: currentUser.uid),
                      _IncomingRequestsTab(userId: currentUser.uid),
                      _MyOffersTab(userId: currentUser.uid),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/post-book'),
          backgroundColor: AppColors.accent,
          foregroundColor: const Color(0xFF1A1B3A),
          icon: const Icon(Icons.add),
          label: const Text('Add Book', style: TextStyle(fontWeight: FontWeight.w700)),
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
                    gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.library_books, size: 48, color: Color(0xFF1A1B3A)),
                ),
                const SizedBox(height: 16),
                const Text('No Books Yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A1B3A))),
                const SizedBox(height: 8),
                Text('Add your first book to get started!', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/post-book'),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Book'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        }

        final availableBooks = books.where((b) => b.status == SwapStatus.available).toList();
        final pendingBooks = books.where((b) => b.status == SwapStatus.pending).toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: books.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                      const Color(0xFF312E81),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(books.length.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Total', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)), maxLines: 1),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(availableBooks.length.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Available', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)), maxLines: 1),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
                    Expanded(
                      child: Column(
                        children: [
                          Text(pendingBooks.length.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                          Text('Pending', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)), maxLines: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            final book = books[index - 1];
            return EnhancedBookCard(
              book: book,
              actionButton: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (book.status == SwapStatus.available) ...[ 
                    OutlinedButton.icon(
                      onPressed: () => context.push('/edit-book/${book.id}'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, ref, book),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ] else ...[  
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('PENDING', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning)),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Error loading books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('$error', style: const TextStyle(fontSize: 16, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        content: Text('Are you sure you want to delete "${book.title}"?', style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(bookServiceProvider).deleteBook(book.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book deleted'), backgroundColor: AppColors.success),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                    gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_horiz, size: 48, color: Color(0xFF1A1B3A)),
                ),
                const SizedBox(height: 16),
                const Text('No Offers Yet', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A1B3A))),
                const SizedBox(height: 8),
                Text('Your swap requests will appear here', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, AppColors.accent.withValues(alpha: 0.02)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.accent, AppColors.accentLight]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.swap_horiz, color: Color(0xFF1A1B3A), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FutureBuilder(
                        future: ref.read(bookServiceProvider).getBookById(swap.bookId),
                        builder: (context, bookSnapshot) {
                          final book = bookSnapshot.data;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book?.title ?? 'Loading...',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1B3A),
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                book != null ? 'by ${book.author}' : 'Fetching book details...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: _getSwapStatusGradient(swap.status)),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getSwapStatusGradient(swap.status)[0].withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  swap.status.label.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    if (swap.status.label == 'accepted')
                      ElevatedButton(
                        onPressed: () => _openChat(context, ref, swap.ownerUserId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Chat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Error loading offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('$error', style: const TextStyle(fontSize: 16, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref, String otherUserId) async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) return;
      
      final chatId = await ref.read(chatServiceProvider).createOrGetChat(currentUser.uid, otherUserId);
      if (context.mounted) {
        context.push('/chat/$chatId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open chat: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Color> _getSwapStatusGradient(dynamic status) {
    final statusLabel = status is String ? status : status.label;
    switch (statusLabel) {
      case 'pending':
        return [AppColors.warning, AppColors.warning.withValues(alpha: 0.8)];
      case 'accepted':
        return [AppColors.success, AppColors.success.withValues(alpha: 0.8)];
      case 'rejected':
        return [Colors.red, Colors.red.withValues(alpha: 0.8)];
      default:
        return [AppColors.primary, AppColors.primaryLight];
    }
  }
}

class _IncomingRequestsTab extends ConsumerWidget {
  final String userId;
  const _IncomingRequestsTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(swapRequestsStreamProvider(userId));

    return requestsAsync.when(
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inbox, size: 48, color: Color(0xFF1A1B3A)),
                ),
                const SizedBox(height: 16),
                const Text('No Requests', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A1B3A))),
                const SizedBox(height: 8),
                Text('Swap requests for your books will appear here', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final isPending = request.status.label == 'pending';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, AppColors.primary.withValues(alpha: 0.02)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FutureBuilder(
                            future: ref.read(bookServiceProvider).getBookById(request.bookId),
                            builder: (context, bookSnapshot) {
                              final book = bookSnapshot.data;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book?.title ?? 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1B3A),
                                      letterSpacing: 0.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    book != null ? 'by ${book.author}' : 'Fetching book details...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: _getSwapStatusGradient(request.status)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            request.status.label.toUpperCase(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (isPending)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (request.id != null) {
                                      _acceptRequest(context, ref, request.id!);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Accept',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (request.id != null) {
                                      _rejectRequest(context, ref, request.id!);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.cancel, color: Colors.white, size: 18),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Reject',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else if (request.status.label == 'accepted')
                      ElevatedButton.icon(
                        onPressed: () => _openChat(context, ref, request.requesterUserId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.chat_bubble, size: 18),
                        label: const Text('Chat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Error loading requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('$error', style: const TextStyle(fontSize: 16, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptRequest(BuildContext context, WidgetRef ref, String swapId) async {
    try {
      await ref.read(swapServiceProvider).updateSwapStatus(swapId, 'accepted');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Swap request accepted! Chat created.'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectRequest(BuildContext context, WidgetRef ref, String swapId) async {
    try {
      await ref.read(swapServiceProvider).updateSwapStatus(swapId, 'rejected');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Swap request rejected'), backgroundColor: Colors.grey),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref, String otherUserId) async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) return;
      
      final chatId = await ref.read(chatServiceProvider).createOrGetChat(currentUser.uid, otherUserId);
      if (context.mounted) {
        context.push('/chat/$chatId');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open chat: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  List<Color> _getSwapStatusGradient(dynamic status) {
    final statusLabel = status is String ? status : status.label;
    switch (statusLabel) {
      case 'pending':
        return [AppColors.warning, AppColors.warning.withValues(alpha: 0.8)];
      case 'accepted':
        return [AppColors.success, AppColors.success.withValues(alpha: 0.8)];
      case 'rejected':
        return [Colors.red, Colors.red.withValues(alpha: 0.8)];
      default:
        return [AppColors.primary, AppColors.primaryLight];
    }
  }
}
