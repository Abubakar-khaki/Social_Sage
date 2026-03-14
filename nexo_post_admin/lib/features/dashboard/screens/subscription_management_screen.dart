import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SubscriptionManagementScreen extends StatelessWidget {
  const SubscriptionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subscription & Plan Management', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 32),

          // Active Tiers Grid
          Row(
            children: [
              _buildPlanCard(context, 'GEN Z', '0', '30 Credits/Mo', LucideIcons.user),
              const SizedBox(width: 16),
              _buildPlanCard(context, 'SILVER', '19', '200 Credits/Mo', LucideIcons.award, color: Colors.blueGrey),
              const SizedBox(width: 16),
              _buildPlanCard(context, 'OIL', '49', '600 Credits/Mo', LucideIcons.flame, color: AppColors.warning),
              const SizedBox(width: 16),
              _buildPlanCard(context, 'GOLD', '99', 'Unlimited', LucideIcons.star, color: Colors.amber),
            ],
          ),

          const SizedBox(height: 32),

          // Platform Toggles
          Text('Global Feature Toggles', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildToggleRow('Facebook Publishing', true),
                  _buildToggleRow('Instagram Publishing', true),
                  _buildToggleRow('YouTube Integration', true),
                  _buildToggleRow('TikTok Publishing', false, reason: 'API Maintenance'),
                  _buildToggleRow('WhatsApp Broadcast', true),
                  _buildToggleRow('AI Content Generation', true),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),

          // Recent Crypto Webhooks
          Text('Crypto Payment Logs (Binance Pay)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                _buildWebhookHeader(),
                const Divider(height: 1),
                _buildWebhookRow('WH-772', 'alex@example.com', '\$49.00', 'COMPLETED', 'Success'),
                _buildWebhookRow('WH-771', 'jane@example.com', '\$19.00', 'FAILED', 'Hash Mismatch', isError: true),
                _buildWebhookRow('WH-770', 'john@example.com', '\$99.00', 'COMPLETED', 'Success'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, String name, String price, String limit, IconData icon, {Color color = AppColors.primaryAccent}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 16),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text('\$$price/mo', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(limit, style: const TextStyle(color: AppColors.textDisabled, fontSize: 13)),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Edit Limits'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, {String? reason}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (reason != null) Text(reason, style: const TextStyle(color: AppColors.error, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: AppColors.primaryAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildWebhookHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: const Row(
        children: [
          Expanded(child: Text('WEBHOOK ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
          Expanded(flex: 2, child: Text('USER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
          Expanded(child: Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
          Expanded(child: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
          Expanded(child: Text('RESULT', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.textDisabled))),
        ],
      ),
    );
  }

  Widget _buildWebhookRow(String id, String user, String amount, String status, String result, {bool isError = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(id, style: const TextStyle(fontFamily: 'Courier', fontSize: 12))),
          Expanded(flex: 2, child: Text(user)),
          Expanded(child: Text(amount)),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                color: isError ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(child: Text(result, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, color: AppColors.textDisabled))),
        ],
      ),
    );
  }
}
