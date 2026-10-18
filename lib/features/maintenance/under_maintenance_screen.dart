import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/navigation/app_restart.dart';
import '../../core/network/server_status.dart';
import '../../core/theme/app_colors.dart';

class UnderMaintenanceScreen extends StatefulWidget {
  const UnderMaintenanceScreen({super.key});

  @override
  State<UnderMaintenanceScreen> createState() => _UnderMaintenanceScreenState();
}

class _UnderMaintenanceScreenState extends State<UnderMaintenanceScreen>
    with SingleTickerProviderStateMixin {
  static const _autoRetryEvery = Duration(seconds: 45);
  static const _cooldown = Duration(seconds: 8);
  static final _supportUri = Uri(
    scheme: 'mailto',
    path: 'info@ddb.gov.ph',
    query: 'subject=DAPE-MA app connection issue',
  );

  late final AnimationController _pulse;
  Timer? _autoRetry;
  DateTime _lastChecked = DateTime.now();
  DateTime? _cooldownUntil;
  bool _checking = false;
  bool _showStillUnavailable = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _autoRetry = Timer.periodic(_autoRetryEvery, (_) => _retry(fromAuto: true));
  }

  @override
  void dispose() {
    _autoRetry?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  bool get _inCooldown {
    final until = _cooldownUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  Future<void> _retry({bool fromAuto = false}) async {
    if (_checking) return;
    if (!fromAuto && _inCooldown) {
      setState(() => _showStillUnavailable = true);
      return;
    }

    setState(() {
      _checking = true;
      _showStillUnavailable = false;
    });

    final ok = await ServerStatus.isReachable();
    if (!mounted) return;

    _lastChecked = DateTime.now();
    if (ok) {
      _autoRetry?.cancel();
      restartFromSplash(context);
      return;
    }

    setState(() {
      _checking = false;
      _cooldownUntil = DateTime.now().add(_cooldown);
      _showStillUnavailable = !fromAuto;
    });
  }

  Future<void> _contactSupport() async {
    if (await canLaunchUrl(_supportUri)) {
      await launchUrl(_supportUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shortest = MediaQuery.sizeOf(context).shortestSide;
    final logoSize = shortest < 360 ? 112.0 : 128.0;
    final lastCheckedLabel = l10n.underMaintenanceLastChecked(
      DateFormat.jm().format(_lastChecked),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _SoftRadialLight()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _PulsingLogo(controller: _pulse, size: logoSize),
                            const SizedBox(height: 24),
                            const _ServiceStatusPill(),
                            const SizedBox(height: 16),
                            Text(
                              l10n.underMaintenanceTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Text(
                                l10n.underMaintenanceMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 16,
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 360),
                              child: SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _checking
                                      ? null
                                      : () => _retry(),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 4,
                                    shadowColor: Colors.black
                                        .withValues(alpha: 0.28),
                                    backgroundColor: AppColors.accentYellow,
                                    foregroundColor: AppColors.secondaryBlue,
                                    disabledBackgroundColor: AppColors
                                        .accentYellow
                                        .withValues(alpha: 0.75),
                                    disabledForegroundColor:
                                        AppColors.secondaryBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  icon: _checking
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.4,
                                            color: AppColors.secondaryBlue,
                                          ),
                                        )
                                      : const Icon(Icons.refresh_rounded),
                                  label: Text(
                                    _checking
                                        ? l10n.underMaintenanceChecking
                                        : l10n.retry,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              lastCheckedLabel,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.55),
                                fontSize: 12,
                              ),
                            ),
                            if (_showStillUnavailable) ...[
                              const SizedBox(height: 8),
                              Text(
                                l10n.underMaintenanceStillUnavailable,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _contactSupport,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(44, 44),
                                foregroundColor:
                                    Colors.white.withValues(alpha: 0.85),
                              ),
                              child: Text(
                                l10n.contactSupport,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftRadialLight extends StatelessWidget {
  const _SoftRadialLight();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.22),
            radius: 0.85,
            colors: [
              Colors.white.withValues(alpha: 0.14),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceStatusPill extends StatelessWidget {
  const _ServiceStatusPill();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.accentYellow.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.accentYellow.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.accentYellow,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.underMaintenanceBadge,
            style: TextStyle(
              color: AppColors.accentYellow.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingLogo extends StatelessWidget {
  const _PulsingLogo({
    required this.controller,
    required this.size,
  });

  final AnimationController controller;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = controller.value;
        final ringScale = 1.0 + (t * 0.28);
        final ringOpacity = (1 - t) * 0.35;

        return SizedBox(
          width: size + 36,
          height: size + 36,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: ringOpacity),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentYellow.withValues(alpha: 0.18),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.16),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Image.asset(
            'assets/ddb.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
