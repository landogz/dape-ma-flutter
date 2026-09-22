import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../account/widgets/settings_hero_header.dart';
import 'legal_page_service.dart';

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.slug,
    required this.fallbackTitle,
    required this.fallbackIntro,
    required this.fallbackBody,
    required this.icon,
    required this.iconBackground,
  });

  final String slug;
  final String fallbackTitle;
  final String fallbackIntro;
  final String fallbackBody;
  final IconData icon;
  final Color iconBackground;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  bool _loading = true;
  String _title = '';
  String _intro = '';
  String _body = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final locale = LocaleScope.of(context).locale.code;
    final page = await LegalPageService.fetchBySlug(
      slug: widget.slug,
      locale: locale,
    );

    if (!mounted) return;

    setState(() {
      _title = (page?.title.isNotEmpty ?? false)
          ? page!.title
          : widget.fallbackTitle;
      _intro = (page?.intro.isNotEmpty ?? false)
          ? page!.intro
          : widget.fallbackIntro;
      _body = (page?.body.isNotEmpty ?? false)
          ? page!.body
          : widget.fallbackBody;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  SettingsHeroHeader(
                    showBack: true,
                    icon: widget.icon,
                    title: _title,
                    subtitle: _intro,
                    iconBackground: widget.iconBackground,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: context.softBrandSurface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      _body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.textPrimary.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
