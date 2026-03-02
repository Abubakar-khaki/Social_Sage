import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';

/// Page 7: Settings — Profile, Security, Platforms, App Settings
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final Set<String> _expandedPlatforms = {};

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    await ref.read(authProvider.notifier).updateProfile(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved!'),
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _clearAllData() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your data including posts, scheduled items, and settings. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                context.go('/onboarding');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final platforms = ref.watch(platformAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════
            // PROFILE SECTION
            // ═══════════════════════════════
            const _SectionTitle(icon: Icons.person_outline_rounded, title: 'Profile'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.neonCyanSubtle,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.neonCyan, width: 2),
                      ),
                      child: const Icon(Icons.person_rounded, size: 36, color: AppColors.neonCyan),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'your@email.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.textTertiary),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Changes', style: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════
            // PLATFORMS SECTION
            // ═══════════════════════════════
            const _SectionTitle(icon: Icons.apps_rounded, title: 'Connected Platforms'),
            ...AppConstants.platforms.map((platform) {
              final isConnected = platforms.any((acc) => acc.platformName == platform.id);
              return _PlatformAccordion(
                  platform: platform,
                  isExpanded: _expandedPlatforms.contains(platform.id),
                  isConnected: isConnected,
                  onToggleExpand: () {
                    setState(() {
                      if (_expandedPlatforms.contains(platform.id)) {
                        _expandedPlatforms.remove(platform.id);
                      } else {
                        _expandedPlatforms.add(platform.id);
                      }
                    });
                  },
                  onToggleConnect: () {
                    final notifier = ref.read(platformAccountsProvider.notifier);
                    if (isConnected) {
                      final account = platforms.firstWhere((acc) => acc.platformName == platform.id);
                      notifier.disconnect(account.id);
                    } else {
                      notifier.connect(platform.id);
                    }
                  },
                );
            }),

            const SizedBox(height: 20),

            // ═══════════════════════════════
            // APP SETTINGS
            // ═══════════════════════════════
            const _SectionTitle(icon: Icons.tune_rounded, title: 'App Settings'),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  _SettingsToggle(
                    icon: Icons.auto_awesome_rounded,
                    title: 'AI Suggestions',
                    subtitle: 'Show smart ideas in post creator',
                    value: settings.aiSuggestions,
                    iconColor: AppColors.gold,
                    onChanged: (v) => ref.read(appSettingsProvider.notifier).update(aiSuggestions: v),
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsToggle(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    value: settings.notifications,
                    onChanged: (v) => ref.read(appSettingsProvider.notifier).update(notifications: v),
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsToggle(
                    icon: Icons.dark_mode_rounded,
                    title: 'Dark Mode',
                    value: settings.darkMode,
                    iconColor: AppColors.neonPurple,
                    onChanged: (v) => ref.read(appSettingsProvider.notifier).update(darkMode: v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════
            // DANGER ZONE
            // ═══════════════════════════════
            const _SectionTitle(icon: Icons.warning_amber_rounded, title: 'Danger Zone', color: AppColors.error),
            GlassCard(
              borderColor: AppColors.error.withOpacity(0.2),
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: _clearAllData,
                  icon: const Icon(Icons.delete_forever_rounded, size: 18),
                  label: const Text('Clear All Data & Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── App Info ──
            Center(
              child: Column(
                children: const [
                  Text('Social Sage v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                  SizedBox(height: 2),
                  Text('Open Source Edition', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  const _SectionTitle({required this.icon, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c, letterSpacing: 0.3)),
        ],
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;

  const _SettingsToggle({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = iconColor ?? AppColors.neonCyan;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: c),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)) : null,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

class _PlatformAccordion extends StatelessWidget {
  final SocialPlatform platform;
  final bool isExpanded;
  final bool isConnected;
  final VoidCallback onToggleExpand;
  final VoidCallback onToggleConnect;

  const _PlatformAccordion({
    required this.platform,
    required this.isExpanded,
    required this.isConnected,
    required this.onToggleExpand,
    required this.onToggleConnect,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(platform.icon, size: 20, color: platform.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      platform.name,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    ),
                  ),
                  GestureDetector(
                    onTap: onToggleConnect,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConnected ? AppColors.neonGreen.withOpacity(0.15) : AppColors.neonCyanSubtle,
                        borderRadius: BorderRadius.circular(12),
                        border: isConnected ? Border.all(color: AppColors.neonGreen.withOpacity(0.3)) : null,
                      ),
                      child: Text(
                        isConnected ? 'Connected' : 'Connect',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isConnected ? AppColors.neonGreen : AppColors.neonCyan,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(44, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 8),
                  const Text('Supported features:', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: platform.postingOptions.map((opt) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(opt, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    )).toList(),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
