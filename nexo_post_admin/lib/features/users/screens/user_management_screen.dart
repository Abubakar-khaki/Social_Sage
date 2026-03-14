import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<_MockUser> _users = [
    _MockUser('1', 'Alex Creator', 'alex@example.com', 450, 'Active'),
    _MockUser('2', 'Sarah Smith', 'sarah@example.com', 120, 'Active'),
    _MockUser('3', 'John Doe', 'john@example.com', 50, 'Inactive'),
    _MockUser('4', 'Crypto Guru', 'crypto@example.com', 2500, 'Active'),
    _MockUser('5', 'Jane Miller', 'jane@example.com', 0, 'Active'),
  ];

  @override
  Widget build(BuildContext context) {
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
                      decoration: InputDecoration(
                        hintText: 'Search users by name, email, or ID...',
                        prefixIcon: const Icon(LucideIcons.search, size: 18),
                        fillColor: AppColors.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildDropdown('Status', ['All', 'Active', 'Inactive']),
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ListView(
                  children: [
                    _buildTableHeader(),
                    const Divider(height: 1),
                    ..._users.map((user) => _buildUserRow(user)),
                  ],
                ),
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
          Expanded(child: Text('CREDITS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDisabled))),
          Expanded(child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDisabled))),
          Expanded(child: Text('ACTIONS', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDisabled))),
        ],
      ),
    );
  }

  Widget _buildUserRow(_MockUser user) {
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
                  tooltip: 'Add Credits',
                ),
              ],
            ),
          ),
          
          // Status
          Expanded(
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

  void _showCreditAdjustDialog(_MockUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Credits: ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Current Balance: 450 Credits'),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount to add/remove',
                hintText: 'e.g. 50 or -20',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Update')),
        ],
      ),
    );
  }
}

class _MockUser {
  final String id;
  final String name;
  final String email;
  final int credits;
  final String status;

  _MockUser(this.id, this.name, this.email, this.credits, this.status);
}
