import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../settings/privacy_notice_screen.dart';
import '../../settings/privacy_policy_screen.dart';
import '../../settings/terms_of_use_screen.dart';
import 'auth_decor.dart';

/// Shared visual tokens for every auth screen.
abstract final class AuthTokens {
  static const muted = Color(0xFF4B5563);
  static const inputText = AppColors.nileBlue;

  static Color mutedOf(BuildContext context) => context.textSecondary;

  static Color inputTextOf(BuildContext context) =>
      context.isDarkMode ? context.textPrimary : inputText;
  static const headlineSize = 26.0;
  static const headlineWeight = FontWeight.w700;
  static const bodySize = 14.0;
  static const horizontalPadding = 28.0;
}

/// One shared chrome for Login / Forgot Password / Register.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.title,
    this.onBack,
    this.showBack = false,
    this.canPop = true,
    this.centerContent = false,
  });

  final Widget child;
  final String? title;
  final VoidCallback? onBack;
  final bool showBack;
  final bool canPop;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        backgroundColor: context.pageBackground,
        body: AuthDecorBackground(
          child: SafeArea(
            child: Column(
              children: [
                if (showBack)
                  AuthBackTitleBar(
                    title: title,
                    onBack: onBack ?? () => Navigator.of(context).maybePop(),
                  )
                else
                  const SizedBox(height: 8),
                Expanded(
                  child: centerContent
                      ? Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(
                              AuthTokens.horizontalPadding,
                              8,
                              AuthTokens.horizontalPadding,
                              48,
                            ),
                            child: child,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            AuthTokens.horizontalPadding,
                            8,
                            AuthTokens.horizontalPadding,
                            48,
                          ),
                          child: child,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Back arrow + optional title on one baseline (44×44 tap target).
class AuthBackTitleBar extends StatelessWidget {
  const AuthBackTitleBar({
    super.key,
    this.title,
    this.onBack,
  });

  final String? title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            padding: EdgeInsets.zero,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: context.heading,
            ),
          ),
          if (title != null) ...[
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title!,
                style: TextStyle(
                  color: context.heading,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Seal + caption wordmark (no stray tagline).
class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key, this.sealSize = 96});

  final double sealSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: SizedBox(
            width: sealSize,
            height: sealSize,
            child: SvgPicture.asset('assets/ddb.svg', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'DAPE-MA',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.heading,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class AuthHeadline extends StatelessWidget {
  const AuthHeadline(this.text, {super.key, this.center = true});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        color: context.heading,
        fontSize: AuthTokens.headlineSize,
        fontWeight: AuthTokens.headlineWeight,
        height: 1.25,
      ),
    );
  }
}

class AuthSubtext extends StatelessWidget {
  const AuthSubtext(this.text, {super.key, this.center = true});

  final String text;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        color: AuthTokens.mutedOf(context),
        fontSize: AuthTokens.bodySize,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class AuthBanner extends StatelessWidget {
  const AuthBanner({
    super.key,
    required this.message,
    this.isError = true,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? AppColors.fireEngineRed : const Color(0xFF15803D);
    final bg = isError ? AppColors.softRed : const Color(0xFFDCFCE7);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Circular OAuth buttons — same pattern on every auth screen.
class AuthSocialCircleRow extends StatelessWidget {
  const AuthSocialCircleRow({
    super.key,
    required this.onTap,
    this.enabled = true,
  });

  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final handler = enabled ? onTap : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AuthSocialCircle(
          onTap: handler,
          child: Text(
            'G',
            style: TextStyle(
              color: context.heading,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        AuthSocialCircle(
          onTap: handler,
          child: Icon(
            Icons.facebook_rounded,
            color: context.heading,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        AuthSocialCircle(
          onTap: handler,
          child: Icon(Icons.apple, color: context.heading, size: 26),
        ),
      ],
    );
  }
}

class AuthSocialCircle extends StatelessWidget {
  const AuthSocialCircle({super.key, required this.onTap, required this.child});

  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBackground,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.cardBackground,
            border: Border.all(color: const Color(0xFFD1D5DB)),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

/// Required consent checkboxes for registration.
class AuthConsentChecks extends StatelessWidget {
  const AuthConsentChecks({
    super.key,
    required this.acceptedTerms,
    required this.acceptedPrivacyPolicy,
    required this.acceptedPrivacyNotice,
    required this.onAcceptedTermsChanged,
    required this.onAcceptedPrivacyPolicyChanged,
    required this.onAcceptedPrivacyNoticeChanged,
    this.enabled = true,
    this.showError = false,
  });

  final bool acceptedTerms;
  final bool acceptedPrivacyPolicy;
  final bool acceptedPrivacyNotice;
  final ValueChanged<bool> onAcceptedTermsChanged;
  final ValueChanged<bool> onAcceptedPrivacyPolicyChanged;
  final ValueChanged<bool> onAcceptedPrivacyNoticeChanged;
  final bool enabled;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ConsentRow(
          value: acceptedTerms,
          enabled: enabled,
          prefix: l10n.consentAgreePrefix,
          documentLabel: l10n.termsOfUse,
          onChanged: onAcceptedTermsChanged,
          onOpenDocument: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TermsOfUseScreen(),
              ),
            );
          },
        ),
        _ConsentRow(
          value: acceptedPrivacyPolicy,
          enabled: enabled,
          prefix: l10n.consentAgreePrefix,
          documentLabel: l10n.privacyPolicy,
          onChanged: onAcceptedPrivacyPolicyChanged,
          onOpenDocument: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrivacyPolicyScreen(),
              ),
            );
          },
        ),
        _ConsentRow(
          value: acceptedPrivacyNotice,
          enabled: enabled,
          prefix: l10n.consentAcceptPrefix,
          documentLabel: l10n.privacyNotice,
          onChanged: onAcceptedPrivacyNoticeChanged,
          onOpenDocument: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PrivacyNoticeScreen(),
              ),
            );
          },
        ),
        if (!(acceptedTerms &&
            acceptedPrivacyPolicy &&
            acceptedPrivacyNotice)) ...[
          const SizedBox(height: 8),
          Text(
            l10n.consentRequired,
            style: TextStyle(
              color: showError
                  ? AppColors.fireEngineRed
                  : AuthTokens.mutedOf(context),
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.value,
    required this.enabled,
    required this.prefix,
    required this.documentLabel,
    required this.onChanged,
    required this.onOpenDocument,
  });

  final bool value;
  final bool enabled;
  final String prefix;
  final String documentLabel;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenDocument;

  @override
  Widget build(BuildContext context) {
    final linkStyle = TextStyle(
      color: context.heading,
      fontWeight: FontWeight.w700,
      fontSize: 13,
      height: 1.4,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.mediumElectricBlue,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () => onChanged(!value) : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: IgnorePointer(
                  child: Checkbox(
                    value: value,
                    onChanged: enabled ? (_) {} : null,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: context.isDarkMode
                          ? context.textSecondary
                          : AppColors.nileBlue,
                      width: 1.6,
                    ),
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return AppColors.mediumElectricBlue;
                      }
                      return Colors.transparent;
                    }),
                    checkColor: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 4, bottom: 8),
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: AuthTokens.mutedOf(context),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(text: prefix),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.baseline,
                          baseline: TextBaseline.alphabetic,
                          child: GestureDetector(
                            onTap: onOpenDocument,
                            child: Text(documentLabel, style: linkStyle),
                          ),
                        ),
                      ],
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
}

/// Soft white fade under footer actions so blobs never steal contrast.
class AuthFooterFade extends StatelessWidget {
  const AuthFooterFade({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            context.pageBackground.withValues(alpha: 0),
            context.pageBackground,
            context.pageBackground,
          ],
          stops: const [0.0, 0.35, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        child: child,
      ),
    );
  }
}
