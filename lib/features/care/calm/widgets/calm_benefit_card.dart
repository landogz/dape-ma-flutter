import 'package:flutter/material.dart';

import '../../care_colors.dart';

class CalmBenefitCard extends StatelessWidget {
  const CalmBenefitCard({
    super.key,
    required this.heading,
    required this.items,
  });

  final String heading;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: CareColors.calmMintCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: CareColors.calmForestMid,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: CareColors.calmForest,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: CareColors.calmForest,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CalmPrimaryButton extends StatelessWidget {
  const CalmPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.play_arrow_rounded,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: CareColors.calmForest,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
