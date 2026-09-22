import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/utils/api_url.dart';
import 'edit_profile/interests_picker_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _loading = true;
  bool _saving = false;
  String _name = '';
  String _email = '';
  String? _about;
  String? _photoUrl;
  String? _memberSince;
  File? _pickedFile;
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(Endpoints.me);
      final data = res.data ?? <String, dynamic>{};
      final user = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;

      final createdAt = user['created_at'] as String?;
      String? memberSince;
      if (createdAt != null) {
        final parsed = DateTime.tryParse(createdAt);
        if (parsed != null) {
          memberSince = DateFormat.yMMMM().format(parsed);
        }
      }

      if (!mounted) return;
      setState(() {
        _name = (user['name'] as String?)?.trim() ?? '';
        _email = (user['email'] as String?)?.trim() ?? '';
        _about = (user['about'] as String?)?.trim();
        _photoUrl = ApiUrl.resolve(user['profile_image_url'] as String?);
        _pickedFile = null;
        _memberSince = memberSince;
        _interests = _parseInterests(user['interests']);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<String> _parseInterests(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _editInterests() async {
    final saved = await InterestsPickerSheet.show(
      context,
      initialInterests: _interests,
    );
    if (saved == null || !mounted) return;
    await _saveProfile(name: _name, interests: saved);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xFile != null && mounted) {
      setState(() => _pickedFile = File(xFile.path));
      await _saveProfile(name: _name, photoFile: _pickedFile);
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _name);
    final saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.fullNameLabel,
                style: const TextStyle(
                  color: AppColors.secondaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(context.l10n.save),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (saved != null && saved.isNotEmpty) {
      await _saveProfile(name: saved);
    }
  }

  Future<void> _editAbout() async {
    final controller = TextEditingController(text: _about ?? '');
    final saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.aboutMeLabel,
                style: const TextStyle(
                  color: AppColors.secondaryBlue,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: context.l10n.aboutMeHint,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(context.l10n.save),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (saved != null) {
      setState(() => _about = saved.isEmpty ? null : saved);
      // Local-only bio for now if API has no about field.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.profileUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _showChangePasswordSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  Future<void> _saveProfile({
    required String name,
    File? photoFile,
    List<String>? interests,
  }) async {
    setState(() => _saving = true);
    try {
      if (photoFile != null) {
        // POST multipart — PHP does not reliably parse files on PUT.
        final formData = FormData.fromMap({
          'name': name,
          'interests': ?interests,
          'profile_photo': await MultipartFile.fromFile(
            photoFile.path,
            filename: photoFile.path.split(RegExp(r'[/\\]')).last,
          ),
        });
        final res = await AuthService.authedPost<Map<String, dynamic>>(
          Endpoints.profileUpdate,
          data: formData,
        );
        final root = res.data ?? <String, dynamic>{};
        final data = root['data'] is Map<String, dynamic>
            ? root['data'] as Map<String, dynamic>
            : root;
        final uploadedUrl =
            ApiUrl.resolve(data['profile_image_url'] as String?);
        if (mounted && uploadedUrl != null) {
          setState(() {
            _photoUrl = uploadedUrl;
            _pickedFile = null;
          });
        }
      } else {
        await AuthService.authedPut<Map<String, dynamic>>(
          Endpoints.profileUpdate,
          data: <String, dynamic>{
            'name': name,
            'interests': ?interests,
          },
        );
      }

      if (!mounted) return;
      setState(() {
        _name = name;
        if (interests != null) {
          _interests = List<String>.from(interests);
        }
        _saving = false;
        _pickedFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileUpdated),
          backgroundColor: Colors.green,
        ),
      );
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _pickedFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.updateFailed),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nameParts = _name.split(' ').where((p) => p.isNotEmpty).toList();
    final firstName = nameParts.isEmpty ? _name : nameParts.first;

    return Scaffold(
      backgroundColor: context.pageBackground,
      appBar: AppBar(
        title: Text(l10n.editProfile),
        backgroundColor: context.pageBackground,
        foregroundColor: AppColors.secondaryBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                          backgroundImage: _pickedFile != null
                              ? FileImage(_pickedFile!)
                              : (_photoUrl != null
                                  ? NetworkImage(_photoUrl!) as ImageProvider
                                  : null),
                          child: _pickedFile == null && _photoUrl == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 42,
                                  color: AppColors.primaryBlue,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: context.cardBackground,
                            shape: const CircleBorder(),
                            elevation: 2,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _saving ? null : _pickImage,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.photo_camera_rounded,
                                  size: 18,
                                  color: AppColors.secondaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            firstName.isEmpty ? l10n.youAreSignedIn : firstName,
                            style: const TextStyle(
                              color: AppColors.secondaryBlue,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (_memberSince != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.memberSince} $_memberSince',
                              style: TextStyle(
                                color: AppColors.primaryBlue.withValues(alpha: 0.75),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _ProfileFieldCard(
                  icon: Icons.person_outline_rounded,
                  value: _name.isEmpty ? '—' : _name,
                  label: l10n.fullNameLabel,
                  onTap: _editName,
                ),
                const SizedBox(height: 12),
                _ProfileFieldCard(
                  icon: Icons.mail_outline_rounded,
                  value: _email.isEmpty ? '—' : _email,
                  label: l10n.emailAddressLabel,
                  onTap: null,
                ),
                const SizedBox(height: 12),
                _ProfileFieldCard(
                  icon: Icons.star_outline_rounded,
                  value: (_about == null || _about!.isEmpty)
                      ? l10n.aboutMeHint
                      : _about!,
                  label: l10n.aboutMeLabel,
                  onTap: _editAbout,
                ),
                const SizedBox(height: 12),
                _ProfileFieldCard(
                  icon: Icons.favorite_outline_rounded,
                  value: InterestsPickerSheet.summary(l10n, _interests),
                  label: l10n.interestsLabel,
                  onTap: _saving ? null : _editInterests,
                ),
                const SizedBox(height: 12),
                _ProfileFieldCard(
                  icon: Icons.lock_outline_rounded,
                  value: '••••••••',
                  label: l10n.changePassword,
                  onTap: _showChangePasswordSheet,
                ),
              ],
            ),
    );
  }
}

class _ProfileFieldCard extends StatelessWidget {
  const _ProfileFieldCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: context.isDarkMode ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.secondaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.secondaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColors.primaryBlue.withValues(alpha: 0.75),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primaryBlue.withValues(alpha: 0.55),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;
    if (current.isEmpty) {
      setState(() => _error = context.l10n.currentPasswordRequired);
      return;
    }
    if (newPass.length < 6) {
      setState(() => _error = context.l10n.passwordMinLength);
      return;
    }
    if (newPass != confirm) {
      setState(() => _error = context.l10n.passwordsDoNotMatch);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.authedPut<Map<String, dynamic>>(
        Endpoints.changePassword,
        data: <String, dynamic>{
          'current_password': current,
          'password': newPass,
          'password_confirmation': confirm,
        },
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.passwordUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = context.l10n.passwordUpdateFailed;
        });
      }
    }
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final inputDecoration = InputDecoration(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.changePassword,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _currentController,
              decoration: inputDecoration.copyWith(
                labelText: l10n.currentPassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrent ? Icons.visibility_off : Icons.visibility,
                    size: 22,
                  ),
                  onPressed: () =>
                      setState(() => _obscureCurrent = !_obscureCurrent),
                ),
              ),
              obscureText: _obscureCurrent,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newController,
              decoration: inputDecoration.copyWith(
                labelText: l10n.newPassword,
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNew ? Icons.visibility_off : Icons.visibility,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
              obscureText: _obscureNew,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              decoration: inputDecoration.copyWith(
                labelText: l10n.confirmNewPassword,
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    size: 22,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              obscureText: _obscureConfirm,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(color: AppColors.accentRed, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.updatePassword),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
