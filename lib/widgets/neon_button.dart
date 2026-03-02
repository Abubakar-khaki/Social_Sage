import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Neon-styled button with glow effect
class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
    this.width,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 2, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width ?? double.infinity,
          height: 48,
          decoration: widget.isPrimary
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyanGlow,
                      blurRadius: _glowAnimation.value,
                      spreadRadius: 0,
                    ),
                  ],
                )
              : null,
          child: widget.isPrimary
              ? ElevatedButton(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  child: _buildChild(),
                )
              : OutlinedButton(
                  onPressed: widget.isLoading ? null : widget.onPressed,
                  child: _buildChild(),
                ),
        );
      },
    );
  }

  Widget _buildChild() {
    if (widget.isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.background,
        ),
      );
    }
    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 18),
          const SizedBox(width: 8),
          Text(widget.label),
        ],
      );
    }
    return Text(widget.label);
  }
}
