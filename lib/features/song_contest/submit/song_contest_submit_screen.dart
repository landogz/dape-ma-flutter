import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/song_contest.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/theme/app_colors.dart';

class SongContestSubmitScreen extends StatefulWidget {
  final SongContest contest;

  const SongContestSubmitScreen({super.key, required this.contest});

  @override
  State<SongContestSubmitScreen> createState() =>
      _SongContestSubmitScreenState();
}

class _SongContestSubmitScreenState extends State<SongContestSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _mediaController = TextEditingController();
  final _regionController = TextEditingController();
  String _entryType = 'song';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final allowed = widget.contest.allowedEntryTypes;
    if (allowed == 'playlist') {
      _entryType = 'playlist';
    } else {
      _entryType = 'song';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _descriptionController.dispose();
    _lyricsController.dispose();
    _mediaController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  List<String> get _allowedTypes {
    switch (widget.contest.allowedEntryTypes) {
      case 'song':
        return ['song'];
      case 'playlist':
        return ['playlist'];
      default:
        return ['song', 'playlist'];
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.songContestSubmit(widget.contest.id),
        data: <String, dynamic>{
          'title': _titleController.text.trim(),
          'artist_name': _artistController.text.trim(),
          'entry_type': _entryType,
          'description': _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          'lyrics': _lyricsController.text.trim().isEmpty
              ? null
              : _lyricsController.text.trim(),
          'media_url': _mediaController.text.trim().isEmpty
              ? null
              : _mediaController.text.trim(),
          'region': _regionController.text.trim().isEmpty
              ? null
              : _regionController.text.trim(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.entrySubmittedForReview)),
      );
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['message'] as String? ??
              context.l10n.entrySubmitFailed)
          : context.l10n.entrySubmitFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.entrySubmitFailed)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.submitContestEntry),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Text(
                widget.contest.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
              ),
              const SizedBox(height: 16),
              Text(l10n.entryTypeLabel,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _allowedTypes.map((type) {
                  final selected = _entryType == type;
                  return ChoiceChip(
                    label: Text(
                      type == 'playlist'
                          ? l10n.playlistType
                          : l10n.songWritingType,
                    ),
                    selected: selected,
                    onSelected: (_) => setState(() => _entryType = type),
                    selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.entryTitleLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _artistController,
                decoration: InputDecoration(
                  labelText: l10n.artistNameLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.requiredField : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mediaController,
                decoration: InputDecoration(
                  labelText: l10n.mediaUrlLabel,
                  hintText: 'YouTube / Spotify URL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _regionController,
                decoration: InputDecoration(
                  labelText: l10n.regionOptionalLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.descriptionOptionalLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_entryType == 'song') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lyricsController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: l10n.lyricsLabel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.submitContestEntry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
