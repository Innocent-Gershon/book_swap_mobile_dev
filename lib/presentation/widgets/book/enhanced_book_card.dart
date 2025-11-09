import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/models/book_model.dart';
import '../../theme/app_colors.dart';

class EnhancedBookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback? onTap;
  final Widget? actionButton;
  final bool showOwnerInfo;

  const EnhancedBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.actionButton,
    this.showOwnerInfo = false,
  });

  bool _isBase64Image(String? imageUrl) {
    return imageUrl != null && imageUrl.startsWith('data:image');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book Cover
                Container(
                  width: 70,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: book.imageUrl != null && book.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _isBase64Image(book.imageUrl)
                              ? Image.memory(
                                  base64Decode(book.imageUrl!.split(',')[1]),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                )
                              : Image.network(
                                  book.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                ),
                        )
                      : _buildPlaceholder(),
                ),
                const SizedBox(width: 12),
                
                // Book Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1B3A),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              book.author,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Condition Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.accentLight,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getConditionIcon(book.condition),
                              size: 12,
                              color: const Color(0xFF1A1B3A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getConditionText(book.condition),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1B3A),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (showOwnerInfo) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                book.ownerEmail,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      if (actionButton != null) ...[
                        const SizedBox(height: 10),
                        actionButton!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 32,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  IconData _getConditionIcon(BookCondition condition) {
    switch (condition) {
      case BookCondition.newBook:
        return Icons.auto_awesome;
      case BookCondition.likeNew:
        return Icons.star;
      case BookCondition.good:
        return Icons.check_circle;
      case BookCondition.used:
        return Icons.book;
    }
  }

  String _getConditionText(BookCondition condition) {
    switch (condition) {
      case BookCondition.newBook:
        return 'NEW';
      case BookCondition.likeNew:
        return 'LIKE NEW';
      case BookCondition.good:
        return 'GOOD';
      case BookCondition.used:
        return 'USED';
    }
  }
}
