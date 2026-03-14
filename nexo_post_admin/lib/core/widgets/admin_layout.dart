import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(context),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.borderCard)),
      ),
      child: Column(
        children: [
          // Brand/Logo Area
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                const Icon(LucideIcons.rocket, color: AppColors.primaryAccent, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Nexo Admin',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(indent: 20, endIndent: 20),
          const SizedBox(height: 16),
          
          // Navigation Items
          _SidebarItem(
            icon: LucideIcons.layoutDashboard,
            label: 'Dashboard',
            isSelected: currentRoute == '/',
            onTap: () => context.go('/'),
          ),
          _SidebarItem(
            icon: LucideIcons.users,
            label: 'User Management',
            isSelected: currentRoute == '/users',
            onTap: () => context.go('/users'),
          ),
          _SidebarItem(
            icon: LucideIcons.fileText,
            label: 'Post Logs',
            isSelected: currentRoute == '/logs',
            onTap: () => context.go('/logs'),
          ),
          _SidebarItem(
            icon: LucideIcons.settings,
            label: 'System Settings',
            isSelected: currentRoute == '/settings',
            onTap: () => context.go('/settings'),
          ),
          
          const Spacer(),
          
          // Bottom Info
          const Padding(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.secondaryAccent,
                  child: Icon(LucideIcons.user, size: 16, color: AppColors.background),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Super Admin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('v1.0.0-MVP', style: TextStyle(color: AppColors.textDisabled, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderCard)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.search, color: AppColors.textDisabled, size: 18),
          const SizedBox(width: 12),
          Text(
            'Global Search...',
            style: TextStyle(color: AppColors.textDisabled, fontSize: 14),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.textPrimary, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.logOut, size: 14),
            label: const Text('Logout', style: TextStyle(fontSize: 13)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected 
            ? Border.all(color: AppColors.primaryAccent.withOpacity(0.3)) 
            : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
