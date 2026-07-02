import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DiaryRichTextToolbar extends StatelessWidget {
  const DiaryRichTextToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  void _wrapSelection(String startTag, String endTag) {
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid) return;

    if (selection.start == selection.end) {
      final insert = '$startTag$endTag';
      final updated = text.replaceRange(selection.start, selection.end, insert);
      controller.value = TextEditingValue(
        text: updated,
        selection: TextSelection.collapsed(offset: selection.start + startTag.length),
      );
    } else {
      final selected = text.substring(selection.start, selection.end);
      final wrapped = '$startTag$selected$endTag';
      final updated = text.replaceRange(selection.start, selection.end, wrapped);
      controller.value = TextEditingValue(
        text: updated,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.start + wrapped.length,
        ),
      );
    }

    focusNode.requestFocus();
  }

  void _insertBullet() {
    final text = controller.text;
    final selection = controller.selection;
    final cursor = selection.start;

    final lineStart = text.lastIndexOf('\n', cursor - 1) + 1;
    final prefix = text.substring(0, lineStart);
    final suffix = text.substring(lineStart);
    final bulletLine = suffix.startsWith('• ') ? suffix : '• $suffix';

    controller.value = TextEditingValue(
      text: '$prefix$bulletLine',
      selection: TextSelection.collapsed(
        offset: lineStart + bulletLine.length,
      ),
    );
    focusNode.requestFocus();
  }

  void _insertNewBulletLine() {
    final text = controller.text;
    final selection = controller.selection;
    final insert = '\n• ';
    final updated = text.replaceRange(selection.start, selection.end, insert);
    controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: selection.start + insert.length),
    );
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToolButton(
            icon: Icons.format_bold,
            tooltip: 'Bold',
            onTap: () => _wrapSelection('<b>', '</b>'),
          ),
          _ToolButton(
            icon: Icons.format_underlined,
            tooltip: 'Underline',
            onTap: () => _wrapSelection('<u>', '</u>'),
          ),
          _ToolButton(
            icon: Icons.format_italic,
            tooltip: 'Italic',
            onTap: () => _wrapSelection('<i>', '</i>'),
          ),
          _ToolButton(
            icon: Icons.format_list_bulleted,
            tooltip: 'Bullet',
            onTap: _insertBullet,
          ),
          _ToolButton(
            icon: Icons.add,
            tooltip: 'New bullet line',
            onTap: _insertNewBulletLine,
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: AppColors.primaryBlue),
      visualDensity: VisualDensity.compact,
    );
  }
}

String diaryPlainTextToHtml(String input) {
  final lines = input.split('\n');
  final buffer = StringBuffer();
  var inList = false;

  for (final line in lines) {
    final trimmed = line.trimRight();
    if (trimmed.startsWith('• ')) {
      if (!inList) {
        buffer.write('<ul>');
        inList = true;
      }
      final item = trimmed.substring(2).trim();
      buffer.write('<li>$item</li>');
    } else {
      if (inList) {
        buffer.write('</ul>');
        inList = false;
      }
      if (trimmed.isNotEmpty) {
        buffer.write('<p>$trimmed</p>');
      }
    }
  }

  if (inList) buffer.write('</ul>');
  return buffer.toString();
}

String diaryHtmlToPlainText(String html) {
  var text = html;
  text = text.replaceAll(RegExp(r'</?ul>', caseSensitive: false), '');
  text = text.replaceAll(RegExp(r'<li>', caseSensitive: false), '• ');
  text = text.replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'</?p>', caseSensitive: false), '\n');
  text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  return text.trim();
}
