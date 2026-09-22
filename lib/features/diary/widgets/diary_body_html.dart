import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../core/theme/app_theme_colors.dart';

class DiaryBodyHtml extends StatelessWidget {
  const DiaryBodyHtml({
    super.key,
    required this.html,
    this.maxLines,
  });

  final String html;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    if (html.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return HtmlWidget(
      html,
      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.textPrimary,
            height: 1.45,
          ),
    );
  }
}
