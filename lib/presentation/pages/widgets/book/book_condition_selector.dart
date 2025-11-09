// lib/presentation/widgets/book/book_condition_selector.dart
import 'package:book_swap/presentation/theme/app_colors.dart';
import 'package:book_swap/presentation/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for book conditions for type safety
enum BookCondition {
  newCondition('New'),
  likeNew('Like New'),
  good('Good'),
  used('Used');

  final String label;
  const BookCondition(this.label);

  static BookCondition? fromLabel(String? label) {
    if (label == null) return null;
    return BookCondition.values.firstWhere(
      (e) => e.label == label,
      orElse: () => BookCondition.used, // Default if not found
    );
  }
}

class BookConditionSelector extends ConsumerWidget {
  const BookConditionSelector({
    super.key,
    this.initialCondition,
    required this.onConditionSelected,
  });

  final String? initialCondition; // Expects String label
  final ValueChanged<String> onConditionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCondition = ref.watch(_localConditionProvider(initialCondition));

    return Wrap(
      spacing: 8.0, // Horizontal space between buttons
      runSpacing: 8.0, // Vertical space between rows of buttons
      children: BookCondition.values.map((condition) {
        final isSelected = selectedCondition == condition.label;
        return ChoiceChip(
          label: Text(condition.label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref.read(_localConditionProvider(initialCondition).notifier).state = condition.label;
              onConditionSelected(condition.label);
            }
          },
          selectedColor: AppColors.primary,
          labelStyle: AppStyles.conditionTag?.copyWith(
            color: isSelected ? AppColors.textLight : AppColors.textDark,
          ) ?? TextStyle(
            color: isSelected ? AppColors.textLight : AppColors.textDark,
          ),
          backgroundColor: AppColors.card,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }
}

// Local provider to manage the selected state within this widget
final _localConditionProvider = StateProvider.family<String?, String?>((ref, initial) => initial);