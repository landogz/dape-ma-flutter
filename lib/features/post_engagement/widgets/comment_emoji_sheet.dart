import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../stickers/kid_listo_stickers.dart';

/// Emoji + Kid Listo sticker picker for the post comment composer.
Future<CommentComposerPick?> showCommentEmojiSheet(BuildContext context) {
  return showModalBottomSheet<CommentComposerPick>(
    context: context,
    backgroundColor: context.cardBackground,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _CommentComposerSheet(),
  );
}

class _CommentComposerSheet extends StatelessWidget {
  const _CommentComposerSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final height = MediaQuery.sizeOf(context).height * 0.42;

    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderSubtle,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                labelColor: AppColors.mediumElectricBlue,
                unselectedLabelColor: context.textSecondary,
                indicatorColor: AppColors.mediumElectricBlue,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                tabs: [
                  Tab(text: l10n.commentEmojiTab),
                  Tab(text: l10n.commentStickersTab),
                ],
              ),
              SizedBox(
                height: height,
                child: TabBarView(
                  children: [
                    _EmojiGrid(onPick: (emoji) {
                      Navigator.of(context).pop(CommentComposerPick.emoji(emoji));
                    }),
                    _StickerGrid(onPick: (asset) {
                      Navigator.of(context).pop(CommentComposerPick.sticker(asset));
                    }),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mediumElectricBlue,
                  minimumSize: const Size(44, 44),
                ),
                child: Text(l10n.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({required this.onPick});

  final ValueChanged<String> onPick;

  static const _emojis = [
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

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _emojis.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        final emoji = _emojis[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onPick(emoji),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
        );
      },
    );
  }
}

class _StickerGrid extends StatelessWidget {
  const _StickerGrid({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      itemCount: KidListoStickers.assets.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        final asset = KidListoStickers.assets[index];
        return Material(
          color: context.softBrandSurface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onPick(asset),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }
}
