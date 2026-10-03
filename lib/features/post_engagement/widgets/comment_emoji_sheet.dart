import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';

/// Compact emoji picker for the post comment composer.
Future<String?> showCommentEmojiSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: context.cardBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      const emojis = [
        '😀', '😃', '😄', '😁', '😅', '😂', '🤣', '😊',
        '😇', '🙂', '😉', '😍', '🥰', '😘', '😗', '😋',
        '😛', '😜', '🤪', '😝', '🤑', '🤗', '🤭', '🤫',
        '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏', '😒',
        '🙄', '😬', '😌', '😔', '😪', '🤤', '😴', '😷',
        '🤒', '🤕', '🤢', '🤮', '🥵', '🥶', '🥴', '😵',
        '👍', '👎', '👏', '🙌', '🤝', '🙏', '💪', '✌️',
        '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
        '💔', '❣️', '💕', '💞', '💓', '💗', '💖', '💘',
        '🔥', '⭐', '✨', '🎉', '🎊', '💯', '✅', '❌',
      ];

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.borderSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Emoji',
                style: TextStyle(
                  color: ctx.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.sizeOf(ctx).height * 0.32,
                child: GridView.builder(
                  itemCount: emojis.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final emoji = emojis[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(ctx).pop(emoji),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mediumElectricBlue,
                  minimumSize: const Size(44, 44),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
