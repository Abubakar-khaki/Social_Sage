import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Platform definitions with icons, colors, and posting options
class SocialPlatform {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> postingOptions;

  const SocialPlatform({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.postingOptions,
  });
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Social Sage';
  static const Duration postCooldown = Duration(minutes: 5);

  static const List<SocialPlatform> platforms = [
    SocialPlatform(
      id: 'facebook',
      name: 'Facebook',
      icon: FontAwesomeIcons.facebook,
      color: AppColors.facebook,
      postingOptions: ['Timeline', 'Story', 'Group', 'Page'],
    ),
    SocialPlatform(
      id: 'instagram',
      name: 'Instagram',
      icon: FontAwesomeIcons.instagram,
      color: AppColors.instagram,
      postingOptions: ['Feed', 'Reels', 'Story'],
    ),
    SocialPlatform(
      id: 'twitter',
      name: 'Twitter / X',
      icon: FontAwesomeIcons.xTwitter,
      color: AppColors.twitter,
      postingOptions: ['Tweet'],
    ),
    SocialPlatform(
      id: 'tiktok',
      name: 'TikTok',
      icon: FontAwesomeIcons.tiktok,
      color: Color(0xFFEE1D52),
      postingOptions: ['Video'],
    ),
    SocialPlatform(
      id: 'youtube',
      name: 'YouTube',
      icon: FontAwesomeIcons.youtube,
      color: AppColors.youtube,
      postingOptions: ['Short', 'Long'],
    ),
    SocialPlatform(
      id: 'linkedin',
      name: 'LinkedIn',
      icon: FontAwesomeIcons.linkedin,
      color: AppColors.linkedin,
      postingOptions: ['Post'],
    ),
    SocialPlatform(
      id: 'pinterest',
      name: 'Pinterest',
      icon: FontAwesomeIcons.pinterest,
      color: AppColors.pinterest,
      postingOptions: ['Pin'],
    ),
    SocialPlatform(
      id: 'telegram',
      name: 'Telegram',
      icon: FontAwesomeIcons.telegram,
      color: AppColors.telegram,
      postingOptions: ['Channel', 'Story'],
    ),
    SocialPlatform(
      id: 'whatsapp',
      name: 'WhatsApp',
      icon: FontAwesomeIcons.whatsapp,
      color: AppColors.whatsapp,
      postingOptions: ['Status', 'Group', 'Channel'],
    ),
    SocialPlatform(
      id: 'snapchat',
      name: 'Snapchat',
      icon: FontAwesomeIcons.snapchat,
      color: AppColors.snapchat,
      postingOptions: ['Story', 'Reels/Short'],
    ),
    SocialPlatform(
      id: 'reddit',
      name: 'Reddit',
      icon: FontAwesomeIcons.reddit,
      color: AppColors.reddit,
      postingOptions: ['Post'],
    ),
    SocialPlatform(
      id: 'discord',
      name: 'Discord',
      icon: FontAwesomeIcons.discord,
      color: AppColors.discord,
      postingOptions: ['Server'],
    ),
    SocialPlatform(
      id: 'wechat',
      name: 'WeChat',
      icon: FontAwesomeIcons.weixin,
      color: AppColors.wechat,
      postingOptions: ['Moments'],
    ),
  ];
}
