import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/book_provider.dart';
import '../theme/app_colors.dart';
import '../../data/models/book_model.dart';
import '../../services/auth_service.dart';

final swapServiceProvider = Provider((ref) => SwapService());

class BrowseListingsPage extends ConsumerWidget {
  const BrowseListingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksStreamProvider);
    final currentUser = AuthService.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Browse Books'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: booksAsync.when(
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
                    child: Icon(Icons.auto_stories, size: 48, color: AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text('No Books Available', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text('Be the first to share a book!', style: TextStyle(fontSize: 16, color: AppColors.textDark.withValues(alpha: 0.7))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                      const SizedBox(height: 8),
                      Text('by ${book.author}', style: TextStyle(fontSize: 16, color: AppColors.textDark.withValues(alpha: 0.7))),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(book.condition.name.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ),
                          const Spacer(),
                          if (currentUser != null && book.ownerId != currentUser.uid)
                            ElevatedButton(
                              onPressed: () => _requestSwap(context, ref, book),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textLight,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Request Swap', style: TextStyle(fontSize: 16)),
                            ),
                        ],
                      ),
                    ],
                  ),
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
              Text('Error loading books', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('$error', style: TextStyle(fontSize: 16, color: Colors.red)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/post-book'),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _requestSwap(BuildContext context, WidgetRef ref, BookModel book) async {
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

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> createSwapRequest({
    required String bookId,
    required String requesterId,
    required String ownerId,
  }) async {
    final batch = _firestore.batch();
    
    // Create swap document
    final swapRef = _firestore.collection('swaps').doc();
    batch.set(swapRef, {
      'id': swapRef.id,
      'bookId': bookId,
      'requesterUserId': requesterId,
      'ownerUserId': ownerId,
      'status': 'pending',
      'initiatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Update book status to pending
    batch.update(
      _firestore.collection('books').doc(bookId),
      {
        'status': 'pending',
        'swapRequesterId': requesterId,
        'updatedAt': FieldValue.serverTimestamp(),
      }
    );
    
    await batch.commit();
  }
}


