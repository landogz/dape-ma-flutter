import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../stickers/kid_listo_stickers.dart';
import 'comment_emoji_sheet.dart';

class EditCommentSheet extends StatefulWidget {
  const EditCommentSheet({
    super.key,
    required this.initialBody,
    this.initialImageUrl,
    required this.onSave,
  });

  final String initialBody;
  final String? initialImageUrl;
  final Future<void> Function(String body, File? image) onSave;

  @override
  State<EditCommentSheet> createState() => _EditCommentSheetState();
}

class _EditCommentSheetState extends State<EditCommentSheet> {
  late final TextEditingController _controller;
  bool _saving = false;
  String? _error;
  File? _stickerFile;

  bool get _hasImage =>
      _stickerFile != null ||
      (widget.initialImageUrl != null && widget.initialImageUrl!.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBody);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickComposerItem() async {
    final pick = await showCommentEmojiSheet(context);
    if (!mounted || pick == null) return;

    final stickerAsset = pick.stickerAsset;
    if (stickerAsset != null && stickerAsset.isNotEmpty) {
      try {
        final file = await KidListoStickers.fileFromAsset(stickerAsset);
        if (!mounted) return;
        setState(() {
          _stickerFile = file;
          _error = null;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _error = context.l10n.commentUpdateFailed);
      }
      return;
    }

    final emoji = pick.emoji;
    if (emoji == null || emoji.isEmpty) return;

    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final next = text.replaceRange(start, end, emoji);
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    setState(() {});
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty && !_hasImage) {
      setState(() => _error = context.l10n.commentCannotBeEmpty);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(body, _stickerFile);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = context.l10n.commentUpdateFailed;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderSubtle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.editComment,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (_hasImage) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 140,
                    maxWidth: 140,
                  ),
                  child: _stickerFile != null
                      ? Image.file(_stickerFile!, fit: BoxFit.contain)
                      : Image.network(
                          widget.initialImageUrl!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Container(
                            height: 88,
                            width: 88,
                            color: AppColors.softBlue,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: context.textSecondary,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _saving ? null : _pickComposerItem,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mediumElectricBlue,
                  minimumSize: const Size(44, 44),
                ),
                icon: const Icon(Icons.emoji_emotions_outlined, size: 18),
                label: Text(l10n.commentChangeSticker),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 4,
            minLines: 2,
            decoration: InputDecoration(
              hintText: _hasImage
                  ? l10n.commentCaptionOptional
                  : l10n.updateCommentHint,
              filled: true,
              fillColor: context.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                tooltip: l10n.commentEmojiTab,
                onPressed: _saving ? null : _pickComposerItem,
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  color: context.textSecondary,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.accentRed, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                minimumSize: const Size(44, 48),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.saveChanges),
            ),
          ),
        ],
      ),
    );
  }
}
