import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import '../theme/app_colors.dart';
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
  String _otherUserName = 'User';

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    _loadOtherUserName();
  }

  void _loadOtherUserName() async {
    final currentUser = AuthService.currentUser;
    if (currentUser != null) {
      final name = await ref.read(chatServiceProvider).getOtherUserName(widget.chatId, currentUser.uid);
      if (mounted) {
        setState(() => _otherUserName = name);
      }
    }
  }

  void _markMessagesAsRead() async {
    final currentUser = AuthService.currentUser;
    if (currentUser != null) {
      await ref.read(chatServiceProvider).markMessagesAsRead(widget.chatId, currentUser.uid);
    }
  }

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('Chat')),
        body: const Center(child: Text('Please sign in to view chat')),
      );
    }

    final messagesAsync = ref.watch(messagesStreamProvider(widget.chatId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        title: Text('Chat with $_otherUserName'),
        elevation: 0,
      ),
      body: Column(
        children: [
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
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start the Conversation',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send your first message to begin discussing the book exchange',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
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
                      onEdit: isMe ? () => _editMessage(message) : null,
                      onDelete: isMe ? () => _deleteMessage(message) : null,
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text('Failed to load messages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text('Please check your connection and try again', style: TextStyle(fontSize: 16, color: AppColors.textSecondary), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(fontSize: 16, color: AppColors.textHint),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
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
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to send messages'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final messageText = text;
    _messageController.clear();

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        await ref.read(chatServiceProvider).sendMessage(
          chatId: widget.chatId,
          senderId: currentUser.uid,
          text: messageText,
        );
        
        if (_scrollController.hasClients) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
            }
          });
        }
        return;
      } catch (e) {
        retryCount++;
        print('Send message attempt $retryCount failed: $e');
        
        if (retryCount >= maxRetries) {
          _messageController.text = messageText;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send after $maxRetries attempts. Check your connection.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    _messageController.clear();
                    _sendMessage();
                  },
                ),
              ),
            );
          }
        } else {
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }
    }
  }

  void _editMessage(MessageModel message) {
    final controller = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Enter new message', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newContent = controller.text.trim();
              if (newContent.isEmpty) return;
              
              try {
                await ref.read(chatServiceProvider).editMessage(widget.chatId, message.id!, newContent);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message edited')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to edit: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(chatServiceProvider).deleteMessage(widget.chatId, message.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message deleted')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
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

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MessageBubble({required this.message, required this.isMe, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[ 
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: Border.all(color: isMe ? AppColors.primary : AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message.content, style: TextStyle(fontSize: 16, color: isMe ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isEdited)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text('edited', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary)),
                        ),
                      Text(_formatTimestamp(message.timestamp), style: TextStyle(fontSize: 12, color: isMe ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe && (onEdit != null || onDelete != null)) ...[
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'edit' && onEdit != null) onEdit!();
                if (value == 'delete' && onDelete != null) onDelete!();
              },
              itemBuilder: (context) => [
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit, size: 18, color: AppColors.primary), SizedBox(width: 8), Text('Edit')]),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete')]),
                  ),
              ],
            ),
          ] else if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 16),
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
