import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';

class EditCommentSheet extends StatefulWidget {
  const EditCommentSheet({
    super.key,
    required this.initialBody,
    required this.onSave,
  });

  final String initialBody;
  final Future<void> Function(String body) onSave;

  @override
  State<EditCommentSheet> createState() => _EditCommentSheetState();
}

class _EditCommentSheetState extends State<EditCommentSheet> {
  late final TextEditingController _controller;
  bool _saving = false;
  String? _error;

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

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty) {
      setState(() => _error = context.l10n.commentCannotBeEmpty);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(body);
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
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.editComment,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 4,
            minLines: 2,
            decoration: InputDecoration(
              hintText: l10n.updateCommentHint,
              filled: true,
              fillColor: AppColors.lightBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: AppColors.accentRed, fontSize: 13),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
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
