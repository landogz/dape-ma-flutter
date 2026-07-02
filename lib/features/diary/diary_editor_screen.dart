import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/diary_entry.dart';
import '../../core/theme/app_colors.dart';
import 'diary_service.dart';
import 'widgets/diary_rich_text_toolbar.dart';

class DiaryEditorScreen extends StatefulWidget {
  const DiaryEditorScreen({super.key, this.existing});

  final DiaryEntry? existing;

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _focusNode = FocusNode();
  bool _saving = false;

  late final String _entryDate;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existing != null;
    _entryDate = widget.existing?.entryDate ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    _titleController.text = widget.existing?.title ?? '';
    _bodyController.text = widget.existing != null
        ? diaryHtmlToPlainText(widget.existing!.bodyHtml)
        : '• ';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final bodyPlain = _bodyController.text.trim();
    if (bodyPlain.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.diaryBodyRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final html = diaryPlainTextToHtml(bodyPlain);
      final title = _titleController.text.trim();

      if (_isEditing && widget.existing != null) {
        await DiaryService.update(
          id: widget.existing!.id,
          title: title.isEmpty ? null : title,
          bodyHtml: html,
        );
      } else {
        await DiaryService.create(
          entryDate: _entryDate,
          title: title.isEmpty ? null : title,
          bodyHtml: html,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.diarySaved)),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.diarySaveFailed)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (!_isEditing || widget.existing == null) return;
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteDiaryTitle),
        content: Text(l10n.deleteDiaryBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: Text(l10n.deleteAction),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await DiaryService.delete(widget.existing!.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.diaryDeleteFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayDate = DateTime.tryParse(_entryDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diaryEditorTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    l10n.save,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                displayDate != null
                    ? DateFormat.yMMMEd().format(displayDate)
                    : _entryDate,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: l10n.diaryTitleHint,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DiaryRichTextToolbar(
                controller: _bodyController,
                focusNode: _focusNode,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextField(
                  controller: _bodyController,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: l10n.diaryBodyHint,
                    filled: true,
                    fillColor: Colors.white,
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
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
