import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/auth_service.dart';
import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/models/diary_entry.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_url.dart';
import '../../diary_service.dart';
import '../../image/diary_image_picker.dart';
import '../diary_rich_text_toolbar.dart';
import 'journal_constants.dart';

Future<bool?> showJournalWizard(
  BuildContext context, {
  DiaryEntry? existing,
  String? firstName,
  String? initialSky,
  List<String>? initialFeelings,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => JournalWizardSheet(
      existing: existing,
      firstName: firstName,
      initialSky: initialSky,
      initialFeelings: initialFeelings,
    ),
  );
}

class JournalWizardSheet extends StatefulWidget {
  const JournalWizardSheet({
    super.key,
    this.existing,
    this.firstName,
    this.initialSky,
    this.initialFeelings,
  });

  final DiaryEntry? existing;
  final String? firstName;
  final String? initialSky;
  final List<String>? initialFeelings;

  @override
  State<JournalWizardSheet> createState() => _JournalWizardSheetState();
}

class _JournalWizardSheetState extends State<JournalWizardSheet> {
  static const _totalSteps = 4;

  int _step = 0;
  bool _saving = false;
  String? _sky;
  final Set<String> _feelings = {};
  String? _impact;
  late final TextEditingController _notesController;
  late final TextEditingController _gratitudeController;
  late final TextEditingController _customFeelingController;
  late final String _entryDate;
  late final bool _isEditing;
  String? _resolvedFirstName;
  File? _imageFile;
  String? _existingImageUrl;
  bool _removeImage = false;
  bool _optimizingImage = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existing != null;
    _entryDate = widget.existing?.entryDate ??
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    _sky = widget.existing?.sky ?? widget.initialSky;
    _feelings.addAll(widget.existing?.feelings ?? const []);
    if (_feelings.isEmpty && widget.initialFeelings != null) {
      _feelings.addAll(widget.initialFeelings!);
    }
    _impact = widget.existing?.impact;
    _existingImageUrl = ApiUrl.resolve(widget.existing?.imageUrl);
    _notesController = TextEditingController(
      text: widget.existing != null
          ? diaryHtmlToPlainText(widget.existing!.bodyHtml)
          : '',
    );
    _gratitudeController = TextEditingController(
      text: widget.existing?.gratitude ?? '',
    );
    _customFeelingController = TextEditingController();
    _resolvedFirstName = widget.firstName;
    if (_resolvedFirstName == null || _resolvedFirstName!.trim().isEmpty) {
      _loadFirstName();
    }
  }

  Future<void> _loadFirstName() async {
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.me,
      );
      final data = res.data ?? <String, dynamic>{};
      final user = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      final name = (user['name'] as String?)?.trim() ?? '';
      if (name.isEmpty || !mounted) return;
      setState(() => _resolvedFirstName = name.split(RegExp(r'\s+')).first);
    } catch (_) {}
  }

  @override
  void dispose() {
    _notesController.dispose();
    _gratitudeController.dispose();
    _customFeelingController.dispose();
    super.dispose();
  }

  bool get _isTagalog => context.l10n.isTagalog;

  String _skyLabel(JournalSkyOption o) =>
      _isTagalog ? o.labelTl : o.labelEn;

  String _skySubtitle(JournalSkyOption o) =>
      _isTagalog ? o.subtitleTl : o.subtitleEn;

  String _feelingLabel(JournalFeelingOption o) =>
      _isTagalog ? o.labelTl : o.labelEn;

  String _impactLabel(JournalImpactOption o) =>
      _isTagalog ? o.labelTl : o.labelEn;

  void _close() => Navigator.of(context).maybePop(false);

  void _back() {
    if (_step == 0) {
      _close();
      return;
    }
    setState(() => _step -= 1);
  }

  Future<void> _nextOrSave() async {
    if (_step < _totalSteps - 1) {
      setState(() => _step += 1);
      return;
    }
    await _save();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final notes = _notesController.text.trim();
    final gratitude = _gratitudeController.text.trim();
    final hasFeelings = _feelings.isNotEmpty;
    final hasImage = _imageFile != null ||
        (_existingImageUrl != null && !_removeImage);

    if ((_sky == null || _sky!.isEmpty) &&
        !hasFeelings &&
        (_impact == null || _impact!.isEmpty) &&
        notes.isEmpty &&
        gratitude.isEmpty &&
        !hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.diaryBodyRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.lightImpact();
    try {
      final bodyHtml = notes.isEmpty ? '' : diaryPlainTextToHtml(notes);
      if (_isEditing && widget.existing != null) {
        await DiaryService.update(
          id: widget.existing!.id,
          sky: _sky ?? '',
          feelings: _feelings.toList(),
          impact: _impact ?? '',
          gratitude: gratitude,
          bodyHtml: bodyHtml,
          imageFile: _imageFile,
          removeImage: _removeImage && _imageFile == null,
        );
      } else {
        await DiaryService.create(
          entryDate: _entryDate,
          sky: _sky,
          feelings: _feelings.toList(),
          impact: _impact,
          gratitude: gratitude.isEmpty ? null : gratitude,
          bodyHtml: bodyHtml.isEmpty ? null : bodyHtml,
          imageFile: _imageFile,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.diarySaved)),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      var message = l10n.diarySaveFailed;
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          final apiMessage = data['message']?.toString();
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final first = errors.values.first;
            if (first is List && first.isNotEmpty) {
              message = first.first.toString();
            } else if (first != null) {
              message = first.toString();
            }
          } else if (apiMessage != null && apiMessage.isNotEmpty) {
            message = apiMessage;
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickImage() async {
    final l10n = context.l10n;
    setState(() => _optimizingImage = true);
    try {
      final file = await DiaryImagePicker.pick(
        context: context,
        title: l10n.journalPhotoSourceTitle,
        cameraLabel: l10n.journalPhotoCamera,
        galleryLabel: l10n.journalPhotoGallery,
        cancelLabel: l10n.cancel,
      );
      if (!mounted || file == null) return;
      setState(() {
        _imageFile = file;
        _removeImage = false;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.journalPhotoFailed)),
      );
    } finally {
      if (mounted) setState(() => _optimizingImage = false);
    }
  }

  void _clearImage() {
    setState(() {
      _imageFile = null;
      if (_existingImageUrl != null) {
        _removeImage = true;
      }
    });
  }

  String _feelingDisplay(String key) {
    for (final o in JournalConstants.feelingOptions) {
      if (o.key == key) return _feelingLabel(o);
    }
    return key;
  }

  void _addCustomFeeling() {
    final value = _customFeelingController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _feelings.add(value);
      _customFeelingController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final height = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: _saving ? null : _back,
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          l10n.journalStepOf(_step + 1, _totalSteps),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(_totalSteps, (i) {
                            final active = i <= _step;
                            return Container(
                              margin: EdgeInsets.only(right: i == _totalSteps - 1 ? 0 : 6),
                              width: 28,
                              height: 4,
                              decoration: BoxDecoration(
                                color: active
                                    ? AppColors.accentYellow
                                    : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _CircleIconButton(
                      icon: Icons.close_rounded,
                      onTap: _saving ? null : _close,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: (_saving || _optimizingImage) ? null : _nextOrSave,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondaryBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.secondaryBlue.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _step == _totalSteps - 1
                                  ? l10n.journalSaveEntry
                                  : l10n.journalNext,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
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

  Widget _buildStep() {
    return switch (_step) {
      0 => _SkyStep(
          selected: _sky,
          onSelect: (key) => setState(() => _sky = key),
          labelOf: _skyLabel,
          subtitleOf: _skySubtitle,
        ),
      1 => _FeelingsStep(
          selected: _feelings,
          onToggle: (key) {
            setState(() {
              if (_feelings.contains(key)) {
                _feelings.remove(key);
              } else {
                _feelings.add(key);
              }
            });
          },
          labelOf: _feelingLabel,
          customController: _customFeelingController,
          onAddCustom: _addCustomFeeling,
        ),
      2 => _ImpactStep(
          selected: _impact,
          onSelect: (key) => setState(() => _impact = key),
          labelOf: _impactLabel,
        ),
      _ => _NotesStep(
          notesController: _notesController,
          gratitudeController: _gratitudeController,
          firstName: _resolvedFirstName,
          skyLabel: () {
            final opt = JournalConstants.skyByKey(_sky);
            return opt == null ? null : _skyLabel(opt);
          }(),
          feelingLabels: _feelings.map(_feelingDisplay).toList(),
          impactLabel: () {
            final opt = JournalConstants.impactByKey(_impact);
            return opt == null ? null : _impactLabel(opt);
          }(),
          imageFile: _imageFile,
          existingImageUrl: _removeImage ? null : _existingImageUrl,
          optimizingImage: _optimizingImage,
          onPickImage: _saving ? null : _pickImage,
          onRemoveImage: _saving ? null : _clearImage,
        ),
    };
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 18, color: AppColors.secondaryBlue),
        ),
      ),
    );
  }
}

class _SkyStep extends StatelessWidget {
  const _SkyStep({
    required this.selected,
    required this.onSelect,
    required this.labelOf,
    required this.subtitleOf,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final String Function(JournalSkyOption) labelOf;
  final String Function(JournalSkyOption) subtitleOf;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedOpt = JournalConstants.skyByKey(selected);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          l10n.journalSkyTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryBlue,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.journalSkySubtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ...JournalConstants.skyOptions.map((opt) {
          final isSelected = selected == opt.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: isSelected
                  ? AppColors.secondaryBlue.withValues(alpha: 0.08)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(opt.key),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 64),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondaryBlue
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: opt.accent.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(opt.icon, color: AppColors.secondaryBlue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          labelOf(opt),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.secondaryBlue
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryBlue,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (selectedOpt != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitleOf(selectedOpt),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}

class _FeelingsStep extends StatelessWidget {
  const _FeelingsStep({
    required this.selected,
    required this.onToggle,
    required this.labelOf,
    required this.customController,
    required this.onAddCustom,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final String Function(JournalFeelingOption) labelOf;
  final TextEditingController customController;
  final VoidCallback onAddCustom;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final presetKeys =
        JournalConstants.feelingOptions.map((e) => e.key).toSet();
    final custom = selected.where((f) => !presetKeys.contains(f)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          l10n.journalFeelingsTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryBlue,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.journalFeelingsSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...JournalConstants.feelingOptions.map((opt) {
              final isOn = selected.contains(opt.key);
              return FilterChip(
                label: Text(labelOf(opt)),
                selected: isOn,
                onSelected: (_) => onToggle(opt.key),
                showCheckmark: false,
                selectedColor: AppColors.accentYellow,
                backgroundColor: const Color(0xFFF3F4F6),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isOn
                      ? AppColors.secondaryBlue
                      : AppColors.textSecondaryLight,
                ),
                side: BorderSide(
                  color: isOn
                      ? AppColors.accentYellow
                      : const Color(0xFFE5E7EB),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              );
            }),
            ...custom.map((feeling) {
              return FilterChip(
                label: Text(feeling),
                selected: true,
                onSelected: (_) => onToggle(feeling),
                showCheckmark: false,
                selectedColor: AppColors.accentYellow,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryBlue,
                ),
                side: const BorderSide(color: AppColors.accentYellow),
              );
            }),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: customController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onAddCustom(),
                decoration: InputDecoration(
                  hintText: l10n.journalAddYourOwn,
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 48,
              height: 48,
              child: IconButton.filled(
                onPressed: onAddCustom,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImpactStep extends StatelessWidget {
  const _ImpactStep({
    required this.selected,
    required this.onSelect,
    required this.labelOf,
  });

  final String? selected;
  final ValueChanged<String> onSelect;
  final String Function(JournalImpactOption) labelOf;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Text(
          l10n.journalImpactTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryBlue,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.journalImpactSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        ...JournalConstants.impactOptions.map((opt) {
          final isSelected = selected == opt.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: isSelected
                  ? AppColors.secondaryBlue.withValues(alpha: 0.08)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(opt.key),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 64),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondaryBlue
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        opt.icon,
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.secondaryBlue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          labelOf(opt),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.secondaryBlue
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryBlue,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _NotesStep extends StatelessWidget {
  const _NotesStep({
    required this.notesController,
    required this.gratitudeController,
    this.firstName,
    this.skyLabel,
    this.feelingLabels = const [],
    this.impactLabel,
    this.imageFile,
    this.existingImageUrl,
    this.optimizingImage = false,
    this.onPickImage,
    this.onRemoveImage,
  });

  final TextEditingController notesController;
  final TextEditingController gratitudeController;
  final String? firstName;
  final String? skyLabel;
  final List<String> feelingLabels;
  final String? impactLabel;
  final File? imageFile;
  final String? existingImageUrl;
  final bool optimizingImage;
  final VoidCallback? onPickImage;
  final VoidCallback? onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gratitudeHint = firstName != null && firstName!.trim().isNotEmpty
        ? l10n.journalGratitudeHintNamed(firstName!.trim())
        : l10n.journalGratitudeHint;
    final hasPreview = imageFile != null ||
        (existingImageUrl != null && existingImageUrl!.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _ReflectionSummaryCard(
          skyLabel: skyLabel,
          feelingLabels: feelingLabels,
          impactLabel: impactLabel,
        ),
        const SizedBox(height: 20),
        Text(
          l10n.journalNotesTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.secondaryBlue,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.journalNotesSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: notesController,
          minLines: 5,
          maxLines: 10,
          decoration: InputDecoration(
            hintText: l10n.diaryBodyHint,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.journalGratitudeLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: gratitudeController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: gratitudeHint,
            filled: true,
            fillColor: const Color(0xFFFFFBEB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.accentYellow.withValues(alpha: 0.6),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.accentYellow.withValues(alpha: 0.6),
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.journalPhotoLabel,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.journalPhotoHint,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        if (hasPreview)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageFile != null)
                    Image.file(imageFile!, fit: BoxFit.cover)
                  else
                    Image.network(
                      existingImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: const Color(0xFFF3F4F6),
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: onRemoveImage,
                        child: const SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Material(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: optimizingImage ? null : onPickImage,
              child: Container(
                constraints: const BoxConstraints(minHeight: 112),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    style: BorderStyle.solid,
                  ),
                ),
                child: optimizingImage
                    ? const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 28,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.journalPhotoAdd,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryBlue,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        if (hasPreview) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: optimizingImage ? null : onPickImage,
              icon: optimizingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_camera_outlined, size: 18),
              label: Text(l10n.journalPhotoChange),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryBlue,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReflectionSummaryCard extends StatelessWidget {
  const _ReflectionSummaryCard({
    this.skyLabel,
    this.feelingLabels = const [],
    this.impactLabel,
  });

  final String? skyLabel;
  final List<String> feelingLabels;
  final String? impactLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final empty = l10n.journalSummaryEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondaryBlue.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.journalSummaryTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryBlue,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: l10n.journalSummarySky,
            value: (skyLabel == null || skyLabel!.isEmpty) ? empty : skyLabel!,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.journalSummaryFeelings,
            value: feelingLabels.isEmpty ? empty : feelingLabels.join(', '),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.journalSummaryImpact,
            value: (impactLabel == null || impactLabel!.isEmpty)
                ? empty
                : impactLabel!,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryLight,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
