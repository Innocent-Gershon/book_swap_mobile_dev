import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../theme/vintage_theme.dart';
import '../widgets/vintage_widgets.dart';
import '../../services/auth_service.dart';

class ChatsListPage extends ConsumerWidget {
  const ChatsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = AuthService.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: VintageTheme.parchment,
        body: VintageEmptyState(
          icon: Icons.person_outline_rounded,
          title: 'Please Sign In',
          subtitle: 'Sign in to view your conversations',
        ),
      );
    }

    final chatsAsync = ref.watch(userChatsStreamProvider(currentUser.uid));

    return Scaffold(
      backgroundColor: VintageTheme.parchment,
      appBar: VintageAppBar(
        title: 'Conversations',
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(context),
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return VintageEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No Conversations Yet',
              subtitle: 'Start a conversation by requesting a book swap!',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userChatsStreamProvider(currentUser.uid));
            },
            color: VintageTheme.antiqueBrown,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _ChatCard(
                  chat: chat,
                  currentUserId: currentUser.uid,
                  onTap: () => context.push('/chat/${chat['id']}'),
                );
              },
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: VintageTheme.antiqueBrown,
            strokeWidth: 3,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: VintageTheme.burgundy.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load conversations',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: VintageTheme.darkBrown,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your connection and try again',
                style: GoogleFonts.crimsonText(
                  fontSize: 16,
                  color: VintageTheme.sepia,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Search Conversations',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: VintageTheme.darkBrown,
          ),
        ),
        content: TextField(
          style: GoogleFonts.crimsonText(fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search messages...',
            hintStyle: GoogleFonts.crimsonText(fontSize: 16, color: VintageTheme.sepia),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: VintageTheme.antiqueBrown),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Search', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  final Map<String, dynamic> chat;
  final String currentUserId;
  final VoidCallback onTap;

  const _ChatCard({
    required this.chat,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final participants = List<String>.from(chat['participants'] ?? []);
    final otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');
    final lastMessage = chat['lastMessage'] ?? '';
    final lastMessageAt = chat['lastMessageAt'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: VintageTheme.vintageCardDecoration,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [VintageTheme.antiqueBrown, VintageTheme.darkBrown],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: VintageTheme.cream,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Chat Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUserId.isNotEmpty ? 'User $otherUserId' : 'Unknown User',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: VintageTheme.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastMessage.isNotEmpty ? lastMessage : 'No messages yet',
                      style: GoogleFonts.crimsonText(
                        fontSize: 16,
                        color: VintageTheme.sepia,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              
              // Time and Indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (lastMessageAt != null)
                    Text(
                      _formatTime(lastMessageAt),
                      style: GoogleFonts.crimsonText(
                        fontSize: 14,
                        color: VintageTheme.sepia.withOpacity(0.7),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: VintageTheme.goldAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final DateTime dateTime = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return DateFormat('MMM d').format(dateTime);
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
