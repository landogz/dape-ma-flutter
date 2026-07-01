import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/api_url.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.radius = 16,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = ApiUrl.resolve(imageUrl);
    final initial = name.isNotEmpty
        ? name.trim().substring(0, 1).toUpperCase()
        : '?';

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
      backgroundImage:
          resolvedUrl != null ? NetworkImage(resolvedUrl) : null,
      onBackgroundImageError: resolvedUrl != null ? (_, __) {} : null,
      child: resolvedUrl == null
          ? Text(
              initial,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.8,
              ),
            )
          : null,
    );
  }
}
