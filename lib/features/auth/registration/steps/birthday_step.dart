import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_decor.dart';
import '../widgets/registration_shell.dart';

class BirthdayStep extends StatelessWidget {
  const BirthdayStep({
    super.key,
    required this.birthday,
    required this.onPick,
  });

  final DateTime? birthday;
  final ValueChanged<DateTime> onPick;

  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: birthday ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now.subtract(const Duration(days: 1)),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final display = birthday == null
        ? null
        : DateFormat('MM / dd / yyyy').format(birthday!);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Center(
          child: RegistrationIconBadge(
            child: Icon(
              Icons.calendar_month_rounded,
              size: 34,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l10n.regBirthdayTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.regBirthdaySubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 28),
        InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(14),
          child: InputDecorator(
            decoration: authFieldDecoration(
              context: context,
              hintText: l10n.regBirthdayHint,
              prefixIcon: Icons.cake_outlined,
              suffixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primaryBlue,
                size: 20,
              ),
            ),
            child: Text(
              display ?? l10n.regBirthdayHint,
              style: TextStyle(
                fontSize: 15,
                color: display == null
                    ? AppColors.primaryBlue.withValues(alpha: 0.45)
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
