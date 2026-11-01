import 'package:flutter/material.dart';

import '../../../../core/analytics/analytics_client.dart';
import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../care_colors.dart';

class CalmCompletePage extends StatefulWidget {
  const CalmCompletePage({
    super.key,
    required this.title,
    required this.body,
    this.hint,
    this.tool,
  });

  final String title;
  final String body;
  final String? hint;
  final String? tool;

  @override
  State<CalmCompletePage> createState() => _CalmCompletePageState();
}

class _CalmCompletePageState extends State<CalmCompletePage> {
  @override
  void initState() {
    super.initState();
    final tool = widget.tool;
    if (tool != null && tool.isNotEmpty) {
      AnalyticsClient.instance.trackCalmComplete(tool);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.close_rounded, color: CareColors.headingOf(context)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
          child: Column(
            children: [
              const Spacer(),
              const Text('👍', style: TextStyle(fontSize: 88)),
              const SizedBox(height: 18),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: CareColors.headingOf(context),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: CareColors.headingOf(context),
                ),
              ),
              if (widget.hint != null && widget.hint!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  widget.hint!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: CareColors.mutedOf(context),
                  ),
                ),
              ],
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(999),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: Center(
                        child: Text(
                          l10n.careBackToCalmCorner,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
