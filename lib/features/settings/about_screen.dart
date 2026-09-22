import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _info;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _info = info);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final version = _info?.version ?? '1.0.0';
    final build = _info?.buildNumber ?? '1';

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: Text(l10n.aboutApp),
        backgroundColor: context.pageBackground,
        foregroundColor: AppColors.secondaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/ddb.svg',
                width: 88,
                height: 88,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'DAPE-MA',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.secondaryBlue,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutTagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlue.withValues(alpha: 0.85),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            _AboutRow(label: l10n.versionLabel, value: version),
            const SizedBox(height: 10),
            _AboutRow(label: l10n.buildLabel, value: build),
            const SizedBox(height: 10),
            _AboutRow(label: l10n.developersLabel, value: 'DDB'),
            const SizedBox(height: 10),
            _AboutRow(label: l10n.contactUsLabel, value: 'info@ddb.gov.ph'),
            const SizedBox(height: 36),
            Icon(
              Icons.verified_rounded,
              color: AppColors.primaryBlue.withValues(alpha: 0.55),
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              l10n.aboutCopyright,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryBlue.withValues(alpha: 0.65),
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.secondaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.primaryBlue.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
