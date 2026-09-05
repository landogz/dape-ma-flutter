import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/training.dart';
import '../../../core/theme/app_colors.dart';

class TrainingDetailScreen extends StatelessWidget {
  final Training training;

  const TrainingDetailScreen({super.key, required this.training});

  Future<void> _launchUrl(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String number) async {
    final digits = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('tel:$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trainingDetailTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              training.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoPill(icon: Icons.category_outlined, label: training.category),
                if (training.region != null && training.region!.isNotEmpty)
                  _InfoPill(icon: Icons.map_outlined, label: training.region!),
              ],
            ),
            if (training.description != null &&
                training.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.aboutTraining,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                training.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimaryLight,
                      height: 1.45,
                    ),
              ),
            ],
            const SizedBox(height: 20),
            _DetailRow(
              icon: Icons.event_outlined,
              label: l10n.scheduleLabel,
              value: training.scheduleLabel,
            ),
            if (training.scheduleNotes != null &&
                training.scheduleNotes!.trim().isNotEmpty)
              _DetailRow(
                icon: Icons.schedule_outlined,
                label: l10n.timeLabel,
                value: training.scheduleNotes!,
              ),
            if (training.venue != null && training.venue!.isNotEmpty)
              _DetailRow(
                icon: Icons.place_outlined,
                label: l10n.venueLabel,
                value: training.venue!,
              ),
            if (training.organizer != null && training.organizer!.isNotEmpty)
              _DetailRow(
                icon: Icons.apartment_outlined,
                label: l10n.organizerLabel,
                value: training.organizer!,
              ),
            if (training.slots != null)
              _DetailRow(
                icon: Icons.groups_outlined,
                label: l10n.slotsLabel,
                value: '${training.slots}',
              ),
            if (training.contact != null && training.contact!.isNotEmpty)
              _DetailRow(
                icon: Icons.phone_outlined,
                label: l10n.contactLabel,
                value: training.contact!,
                onTap: () => _launchPhone(training.contact!),
                isLink: true,
              ),
            if (training.registrationUrl != null &&
                training.registrationUrl!.trim().isNotEmpty) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(training.registrationUrl!),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.registerOrLearnMore),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool isLink;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondaryLight),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isLink
                            ? AppColors.primaryBlue
                            : AppColors.textPrimaryLight,
                        decoration:
                            isLink ? TextDecoration.underline : null,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: content,
    );
  }
}
