import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';

/// Branding header for login, register, and forgot password screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: SvgPicture.asset(
            'assets/ddb.svg',
            fit: BoxFit.contain,
            placeholderBuilder: (BuildContext context) => Container(
              padding: const EdgeInsets.all(16),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'DAPE-MA',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryLight,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Citizen information & rehab directory',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
