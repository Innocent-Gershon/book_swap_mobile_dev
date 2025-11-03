// lib/presentation/widgets/common/loading_indicator.dart
import 'package:book_swap/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Ensure flutter_spinkit is in pubspec.yaml

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.color = AppColors.primary, this.size = 50.0});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: color,
        size: size,
      ),
    );
  }
}