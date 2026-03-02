import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_constants.dart';

/// Circular platform icon with neon glow effect
class PlatformIcon extends StatelessWidget {
  final SocialPlatform platform;
  final bool isConnected;
  final double size;
  final VoidCallback? onTap;

  const PlatformIcon({
    super.key,
    required this.platform,
    this.isConnected = false,
    this.size = 56,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: isConnected ? platform.color : AppColors.border,
                width: isConnected ? 2 : 1,
              ),
              boxShadow: isConnected
                  ? [
                      BoxShadow(
                        color: platform.color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                platform.icon,
                size: size * 0.4,
                color: isConnected ? platform.color : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: size + 8,
            child: Text(
              platform.name,
              style: TextStyle(
                fontSize: 10,
                color: isConnected ? AppColors.textSecondary : AppColors.textTertiary,
                fontWeight: isConnected ? FontWeight.w500 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
