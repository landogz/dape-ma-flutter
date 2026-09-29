import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_decor.dart';
import '../../widgets/auth_scaffold.dart';

/// Shared chrome for registration steps — same light + navy blob system as Login.
class RegistrationShell extends StatelessWidget {
  const RegistrationShell({
    super.key,
    required this.child,
    this.onBack,
    this.onNext,
    this.nextLoading = false,
    this.showNextFab = true,
    this.showBack = true,
  });

  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool nextLoading;
  final bool showNextFab;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: AuthDecorBackground(
        child: SafeArea(
          child: Stack(
            children: [
              if (showBack)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AuthBackTitleBar(
                    onBack: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AuthTokens.horizontalPadding,
                    showBack ? 52 : 16,
                    AuthTokens.horizontalPadding,
                    showNextFab ? 88 + safeBottom : 24 + safeBottom,
                  ),
                  child: child,
                ),
              ),
              if (showNextFab)
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 16 + safeBottom + (bottomInset > 0 ? 0 : 0),
                  child: Center(
                    child: Material(
                      color: AppColors.nileBlue,
                      shape: const CircleBorder(),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.nileBlue.withValues(alpha: 0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: nextLoading ? null : onNext,
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: nextLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(18),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
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
}

class RegistrationIconBadge extends StatelessWidget {
  const RegistrationIconBadge({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.softBlue,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
