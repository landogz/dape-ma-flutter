import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/registration/registration_constants.dart';

/// Multi-select interests editor with optional custom "Other" value.
class InterestsPickerSheet extends StatefulWidget {
  const InterestsPickerSheet({
    super.key,
    required this.initialInterests,
  });

  final List<String> initialInterests;

  static const otherKey = 'other';
  static const otherPrefix = 'other:';

  static Future<List<String>?> show(
    BuildContext context, {
    required List<String> initialInterests,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InterestsPickerSheet(initialInterests: initialInterests),
    );
  }

  static String? otherLabelFrom(Iterable<String> interests) {
    for (final value in interests) {
      if (value.startsWith(otherPrefix)) {
        final label = value.substring(otherPrefix.length).trim();
        if (label.isNotEmpty) return label;
      }
    }
    return null;
  }

  static Set<String> presetKeysFrom(Iterable<String> interests) {
    final presets = RegistrationConstants.interests.map((i) => i.key).toSet();
    return interests.where(presets.contains).toSet();
  }

  static String summary(AppStrings l10n, List<String> interests) {
    if (interests.isEmpty) return l10n.interestsHint;
    final labels = <String>[];
    for (final key in presetKeysFrom(interests)) {
      labels.add(l10n.regInterestLabel(key));
    }
    final other = otherLabelFrom(interests);
    if (other != null) labels.add(other);
    if (labels.isEmpty) return l10n.interestsHint;
    return labels.join(', ');
  }

  @override
  State<InterestsPickerSheet> createState() => _InterestsPickerSheetState();
}

class _InterestsPickerSheetState extends State<InterestsPickerSheet> {
  late final Set<String> _selected;
  late final TextEditingController _otherController;
  bool _otherSelected = false;

  @override
  void initState() {
    super.initState();
    _selected = InterestsPickerSheet.presetKeysFrom(widget.initialInterests);
    final other = InterestsPickerSheet.otherLabelFrom(widget.initialInterests);
    _otherSelected = other != null;
    _otherController = TextEditingController(text: other ?? '');
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _toggle(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
  }

  void _save() {
    final l10n = context.l10n;
    final otherText = _otherController.text.trim();

    if (_otherSelected && otherText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.interestsOtherRequired),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    final result = <String>[..._selected];
    if (_otherSelected) {
      result.add('${InterestsPickerSheet.otherPrefix}$otherText');
    }

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.interestsLabel,
                style: const TextStyle(
                  color: AppColors.secondaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.interestsPickerHint,
                style: TextStyle(
                  color: AppColors.primaryBlue.withValues(alpha: 0.75),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final interest
                            in RegistrationConstants.interests)
                          _InterestChip(
                            label: l10n.regInterestLabel(interest.key),
                            selected: _selected.contains(interest.key),
                            accent: interest.accent,
                            tint: interest.tint,
                            onTap: () => _toggle(interest.key),
                          ),
                        _InterestChip(
                          label: l10n.interestsOther,
                          selected: _otherSelected,
                          accent: AppColors.secondaryBlue,
                          tint: const Color(0xFFEEF2FF),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _otherSelected = !_otherSelected;
                              if (!_otherSelected) {
                                _otherController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_otherSelected) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.interestsOtherHint,
                        style: const TextStyle(
                          color: AppColors.secondaryBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _otherController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 60,
                        decoration: InputDecoration(
                          hintText: l10n.interestsOtherPlaceholder,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.save,
                    style: const TextStyle(fontWeight: FontWeight.w700),
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

class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? tint : Colors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? accent : const Color(0xFFD1D5DB),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                Icon(Icons.check_rounded, size: 16, color: accent),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: selected ? accent : AppColors.secondaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
