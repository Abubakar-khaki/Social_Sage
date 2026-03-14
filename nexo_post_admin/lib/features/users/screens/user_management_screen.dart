import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/providers/admin_providers.dart';
import '../../../core/services/admin_api_service.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('User Management', style: Theme.of(context).textTheme.displayMedium),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.userPlus, size: 16),
                label: const Text('Add User'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Filters & Search
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search users by name, email, or ID...',
                        prefixIcon: const Icon(LucideIcons.search, size: 18),
                        fillColor: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildDropdown('Status', ['All', 'Active', 'Suspended']),
                  const SizedBox(width: 16),
                  _buildDropdown('Sort By', ['Newest', 'Credits', 'Name']),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Users Table
          Expanded(
            child: Card(
              child: usersAsync.when(
                data: (users) {
                  final filteredUsers = users.where((u) => 
                    u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    u.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    u.id.contains(_searchQuery)
                  ).toList();

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ListView(
                      children: [
                        _buildTableHeader(),
                        const Divider(height: 1),
                        if (filteredUsers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: Text('No users found.')),
                          )
                        else
                          ...filteredUsers.map((user) => _buildUserRow(user)),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: AppColors.background.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('NAME / EMAIL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDisabled))),
          Expanded(child: Text('PLAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDisabled))),
          Expanded(child: Text('CREDITS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDisabled))),
          Expanded(child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDisabled))),
          Expanded(child: Text('ACTIONS', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDisabled))),
        ],
      ),
    );
  }

  Widget _buildUserRow(AdminUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          // User Info
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryAccent.withOpacity(0.1),
                  child: Text(user.name[0], style: const TextStyle(color: AppColors.primaryAccent)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user.email, style: const TextStyle(color: AppColors.textDisabled, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          
          // Plan
          Expanded(
            child: Text(user.plan, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),

          // Credits
          Expanded(
            child: Row(
              children: [
                const Icon(LucideIcons.coins, size: 14, color: AppColors.warning),
                const SizedBox(width: 6),
                Text('${user.credits}'),
                IconButton(
                  icon: const Icon(LucideIcons.plusCircle, size: 14, color: AppColors.primaryAccent),
                  onPressed: () => _showCreditAdjustDialog(user),
                  tooltip: 'Adjust Credits',
                ),
              ],
            ),
          ),
          
          // Status
          Expanded(
            child: InkWell(
              onTap: () => ref.read(adminUsersProvider.notifier).toggleStatus(user.id, user.status),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (user.status == 'Active' ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.status,
                  style: TextStyle(
                    color: user.status == 'Active' ? AppColors.success : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Actions
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(LucideIcons.edit2, size: 18), onPressed: () {}),
                IconButton(icon: const Icon(LucideIcons.trash2, size: 18, color: AppColors.error), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.first,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 13)),
            );
          }).toList(),
          onChanged: (_) {},
          dropdownColor: AppColors.surface,
        ),
      ),
    );
  }

  void _showCreditAdjustDialog(AdminUser user) {
    _creditController.text = user.credits.toString();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Credits: ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Balance: ${user.credits} Credits'),
            const SizedBox(height: 16),
            TextField(
              controller: _creditController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Credit Balance',
                hintText: 'Enter total amount',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newCredits = int.tryParse(_creditController.text);
              if (newCredits != null) {
                ref.read(adminUsersProvider.notifier).updateCredits(user.id, newCredits);
                Navigator.pop(context);
              }
            }, 
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
