import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:book_swap/core/providers/app_providers.dart';
import 'package:book_swap/data/services/firebase_service.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_colors.dart';
import 'package:book_swap/presentation/pages/widgets/theme/app_styles.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseService.currentUser;
    final notificationSettings = ref.watch(notificationSettingsProvider);

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
          _ProfileSection(user: currentUser),
          const SizedBox(height: 24),

          // Notifications Section
          _SectionHeader(title: 'Notifications'),
          const SizedBox(height: 8),
          _NotificationTile(
            title: 'Swap Notifications',
            subtitle: 'Get notified when someone wants to swap with you',
            value: notificationSettings.swapNotifications,
            onChanged: (_) => ref.read(notificationSettingsProvider.notifier).toggleSwapNotifications(),
          ),
          _NotificationTile(
            title: 'Chat Messages',
            subtitle: 'Get notified about new chat messages',
            value: notificationSettings.chatNotifications,
            onChanged: (_) => ref.read(notificationSettingsProvider.notifier).toggleChatNotifications(),
          ),
          _NotificationTile(
            title: 'Email Notifications',
            subtitle: 'Receive notifications via email',
            value: notificationSettings.emailNotifications,
            onChanged: (_) => ref.read(notificationSettingsProvider.notifier).toggleEmailNotifications(),
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
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Learn how we protect your data',
            onTap: () {
              // TODO: Open privacy policy
            },
          ),
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with using BookSwap',
            onTap: () {
              // TODO: Open help
            },
          ),

          const SizedBox(height: 24),

          // Account Section
          _SectionHeader(title: 'Account'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () => _signOut(context, ref),
            textColor: AppColors.error,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseService.signOut();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Signed out successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}

class _ProfileSection extends StatelessWidget {
  final dynamic user;

  const _ProfileSection({this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.email ?? 'Not signed in',
                    style: AppStyles.cardTitle,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        user?.emailVerified == true 
                            ? Icons.verified 
                            : Icons.warning,
                        size: 16,
                        color: user?.emailVerified == true 
                            ? AppColors.success 
                            : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user?.emailVerified == true 
                            ? 'Verified' 
                            : 'Not verified',
                        style: AppStyles.bodyText2.copyWith(
                          color: user?.emailVerified == true 
                              ? AppColors.success 
                              : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                // TODO: Edit profile
              },
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.primary,
            ),
          ],
        ),
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
        style: AppStyles.headline3.copyWith(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: AppStyles.bodyText1),
        subtitle: Text(
          subtitle,
          style: AppStyles.bodyText2.copyWith(
            color: AppColors.textDark.withValues(alpha: 0.6),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          icon,
          color: textColor ?? AppColors.primary,
        ),
        title: Text(
          title,
          style: AppStyles.bodyText1.copyWith(color: textColor),
        ),
        subtitle: Text(
          subtitle,
          style: AppStyles.bodyText2.copyWith(
            color: textColor?.withValues(alpha: 0.7) ?? 
                   AppColors.textDark.withValues(alpha: 0.6),
          ),
        ),
        trailing: onTap != null
            ? Icon(
                Icons.chevron_right,
                color: AppColors.textDark.withValues(alpha: 0.3),
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
