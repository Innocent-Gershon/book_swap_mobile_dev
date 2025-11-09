import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/vintage_theme.dart';

class VintageBookCard extends StatelessWidget {
  final String title;
  final String author;
  final String condition;
  final VoidCallback? onTap;
  final VoidCallback? onSwap;
  final String? imageUrl;

  const VintageBookCard({
    super.key,
    required this.title,
    required this.author,
    required this.condition,
    this.onTap,
    this.onSwap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: VintageTheme.vintageCardDecoration,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Book Cover
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: VintageTheme.antiqueBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: VintageTheme.antiqueBrown.withValues(alpha: 0.3),
                  ),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildBookIcon(),
                        ),
                      )
                    : _buildBookIcon(),
              ),
              const SizedBox(width: 16),
              
              // Book Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: VintageTheme.darkBrown,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by $author',
                      style: GoogleFonts.crimsonText(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: VintageTheme.sepia,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: VintageTheme.goldAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: VintageTheme.goldAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        condition.toUpperCase(),
                        style: GoogleFonts.crimsonText(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: VintageTheme.darkBrown,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action Button
              if (onSwap != null)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [VintageTheme.antiqueBrown, VintageTheme.darkBrown],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: VintageTheme.darkBrown.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onSwap,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'SWAP',
                          style: GoogleFonts.crimsonText(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: VintageTheme.cream,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookIcon() {
    return Icon(
      Icons.menu_book_rounded,
      size: 30,
      color: VintageTheme.antiqueBrown.withValues(alpha: 0.6),
    );
  }
}

class VintageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const VintageAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [VintageTheme.antiqueBrown, VintageTheme.darkBrown],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: VintageTheme.darkBrown.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: VintageTheme.cream,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: actions,
        iconTheme: const IconThemeData(color: VintageTheme.cream),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class VintageFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const VintageFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [VintageTheme.goldAccent, VintageTheme.antiqueBrown],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: VintageTheme.darkBrown.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(icon, color: VintageTheme.cream, size: 28),
      ),
    );
  }
}

class VintageEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const VintageEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: VintageTheme.antiqueBrown.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: VintageTheme.antiqueBrown.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 64,
                color: VintageTheme.antiqueBrown.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: VintageTheme.darkBrown,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: GoogleFonts.crimsonText(
                fontSize: 18,
                color: VintageTheme.sepia,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 32),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class VintageStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const VintageStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.crimsonText(
              fontSize: 14,
              color: VintageTheme.sepia,
            ),
          ),
        ],
      ),
    );
  }
}
