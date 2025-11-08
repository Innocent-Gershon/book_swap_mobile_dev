import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../theme/vintage_theme.dart';
import '../../data/models/message_model.dart';
import '../../services/auth_service.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  final String chatId;

  const ChatDetailPage({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: VintageTheme.parchment,
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Please sign in to view chat')),
      );
    }

    final messagesAsync = ref.watch(messagesStreamProvider(widget.chatId));

    return Scaffold(
      backgroundColor: VintageTheme.parchment,
      appBar: AppBar(
        backgroundColor: VintageTheme.antiqueBrown,
        foregroundColor: VintageTheme.cream,
        title: Text(
          'Book Exchange Chat',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: VintageTheme.antiqueBrown.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: VintageTheme.antiqueBrown.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: VintageTheme.antiqueBrown.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start the Conversation',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: VintageTheme.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send your first message to begin discussing the book exchange',
                          style: GoogleFonts.crimsonText(
                            fontSize: 16,
                            color: VintageTheme.sepia,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser.uid;
                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
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
                      size: 48,
                      color: VintageTheme.burgundy.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load messages',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
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
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VintageTheme.oldPaper,
              border: Border(
                top: BorderSide(
                  color: VintageTheme.antiqueBrown.withOpacity(0.3),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: VintageTheme.cream,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: VintageTheme.antiqueBrown.withOpacity(0.3),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: GoogleFonts.crimsonText(
                        fontSize: 18,
                        color: VintageTheme.darkBrown,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: GoogleFonts.crimsonText(
                          fontSize: 16,
                          color: VintageTheme.sepia.withOpacity(0.7),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [VintageTheme.antiqueBrown, VintageTheme.darkBrown],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: VintageTheme.darkBrown.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: VintageTheme.cream,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    try {
      await ref.read(chatServiceProvider).sendMessage(
        chatId: widget.chatId,
        senderId: currentUser.uid,
        text: text,
      );
      
      _messageController.clear();
      
      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: VintageTheme.burgundy,
          ),
        );
      }
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [VintageTheme.sepia, VintageTheme.darkBrown],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: VintageTheme.cream,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? VintageTheme.antiqueBrown : VintageTheme.oldPaper,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: Border.all(
                  color: isMe 
                      ? VintageTheme.darkBrown.withOpacity(0.3)
                      : VintageTheme.antiqueBrown.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: VintageTheme.darkBrown.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: GoogleFonts.crimsonText(
                      fontSize: 18,
                      color: isMe ? VintageTheme.cream : VintageTheme.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: GoogleFonts.crimsonText(
                      fontSize: 14,
                      color: isMe 
                          ? VintageTheme.cream.withOpacity(0.8)
                          : VintageTheme.sepia.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [VintageTheme.goldAccent, VintageTheme.antiqueBrown],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: VintageTheme.cream,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    
    try {
      final DateTime dateTime = timestamp.toDate();
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 0) {
        return DateFormat('MMM d, HH:mm').format(dateTime);
      } else {
        return DateFormat('HH:mm').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }
}
