import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/video_contest.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/theme/app_colors.dart';

class VideoContestSubmitScreen extends StatefulWidget {
  final VideoContest contest;

  const VideoContestSubmitScreen({super.key, required this.contest});

  @override
  State<VideoContestSubmitScreen> createState() =>
      _VideoContestSubmitScreenState();
}

class _VideoContestSubmitScreenState extends State<VideoContestSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _regionController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.videoContestSubmit(widget.contest.id),
        data: <String, dynamic>{
          'title': _titleController.text.trim(),
          'creator_name': _creatorController.text.trim(),
          'video_url': _videoUrlController.text.trim(),
          if (_descriptionController.text.trim().isNotEmpty)
            'description': _descriptionController.text.trim(),
          if (_regionController.text.trim().isNotEmpty)
            'region': _regionController.text.trim(),
        },
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.videoSubmittedForReview)),
      );
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      if (!mounted) return;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response!.data['message'] as String? ??
              context.l10n.videoSubmitFailed)
          : context.l10n.videoSubmitFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.videoSubmitFailed)),
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
        title: Text(l10n.submitVideoEntry),
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
                    ),
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
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.requiredField
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creatorController,
                decoration: InputDecoration(
                  labelText: l10n.creatorNameLabel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.requiredField
                    : null,
              ),
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
                    return l10n.videoUrlInvalid;
                  }
                  return null;
                },
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
                      : Text(l10n.submitVideoEntry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
