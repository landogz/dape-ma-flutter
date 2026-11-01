import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/sticker_pack.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../stickers/kid_listo_stickers.dart';
import '../stickers/sticker_library_repository.dart';

/// Emoji + sticker picker for the post comment composer.
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
                    _StickerGrid(onPick: (file) {
                      Navigator.of(context).pop(CommentComposerPick.stickerFile(file));
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

class _StickerGrid extends StatefulWidget {
  const _StickerGrid({required this.onPick});

  final ValueChanged<File> onPick;

  @override
  State<_StickerGrid> createState() => _StickerGridState();
}

class _StickerGridState extends State<_StickerGrid> {
  final _repo = StickerLibraryRepository.instance;
  List<StickerItem> _remote = const [];
  var _loading = true;
  var _picking = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stickers = await _repo.fetchStickers();
    if (!mounted) return;
    setState(() {
      _remote = stickers;
      _loading = false;
    });
  }

  Future<void> _pickRemote(StickerItem sticker) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final file = await _repo.fileFromRemote(sticker);
      if (!mounted) return;
      widget.onPick(file);
    } catch (_) {
      if (!mounted) return;
      setState(() => _picking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.actionFailed('load sticker'))),
      );
    }
  }

  Future<void> _pickAsset(String asset) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final file = await _repo.fileFromAsset(asset);
      if (!mounted) return;
      widget.onPick(file);
    } catch (_) {
      if (!mounted) return;
      setState(() => _picking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.actionFailed('load sticker'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }

    final useRemote = _remote.isNotEmpty;
    final count = useRemote ? _remote.length : KidListoStickers.assets.length;

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
          itemCount: count,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            if (useRemote) {
              final sticker = _remote[index];
              return Material(
                color: context.softBrandSurface,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _pickRemote(sticker),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.network(
                      sticker.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image_outlined,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }

            final asset = KidListoStickers.assets[index];
            return Material(
              color: context.softBrandSurface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _pickAsset(asset),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Image.asset(asset, fit: BoxFit.contain),
                ),
              ),
            );
          },
        ),
        if (_picking)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.18),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
