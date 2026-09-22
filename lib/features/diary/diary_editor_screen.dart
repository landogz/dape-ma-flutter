import 'package:flutter/material.dart';

import '../../core/models/diary_entry.dart';
import 'widgets/journal_wizard/journal_wizard_sheet.dart';

/// Legacy entry point — routes create/edit into the reflection wizard.
class DiaryEditorScreen extends StatefulWidget {
  const DiaryEditorScreen({super.key, this.existing});

  final DiaryEntry? existing;

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openWizard());
  }

  Future<void> _openWizard() async {
    final saved = await showJournalWizard(
      context,
      existing: widget.existing,
    );
    if (!mounted) return;
    Navigator.of(context).pop(saved == true);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
