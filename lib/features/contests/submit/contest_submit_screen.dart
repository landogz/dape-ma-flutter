import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/contest.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/widgets/brand_app_bar/brand_app_bar.dart';

class ContestSubmitScreen extends StatefulWidget {
  final Contest contest;

  const ContestSubmitScreen({super.key, required this.contest});

  @override
  State<ContestSubmitScreen> createState() => _ContestSubmitScreenState();
}

class _ContestSubmitScreenState extends State<ContestSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _mediaController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _regionController = TextEditingController();
  String _entryType = 'song';
  bool _submitting = false;

  bool get _isSong => widget.contest.isSong;
  bool get _isPoster => widget.contest.isPoster;
  bool get _isVideo => widget.contest.isVideo;

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
    _creatorController.dispose();
    _descriptionController.dispose();
    _lyricsController.dispose();
    _mediaController.dispose();
    _posterUrlController.dispose();
    _videoUrlController.dispose();
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

    if (_isSong) {
      final hasMedia = _mediaController.text.trim().isNotEmpty;
      final hasLyrics = _lyricsController.text.trim().isNotEmpty;
      if (!hasMedia && !hasLyrics) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.mediaOrLyricsRequired)),
        );
        return;
      }
    }

    setState(() => _submitting = true);
    try {
      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'creator_name': _creatorController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        if (_regionController.text.trim().isNotEmpty)
          'region': _regionController.text.trim(),
      };

      if (_isSong) {
        data['entry_type'] = _entryType;
        if (_mediaController.text.trim().isNotEmpty) {
          data['media_url'] = _mediaController.text.trim();
        }
        if (_lyricsController.text.trim().isNotEmpty) {
          data['lyrics'] = _lyricsController.text.trim();
        }
      } else if (_isPoster) {
        data['poster_image_url'] = _posterUrlController.text.trim();
      } else if (_isVideo) {
        data['video_url'] = _videoUrlController.text.trim();
      }

      await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.contestSubmit(widget.contest.id),
        data: data,
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

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.requiredField;
    }
    return null;
  }

  String? _urlValidator(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? context.l10n.requiredField : null;
    }
    final uri = Uri.tryParse(value.trim());
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return context.l10n.videoUrlInvalid;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: BrandAppBar(title: l10n.submitContestEntry),
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
                      color: context.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),
              if (_isSong) ...[
                Text(
                  l10n.entryTypeLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
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
              ],
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.entryTitleLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creatorController,
                decoration: InputDecoration(
                  labelText: _isSong
                      ? l10n.artistNameLabel
                      : l10n.creatorNameLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: _requiredValidator,
              ),
              if (_isSong) ...[
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
              ],
              if (_isPoster) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _posterUrlController,
                  decoration: InputDecoration(
                    labelText: l10n.posterImageUrlLabel,
                    hintText: l10n.orPosterImageUrl,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => _urlValidator(v, required: true),
                ),
              ],
              if (_isVideo) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _videoUrlController,
                  decoration: InputDecoration(
                    labelText: l10n.videoUrlLabel,
                    hintText: l10n.videoUrlHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => _urlValidator(v, required: true),
                ),
              ],
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
              if (_isSong && _entryType == 'song') ...[
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
