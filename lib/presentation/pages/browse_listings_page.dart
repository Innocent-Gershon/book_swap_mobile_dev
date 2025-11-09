import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/book_provider.dart';
import '../providers/swap_provider.dart';
import '../theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../widgets/book/enhanced_book_card.dart';

class BrowseListingsPage extends ConsumerStatefulWidget {
  const BrowseListingsPage({super.key});

  @override
  ConsumerState<BrowseListingsPage> createState() => _BrowseListingsPageState();
}

class _BrowseListingsPageState extends ConsumerState<BrowseListingsPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookModel> _filterBooks(List<BookModel> books) {
    if (_searchQuery.isEmpty) return books;
    
    final query = _searchQuery.toLowerCase();
    return books.where((book) {
      final title = book.title.toLowerCase();
      final author = book.author.toLowerCase();
      final condition = book.condition.toString().split('.').last.toLowerCase();
      
      return title.contains(query) || author.contains(query) || condition.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;
    final booksAsync = ref.watch(booksStreamProvider);

    return Scaffold(
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
                child: _isSearching ? _buildSearchBar() : _buildHeader(),
              ),
              Expanded(child: _buildBooksList(booksAsync, currentUser)),
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
    );
  }

  Widget _buildHeader() {
    final currentUser = AuthService.currentUser;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.accent, AppColors.accentLight],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.auto_stories, color: Color(0xFF1A1B3A), size: 22),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Discover Books', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('Find your next great read', style: TextStyle(fontSize: 13, color: Colors.white70), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (currentUser != null)
          StreamBuilder<int>(
            stream: NotificationService().getUnreadCountStream(currentUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
              }
              final unreadCount = snapshot.data ?? 0;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                    onPressed: () => context.push('/notifications'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white, size: 22),
          onPressed: () => setState(() => _isSearching = true),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search by title, author, or condition...',
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
          suffixIcon: IconButton(
            icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildBooksList(AsyncValue<List<BookModel>> booksAsync, dynamic currentUser) {
    return booksAsync.when(
      data: (books) {
        final filteredBooks = _filterBooks(books);
        
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
                  child: const Icon(Icons.auto_stories, size: 48, color: Color(0xFF1A1B3A)),
                ),
                const SizedBox(height: 16),
                const Text('No Books Available', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A1B3A))),
                const SizedBox(height: 8),
                Text('Be the first to share a book!', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ],
            ),
          );
        }

        if (filteredBooks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                Text('No Books Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Text('Try searching with different keywords', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
          itemCount: filteredBooks.length,
          itemBuilder: (context, index) {
            final book = filteredBooks[index];
            final isPending = book.status.toString().split('.').last == 'pending';
            final isOwnBook = currentUser != null && book.ownerId == currentUser.uid;
            
            Widget? actionButton;
            if (!isOwnBook) {
              actionButton = ElevatedButton.icon(
                onPressed: isPending ? null : () => _requestSwap(book),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPending ? Colors.grey[400] : AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  disabledBackgroundColor: Colors.grey[400],
                  disabledForegroundColor: Colors.white,
                ),
                icon: Icon(isPending ? Icons.lock_outline : Icons.swap_horiz, size: 18),
                label: Text(
                  isPending ? 'Unavailable' : 'Request Swap',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              );
            }
            
            return EnhancedBookCard(
              book: book,
              showOwnerInfo: true,
              actionButton: actionButton,
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories, size: 48, color: Color(0xFF1A1B3A)),
            ),
            const SizedBox(height: 16),
            const Text('No Books Available', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1A1B3A))),
            const SizedBox(height: 8),
            Text('Be the first to share a book!', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  void _requestSwap(BookModel book) async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to request swaps')),
      );
      return;
    }

    try {
      await ref.read(swapServiceProvider).createSwapRequest(
        bookId: book.id,
        requesterId: currentUser.uid,
        ownerId: book.ownerId,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Swap request sent for "${book.title}"')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send swap request: $e')),
        );
      }
    }
  }
}


