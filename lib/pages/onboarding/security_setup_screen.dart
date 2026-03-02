import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/neon_button.dart';
import '../../providers/app_providers.dart';

/// Security setup screen — choose fingerprint, face, or password
class SecuritySetupScreen extends ConsumerStatefulWidget {
  final String username;
  const SecuritySetupScreen({super.key, required this.username});

  @override
  ConsumerState<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends ConsumerState<SecuritySetupScreen> {
  String _selectedMethod = 'fingerprint';
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    final pass = _passwordController.text;
    final confirm = _confirmController.text;

    if (pass.length < 4) {
      setState(() => _error = 'Password must be at least 4 characters');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    await ref.read(authProvider.notifier).completeOnboarding(
      widget.username,
      _selectedMethod,
      password: _passwordController.text,
    );

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/onboarding'),
        ),
        title: const Text('Security Setup'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              const Center(
                child: Icon(Icons.shield_rounded, size: 64, color: AppColors.neonCyan),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Hi, ${widget.username}! 👋',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Choose how you want to protect your app',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ),

              const SizedBox(height: 36),

              // ── Security Methods ──
              _SecurityOption(
                icon: Icons.fingerprint_rounded,
                title: 'Fingerprint',
                subtitle: 'Recommended • Fast & secure',
                isSelected: _selectedMethod == 'fingerprint',
                onTap: () => setState(() => _selectedMethod = 'fingerprint'),
              ),
              const SizedBox(height: 12),
              _SecurityOption(
                icon: Icons.face_rounded,
                title: 'Face Recognition',
                subtitle: 'Use face unlock',
                isSelected: _selectedMethod == 'face',
                onTap: () => setState(() => _selectedMethod = 'face'),
              ),
              const SizedBox(height: 12),
              _SecurityOption(
                icon: Icons.lock_outline_rounded,
                title: 'Password Only',
                subtitle: 'Set a strong password',
                isSelected: _selectedMethod == 'password',
                onTap: () => setState(() => _selectedMethod = 'password'),
              ),

              const SizedBox(height: 32),

              // ── Password Fields ──
              const Text(
                'Set Password (Required)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() => _error = null),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter password (min 4 chars)',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                onChanged: (_) => setState(() => _error = null),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Confirm password',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textTertiary),
                  errorText: _error,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              NeonButton(
                label: _isLoading ? 'Setting up...' : 'Get Started',
                isLoading: _isLoading,
                onPressed: _isLoading ? null : () => _onGetStarted(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SecurityOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyanSubtle : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.neonCyan : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.neonCyan.withOpacity(0.1), blurRadius: 12)]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.neonCyan.withOpacity(0.15)
                    : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.neonCyan : AppColors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppColors.neonCyan : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.neonCyan, size: 22),
          ],
        ),
      ),
    );
  }
}
