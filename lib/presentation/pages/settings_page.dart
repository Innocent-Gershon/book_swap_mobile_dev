import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap/services/auth_service.dart';
import 'package:book_swap/widgets/auth_dialogs.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.person, size: 30, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.displayName ?? currentUser?.email ?? 'Not signed in',
                          style: AppStyles.cardTitle,
                        ),
                        const SizedBox(height: 4),
                        if (currentUser?.email != null) ...[
                          Text(
                            currentUser!.email!,
                            style: AppStyles.bodyText2.copyWith(
                              color: AppColors.textDark.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Row(
                          children: [
                            Icon(
                              currentUser?.emailVerified == true 
                                  ? Icons.verified 
                                  : Icons.warning,
                              size: 16,
                              color: currentUser?.emailVerified == true 
                                  ? AppColors.success 
                                  : AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              currentUser?.emailVerified == true 
                                  ? 'Verified' 
                                  : 'Not verified',
                              style: AppStyles.bodyText2.copyWith(
                                color: currentUser?.emailVerified == true 
                                    ? AppColors.success 
                                    : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Account Section
          _SectionHeader(title: 'Account'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () => _showSignOutDialog(context),
            isDestructive: true,
          ),
          const SizedBox(height: 24),

          // App Info Section
          _SectionHeader(title: 'About'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: '1.0.0',
            onTap: null,
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.signOut();
              if (context.mounted) context.go('/welcome');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppStyles.headline3.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDestructive ? AppColors.error : null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: textColor ?? AppColors.primary),
        title: Text(title, style: AppStyles.bodyText1.copyWith(color: textColor)),
        subtitle: Text(
          subtitle,
          style: AppStyles.bodyText2.copyWith(
            color: textColor?.withValues(alpha: 0.7) ?? 
                   AppColors.textDark.withValues(alpha: 0.6),
          ),
        ),
        trailing: onTap != null
            ? Icon(Icons.chevron_right, color: AppColors.textDark.withValues(alpha: 0.3))
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
